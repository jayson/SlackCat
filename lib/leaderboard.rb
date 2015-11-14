require 'cinch'
require 'plugin_helpers'
require 'sqlite3'

class Leaderboard
    include Cinch::Plugin, SlackCat::PluginHelpers

    match /(increment) (.*)?/i, prefix: ";", method: :add_one
    match /(plus) (.*)?/i, prefix: ";", method: :add_one

    match /(decrement) (.*)?/i, prefix: ";", method: :sub_one
    match /(minus) (.*)?/i, prefix: ";", method: :sub_one

    match /(troll) (.*)?/i, prefix: ";", method: :add_one

    match /(pluses)/i, prefix: ";", method: :leaderboard
    match /(trolls)/i, prefix: ";", method: :leaderboard
    match /(leaderboard)/i, prefix: ";", method: :leaderboard

    match /^([a-zA-Z\.]+)\+\+$/, use_prefix: false, method: :add_one_2
    match /^([a-zA-Z\.]+)--$/, use_prefix: false, method: :sub_one_2

    match /^\+\+([a-zA-Z\.])+$/, use_prefix: false, method: :add_one_3
    match /^--([a-zA-Z\.]+)$/, use_prefix: false, method: :sub_one_3

    def modify_pluses(memo, nick, username, table, sign)
        db = SQLite3::Database.new "pluses.db"
        if (nick != "") 
            if (nick == username)
                memo.reply "Nice try!"
            else
                db.execute("INSERT OR IGNORE INTO #{table} VALUES (?, 0)", [nick])
                db.execute("UPDATE #{table} SET pluses = pluses #{sign} 1 WHERE nick = ?", [nick])

                db.execute("SELECT pluses FROM #{table} WHERE nick = ?", [nick]) do |row|
                    memo.reply "#{nick} now has #{row[0]} #{table}"
                end
            end
        end
    end

    def add_one_3(memo)
        #memo.reply "got memo for ++ : '#{memo}'"
        #memo.reply "message: '#{memo.message}'"
        #memo.reply "raw: '#{memo.raw}'"

        nick = memo.message.split("++")[1]
        info("nick is '#{nick}' and memo.user is '#{memo.user}'")
        username = "#{memo.user}"

        table = "pluses"
        modify_pluses(memo, nick, username, table, "+")
    end

    def sub_one_3(memo)
        #memo.reply "got memo for ++ : '#{memo}'"
        #memo.reply "message: '#{memo.message}'"
        #memo.reply "raw: '#{memo.raw}'"

        nick = memo.message.split("--")[1]
        info("nick is '#{nick}' and memo.user is '#{memo.user}'")
        username = "#{memo.user}"

        table = "pluses"
        modify_pluses(memo, nick, username, table, "-")
    end

    def add_one_2(memo)
        #memo.reply "got memo for ++ : '#{memo}'"
        #memo.reply "message: '#{memo.message}'"
        #memo.reply "raw: '#{memo.raw}'"

        nick = memo.message.split("++")[0]
        info("nick is '#{nick}' and memo.user is '#{memo.user}'")
        username = "#{memo.user}"

        table = "pluses"
        modify_pluses(memo, nick, username, table, "+")
    end

    def sub_one_2(memo)
        #memo.reply "got memo for ++ : '#{memo}'"
        #memo.reply "message: '#{memo.message}'"
        #memo.reply "raw: '#{memo.raw}'"

        nick = memo.message.split("--")[0]
        info("nick is '#{nick}' and memo.user is '#{memo.user}'")
        username = "#{memo.user}"

        table = "pluses"
        modify_pluses(memo, nick, username, table, "-")
    end

    def sub_one(memo, command, term)
        #info("I'm trying to subtract one!")
        #memo.reply "I'm trying to subtract one!"

        if command == "decrement"
            command = "plus"
        end
        table = command
        if table[-1, 1] != "s"
            table = "#{table}s"
        end
        if table[-1, 1] != "e"
            table = "#{table}es"
        end
        nick = term.split(" ")[0]

        info("nick is '#{nick}' and memo.user is '#{memo.user}'")
        username = "#{memo.user}"

        modify_pluses(memo, nick, username, table, "-")
    end

    def add_one(memo, command, term)
        #info("I'm trying to add one!")
        #memo.reply "I'm trying to add one!"

        if command == "increment"
            command = "plus"
        end
        table = command
        if table[-1, 1] != "s"
            table = "#{table}s"
        end
        if table[-1, 1] != "e"
            table = "#{table}es"
        end
        nick = term.split(" ")[0]

        info("nick is '#{nick}' and memo.user is '#{memo.user}'")
        username = "#{memo.user}"
        modify_pluses(memo, nick, username, table, "+")
    end

    def leaderboard(memo, table)
        db = SQLite3::Database.new "pluses.db"
        index = 0
        message = "#{table.slice(0,1).capitalize + table.slice(1..-1)} Leaderboard:\n"
        db.execute("SELECT nick, pluses FROM #{table} ORDER BY pluses DESC LIMIT 10") do |nick, pluses|
            index += 1
            message += "#{index}. #{pluses} #{nick}\n"
        end
        memo.reply message
    end

end
