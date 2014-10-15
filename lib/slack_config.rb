module Cinch
  module SlackConfig

    # Config Helpers
    def file_config(config_file_index, default = nil)
      config_file_index = config_file_index.to_s
      if @slack_config.has_key? config_file_index
        @slack_config[config_file_index]
      else
        default
      end
    end

    def set_config(config_variable, default = nil, config_file_index = nil)
      config_file_index = config_variable if config_file_index.nil?
      config_variable = config_variable.to_s
      if (config_variable == "ssl")
        @config.ssl.use = file_config(config_file_index, false)
        @config.ssl.verify = file_config(config_file_index, false)
      else
        @config.send("#{config_variable}=", file_config(config_file_index, default))
      end
    end

    def get_slack_config(index = nil, default = nil)
      if index.nil?
        return @slack_config
      end
      if @slack_config.has_key? index
        @slack_config[index]
      else
        default
      end
    end

    def set_slack_config(index, value)
      @slack_config[index] = value
    end

    def load_plugins
      plugins = get_slack_config("plugins", [])
      plugins_to_load = []
      plugins.each do |plugin|
        require plugin
        plugins_to_load.unshift Kernel.const_get(plugin.split('_').collect!{ |w| w.capitalize }.join)
      end
      puts plugins_to_load
      @config.plugins.plugins = [DiceRoll]
    end
  end
end
