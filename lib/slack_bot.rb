# vim: ts=2:sw=2:softtabstop=2:et
require 'slack_config'
module Cinch
  class SlackBot < Bot
    include Cinch::SlackConfig

    # DSL Macros
    def command(regexp, *args, &block)
      new_regexp = Regexp.new("^#{Regexp.escape(get_slack_config("prefix", "!"))}#{regexp.to_s}")
      info("Registering new slack command for #{new_regexp.to_s}")
      on(:message, new_regexp, *args, &block)
    end

  end
end

