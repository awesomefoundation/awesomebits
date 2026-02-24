#!/usr/bin/env ruby
# frozen_string_literal: true

# Import CSV data into Parquet and DuckDB for Signal Score analysis.
#
# Prerequisites:
#   - DuckDB CLI: `brew install duckdb` or `mise install duckdb`
#   - CSV files in .scratch/data/ (see DATA SOURCES below)
#
# DATA SOURCES:
#   Historical application data is exported from the Awesome Foundation
#   production database and stored in a privileged Google Drive folder.
#   Contact @divideby0 for access.
#
#   Expected CSV files:
#     - projects.csv    (~64K rows) — all applications across all chapters
#     - chapters.csv    (~220 rows) — chapter metadata
#     - comments.csv    — trustee comments on applications
#
# Usage:
#   ruby scripts/signal-score/import_data.rb
#   ruby scripts/signal-score/import_data.rb --csv-only    # Skip DuckDB
#   ruby scripts/signal-score/import_data.rb --force        # Overwrite existing

require "fileutils"
require "open3"

DATA_DIR = File.expand_path("../../.scratch/data", __dir__)
DB_PATH = File.join(DATA_DIR, "awesomebits.duckdb")

TABLES = {
  "projects" => "projects.csv",
  "chapters" => "chapters.csv",
}.freeze

def run(cmd)
  puts "  $ #{cmd}"
  stdout, stderr, status = Open3.capture3(cmd)
  unless status.success?
    warn "ERROR: #{stderr}"
    exit 1
  end
  stdout
end

def csv_to_parquet(csv_file, parquet_file, force: false)
  if File.exist?(parquet_file) && !force
    puts "  ✓ #{File.basename(parquet_file)} exists (skip)"
    return
  end

  sql = <<~SQL
    COPY (SELECT * FROM read_csv_auto('#{csv_file}'))
    TO '#{parquet_file}' (FORMAT PARQUET);
  SQL
  run("duckdb -c \"#{sql}\"")
  puts "  ✓ #{File.basename(csv_file)} → #{File.basename(parquet_file)}"
end

def load_to_duckdb(parquet_file, table_name, force: false)
  sql = if force
    "DROP TABLE IF EXISTS #{table_name}; CREATE TABLE #{table_name} AS SELECT * FROM read_parquet('#{parquet_file}');"
  else
    "CREATE TABLE IF NOT EXISTS #{table_name} AS SELECT * FROM read_parquet('#{parquet_file}');"
  end
  run("duckdb #{DB_PATH} -c \"#{sql}\"")
  count = run("duckdb #{DB_PATH} -c \"SELECT count(*) FROM #{table_name};\"").strip.split("\n").last.strip
  puts "  ✓ #{table_name}: #{count} rows"
end

def main
  force = ARGV.include?("--force")
  csv_only = ARGV.include?("--csv-only")

  puts "Signal Score Data Import"
  puts "========================"
  puts "Data dir: #{DATA_DIR}"
  puts

  # Check for CSV files
  missing = TABLES.values.reject { |f| File.exist?(File.join(DATA_DIR, f)) }
  unless missing.empty?
    warn "Missing CSV files in #{DATA_DIR}:"
    missing.each { |f| warn "  - #{f}" }
    warn "\nCSV data must be downloaded from the privileged Google Drive folder."
    warn "Contact @divideby0 for access."
    exit 1
  end

  # CSV → Parquet
  puts "Converting CSV → Parquet..."
  TABLES.each do |table, csv|
    csv_path = File.join(DATA_DIR, csv)
    parquet_path = File.join(DATA_DIR, "#{table}.parquet")
    csv_to_parquet(csv_path, parquet_path, force: force)
  end
  puts

  return if csv_only

  # Parquet → DuckDB
  puts "Loading into DuckDB (#{DB_PATH})..."
  TABLES.each do |table, _|
    parquet_path = File.join(DATA_DIR, "#{table}.parquet")
    load_to_duckdb(parquet_path, table, force: force)
  end

  # Also load any additional parquet files
  %w[chicago_validation sample_100].each do |extra|
    parquet = File.join(DATA_DIR, "#{extra}.parquet")
    next unless File.exist?(parquet)
    load_to_duckdb(parquet, extra, force: force)
  end

  puts
  puts "Done. Query with: duckdb #{DB_PATH}"
end

main
