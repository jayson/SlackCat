# vim: ts=2:sw=2:softtabstop=2
require 'cinch'
require 'net/http'
require 'plugin_helpers'

class Summon
  include Cinch::Plugin, SlackCat::PluginHelpers

  match(/(summon) (.*)?/i, {:prefix => "."})
  match(/(gif) (.*)?/i, {:prefix => "."})
  match(/(resummon) (.*)?/i, {:prefix => "."})
  def execute(memo, command, term)
    safe_search = "safe=strict&"
    if memo.channel == "#nsfw" || memo.channel == "#mensroom"
      safe_search = ""
    end
    puts safe_search

    uri = URI("http://www.google.com/search?#{safe_search}ftbm=isch&um=1&ie=UTF-8&hl=en&tbm=isch&source=og&sa=N&tab=wis&q=#{URI.escape(term)}")
    req = Net::HTTP::Get.new(uri.request_uri)
    req['user-agent'] = 'Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)'
    res = Net::HTTP.start(uri.hostname, uri.port) {|http|
      http.request(req)
    }

    matches = []
    res.body.scan(/imgurl=(.*?)&/) do |match|
      if command == "resummon"
        matches.push(match[0])
      else
        memo.reply match[0]
        return
      end
    end

    memo.reply matches.sample
  end
end
