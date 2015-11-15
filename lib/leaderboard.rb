require 'cinch'
require 'plugin_helpers'
require 'sqlite3'

class Leaderboard
    include Cinch::Plugin, SlackCat::PluginHelpers

    match /(troll) (.*)?/i, prefix: ";", method: :add_troll
    match /(trolls)/i, prefix: ";", method: :leaderboard

    match /(pluses)/i, prefix: ";", method: :leaderboard
    match /(leaderboard)/i, prefix: ";", method: :leaderboard

    match /(increment) (.*)?/i, prefix: ";", method: :add_plus
    match /(plus) (.*)?/i, prefix: ";", method: :add_plus

    match /(decrement) (.*)?/i, prefix: ";", method: :sub_plus
    match /(minus) (.*)?/i, prefix: ";", method: :sub_plus

    match /^([a-zA-Z\.]+)\+\+$/, use_prefix: false, method: :add_plus_postfix
    match /^([a-zA-Z\.]+)--$/, use_prefix: false, method: :sub_plus_postfix

    match /^\+\+([a-zA-Z\.])+$/, use_prefix: false, method: :add_plus_prefix
    match /^--([a-zA-Z\.]+)$/, use_prefix: false, method: :sub_plus_prefix

    def modify_pluses(memo, nick, table, sign)
        username = "#{memo.user}"

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

    def add_plus_prefix(memo)
        nick = memo.message.split("++")[1]
        modify_pluses(memo, nick, "pluses", "+")
    end

    def sub_plus_prefix(memo)
        nick = memo.message.split("--")[1]
        modify_pluses(memo, nick, "pluses", "-")
    end

    def add_plus_postfix(memo)
        nick = memo.message.split("++")[0]
        modify_pluses(memo, nick, "pluses", "+")
    end

    def sub_plus_postfix(memo)
        nick = memo.message.split("--")[0]
        modify_pluses(memo, nick, "pluses", "-")
    end

    def sub_plus(memo, command, term)
        nick = term.split(" ")[0]
        modify_pluses(memo, nick, "pluses", "-")
    end

    def add_plus(memo, command, term)
        nick = term.split(" ")[0]
        modify_pluses(memo, nick, "pluses", "+")
    end

    def sub_troll(memo, command, term)
        nick = term.split(" ")[0]
        modify_trolls(memo, nick, "trolls", "-")
    end

    def add_troll(memo, command, term)
        nick = term.split(" ")[0]
        modify_trolls(memo, nick, "trolls", "+")
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
