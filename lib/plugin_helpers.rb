require 'net/http'
require 'timeout'

module SlackCat
  module PluginHelpers
    def with_timeout(memo, seconds, description=nil,  &block)
      begin
        Timeout.timeout(seconds) do
          yield
        end
      rescue Timeout::Error => e
        info = "#{Time.now}: Timeout: #{e}"
        info += " for #{description}" unless description.nil?
        m.reply info
      end
    end
  end
end
