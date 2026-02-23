require_relative 'ruby-engine/lib/engine'
require 'json'

def run_test
  puts "🧪 Iniciando Teste Unitário: Havera Engine..."
  
  # Simulação de um log minimalista
  log_content = [
    "00:00 New match 1 has started.",
    "00:01 Kill: Tiago killed Monique using Exori Gran",
    "00:02 Match 1 ended."
  ]
  
  # Criar arquivo temporário de teste
  File.write('unit_test_log.txt', log_content.join("\n"))
  
  # Carrega a Engine do motor Ruby
  engine = Engine.new('unit_test_log.txt')
  result = JSON.parse(engine.to_json)
  
  # Verificações de integridade
  match_data = result["match_1"]
  raise "Erro: Total de kills incorreto" unless match_data["total_kills"] == 1
  raise "Erro: MVP incorreto" unless match_data["players"]["Tiago"]["kills"] == 1
  
  puts "✅ Teste Unitário Passou: Lógica de Abates e MVP validada!"
ensure
  File.delete('unit_test_log.txt') if File.exist?('unit_test_log.txt')
end

run_test