require "fileutils"

class Api::V1::ChatController < ApplicationController
  before_action :load_data

  def index
    render json: @data["rooms"].keys
  end

  def create
    room_name = params[:name].to_s.strip
    if room_name.blank?
      return render json: { error: "Room name is required" }, status: :bad_request
    end

    if @data["rooms"].key?(room_name)
      return render json: { error: "Room already exists" }, status: :conflict
    end

    @data["rooms"][room_name] = {
      "messages" => []
    }
    save_data
    render json: { message: "Room created", name: room_name }, status: :created
  end

  def messages
    room_name = params[:name].to_s.strip
    room = @data["rooms"][room_name]

    if room.nil?
      return render json: { error: "Room not found" }, status: :not_found
    end

    # ensure array messages exists
    room["messages"] ||= []
    render json: room["messages"]
  end

  def send_message
    room_name = params[:name].to_s.strip
    user = params[:user]&.strip.presence || "Anonymous"
    text = params[:text]&.strip

    if text.blank?
      return render json: { error: "Message text is required" }, status: :bad_request
    end

    room = @data["rooms"][room_name]
    if room.nil?
      return render json: { error: "Room not found" }, status: :not_found
    end

    # ensure array messages exists
    room["messages"] ||= []

    message = {
      "user" => user,
      "text" => text,
      "timestamp" => Time.now.utc.iso8601
    }

    room["messages"] << message
    save_data
    render json: message, status: :created
  end

  private

  def data_file
    Rails.root.join("tmp", "chat_data.json")
  end

  def load_data
    @data = {}

    if File.exist?(data_file) && File.size?(data_file)
      begin
        content = File.read(data_file)
        parsed = JSON.parse(content)

        if parsed.is_a?(Hash)
          @data = parsed
        end
      rescue JSON::ParserError => e
        Rails.logger.error "JSON parse error: #{e.message}"
      end
    end

    # required minimal structure
    @data["rooms"] ||= {}

    # ensure array messages exists
    @data["rooms"].each do |room_name, room_data|
      room_data["messages"] ||= []
    end
  end

  def save_data
    begin
      FileUtils.mkdir_p(File.dirname(data_file))
      File.write(data_file, JSON.pretty_generate(@data))
    rescue => e
      Rails.logger.error "Failed to save chat data: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
    end
  end
end
