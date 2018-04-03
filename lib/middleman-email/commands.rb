require 'middleman-core/cli'
require 'middleman-core/rack' if Middleman::VERSION.to_i > 3

module Middleman
  module Cli
    # This class provides a "email" command for the middleman CLI.
    class Email < Thor::Group

      include Thor::Actions

      check_unknown_options!

      namespace :email

      # Tell Thor to exit with a nonzero exit code on failure
      def self.exit_on_failure?
        true
      end

      # desc 'email [options]', Middleman::Email::TAGLINE
      class_option 'file',
        type: :string,
        aliases: '-f',
        desc: 'Path of file from emails base path. Executes the email task only for this file.'
      class_option 'subfolder',
        type: :string,
        aliases: '-s',
        desc: 'Subfolder path from emails base path. Executes the email task for all html files inside the directory'
      class_option 'build_before',
        type: :boolean,
        aliases: '-b',
        desc: 'Executes a build before premailer.'
      class_option 'local_only',
        type: :boolean,
        aliases: '-l',
        desc: 'Does not send the resulting compiled template. It saves it into disk.'

      def email
        emails_path = options.fetch('emails_path', email_options.emails_path)
        build_before = options.fetch('build_before', email_options.build_before)
        local_only = options.fetch('local_only', email_options.local_only)
        run('middleman build') if build_before
        email_options.build_dir = build_dir
        compiled_emails = compile_files(files_to_send(emails_path))
        if local_only
          save_emails_to_file(compiled_emails)
        else
          send_emails(compiled_emails)
        end
      end

      protected

      def compile_files(files_path)
        files_path.map do |file|
          email_file = Middleman::Email::Compiler.new(file, email_options)
          html_content = email_file.compile
          email_file.print_warnings
          { title: email_name.file_name, html_content: html_content }
        end
      end

      def send_emails(compiled_emails)
        compiled_emails.each do |compiled_email|
          Middleman::Email::FileSender.new(compiled_email[:title],
                                           compiled_email[:html_content],
                                           email_options).send
        end
      end

      def save_emails_to_file(compiled_emails)
        compiled_emails.each do |compiled_email|
          FileUtils.mkdir('compiled_emails')
          file_path = "compiled_emails/#{compiled_email[:title]}-#{Time.now.to_i}"
          File.open(file_path, 'w') { |file| compiled_email[:html_content] }
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
        [File.join(build_dir, base_path, options.fetch('file'))]
      end

      def subfolder_path(base_path)
        subfolder = options.fetch('subfolder')
        Dir.glob(File.join(build_dir, base_path, subfolder, '**','*.html'))
      end

      def all_files_path(base_path)
        Dir.glob(File.join(build_dir, base_path, '**', '*.html'))
      end

      def email_options
        options = nil

        begin
          options = ::Middleman::Email.options
        rescue NoMethodError
          raise Error, 'ERROR: ou need to activate the email extension in '\
            "config.rb.\n#{Middleman::Email::README}"
        end

        unless options.emails_path
          raise Error, 'ERROR: You should indicate a emails_path in the activate'\
            "block.\n#{Middleman::Email::README}"
        end

        unless options.to_email
          raise Error, 'ERROR: You should indicate a to_email in the activate '\
            "block.\n#{Middleman::Email::README}"
        end

        unless options.from_email
          raise Error, 'ERROR: You should indicate a from_email in the activate '\
            "block.\n#{Middleman::Email::README}"
        end
        options
      end

      def app
        @app ||= ::Middleman::Application.new
      end

      def build_dir
        app.config.setting(:build_dir).value
      end

    end

    # Add to CLI
    Base.register(Middleman::Cli::Email, 'email', 'email [options]', Middleman::Email::TAGLINE)

    Base.map('ems' => 'email')
  end
end
