# DisBot (database.rb) - A Discord bot
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
require 'sqlite3' # for SQLite data retrieval and storage

# Open database
def open_database(results_as_hash: false)
  db = SQLite3::Database.new($config.db_name)
  db.results_as_hash = results_as_hash
  yield db
ensure
  db.close if db
end

# Initialize contributors table
def init_contributors_table(db)
  puts('Initializing contributors table...')
  begin
    db.execute <<~SQL
      CREATE TABLE IF NOT EXISTS contributors (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER UNIQUE NOT NULL,
      user_name TEXT NOT NULL,
      added_by TEXT NOT NULL,
      date_added TEXT NOT NULL
      );
    SQL
  rescue => e
    abort("Database error: #{e.message}")
  end
end

# Initialize quotes table
def init_quotes_table(db)
  puts('Initializing quotes table...')
  begin
    db.execute <<~SQL
      CREATE TABLE IF NOT EXISTS quotes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      quote TEXT UNIQUE NOT NULL,
      added_by TEXT NOT NULL,
      date_added TEXT NOT NULL
      );
    SQL
  rescue => e
    abort("Database error: #{e.message}")
  end
end

# Initialize statistics table
def init_stats_table(db)
  puts('Initializing stats table...')
  begin
    db.execute <<~SQL
      CREATE TABLE IF NOT EXISTS stats (
      id INTEGER PRIMARY KEY CHECK(id = 1),
      nick_queries INTEGER NOT NULL DEFAULT 0,
      mention_queries INTEGER NOT NULL DEFAULT 0,
      slash_queries INTEGER NOT NULL DEFAULT 0
      );
    SQL
    db.execute <<~SQL
      CREATE TABLE IF NOT EXISTS unique_queriers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      user_name TEXT NOT NULL,
      date_added TEXT NOT NULL
      );
    SQL
    db.execute <<~SQL
      INSERT OR IGNORE INTO stats (id) VALUES (1);
    SQL
  rescue => e
    abort("Database error: #{e.message}")
  end
end

# Create database
def init_database
  puts('Initializing database...')
  begin
    open_database() do |db|
      init_contributors_table(db)
      init_quotes_table(db)
      init_stats_table(db)
    end
  rescue => e
    abort("Database error: #{e.message}")
  end
end

# Load contributors
def load_contributors
  begin
    puts('Loading contributors...')
    open_database(results_as_hash: true) do |db|
      result = db.execute('SELECT * FROM contributors')
      result.each { |row| $contributors.add(row['user_id']) }
    end
    puts("#{$contributors.length} contributors loaded.")
  rescue => e
    STDERR.puts("Unable to load contributors: #{e.message}")
  end
end

# Load statistics
def load_stats
  begin
    puts('Loading stats...')
    open_database(results_as_hash: true) do |db|
      #result = db.execute "SELECT * FROM stats"
      #$nick_queries = result[0]['nick_queries']
      #$mention_queries = result[0]['mention_queries']
      #$slash_queries = result[0]['slash_queries']
      row = db.get_first_row('SELECT * FROM stats WHERE id = 1')
      $nick_queries = row['nick_queries']
      $mention_queries = row['mention_queries']
      $slash_queries = row['slash_queries']
      result = db.execute('SELECT * FROM unique_queriers')
      result.each { |row| $unique_queriers.add(row['user_id']) }
    end
  rescue => e
    STDERR.puts("Unable to load stats: #{e.message}")
  end
end

# Load quotes
def load_quotes
  begin
    puts('Loading quotes...')
    #quotes_file = File.open('quotes.txt', 'r')
    #quotes_file.each_line do |quote|
    #  $quotes << quote.chomp
    #end
    #quotes_file.close
    open_database(results_as_hash: true) do |db|
      result = db.execute('SELECT * FROM quotes')
      result.each { |row| $quotes << row['quote'] }
    end
    puts("#{$quotes.length} quotes loaded.")
  rescue => e
    STDERR.puts("Unable to load quotes: #{e.message}")
  end
end
