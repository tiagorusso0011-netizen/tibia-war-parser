#!/usr/bin/env ruby
require 'json'
require_relative '../lib/engine'

log_file_path = ARGV[0]

unless log_file_path && File.exist?(log_file_path)
  puts JSON.generate({ error: "Arquivo de log não encontrado no caminho: #{log_file_path}" })
  exit 1
end

begin
  parser = CombatLogParser.new
  battles = parser.parse_file(log_file_path)
  
  report = battles.map(&:generate_war_report)
  
  puts JSON.pretty_generate(report)
rescue StandardError => e
  puts JSON.generate({ error: "Erro crítico ao processar o log: #{e.message}" })
  exit 1
end