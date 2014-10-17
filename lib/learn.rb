require 'cinch'
require 'plugin_helpers'

class Learn
  include Cinch::Plugin, SlackCat::PluginHelpers

  match /learn ([^ ]*) (.*)?/i, prefix: ".", method: :learn
  match /(.*)?/i, prefix: ".", method: :respond
  def respond(memo, command)
    db = SQLite3::Database.new "pluses.db"
    db.execute("SELECT response FROM commands WHERE command = ? ORDER BY RANDOM() LIMIT 1", [command]) do |response|
      memo.reply response[0]
    end
  end

  def learn(memo, command, response)
    db = SQLite3::Database.new "pluses.db"
    db.execute("INSERT OR IGNORE INTO commands VALUES (?, ?, ?)", [memo.user.to_s, command, response])

    memo.reply "Learned command: #{command}"
  end
end
