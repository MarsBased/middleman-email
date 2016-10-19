module Middleman
  module Email
    class EmailOptions

      def self.options
        validate_options
        app_options
      rescue NoMethodError
        raise StandardError, "ERROR: you need to activate the email extension in config.rb.\n#{readme}"
      end

      def self.validate_options
        validate_emails_path_option
        validate_to_option
        validate_from_option
      end

      def self.validate_to_option
        unless app_options.to_email
          raise_validation_error('You should indicate a to_email in the activate block.')
        end
      end

      def self.validate_from_option
        unless app_options.from_email
          raise_validation_error('You should indicate a from_email in the activate block.')
        end
      end

      def self.validate_emails_path_option
        unless app_options.emails_path
          raise_validation_error('You should indicate a emails_path in the activate block.')
        end
      end

      def self.app_options
        @app_options ||= ::Middleman::Application.server.inst.options
      end

      def self.raise_validation_error(msg)
        raise StandardError, "ERROR: #{msg}\n#{Middleman::Email::README}"
      end

    end
  end
end
