# Require core library
require 'middleman-core'

# Extension namespace
module Middleman
  module Email
    class Options < Struct.new(:user, :password, :domain, :address, :port,
                               :authentication,:emails_path, :build_before, :to_email, :from_email);
    end

    class << self
      def options
        @@options
      end

      def registered(app, options_hash = {}, &block)
        require 'premailer'
        require 'mail'

        options = Options.new(options_hash)
        yield options if block_given?


        # Default options for the rsync method.
        options.port ||= 587
        options.domain ||= 'mg.marsbased.com'
        options.address = 'smtp.mailgun.org'
        options.authentication = :plain
        options.build_before = true


        @@options = options
        configure_emails(options)

        app.send :include, Helpers
      end

      def configure_emails(options)
        Mail.defaults do
          delivery_method :smtp, { address: options.address,
                                 port: options.port,
                                 domain: options.domain,
                                 authentication: options.authentication,
                                 user_name: options.user,
                                 password: options.password
                                }
        end
      end


      alias_method :included, :registered
    end



    module Helpers
      def options
        ::Middleman::Email.options
      end
    end
  end
end
