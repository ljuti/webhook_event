require File.expand_path("../boot", __FILE__)

require "action_controller/railtie"

require "webhook_event"

module Dummy
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.filter_parameters += [ :password ]

    config.active_support.escape_html_entities_in_json = true

    if config.respond_to?(:assets)
      config.assets.enabled = true
      config.assets.version = "1.0"
    end
  end
end