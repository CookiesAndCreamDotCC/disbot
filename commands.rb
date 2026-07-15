# DisBot (commands.rb) - A Discord bot
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

# Add a contributor
$bot.register_application_command(:contributor_add, 'Add a contributor to the database', server_id: $config.server_id) do |cmd|
  cmd.string('user_name', 'Username of contributor', required: true)
  cmd.string('user_id', 'Unique numerical Discord user ID', required: true)
end

$bot.application_command(:contributor_add) do |event|
  begin
    if $admins.include?(event.user.id)
      user_id = event.options['user_id'].to_i
      open_database() do |db|
        user_name = event.options['user_name']
        added_by = event.user.display_name
        date_added = Date.today.to_s
        update_stats(db, :slash, event.user)
        db.execute('INSERT INTO contributors (user_id, user_name, added_by, date_added) VALUES (?, ?, ?, ?)', [user_id, user_name, added_by, date_added])
      end
      $contributors.add(user_id)
      event.respond(content: 'Contributor added.')
    else
      event.respond(content: 'Permission denied.')
    end
  rescue SQLite3::ConstraintException => e
    event.respond(content: 'Contributor not added: User already exists in the database.')
    STDERR.puts("Contributor not added: #{e.message}")
  rescue => e
    event.respond(content: "Contributor not added: #{e.message}")
    STDERR.puts("Contributor not added: #{e.message}")
  end
end

# Delete a contributor
$bot.register_application_command(:contributor_delete, 'Remove a contributor from the database', server_id: $config.server_id) do |cmd|
  cmd.string('user_id', 'Unique numerical Discord user ID', required: true)
end

$bot.application_command(:contributor_delete) do |event|
  begin
    if $admins.include?(event.user.id)
      open_database(results_as_hash: true) do |db|
        update_stats(db, :slash, event.user)
        result = db.execute('DELETE FROM contributors WHERE user_id = ? COLLATE NOCASE RETURNING *', event.options['user_id'])
        #result.each do |row|
        #  puts "#{row['user_name']} deleted"
        #end
        if result.length == 0
          event.respond(content: "#{event.options['user_id']} does not exist in the database.")
        elsif result.length == 1
          $contributors.delete(event.options['user_id'])
          event.respond(content: "#{result.length} contributor deleted.")
        else
          $contributors.delete(event.options['user_id'])
          event.respond(content: "#{result.length} contributors deleted.")
        end
      end
    else
      event.respond(content: 'Permission denied.')
    end
  rescue => e
    event.respond(content: "Unable to remove contributor: #{e.message}")
    STDERR.puts("Unable to remove contributor: #{e.message}")
  end
end

# List contributors
$bot.register_application_command(:contributor_list, 'Enumerate contributors from the database', server_id: $config.server_id) do |cmd|
  #
end

$bot.application_command(:contributor_list) do |event|
  begin
    if $admins.include?(event.user.id)
      open_database(results_as_hash: true) do |db|
        update_stats(db, :slash, event.user)
        result = db.execute('SELECT * FROM contributors')
        contributors = '```'
        result.each do |row|
          contributors += "* #{row['user_name']} (#{row['user_id']})\n"
          contributors += ""
        end
        contributors += '```'
        if result.length < 1
          event.respond(content: "#{result.length} contributors contained in the database.")
        elsif result.length == 1
          event.respond(content: "#{result.length} contributor contained in the database:\n#{contributors}")
        else
          event.respond(content: "#{result.length} contributors contained in the database:\n#{contributors}")
        end
      end
    else
      event.respond(content: 'Permission denied.')
    end
  rescue => e
    event.respond(content: "Unable to enumerate contributors: #{e.message}")
    STDERR.puts("Unable to enumerate contributors: #{e.message}")
  end
end

# Add a quote
$bot.register_application_command(:quote_add, 'Add a quote to the database', server_id: $config.server_id) do |cmd|
  cmd.string('quote', 'Quote text', required: true)
end

$bot.application_command(:quote_add) do |event|
  begin
    if $admins.include?(event.user.id) || $contributors.include?(event.user.id)
      quote = event.options['quote']
      open_database() do |db|
        added_by = event.user.display_name
        date_added = Date.today.to_s
        update_stats(db, :slash, event.user)
        db.execute('INSERT INTO quotes (quote, added_by, date_added) VALUES (?, ?, ?)', [quote, added_by, date_added])
      end
      $quotes << quote
      event.respond(content: 'Quote added.')
    else
      event.respond(content: 'Permission denied.')
    end
  rescue SQLite3::ConstraintException => e
    event.respond(content: 'Quote not added: Quote already exists in the database.')
    STDERR.puts("Quote not added: #{e.message}")
  rescue => e
    event.respond(content: "Quote not added: #{e.message}")
    STDERR.puts("Quote not added: #{e.message}")
  end
end

# Delete a quote
$bot.register_application_command(:quote_delete, 'Remove a quote from the database', server_id: $config.server_id) do |cmd|
  cmd.string('quote', 'Quote text', required: true)
end

