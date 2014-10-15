# -*- coding: utf-8 -*-
require "rubygems"
require "bundler"
Bundler.setup
require "cinch"
require "cinch/exceptions"
require "json"

slackcat = Cinch::Bot.new do
  @prefix = '!'
  @slack_config = JSON.parse(File.read(".config"))

  configure do |config|
    config.nick = "SlackCat"
    config.ssl.use = true
    config.ssl.verify = true
    config.user = "slackcat"
    config.nick = "SlackCat"
    config.password = File.open('.password', 'r') { |f| f.read }.strip!
    config.server = "roguesquadron.irc.slack.com"
    config.channels = []
  end

  # DSL Macros
  def slack_command(regexp, *args, &block)
    new_regexp = Regexp.new("^#{Regexp.escape(@prefix)}#{regexp.to_s}")
    info("Registering new slack command for #{new_regexp.to_s}")
    on(:message, new_regexp, *args, &block)
  end

  # Base slack commands
  slack_command /join (.+)/ do |message, channel|
    info("Joining channel #{channel}")
    bot.join(channel)
  end

  slack_command /part(?: (.+))?/ do |message, channel|
    # Part current channel if none is given
    channel = channel || message.channel

    if channel
      info("Parting channel #{channel}")
      bot.part(channel)
    else
     info("No such channel to part #{channel}") 
    end
  end

  # TODO: not working due to load_config undefined
  slack_command /reload/ do |message|
    @slack_config = JSON.parse(File.read(".config"))
    puts @slack_config
    @slack_config["channels"].each do |channel| 
      bot.join(channel)
    end
  end
end

slackcat.start
