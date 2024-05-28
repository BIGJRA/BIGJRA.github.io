require 'json'
require 'yaml'
require 'nokogiri'

UTILS_DIR = File.dirname(File.expand_path(__FILE__))
ROOT_DIR = File.dirname(UTILS_DIR)
CONFIG = YAML.safe_load(File.open(File.join(ROOT_DIR, "_config.yml")))

SCRIPTS_DIR = CONFIG['scripts_dir']

SECTIONS = {"reborn" => [["main", 19], ["post", 9], ["appendices", 1]], "rejuv" => [["main", 15]]}

TYPE_IMGS = {:LandMorning => "morning", :LandDay => "day", :LandNight => "night", :OldRod => "oldrod", :GoodRod => "goodrod", :SuperRod => "superrod" }

EV_ARRAY = ["HP", "Atk", "Def", "SpA", "SpD", "Spe"]


def get_game_contents_dir(game)
  File.join(ROOT_DIR, "raw", game)
end

def load_chapter_md(game, type, chapter_num)
  game_contents_dir = get_game_contents_dir(game)
  if type != 'appendices'
    file_path = File.join(game_contents_dir, "#{type}_ep_#{chapter_num.to_s.rjust(2, '0')}.md")
  else
    file_path = File.join(game_contents_dir, 'appendices.md')
  end
  File.read(file_path)
end

def set_to_range_string(integers_set)
  ranges = []

  integers_set.sort.each do |num|
    if ranges.empty? || ranges.last.last != num - 1
      ranges << [num]
    else
      ranges.last << num
    end
  end

  ranges.map { |range| range.size > 1 ? "#{range.first}-#{range.last}" : range.first.to_s }.join(', ')
end

def load_item_hash(game)
  data = File.read(File.join(SCRIPTS_DIR, game, 'itemtext.rb'))
  eval(data)
end

def load_enc_hash(game)
  data = File.read(File.join(SCRIPTS_DIR, game, 'enctext.rb'))
  eval(data)
end

def load_trainer_hash(game)
  data = File.read(File.join(SCRIPTS_DIR, game, 'trainertext.rb'))
  base_hash = eval(data)
  ret = {}
  base_hash.each do |trainer_hash|
    ret[trainer_hash[:teamid]] = trainer_hash
  end
  ret
end

def load_trainer_type_hash(game)
  data = File.read(File.join(SCRIPTS_DIR, game, 'ttypetext.rb'))
  eval(data)
end

def load_ability_hash(game)
  data = File.read(File.join(SCRIPTS_DIR, game, 'abiltext.rb'))
  eval(data)
end

def load_move_hash(game)
  data = File.read(File.join(SCRIPTS_DIR, game, 'movetext.rb'))
  eval(data)
end

def load_pokemon_hash(game)
  data = File.read(File.join(SCRIPTS_DIR, game, 'montext.rb'))
  eval(data)
end

def load_mining_hash(game=nil)
  if game && game.capitalize == "Rejuv"
    lines = File.read(File.join(SCRIPTS_DIR, game, 'RejuvCustomScripts.rb'))
  else
    lines = File.read(File.join(SCRIPTS_DIR, 'MinigameMining.rb'))
  end

  item_hash = Hash.new(0)

  lines.each_line do |line|
    next if !line.match(/\[:\w+,\s*\d+,\s*\d+,\s*\d+,\s*\d+,\s*\d+,\s*\[[01\s,]+\]/)

    item_symbol = line.match(/(\w+)/)[1].to_sym
    probability = line.match(/(\d+)/)[0].to_i

    item_hash[item_symbol] += probability
  end

  total_prob = item_hash.values.sum.to_f
  item_hash.transform_values! { |prob| (prob / total_prob * 100).round(2) }

  grouped_hash = item_hash.map { |sym, prob| [sym, prob] }.group_by(&:last).transform_values { |elements| elements.map(&:first) }

  return grouped_hash.map { |prob, l| [prob, l] }.sort_by { |a| a[0].to_f }.reverse
end

def get_map_names(game)
  ret = {}
  data = File.read(File.join(SCRIPTS_DIR, game, 'metatext.rb'))
  lines = data.split("\n")

  lines.each_with_index do |line, index|
    match = line.match(/^\s*(\d{1,3})\s*=>\s*{/)
    if match
      key = match[1].to_i
      comment_line = lines[index - 1]
      name = comment_line.match(/#(.+)/)[1].strip
      ret[key] = name
    end
  end
  ret
end

class EncounterMapWrapper
  def initialize(game)
    @data = {}
    parse_file(game)
    case game
    when "reborn" then @encounterMaps = {
      :RATTATA    => {1 => "Rattata"},
      :RATICATE   => {1 => "Rattata"},
      :SANDSHREW  => {1 => "Sandshrew"},
      :SANDSLASH  => {1 => "Sandshrew"},
      :VULPIX     => {1 => "Vulpix"},
      :NINETALES  => {1 => "Vulpix"},
      :DIGLETT    => {1 => "Diglett"},
      :DUGTRIO    => {1 => "Diglett"},
      :MEOWTH     => {1 => "Rattata"},
      :PERSIAN    => {1 => "Rattata"},
      :GEODUDE    => {1 => "Geodude"},
      :GRAVELER   => {1 => "Geodude"},
      :GOLEM      => {1 => "Geodude"},
      :GRIMER     => {1 => "Grimer"},
      :MUK        => {1 => "Grimer"},
      :MAROWAK    => {1 => "Cubone"},
    }
    when "rejuv" then {}
    end
    
  end

  def get_enc_maps(pokemon_symbol)
    form_data = @encounterMaps[pokemon_symbol]
    return {} unless form_data
    
    form_number = form_data.keys.first
    mon_name = form_data.values.first
    result = {}
    @data[mon_name].each { |num| result[num] = form_number }
    result
  end
  
  
  private

  def parse_file(game)
    file_contents = File.read(File.join(SCRIPTS_DIR, game, 'SystemConstants.rb'))
    relevant_contents = file_contents.scan(/# Evos first(.*?)# \* Constants for maps to reflect sprites on/m)
  
    relevant_contents[0][0].scan(/(\w+)\s*=\s*\[([0-9\s,]*)\]/) do |pokemon_name, pokemon_numbers|
      process_assignment(pokemon_name.strip, pokemon_numbers)
    end
  end
  
  def process_assignment(pokemon_name, pokemon_numbers)
    numbers_array = pokemon_numbers.split(',').map(&:strip).map(&:to_i)
    @data[pokemon_name] = numbers_array
  end
  
  def parse_map_numbers(pokemon_numbers)
    pokemon_numbers.scan(/\d+/).map(&:to_i)
  end
end

def main
  wrapper = EncounterMapWrapper.new('reborn')
  p wrapper.get_enc_maps(:MAROWAK)
  p wrapper.get_enc_maps(:Grimer)
  p wrapper.get_enc_maps(:Meowth)
  p wrapper.get_enc_maps(:CRABOMINABLE)
end

main if __FILE__ == $PROGRAM_NAME