require 'yaml'
require_relative 'common'

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

def generate_encounter_table(map_id, enc_type_exclude_list = nil, to_bold = nil, **kwargs)
  version = kwargs["version"] || 'reborn'
  enc_filename = get_encounter_filename(version)
  map_encounters = get_encounters_from_file(map_id, enc_filename)
  # Add your logic here
end

def get_encounter_filename(version)
  File.join(SCRIPTS_DIR, version, 'enctext.rb')
end

def get_encounters_from_file(map_id, filename)
  # Load the Ruby hash from the file
  data = File.read(filename)
  data = data.gsub("\t", '  ')
  data = data.gsub(/ => /, ': ')

  # Parse the Ruby hash using ruamel.yaml
  yaml_data = YAML.load(data)
  puts yaml_data
end

def split_text_into_blocks(text)
  blocks = text.split(/^#[#]+\n*/)
  blocks.reject(&:empty?)
end

def get_correct_pokemon_name(string)
  ans = string.capitalize
  return CORR_MON_NAMES[ans] if CORR_MON_NAMES.key?(ans)
  ans
end

def get_data_from_block(block)
  # Add your logic here
end

def get_markdown_tables(data)
  # Add your logic here
end

def find_equalities(data)
  # Add your logic here
end

def combine_tables(mini_tables)
  # Add your logic here
end

def process_mini_tables(mini_tables)
  # Add your logic here
end

def process_encounters(data, game = "reborn")
  # Add your logic here
end

def main
  game = process_game_arg
  data = read_pbs_file("encounters", game)
  outfile = write_resource_file(process_encounters(data, game), "encounters")
  puts "Generated encounters textfile at #{outfile}."
end

main if __FILE__ == $PROGRAM_NAME
