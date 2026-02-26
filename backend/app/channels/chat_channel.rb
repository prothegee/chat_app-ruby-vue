require "fileutils"

# NOTE:
# - check:
#   - config/cable.yml
#   - config/database.yml
# ---
# wether we gonna use database on that or not, it could break some change
# ---
# ps:
# `ruby on rails need to be start with simple minimalist setup/init` @prothegee
class ChatChannel < ApplicationCable::Channel
  def subscribed
    room_name = params[:room]
    return reject unless room_name.present?

    stream_from "chat_#{room_name}"
    @room_name = room_name
    Rails.logger.info "Subscribed to chat_#{@room_name}"
  end

  def unsubscribed
    Rails.logger.info "Unsubscribed"
  end

  # ActionCable calls this when NO action specified
  def receive(data)
    Rails.logger.info "receive() called with: #{data.inspect}"
    handle_message(data)
  end

  # ActionCable calls this when action: "send_message" is specified
  def send_message(data)
    Rails.logger.info "send_message() called with: #{data.inspect}"
    handle_message(data)
  end

  private

  def handle_message(data)
    # handle nested JSON string (frontend kirim data sebagai JSON string)
    # error on instance apprunner & ec2 (vm-liked); for some reason localdev survive, but instances are not
    message_data = if data.is_a?(String)
      JSON.parse(data)
    elsif data.is_a?(Hash)
      data
    else
      Rails.logger.warn "Unknown data format: #{data.class}"
      return
    end

    Rails.logger.info "Parsed  #{message_data.inspect}"

    user = message_data["user"]&.strip.presence || "Anonymous"
    text = message_data["text"]&.strip

    if text.blank?
      Rails.logger.warn "Discarding empty message: #{message_data.inspect}"
      return
    end

    message = {
      "user" => user,
      "text" => text,
      "timestamp" => Time.now.utc.iso8601
    }

    Rails.logger.info "message: #{message.inspect}"
    save_to_file(message)

    Rails.logger.info "broadcasting to chat_#{@room_name}"
    ActionCable.server.broadcast("chat_#{@room_name}", message)
  end

  def save_to_file(message)
    data_file = Rails.root.join("tmp", "chat_data.json")

    if File.exist?(data_file) && File.size?(data_file)
      content = File.read(data_file)
      data = JSON.parse(content)
    else
      data = { "rooms" => {} }
    end

    data["rooms"][@room_name] ||= { "messages" => [] }
    data["rooms"][@room_name]["messages"] ||= []
    data["rooms"][@room_name]["messages"] << message

    FileUtils.mkdir_p(File.dirname(data_file))
    File.write(data_file, JSON.pretty_generate(data))

    Rails.logger.info "Saved to #{data_file}"
  end
end
