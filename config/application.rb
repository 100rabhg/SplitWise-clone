require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BeAssignmentJunior1
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = 'Chennai'
    # config.eager_load_paths << Rails.root.join("extras")

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: ENV.fetch('SMTP_ADDRESS'),
      port: ENV.fetch('SMTP_PORT'),
      domain: ENV.fetch('SMTP_DOMAIN'),
      user_name: ENV.fetch('SMTP_USERNAME', nil),
      password: ENV.fetch('SMTP_PASSWORD', nil),
      authentication: :login,
      enable_starttls_auto: ENV.fetch('SMTP_ENABLE_STARTTLS_AUTO', false)
    }
  end
end
