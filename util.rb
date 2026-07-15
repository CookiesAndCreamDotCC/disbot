# DisBot (util.rb) - A Discord bot
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

# Constants
SECONDS_PER_MINUTE = 60
MINUTES_PER_HOUR = 60
HOURS_PER_DAY = 24
SECONDS_PER_HOUR = SECONDS_PER_MINUTE * MINUTES_PER_HOUR
SECONDS_PER_DAY = SECONDS_PER_HOUR * HOURS_PER_DAY

# Holds uptime values
Uptime = Struct.new(
  :days,
  :hours,
  :minutes,
  :seconds,
  keyword_init: true
)

# Return uptime string
def get_uptime
  delta = Time.now.to_i - $start_time
  days = delta / SECONDS_PER_DAY
  delta %= SECONDS_PER_DAY
  hours = delta / SECONDS_PER_HOUR
  delta %= SECONDS_PER_HOUR
  minutes = delta / SECONDS_PER_MINUTE
  seconds = delta % SECONDS_PER_MINUTE

  Uptime.new(
    days: days,
    hours: hours,
    minutes: minutes,
    seconds: seconds
  )
end

# Get a random quote
def get_quote
  $quotes.sample
end

# Update statistics
def update_stats(db, type, user)
  case type
    when :mention
      $mention_queries += 1
      db.execute('UPDATE stats SET mention_queries = ? WHERE id = 1', [$mention_queries])
    when :nick
      $nick_queries += 1
      db.execute('UPDATE stats SET nick_queries = ? WHERE id = 1', [$nick_queries])
    when :slash
      $slash_queries += 1
      db.execute('UPDATE stats SET slash_queries = ? WHERE id = 1', [$slash_queries])
  end

  unless $unique_queriers.include?(user.id)
    $unique_queriers.add(user.id)
    db.execute('INSERT INTO unique_queriers (user_id, user_name, date_added) VALUES (?, ?, ?)', [user.id, user.name, Date.today.to_s])
  end
end
