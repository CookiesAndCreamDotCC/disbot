# DisBot (disbot.rb) - A Discord bot
# Copyright (C) 2025-2026 Lazy Villain
# https://github.com/CookiesAndCreamDotCC/disbot
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

# Requires
require 'discordrb' # for Discord communication
require 'set'       # for data sets instead of arrays

# Local requires
require_relative 'options'
# Parse configuration file -- this must exist here
parse_config()
require_relative 'database'
# Create bot -- this must also exist here
$bot = Discordrb::Commands::CommandBot.new(token: $config.bot_token, intents: [:server_messages], prefix: $config.bot_prefix)
require_relative 'commands'
require_relative 'util'

# Constants
AUTHOR = 'Lazy Villain'
VERSION = '2.0.0' # 2.x added SQLite support

# Globals
$admins = Set.new
$admins.add($config.admin_id)
$contributors = Set.new
$start_time = Time.now.to_i
$quotes = []
$nick_queries = 0
$mention_queries = 0
$slash_queries = 0
$unique_queriers = Set.new

# Reset status on reconnect
$bot.ready { $bot.game = $config.bot_status }

# Initialize bot
init_database
load_contributors
load_quotes
load_stats

# Launch bot
#$bot.run
$bot.run :async
$bot.game = $config.bot_status
$bot.sync
