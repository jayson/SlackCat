# -*- coding: utf-8 -*-
# vim: ts=2:sw=2:softtabstop=2
require "./slackbot_setup"
require 'open3'

slackcat = Cinch::SlackBot.new do
  if (File.exist?(".config"))
    @slack_config = JSON.parse(File.read(".config"))
  else 
    @slack_config = []
    File.write(".config", "{}")
  end

  set_config :ssl
  set_config :user
  set_config :nick, "slackcat"
  set_config :user
  set_config :password
  set_config :server
  set_config :port, 6667
  load_plugins

  # Helpers
  helpers do 
    def save_config
      File.write(".config", JSON.pretty_generate(bot.get_slack_config, quirks_mode: true))
    end

    def load_config
      @slack_config = JSON.parse(File.read(".config"))
    end
  end

  # Base slack bot commands
  command /join (.+)/ do |message, channel|
    info("Joining channel #{channel}")
    bot.join(channel)
    channels = bot.get_slack_config("channels")
    channels.unshift channel
    bot.set_slack_config("channels", channels)
    save_config
  end

  command /part(?: (.+))?/ do |message, channel|
    # Part current channel if none is given
    channel = channel || message.channel

    if channel
      info("Parting channel #{channel}")
      bot.part(channel)
      channels = bot.get_slack_config("channels")
      channels.delete_if { |key, value| value == channel }
      bot.set_slack_config("channels", channels)
      save_config
    else
      info("No such channel to part #{channel}") 
    end
  end

  command /reload/ do |message|
    load_config
    @slack_config = JSON.parse(File.read(".config"))
    @slack_config["channels"].each do |channel| 
      bot.join(channel)
    end
  end

  command /source/ do |message|
    message.reply "https://github.com/jayson/SlackCat"
  end

  command /gitup/ do |message|
    cmd = "git pull"

    puts cmd
    Open3.popen3(cmd) do |inn, out, err, wait_thr|
      output = ""
      until out.eof?
        # raise "Timeout" if output.empty? && Time.now.to_i - start > 300
        chr = out.read(1)
        output << chr
      end
      error_message = nil
      error_message = err.read unless err.eof?
      message.reply("#{output} #{error_message}")
    end
  end
end

slackcat.start
