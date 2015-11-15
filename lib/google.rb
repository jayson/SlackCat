# vim: ts=2:sw=2:softtabstop=2
require 'cinch'
require 'plugin_helpers'
require 'json'

class Google 
  include Cinch::Plugin, SlackCat::PluginHelpers

  match(/(g) (.*)?/i, {:prefix => "."})
  match(/(google) (.*)?/i, {:prefix => "."})
  def execute(memo, command, term)
    puts "http://ajax.googleapis.com//ajax/services/search/web?v=1.0&rsz=large&start=0&q=#{URI.escape(term)}"
    uri = URI("http://ajax.googleapis.com//ajax/services/search/web?v=1.0&rsz=large&start=0&q=#{URI.escape(term)}")
    req = Net::HTTP::Get.new(uri.request_uri)
    req['user-agent'] = 'Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)'
    res = Net::HTTP.start(uri.hostname, uri.port) {|http|
      http.request(req)
    }

    result = JSON.parse res.body
    memo.reply("#{result['responseData']['results'][0]['titleNoFormatting']} @ #{result['responseData']['results'][0]['unescapedUrl']}")
  end
end