$bot.application_command(:quote_delete) do |event|
  begin
    if $admins.include?(event.user.id) || $contributors.include?(event.user.id)
      open_database(results_as_hash: true) do |db|
        update_stats(db, :slash, event.user)
        result = db.execute('DELETE FROM quotes WHERE quote = ? COLLATE NOCASE RETURNING *', event.options['quote'])
        #result.each do |row|
        #  puts "#{row['quote']} deleted"
        #end
        if result.length == 0
          event.respond(content: 'Quote does not exist in the database.')
        elsif result.length == 1
          event.respond(content: "#{result.length} quote deleted.")
          $quotes.delete(event.options['quote'])
        else
          event.respond(content: "#{result.length} quotes deleted.")
          $quotes.delete(event.options['quote'])
        end
      end
    else
      event.respond(content: 'Permission denied.')
    end
  rescue => e
    event.respond(content: "Unable to remove quote: #{e.message}")
    STDERR.puts("Unable to remove quote: #{e.message}")
  end
end

# Allow bot to respond to its name
$bot.register_application_command($config.bot_name.to_sym, "Invoke #{$config.bot_name}", server_id: $config.server_id) do |cmd|
  #
end

$bot.application_command($config.bot_name.to_sym) do |event|
  begin
    open_database() do |db|
      update_stats(db, :slash, event.user)
    end
  rescue => e
    STDERR.puts("Unable to update stats database: #{e.message}")
  end
  #event.channel.start_typing
  #sleep 3
  #event.respond(content: response, timeout: 5) #, ephemeral: true)
  event.respond(content: get_quote)
end

# Respond if a chat message contains the bot name
$bot.message(contains: /#{Regexp.escape($config.bot_name)}/i) do |event|
  begin
    open_database() do |db|
      update_stats(db, :nick, event.user)
    end
  rescue => e
    STDERR.puts("Unable to update stats database: #{e.message}")
  end
  event.channel.start_typing
  sleep 5
  event.respond(get_quote)
end

# Respond if bot is mentioned/tagged
$bot.mention(contains: /.*/) do |event|
  begin
    open_database() do |db|
      update_stats(db, :mention, event.user)
    end
  rescue => e
    STDERR.puts("Unable to update stats database: #{e.message}")
  end
  event.channel.start_typing
  sleep 5
  event.respond(get_quote)
end

# Reload the bot
$bot.command(:reload, help_available: false) do |event|
  if $admins.include?(event.user.id)
    $quotes.clear
    load_quotes
    $bot.send_message(event.channel.id, "#{$quotes.length} quotes loaded.")
  end
end

# Shut down the bot
$bot.command(:shutdown, help_available: false) do |event|
  if $admins.include?(event.user.id)
    $bot.send_message(event.channel.id, 'Shutting down...')
    $bot.stop
    exit
  end
end

# Display statistics
$bot.command(:stats, help_available: false) do |event|
  if $admins.include?(event.user.id)
    uptime = get_uptime()
    uptime_str = "#{uptime.days}d:#{uptime.hours}h:#{uptime.minutes}m:#{uptime.seconds}s"
    event.channel.send_embed() do |embed|
      embed.color = $config.embed_color
      embed_fields = []
      embed_fields << Discordrb::Webhooks::EmbedField.new(name: 'Author', value: AUTHOR, inline: true)
      embed_fields << Discordrb::Webhooks::EmbedField.new(name: 'Version', value: VERSION.to_s, inline: true)
      embed_fields << Discordrb::Webhooks::EmbedField.new(name: 'Uptime', value: uptime_str, inline: true)
      embed_fields << Discordrb::Webhooks::EmbedField.new(name: 'Administrators', value: $admins.length, inline: true)
      embed_fields << Discordrb::Webhooks::EmbedField.new(name: 'Contributors', value: $contributors.length, inline: true)
      embed_fields << Discordrb::Webhooks::EmbedField.new(name: 'Quotes', value: $quotes.length, inline: true)
      embed_fields << Discordrb::Webhooks::EmbedField.new(name: 'Nick Queries', value: $nick_queries, inline: true)
      embed_fields << Discordrb::Webhooks::EmbedField.new(name: 'Mention Queries', value: $mention_queries, inline: true)
      embed_fields << Discordrb::Webhooks::EmbedField.new(name: 'Slash Queries', value: $slash_queries, inline: true)
      embed_fields << Discordrb::Webhooks::EmbedField.new(name: 'Total Queries', value: $nick_queries + $mention_queries + $slash_queries, inline: true)
      embed_fields << Discordrb::Webhooks::EmbedField.new(name: 'Unique Queriers', value: $unique_queriers.length, inline: true)
      embed.fields = embed_fields
      embed.title = "#{$config.bot_name} Statistics"
    end
  end
end

# Set arbitrary bot status
$bot.command(:status, help_available: false) do |event, *text|
  if $admins.include?(event.user.id)
    $bot.game = text.join(' ')
    $bot.send_message(event.channel.id, "Status updated to: #{text.join(' ')}")
  end
end

# Display bot uptime
$bot.command(:uptime) do |event|
  uptime = get_uptime()
  uptime_str = "I've been online for #{uptime.days} day(s), #{uptime.hours} hour(s), #{uptime.minutes} minute(s), and #{uptime.seconds} second(s)."
  $bot.send_message(event.channel.id, uptime_str)
end
