Rails.application.configure do
  # Allow any origin from App Runner
  config.action_cable.allowed_request_origins = [
    /https?:\/\/.*\.awsapprunner\.com/,
    /http:\/\/.*\.awsapprunner\.com/,
    /http:\/\/localhost:\d+/,
    /wss:\/\/.*\.awsapprunner\.com/,
    /ws:\/\/.*\.awsapprunner\.com/,
    /wss:\/\/.*\.prothegee\.com/,
    /ws:\/\/.*\.prothegee\.com/,
    /ws:\/\/localhost:\d+/
  ]

  config.action_cable.disable_request_forgery_protection = true

  config.action_cable.logger = Logger.new(STDOUT)
end
