require 'middleman-core'

require 'middleman-email/commands'

::Middleman::Extensions.register(:email) do
  require 'middleman-email/extension'
  ::Middleman::Email
end
