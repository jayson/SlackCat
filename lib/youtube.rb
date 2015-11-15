# vim: ts=2:sw=2:softtabstop=2
require 'cinch'
require 'plugin_helpers'

class Youtube
  include Cinch::Plugin, SlackCat::PluginHelpers

  match(/(y) (.*)?/i, {:prefix => "."})
  match(/(youtube) (.*)?/i, {:prefix => "."})
  def execute(memo, command, term)
    cmd = "./youtube.py #{term}"

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
      memo.reply("#{output} #{error_message}")
    end
  end
end
