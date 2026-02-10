require "fileutils"

# note:
# - https://guides.rubyonrails.org/action_cable_overview.html
#
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    room_name = params[:room]
    return reject unless room_name.present?

    stream_from "chat_#{room_name}"
    @room_name = room_name
  end

  def unsubscribed
    # nothing todo for now
  end

  def send_message(data)
    user = data["user"]&.strip.presence || "Anonymous"
    text = data["text"]&.strip

    return if text.blank?

    # ensure there's no empty data
    unless user.present? && text.present?
      Rails.logger.warn "Discarding invalid message: #{data.inspect}"
      return
    end

    message = {
      "user" => user,
      "text" => text,
      "timestamp" => Time.now.utc.iso8601
    }

    # note:
    # - not using db
    save_to_file(message)
    ActionCable.server.broadcast("chat_#{@room_name}", message)
  end

  private

  # temporal solution to store chat data
  def save_to_file(message)
    data_file = Rails.root.join("tmp", "chat_data.json")

    # load existing data
    if File.exist?(data_file) && File.size?(data_file)
      content = File.read(data_file)
      data = JSON.parse(content)
    else
      data = { "rooms" => {} }
    end

    # ensure room exists
    data["rooms"][@room_name] ||= { "messages" => [] }
    data["rooms"][@room_name]["messages"] ||= []

    # add message
    data["rooms"][@room_name]["messages"] << message

    # save
    FileUtils.mkdir_p(File.dirname(data_file))
    File.write(data_file, JSON.pretty_generate(data))
  end
end
