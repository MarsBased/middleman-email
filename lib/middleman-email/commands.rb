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
        compile_and_send_emails(emails_path)
      end

      def compile_and_send_emails(emails_path)
        files_to_send(emails_path).each do |file|
          body = Premailer.compile(file)
          Email.new(body: body,
                    from: email_options.from_email,
                    to: email_options.to_email).send
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

      def email_options
        @email_options ||= EmailOptions.options
      end

    end
    Base.map('ems' => 'email')
  end
end
