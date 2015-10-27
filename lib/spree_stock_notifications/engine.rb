module SpreeStockNotifications
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_stock_notifications'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer "spree_stock_notifications.environment", before: :load_config_initializers do |app|
      Spree::AppConfiguration.class_eval do
        preference :low_stock_threshold,      :integer, default: 1
        preference :low_stock_notification_emails, :string
        preference :out_of_stock_notification_emails, :string
      end
    end

    def self.activate
      # load concerns first since they are potentially needed in the decorator
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/models/concerns/*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
