require_relative 'common'

class EncounterGetter
  attr_accessor :version
  attr_accessor :enchash

  def initialize(version)
    @version = version
    @enchash = load_enchash(version)
  end

  def get_encounter_md(map_id, enc_type_exclude_list = nil, to_bold = nil)
    enc_type_exclude_list ||= []
    to_bold ||= []

    obj = get_map_object(map_id)
    return obj.to_s # TODO
  end

  private

  def get_map_object(map_id)
    return @enchash[map_id]
  end

  def load_enchash(version)
    filename = get_encounter_filename(version)
    data = File.read(filename)
    eval(data)
  end

  def get_encounter_filename(version)
    File.join(SCRIPTS_DIR, version, 'enctext.rb')
  end
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

# main if __FILE__ == $PROGRAM_NAME
