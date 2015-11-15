require 'cinch'
require 'plugin_helpers'
require 'sqlite3'

class Leaderboard
  include Cinch::Plugin, SlackCat::PluginHelpers

  match /(troll) (.*)?/i, prefix: ".", method: :modify_leaderboard
  match /(trolls)/i, prefix: ".", method: :leaderboard

  match /(pluses)/i, prefix: ".", method: :leaderboard
  match /(leaderboard)/i, prefix: ".", method: :leaderboard

  match /(increment) (.*)?/i, prefix: ".", method: :modify_leaderboard
  match /(plus) (.*)?/i, prefix: ".", method: :modify_leaderboad

  match /(decrement) (.*)?/i, prefix: ".", method: :modify_leaderboad
  match /(minus) (.*)?/i, prefix: ".", method: :modify_leaderboard

  match /^([a-zA-Z\.]+)(\+\+)$/, use_prefix: false, method: :modify_leaderboard
  match /^([a-zA-Z\.]+)(--)$/, use_prefix: false, method: :modify_leaderboard

  match /^(\+\+)([a-zA-Z\.]+)$/, use_prefix: false, method: :modify_leaderboard
  match /^(--)([a-zA-Z\.]+)$/, use_prefix: false, method: :modify_leaderboard

  def get_table_name(command)
    # Create hash with default table to pluses then add ones that are different
    tables = Hash.new("pluses")
    tables["troll"] = "trolls"
    tables[command.to_s]
  end

  def get_sign(command)
    decrement_commands = ["--", "decrement", "minus"]
    decrement_commands.include?(command.to_s) ? "-" : "+"
  end

  def modify_leaderboard(memo, first_match, second_match)
    # Check if we are pre or post increment and swap if needed
    if (second_match.to_s == "++" || second_match.to_s == "--")
      first_match, second_match = second_match, first_match
    end

    # Name these variables something sane
    command, nick = first_match, second_match

    table = get_table_name(command)
    sign = get_sign(command)

    db = SQLite3::Database.new "pluses.db"
    if (nick != "") 
      if (nick.to_s == memo.user.to_s)
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

  def leaderboard(memo, table)
    db = SQLite3::Database.new "pluses.db"
    index = 0
    message = "#{table.slice(0,1).capitalize + table.slice(1..-1)} Leaderboard:\n"
    db.execute("SELECT nick, pluses FROM #{table} ORDER BY pluses DESC LIMIT 5") do |nick, pluses|
      index += 1
      message += "#{index}. #{pluses} #{nick}\n"
    end
    memo.reply message
  end
end
