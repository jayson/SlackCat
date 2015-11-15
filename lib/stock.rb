# vim: ts=2:sw=2:softtabstop=2:et
require 'cinch'
require 'plugin_helpers'
require 'json'

class Stock
  include Cinch::Plugin, SlackCat::PluginHelpers

  match(/(q) (.*)?/i, {:prefix => "."})
  match(/(quote) (.*)?/i, {:prefix => "."})
  def execute(memo, command, term)
    params = [
      's',
      'k1',
      'k2',
      'c6',
      'x',
      'n',
      'v',
      'j1'
    ]

    url = "http://download.finance.yahoo.com/d/quotes.csv?f=#{params.join}&s=#{URI.escape(term)}"
    puts url
    uri = URI(url)
    req = Net::HTTP::Get.new(uri.request_uri)
    req['user-agent'] = 'Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)'
    res = Net::HTTP.start(uri.hostname, uri.port) {|http|
      http.request(req)
    }

    raw_list = res.body.gsub('"', "").gsub("N/A - ", "").gsub("<b>", "").gsub("</b>", "").split(",")
    message = "#{raw_list[5]} (#{raw_list[0]}) #{raw_list[1]} #{raw_list[3]} (#{raw_list[2]}) http://finance.yahoo.com/q?s=#{raw_list[0]}"

    memo.reply message
  end
end
