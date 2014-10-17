require 'cinch'
require 'plugin_helpers'
require 'sqlite3'

class Leaderboard
  include Cinch::Plugin, SlackCat::PluginHelpers

  match /(increment) (.*)?/i, prefix: ".", method: :add_one
  match /(plus) (.*)?/i, prefix: ".", method: :add_one
  match /(troll) (.*)?/i, prefix: ".", method: :add_one
  match /(pluses)/i, prefix: ".", method: :leaderboard
  match /(trolls)/i, prefix: ".", method: :leaderboard
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

  def add_one(memo, command, term)
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

    db = SQLite3::Database.new "pluses.db"
    if (nick != "") 
      if (nick != memo.user)
        db.execute("INSERT OR IGNORE INTO #{table} VALUES (?, 0)", [nick])
        db.execute("UPDATE #{table} SET pluses = pluses + 1 WHERE nick = ?", [nick])

        db.execute("SELECT pluses FROM #{table} WHERE nick = ?", [nick]) do |row|
          memo.reply "#{nick} now has #{row} #{table}"
        end
      else
        memo.reply "Nice try!"
      end
    end
  end
end
