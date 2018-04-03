# Require core library
require 'middleman-core'

# Extension namespace
module Middleman
  module Email
    class << self

      attr_reader :options
      attr_writer :options

    end

    class Extension < Extension

      option :user, nil
      option :password, nil
      option :emails_path, nil
      option :to_email, nil
      option :from_email, nil
      option :port, nil
      option :domain, nil
      option :address, nil
      option :base_url, nil
      option :authentication, :plain
      option :build_before, true
      option :local_only, true
      option :build_dir

      def initialize(app, options_hash = {}, &block)
        super
        yield options if block_given?
      end

      def configure_emails(options)
        Mail.defaults do
          delivery_method :smtp,
                          address: options.address,
                          port: options.port,
                          domain: options.domain,
                          authentication: options.authentication,
                          user_name: options.user,
                          password: options.password
        end
      end

      def after_configuration
        ::Middleman::Email.options = options
        require 'premailer'
        require 'mail'
        configure_emails(options)
      end

    end

    module Helpers
      def email_options
        ::Middleman::Email.options
      end
    end
  end
end
