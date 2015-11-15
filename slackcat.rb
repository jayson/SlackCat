# -*- coding: utf-8 -*-
require "./slackbot_setup"
require 'open3'

slackcat = Cinch::SlackBot.new do
    if (File.exist?(".config"))
        @slack_config = JSON.parse(File.read(".config"))
    else 
        @slack_config = []
        File.write(".config", "{}")
    end

    set_config :ssl, true
    set_config :nick, "travisbot"
    set_config :user, "travisbot"
    set_config :password
    set_config :server, "roguesquadron.irc.slack.com"
    set_config :port, 6697
    #set_config :plugins, (["leaderboard"].to_s)

    #info("password: " + password)

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

    # on :message, "/^([a-zA-Z]+)\+\+" do |m|
    on :message, "hello" do |m|
        info("trying the on :message!")
        m.reply "got an '#{m.raw}' message!"
    end

    on :message, /;join (.+)/ do |m|
        channel = m.message.split(" ")[1]
        info("trying to join channel: #{channel}")
        bot.join(channel)
    end

    on :message, /;part (.+)/ do |m|
        channel = m.message.split(" ")[1]
        info("trying to part channel: #{channel}")
        bot.part(channel)
    end

    #on :message, /[a-zA-Z\.]\+\+$/ do |m|
    #    name = m.message.split("+")[0]
    #    info("incrementing '#{name}'")
    #    m.reply "incremeting '#{name}'! - suck it jpaul"
    #end

    #on :message, /[a-zA-Z\.]--$/ do |m|
    #    name = m.message.split("-")[0]
    #    info("decrementing'#{name}'")
    #    m.reply "decrementing '#{name}'! - suck it jpaul"
    #end


end

slackcat.start
