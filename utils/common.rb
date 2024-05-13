require 'json'
require 'yaml'
require 'nokogiri'

UTILS_DIR = File.dirname(File.expand_path(__FILE__))
ROOT_DIR = File.dirname(UTILS_DIR)
CONFIG = YAML.safe_load(File.open(File.join(ROOT_DIR, "_config.yml")))

SCRIPTS_DIR = CONFIG['scripts_dir']

GAME_DIRS = {"reborn" => CONFIG['reborn_dir'], "rejuv" => CONFIG['rejuv_dir']}
SECTIONS = {"reborn" => [["main", 19], ["post", 9], ["appendices", 1]], "rejuv" => [["main", 15]]}


TYPE_IMGS = { :LandMorning => "morning", :LandDay => "day", :LandNight => "night", :OldRod => "oldrod", :GoodRod => "goodrod", :SuperRod => "superrod" }

MON_NAME_FIX_DICT = {
  "Nidoranma" => ["Nidoran M.", "Nidoran-M"],
  "Nidoranfe" => ["Nidoran F.", "Nidoran-F"],
  "Mimejr" => ["Mime Jr.", "Mime-Jr"],
  "Mrmime" => ["Mr. Mime", "Mr-Mime"],
  "Typenull" => ["Type: Null", "Type-Null"],
  "Tapukoko" => ["Tapu Koko", "Tapu-Koko"],
  "Tapubulu" => ["Tapu Bulu", "Tapu-Bulu"],
  "Tapufini" => ["Tapu Fini", "Tapu-Fini"],
  "Tapulele" => ["Tapu Lele", "Tapu-Lele"],
  "Mrrime" => ["Mr. Rime", "Mr-Rime"],
  "Hooh" => ["Ho-oh", "Ho-oh"],
  "Porygonz" => ["Porygon-Z", "Porygon-Z"],
  "Jangmoo" => ["Jangmo-o", "Jangmo-o"],
  "Hakamoo" => ["Hakamo-o", "Hakamo-o"],
  "Kommoo" => ["Kommo-o", "Kommo-o"],
  "Farfetchd" => ["Farfetch'd", "Farfetchd"],
  "Sirfetchd" => ["Sirfetch'd", "Sirfetchd"],
  "Porygon2" => ["Porygon2", "Porygon2"],
  "Flabebe" => ["Flabebe", "Flabebe"]
}


POKEMON_WIDTH = 19 # width of pokemon name column for encounter md tables
PERCENT_WIDTH = 3 # width of percent for encounter md tables. 
# (always 3 for vals <= 100)

ENC_TYPES = {
  "Land" => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
  "LandMorning" => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
  "LandDay" => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
  "LandNight" => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
  "Water" => [60, 30, 5, 4, 1],
  "RockSmash" => [60, 30, 5, 4, 1],
  "Cave" => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
  "OldRod" => [70, 30],
  "GoodRod" => [60, 20, 20],
  "SuperRod" => [40, 40, 15, 4, 1],
  "HeadbuttLow" => [30, 25, 20, 10, 5, 5, 4, 1],
  "HeadbuttHigh" => [30, 25, 20, 10, 5, 5, 4, 1]
}

ENC_NAMES = {
  "OldRod" => "Old Rod",
  "GoodRod" => "Good Rod",
  "SuperRod" => "Super Rod",
  "WaterGoodRodSuperRod" => "Water/G+S Rods",
  "Land" => "Land",
  "LandMorningLandDayLandNight" => "Land",
  "LandMorning" => "Land (Morning)",
  "LandDay" => "Land (Day)",
  "LandMorningLandDay" => "Land (Morning/Day)",
  "LandNight" => "Land (Night)",
  "Cave" => "Cave",
  "Water" => "Water",
  "RockSmash" => "Rock Smash",
  "HeadbuttLow" => "Headbutt Rare",
  "HeadbuttHigh" => "Headbutt Common",
  "HeadbuttLowHeadbuttHigh" => "Headbutt"
}

CORR_MON_NAMES = {
  "Nidoranma" => "Nidoran M.",
  "Nidoranfe" => "Nidoran F.",
  "Mimejr" => "Mime Jr.",
  "Mrmime" => "Mr. Mime",
  "Typenull" => "Type: Null",
  "Tapukoko" => "Tapu Koko",
  "Tapubulu" => "Tapu Bulu",
  "Tapufini" => "Tapu Fini",
  "Tapulele" => "Tapu Lele",
  "Mrrime" => "Mr. Rime",
  "Hooh" => "Ho-oh",
  "Porygonz" => "Porygon-Z",
  "Jangmoo" => "Jangmo-o",
  "Hakamoo" => "Hakamo-o",
  "Kommoo" => "Kommo-o",
  "Farfetchd" => "Farfetch'd",
  "Sirfetchd" => "Sirfetch'd",
  "Porygon2" => "Porygon2",
  "Flabebe" => "Flabebe"
}

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


def main
  p load_mining_hash
end

main if __FILE__ == $PROGRAM_NAME