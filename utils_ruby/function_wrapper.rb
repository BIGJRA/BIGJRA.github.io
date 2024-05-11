require_relative 'common'
require_relative 'encounter_getter'
require_relative 'shop_getter'
require_relative 'trainer_getter'

# This is the magic class of the rewrite. 
# Each function should return a string of some kind (can be multiline)
class FunctionWrapper
  attr_accessor :game
  attr_accessor :shortnames
  attr_accessor :encGetter
  attr_accessor :shopGetter
  attr_accessor :trainerGetter

  def initialize(game)
    # I need to pass in game to basically all of the potential functions, so 
    # here we stick it in as as an argument. Anything that is consistent
    # across the whole document (ie. Version) should be used here:
    @game = game

    @mapNames = get_map_names(game)

    @encHash = load_enc_hash(game)
    @itemHash = load_item_hash(game)
    @trainerHash = load_trainer_hash(game)

    @encGetter = EncounterGetter.new(game, @encHash, @mapNames)
    @shopGetter = ShopGetter.new(game, @itemHash)
    @trainerGetter = TrainerGetter.new(game, @trainerHash, @itemHash)

    @shortNames = { 
      "img" => "generate_image_markdown",
      "enc" => "generate_encounter_markdown",
      "shop" => "generate_shop_markdown",
      "fight" => "generate_trainer_markdown"
    }

  end

  def evaluate_function_from_string(s)
    '''Transforms a walkthrough function string into a function call and returns its contents.
    s is a string that should look like:
        "!functionname(arg1,arg2)" where:
        arguments are optional, functionname is short or long
    returns a string in valid markdown format corresponding to the evaluated function.
    '''
    s = s.strip[1..-2]
    func_shortname, args = s.split('(')

    # Shortnames should make things quicker while coding - full function names work too
    func = @shortNames[func_shortname] || func_shortname

    run_str = "#{func}(#{args})"
    puts "Evaluating run_str #{run_str}..."
    return eval(run_str) + "\n" # evaluates function, preserves its newline
  end

  def generate_image_markdown(filename)
    "<img class=\"tabImage\" src=\"/static/images/#{@game}/#{filename}\"/>"
  end

  def generate_encounter_markdown(map_id, enc_type_exclude_list = nil)
    return @encGetter.get_encounter_md(map_id, enc_type_exclude_list)
  end

  def generate_shop_markdown(shop_title, shop_items)
    return @shopGetter.generate_shop_markdown(shop_title, shop_items)
  end

  def generate_trainer_markdown(trainer_id)
    return @trainerGetter.generate_trainer_markdown(trainer_id)
  end

end


def main
  fw = FunctionWrapper.new('reborn')
end

main if __FILE__ == $PROGRAM_NAME