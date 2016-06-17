# Activation

To activate the extension you should include the following block in your config.rb file:


activate :email do |email|
  email.user = Required: <smtp username>
  email.password = Required: <smtp password>
  email.emails_path= Required: <Folder where your emails are placed in your build directory, for example: emails. This path will be the base path after your build directory.>
  email.to_email = Required: <email address where emails will be sent>
  email.from_email = Required: <from address that will appear in all sent emails>
end

Another properties that you can specify in the block are:

port = <Smtp port>, default: 587
domain = <Smtp domain> default: mg.marsbased.com
address = <Smtp address> default: smtp.mailgun.org
authentication = <Authentication method for smtp> default: :plain

After this you can send ALL the email in your emails folder using the command:

bundle exec middleman email

# Command line options
There are three options available:

-b (build_before) true/false | Default: true | If a false flag is indicated the build task will not be executed before premailer.
Example:
bundle exec middleman email -b false

-s (subfolder) We can pass a subfolder to the command and all the emails inside this subfolder (inside the emails_path directory) will be sent.
Example:
bundle exec middleman email -s common_emails

If for example, emails_path is 'emails', all html files inside build_dir/emails/common_emails will be sent.

-f (file) File to be sent in the email. The value must be the path of the file.
Example:

bundle exec middleman email -s common_emails/my_email.html
