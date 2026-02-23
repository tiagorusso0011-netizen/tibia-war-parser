require 'time'
require 'json'

class Character
  attr_reader :name, :frags, :deaths, :spells_used, :kill_timestamps

  def initialize(name)
    @name = name
    @frags = 0
    @deaths = 0
    @spells_used = Hash.new(0)
    @kill_timestamps = []
    @current_streak = 0
    @max_streak = 0
  end

  def add_frag(spell_or_rune, timestamp, victim)
    @frags += 1
    @spells_used[spell_or_rune] += 1
    @current_streak += 1
    @max_streak = @current_streak if @current_streak > @max_streak
    @kill_timestamps << timestamp
  end

  def add_death
    @deaths += 1
    @current_streak = 0
  end

  def favorite_spell
    @spells_used.max_by { |_, count| count }&.first
  end

  def achievements
    unlocked = []
    unlocked << "Survivor (0 Deaths)" if @deaths == 0 && @frags > 0
    unlocked << "Annihilator (5 Kills in 1 min)" if casted_rapid_kills?
    unlocked
  end

  private

  def casted_rapid_kills?
    @kill_timestamps.each_cons(5) do |window|
      return true if (window.last - window.first) <= 60
    end
    false
  end
end

class WarBattle
  attr_reader :id, :characters, :start_time, :end_time

  def initialize(id, start_time)
    @id = id
    @start_time = start_time
    @characters = {}
  end

  def finish_battle(time)
    @end_time = time
  end

  def register_fatality(killer_name, victim_name, damage_source, timestamp)
    victim = fetch_or_create_character(victim_name)
    victim.add_death

    if killer_name != "<WORLD>"
      killer = fetch_or_create_character(killer_name)
      killer.add_frag(damage_source, timestamp, victim)
    end
  end

  def mvp_ranking
    @characters.values.sort_by { |char| [-char.frags, char.deaths] }
  end

  def generate_war_report
    mvp = mvp_ranking.first
    
    report = {
      battle_id: @id,
      total_fatalities: @characters.values.sum(&:deaths),
      scoreboard: mvp_ranking.map do |char| 
        { 
          name: char.name, 
          frags: char.frags, 
          deaths: char.deaths, 
          highest_killstreak: char.send(:instance_variable_get, :@max_streak), 
          achievements: char.achievements 
        } 
      end
    }

    if mvp && mvp.frags > 0
      report[:mvp_stats] = {
        name: mvp.name,
        favorite_spell: mvp.favorite_spell
      }
    end

    report
  end

  private

  def fetch_or_create_character(name)
    @characters[name] ||= Character.new(name)
  end
end

class CombatLogParser
  BATTLE_START_REGEX = %r{(\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2}) - New match (\d+) has started}
  BATTLE_END_REGEX   = %r{(\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2}) - Match (\d+) has ended}
  FATALITY_REGEX     = %r{(\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2}) - (.+?) killed (.+?) (?:using|by) (.+)}

  def parse_file(file_path)
    battles = {}
    current_battle_id = nil

    File.foreach(file_path) do |line|
      line.strip!
      next if line.empty?

      if match_data = line.match(BATTLE_START_REGEX)
        time = Time.parse(match_data[1])
        current_battle_id = match_data[2]
        battles[current_battle_id] = WarBattle.new(current_battle_id, time)

      elsif match_data = line.match(BATTLE_END_REGEX)
        time = Time.parse(match_data[1])
        battles[current_battle_id].finish_battle(time)
        current_battle_id = nil

      elsif match_data = line.match(FATALITY_REGEX)
        next unless current_battle_id
        
        time = Time.parse(match_data[1])
        killer = match_data[2]
        victim = match_data[3]
        damage_source = match_data[4]

        battles[current_battle_id].register_fatality(killer, victim, damage_source, time)
      end
    end

    battles.values
  end
end