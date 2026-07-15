# DisBot (options.rb) - A Discord bot
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
require 'yaml' # for configuration options

# Holds configuration options
Config = Struct.new(
  :bot_token,
  :bot_prefix,
  :bot_name,
  :bot_status,
  :embed_color,
  :admin_id,
  :server_id,
  :db_name,
  keyword_init: true
)

# Parse configuration file
def parse_config
  puts('Parsing configuration file...')
  begin
    config_file = YAML.load_file('disbot.yml')
  rescue => e
    STDERR.puts("Unable to read disbot.yml: #{e.message}")
    exit!
  end

  $config = Config.new(
    bot_token: config_file['bot_token'].to_s,
    bot_prefix: config_file['bot_prefix'].to_s,
    bot_name: config_file['bot_name'].to_s,
    bot_status: config_file['bot_status'].to_s,
    embed_color: config_file['embed_color'].to_s,
    admin_id: config_file['admin_id'].to_i,
    server_id: config_file['server_id'].to_i,
    db_name: config_file['db_name'].to_s
  )
  validate_config()
end

# Validate configuration options
def validate_config
  if $config.bot_token.to_s.strip.empty?
    STDERR.puts('No bot token set!')
    exit!
  end

  if $config.bot_prefix.to_s.strip.empty?
    STDERR.puts('No bot prefix set. Using a default of: !')
    $config.bot_prefix = '!'
  end

  if $config.bot_name.to_s.strip.empty?
    STDERR.puts('No bot name set. Using a default of: disbot')
    $config.bot_name = 'disbot'
  end

  # bot_status can be empty

  if $config.embed_color.to_s.strip.empty?
    STDERR.puts('No embed color set. Using a default of: A0522D')
    $config.embed_color = 'A0522D'
  end

  if $config.admin_id.zero?
    STDERR.puts('No administrator ID set!')
    exit!
  end

  if $config.server_id.zero?
    STDERR.puts('No server ID set!')
    exit!
  end

  if $config.db_name.to_s.strip.empty?
    STDERR.puts('No database name set. Using a default of: disbot.db')
    $config.db_name = 'disbot.db'
  end
end
