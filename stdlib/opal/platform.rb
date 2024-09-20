require 'opal-platform'

case OPAL_PLATFORM
when 'gjs'              then require 'gjs'
when 'quickjs'          then require 'quickjs'
when 'deno'             then require 'deno/base'
when 'nodejs'           then require 'nodejs/base'
when 'headless-chrome'  then require 'headless_browser/base'
when 'headless-firefox' then require 'headless_browser/base'
when 'safari'           then require 'headless_browser/base'
when 'opal-miniracer'   then require 'opal/miniracer'
end
