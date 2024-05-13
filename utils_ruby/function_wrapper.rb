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
    @trainerTypeHash = load_trainer_type_hash(game)
    @moveHash = load_move_hash(game)
    @abilityHash = load_ability_hash(game)
    @pokemonHash = load_pokemon_hash(game)

    @encGetter = EncounterGetter.new(game, @encHash, @mapNames)
    @shopGetter = ShopGetter.new(game, @itemHash)
    @trainerGetter = TrainerGetter.new(game, @trainerHash, @trainerTypeHash, @itemHash, @moveHash, @abilityHash, @pokemonHash)

    @shortNames = { 
      "img" => "generate_image_markdown",
      "enc" => "generate_encounter_markdown",
      "shop" => "generate_shop_markdown",
      "battle" => "generate_trainer_markdown",
      "mine" => "generate_mining_markdown",
      "wildheld" => "generate_wild_held_markdown"
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
    func_shortname, args = s.split('(', 2)

    # Shortnames should make things quicker while coding - full function names work too
    func = @shortNames[func_shortname] || func_shortname

    run_str = "#{func}(#{args})"
    return eval(run_str) + "\n" # evaluates function, preserves its newline
  end

  def generate_image_markdown(filename)
    "<img class=\"tabImage\" src=\"/static/images/#{@game}/#{filename}\"/>"
  end

  def generate_mining_markdown()
    mining_hash = load_mining_hash(@game)
    # Creates nokogiri HTML
    doc = Nokogiri::HTML::Document.new
    div = doc.create_element('div', class: 'mining_table')
    doc.add_child(div)

    table = doc.create_element('table')
    div.add_child(table)

    # Creates the header for the table
    thead = doc.create_element('thead')
    table.add_child(thead)
    
    table_header = doc.create_element('th', colspan: 2)
    thead.add_child(table_header)

    bold = doc.create_element('strong')
    bold.content = "Mining Probabilities"
    table_header.add_child(bold)
    table_header['class'] = 'table-header'
    table_header['style'] = 'text-align: center;'
    
    mining_hash.each do |prob, item_list|

      content_row = doc.create_element('tr')
      table.add_child(content_row)
      
      # Column 1: Item Name (italicized)
      item_str = item_list.map {|sym| @itemHash[sym][:name] }.join(', ')
      td_item = doc.create_element('td', style: 'text-align: center')
      td_item.add_child(doc.create_element('em', content=item_str))
      content_row.add_child(td_item)
    
      # Column 2: Probability
      td_price = doc.create_element('td', style: 'text-align: center')
      td_price.content = "#{prob}%"
      content_row.add_child(td_price)
    end

    html_output = doc.to_html 
    return html_output.split("\n")[1..].join("\n")
  end

  def generate_wild_held_markdown()
    # Create the main hash with default value as a proc
    lookup_hash = Hash.new { |hash, key| hash[key] = { "common" => [], "uncommon" => [], "rare" => [] } }
  
    @pokemonHash.each do |mon_symbol, form_hash|
      f = form_hash.reject! { |key| !key.is_a?(String) }.compact
      next if not f
  
      f.each do |form, data|
        lookup_hash[data[:WildItemCommon]]["common"] << [mon_symbol, form] if data[:WildItemCommon]
        lookup_hash[data[:WildItemUncommon]]["uncommon"] << [mon_symbol, form] if data[:WildItemUncommon]
        lookup_hash[data[:WildItemRare]]["rare"] << [mon_symbol, form] if data[:WildItemRare]
      end
    end
  
    # Creates nokogiri HTML
    doc = Nokogiri::HTML::Document.new
    div = doc.create_element('div', class: 'mining_table')
    doc.add_child(div)

    table = doc.create_element('table')
    div.add_child(table)

    # Creates the header for the table
    thead = doc.create_element('thead')
    table.add_child(thead)
    
    table_header = doc.create_element('th', colspan: 2)
    thead.add_child(table_header)

    bold = doc.create_element('strong')
    bold.content = "Wild Pokemon Held Item Chances"
    table_header.add_child(bold)
    table_header['class'] = 'table-header'
    table_header['style'] = 'text-align: center;'
    
    # Sorts items by order in item hash
    lookup_hash.map {|item, mon_hash| [item, mon_hash]}.sort_by {|a, _| @itemHash.keys.index(a)}.each do |item, mon_hash| 

      result = ''
      next if !mon_hash
      mon_hash.each do |rarity, pokemon_list|
        next if pokemon_list.empty?
    
        # Transform each Pokémon entry into the desired format
        pokemon_string = pokemon_list.map do |pokemon, form|
          form_1_key = @pokemonHash[pokemon].keys.find_all { |key| key.is_a?(String) }[0]
          form_1_data = @pokemonHash[pokemon][form_1_key]
          pokemon_name = "#{@pokemonHash[pokemon][form_1_key][:name]}"
          if form == "Alolan Form"
            "#{pokemon_name} (#{form})"
          else
            pokemon_name.to_s
          end
        end.join(", ")
    
        # Concatenate the rarity and Pokémon string
        result << "- #{rarity.capitalize} (#{{"common" => 50, "uncommon" => 5, "rare" => 1}[rarity]}%): #{pokemon_string}\n"
      end
      result = result.chomp

      content_row = doc.create_element('tr')
      table.add_child(content_row)
      
      # Column 1: Item Name (italicized)
      td_item = doc.create_element('td', style: 'text-align: center')
      td_item.add_child(doc.create_element('em', content=@itemHash[item][:name]))
      content_row.add_child(td_item)
    
      # Column 2: Mon List With Prob
      td_price = doc.create_element('td')
      td_price.content = "#{result}"
      content_row.add_child(td_price)
    end

    html_output = doc.to_html 
    return html_output.split("\n")[1..].join("\n")
    
  end
  

  def generate_encounter_markdown(map_id, enc_type_exclude_list = nil)
    return @encGetter.get_encounter_md(map_id, enc_type_exclude_list)
  end

  def generate_shop_markdown(shop_title, shop_items)
    return @shopGetter.generate_shop_markdown(shop_title, shop_items)
  end

  def generate_trainer_markdown(trainer_id, field=nil, second_trainer_id=nil )
    return @trainerGetter.generate_trainer_markdown(trainer_id, field, second_trainer_id)
  end

end


def main
  fw = FunctionWrapper.new('reborn')
  puts fw.generate_wild_held_markdown
end

main if __FILE__ == $PROGRAM_NAME