require 'middleman-core/cli'

require 'middleman-email/pkg-info'
require 'middleman-email/extension'


module Middleman
  module Cli
    # This class provides a "email" command for the middleman CLI.
    class Email < Thor
      include Thor::Actions

      check_unknown_options!

      namespace :email

      # Tell Thor to exit with a nonzero exit code on failure
      def self.exit_on_failure?
        true
      end

      desc 'email [options]', Middleman::Email::TAGLINE
      method_option 'file',
        type: :string,
        aliases: '-f',
        desc: 'Path of file from emails base path. Executes the email task only for this file.'
      method_option 'subfolder',
        type: :string,
        aliases: '-s',
        desc: 'Subfolder path from emails base path. Executes the email task for all html files inside the directory'
      method_option 'build_before',
        type: :boolean,
        aliases: '-b',
        desc: 'Executes a build before premailer. '

      def email(*args)
        emails_path = options.fetch('emails_path', email_options.emails_path)
        build_before = options.fetch('build_before', email_options.build_before)
        file = options.fetch('file', nil)
        run('middleman build') if build_before
        premailer(files_to_send(emails_path))
      end

      def premailer(files_path)
        files_path.each do |file|
          base_url = email_options.base_url || ''
          premailer = Premailer.new(file, :base_url => base_url, :warn_level => Premailer::Warnings::SAFE, :adapter => :nokogiri, :preserve_styles => false, :remove_comments => false, :remove_ids => true, :'query-string' => '')
          fileout = File.open(file, 'w')
          fileout.puts premailer.to_inline_css
          fileout.close
          send_email(file)
          premailer.warnings.each do |w|
            puts "#{w[:message]} (#{w[:level]}) may not render properly in #{w[:clients]}"
          end
        end
      end

      def files_to_send(base_path)
        paths = all_files_path(base_path)
        if options.fetch('subfolder', nil)
          paths = subfolder_path(base_path)
        elsif options.fetch('file', nil)
          paths = simple_file_path(base_path)
        end
        paths
      end

      def simple_file_path(base_path)
        [File.join(app.build_dir, base_path, options.fetch('file'))]
      end

      def subfolder_path(base_path)
        subfolder = options.fetch('subfolder')
        Dir.glob(File.join(app.build_dir, base_path, subfolder, '**','*.html'))
      end

      def all_files_path(base_path)
        Dir.glob(File.join(app.build_dir, base_path, '**', '*.html'))
      end

      def send_email(file)
        from = email_options.from_email
        to = email_options.to_email
        subject = file.gsub(File.join(app.build_dir, email_options.emails_path), '')
        Mail.deliver do
          from     from
          to       to
          subject  "Email: #{subject}"
          body
           html_part do
            content_type 'text/html; charset=UTF-8'
            body File.open(file).read
          end
        end
      end

      def email_options
        options = nil

        begin
          options = app.options
        rescue NoMethodError
          raise Error, "ERROR: ou need to activate the email extension in config.rb.\n#{Middleman::Email::README}"
        end

        unless options.emails_path
          raise Error, "ERROR: You should indicate a emails_path in the activate block.\n#{Middleman::Email::README}"
        end

        unless options.to_email
          raise Error, "ERROR: You should indicate a to_email in the activate block.\n#{Middleman::Email::README}"
        end

        unless options.from_email
          raise Error, "ERROR: You should indicate a from_email in the activate block.\n#{Middleman::Email::README}"
        end
        options
      end

      def app
        ::Middleman::Application.server.inst
      end



    end
    Base.map('ems' => 'email')
  end
end
