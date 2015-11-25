# vim: ts=2:sw=2:softtabstop=2:et
require 'cinch'
require 'plugin_helpers'

class Bash
  include Cinch::Plugin, SlackCat::PluginHelpers

  match /bash/i, prefix: ".", method: :random_bash

  def random_bash(memo)
    memo.reply(`curl -s http://bash.org/?random1|grep -oE '<p class=\"quote\">.*</p>.*</p>'|grep -oE "<p class=\\"qt.*?</p>"|sed -e 's/<\\/p>/\\n/g' -e 's/<p class=\\"qt\\">//g' -e 's/<p class=\\"qt\\">//g'|perl -ne 'use HTML::Entities;print decode_entities($_),"\n"'|head -1`)
  end

end
