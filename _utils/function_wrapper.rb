require_relative 'common'
require_relative 'encounter_getter'
require_relative 'shop_getter'
require_relative 'trainer_getter'

# This is the magic class of the rewrite.
# Each function should return a string of some kind (can be multiline)
class FunctionWrapper

  def initialize(game, scripts_dir)
    # I need to pass in game to basically all of the potential functions, so
    # here we stick it in as as an argument. Anything that is consistent
    # across the whole document (ie. Version) should be used here:
    @game = game
    @scriptsDir = scripts_dir

    @mapHash = load_maps_hash(game, @scriptsDir)
    @encHash = load_enc_hash(game, @scriptsDir)
    @itemHash = load_item_hash(game, @scriptsDir)
    @trainerHash = load_trainer_hash(game, @scriptsDir)
    @bossHash = load_boss_hash(game, @scriptsDir)
    @trainerTypeHash = load_trainer_type_hash(game, @scriptsDir)
    @typeHash = load_type_hash(game, @scriptsDir)
    @moveHash = load_move_hash(game, @scriptsDir)
    @abilityHash = load_ability_hash(game, @scriptsDir)
    @pokemonHash = load_pokemon_hash(game, @scriptsDir)
    @raidDenHash = load_raid_den_hash(game, @scriptsDir)
    @encMapWrapper = EncounterMapWrapper.new(game, @scriptsDir)

    @encGetter = EncounterGetter.new(game, @scriptsDir, @encHash, @mapHash, @encMapWrapper, @pokemonHash)
    @shopGetter = ShopGetter.new(game, @scriptsDir, @itemHash)
    @trainerGetter = TrainerGetter.new(game, @scriptsDir, @trainerHash, @bossHash, @trainerTypeHash, @itemHash, @moveHash, @abilityHash,
                                       @pokemonHash, @typeHash)

    @shortNames = {
      'img' => 'generate_image_markdown',
      'enc' => 'generate_encounter_markdown',
      'shop' => 'generate_shop_markdown',
      'battle' => 'generate_trainer_markdown',
      'btsinglesboss' => 'generate_battle_tower_singles_bosses_markdown',
      'btdoublesboss' => 'generate_battle_tower_doubles_bosses_markdown',
      'ttbattles' => 'generate_theme_teams_markdown',
      'dbattle' => 'generate_double_markdown',
      'mine' => 'generate_mining_markdown',
      'wildheld' => 'generate_wild_held_markdown',
      'tutor' => 'generate_tutor_markdown',
      'partner' => 'generate_partner_markdown',
      'newself' => 'generate_newself_markdown',
      'pickup' => 'generate_pickup_markdown',
      'boss' => 'generate_boss_markdown',
      'move' => 'generate_move_markdown',
      'raid' => 'generate_raid_den_markdown'
    }
  end

  def evaluate_function_from_string(s)
    s = s.strip[1..-2]
    func_shortname, args = s.split('(', 2)
    raise "#{func_shortname} not found in list of shortnames." unless @shortNames[func_shortname]
      
    func = @shortNames[func_shortname]
    run_str = "#{func}(#{args})"
    # puts run_str
    eval(run_str) + "\n" # evaluates function, preserves its newline
  end

  def generate_image_markdown(filename)
    "<img class=\"tabImage\" src=\"/assets/images/#{@game}/#{filename}\"/>"
  end

  def generate_mining_markdown
    mining_hash = load_mining_hash(@game, @scriptsDir)
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
    bold.content = 'Mining Probabilities'
    table_header.add_child(bold)
    table_header['class'] = 'table-header'
    table_header['style'] = 'text-align: center;'

    mining_hash.each do |prob, item_list|
      content_row = doc.create_element('tr')
      table.add_child(content_row)

      # Column 1: Item Name (italicized)
      item_str = item_list.map { |sym| @itemHash[sym][:name] }.join(', ')
      td_item = doc.create_element('td', style: 'text-align: center')
      td_item.add_child(doc.create_element('em', content = item_str))
      content_row.add_child(td_item)

      # Column 2: Probability
      td_price = doc.create_element('td', style: 'text-align: center')
      td_price.content = "#{prob}%"
      content_row.add_child(td_price)
    end

    html_output = doc.to_html
    html_output.split("\n")[1..].join("\n")
  end

  def generate_wild_held_markdown
    # Create the main hash with default value as a proc
    lookup_hash = Hash.new { |hash, key| hash[key] = { 'common' => [], 'uncommon' => [], 'rare' => [] } }

    @pokemonHash.each do |mon_symbol, form_hash|
      f = form_hash.reject! { |key| !key.is_a?(String) }.compact
      next unless f

      f.each do |form, data|
        lookup_hash[data[:WildItemCommon]]['common'] << [mon_symbol, form] if data[:WildItemCommon]
        lookup_hash[data[:WildItemUncommon]]['uncommon'] << [mon_symbol, form] if data[:WildItemUncommon]
        lookup_hash[data[:WildItemRare]]['rare'] << [mon_symbol, form] if data[:WildItemRare]
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
    bold.content = 'Wild Pokemon Held Item Chances'
    table_header.add_child(bold)
    table_header['class'] = 'table-header'
    table_header['style'] = 'text-align: center;'

    # Hardcode deletes from Lookup Hash due to in progress development

    lookup_hash.delete(:LEADERSCREST)
    lookup_hash.delete(:BOOSTERENERGY)
    
    # Sorts items by order in item hash

    lookup_hash.map do |item, mon_hash|
      [item, mon_hash]
    end.sort_by { |a, _| @itemHash.keys.index(a) }.each do |item, mon_hash|
      result = ''
      next unless mon_hash

      mon_hash.each do |rarity, pokemon_list|
        next if pokemon_list.empty?

        # Transform each Pokemon entry into the desired format
        pokemon_string = pokemon_list.map do |pokemon, form|
          form_1_key = @pokemonHash[pokemon].keys.find_all { |key| key.is_a?(String) }[0]
          form_1_data = @pokemonHash[pokemon][form_1_key]
          pokemon_name = "#{@pokemonHash[pokemon][form_1_key][:name]}"
          if form == 'Alolan Form'
            "#{pokemon_name} (#{form})"
          else
            pokemon_name.to_s
          end
        end.join(', ')

        # Concatenate the rarity and Pokemon string
        result << "- #{rarity.capitalize} (#{{ 'common' => 50, 'uncommon' => 5,
                                               'rare' => 1 }[rarity]}%): #{pokemon_string}\n"
      end
      result = result.chomp

      content_row = doc.create_element('tr')
      table.add_child(content_row)

      # Column 1: Item Name (italicized)
      td_item = doc.create_element('td', style: 'text-align: center')
      td_item.add_child(doc.create_element('em', content = @itemHash[item][:name]))
      content_row.add_child(td_item)

      # Column 2: Mon List With Prob
      td_price = doc.create_element('td')
      td_price.content = "#{result}"
      content_row.add_child(td_price)
    end

    html_output = doc.to_html
    html_output.split("\n")[1..].join("\n")
  end

  def generate_pickup_markdown
    pickup_data = load_pickup_data(@game, @scriptsDir)
  
    doc = Nokogiri::HTML::Document.new
    div = doc.create_element('div', class: 'pickup_table')
    doc.add_child(div)
  
    table = doc.create_element('table', id: 'pickup-table')
    div.add_child(table)
  
    # Create the header for the table
    thead = doc.create_element('thead')
    table.add_child(thead)
  
    header_row = doc.create_element('tr', class: 'header')
    thead.add_child(header_row)
  
    # Single header for Pickup Odds
    table_header = doc.create_element('th', colspan: 2)
    table_header.add_child(doc.create_element('strong', 'Pickup Odds'))
    table_header['class'] = 'table-header'
    table_header['style'] = 'text-align: center;'
    header_row.add_child(table_header)
  
    tbody = doc.create_element('tbody')
    table.add_child(tbody)
  
    # Sort entries by the order in item hash
    sorted_pickup_data = pickup_data.sort_by { |item, _| @itemHash.keys.index(item) }
  
    # Iterate over each item in the sorted pickup data
    sorted_pickup_data.each do |item, odds_hash|
      content_row = doc.create_element('tr')
      tbody.add_child(content_row)
  
      # Column 1: Item Name (italicized)
      td_item = doc.create_element('td', style: 'text-align: center')
      td_item.add_child(doc.create_element('em', @itemHash[item][:name]))
      content_row.add_child(td_item)
  
      # Column 2: Odds and Level Ranges
      odds_string = odds_hash.map do |odds, range|
        "- #{odds}%: Lv. #{range[0]}-#{range[1]}"
      end.join("\n")
  
      td_odds = doc.create_element('td')
      td_odds.content = odds_string
      content_row.add_child(td_odds)
    end
  
    html_output = doc.to_html
    html_output.split("\n")[1..].join("\n")  # Format output similar to your example
  end
  
  def generate_encounter_markdown(map_id, include_list = nil, rods = nil, custom_map_name = nil)
    @encGetter.get_encounter_md(map_id, include_list, rods, custom_map_name)
  end

  def generate_shop_markdown(shop_title, shop_items)
    @shopGetter.generate_shop_markdown(shop_title, shop_items)
  end

  def generate_move_markdown(move_name)
    # Creates nokogiri HTML
    m = @moveHash[move_name.to_sym]
    "#{m[:name]}: #{m[:type].to_s.capitalize} \\| #{m[:category].to_s.capitalize} \\| #{m[:basedamage]} Pwr \\| #{m[:accuracy]}% Acc \\| #{m[:desc]}"
  end

  def generate_trainer_markdown(trainer_id, field = nil)
    @trainerGetter.generate_trainer_markdown(trainer_id, field)
  end

  def generate_boss_markdown(boss_name, field = nil)
    @trainerGetter.generate_trainer_markdown(boss_name.to_sym, field)
  end

  def generate_battle_tower_singles_bosses_markdown
    return_array = []
    teams = { 'reborn' => REBORN_BT_SINGLES }[@game]
    teams.each do |team|
      field_name = FIELDS[team[3]]
      return_array.push(generate_trainer_markdown([team[1], team[0], team[2]], field_name))
    end
    return_array.join("\n\n")
  end

  def generate_battle_tower_doubles_bosses_markdown
    return_array = []
    teams = { 'reborn' => REBORN_BT_DOUBLES }[@game]
    teams.each do |team|
      field_name = FIELDS[team[3]]
      return_array.push(generate_trainer_markdown([team[1], team[0], team[2]], field_name))
    end
    return_array.join("\n\n")
  end

  def generate_theme_teams_markdown
    return_array = []
    teams = { 'reborn' => REBORN_THEME_TEAMS }[@game]
    teams.each do |team|
      fight, data = @trainerHash.find { |fight, _data| fight[0] == team[:trainer] && fight[2] == team[:teamnumber] }
      field_name = FIELDS[team[:field]]
      return_array.push(generate_bp_trainer_markdown(fight, field_name, team_name = "(#{team[:name]})"))
    end

    return_array.join("\n\n")
  end

  def generate_bp_trainer_markdown(trainer_id, field_text = 'Random Field', team_name = '')
    @trainerGetter.generate_trainer_markdown(trainer_id, field = field_text, nil, 0, name_ext = team_name)
  end

  def generate_double_markdown(trainer_id1, trainer_id2, field = nil)
    @trainerGetter.generate_trainer_markdown(trainer_id1, field, trainer_id2)
  end

  def generate_partner_markdown(trainer_id)
    @trainerGetter.generate_trainer_markdown(trainer_id, nil, nil, 1)
  end

  def generate_newself_markdown(trainer_id, new_title)
    @trainerGetter.generate_trainer_markdown(trainer_id, nil, nil, 2, new_title)
  end

  def generate_tutor_markdown(tutor_title, moves)
    # Creates nokogiri HTML
    doc = Nokogiri::HTML::Document.new
    div = doc.create_element('div', class: 'tutor_table')
    doc.add_child(div)

    table = doc.create_element('table')
    div.add_child(table)

    # Creates the header for the table
    thead = doc.create_element('thead')
    table.add_child(thead)

    table_header = doc.create_element('th', colspan: 2)
    thead.add_child(table_header)

    bold = doc.create_element('strong')
    bold.content = tutor_title
    table_header.add_child(bold)
    table_header['class'] = 'table-header'
    table_header['style'] = 'text-align: center;'

    moves.each do |move, price|
      content_row = doc.create_element('tr')
      table.add_child(content_row)

      # Column 1: Move Name (bolded)
      td_move = doc.create_element('td', style: 'text-align: center')
      td_move.add_child(doc.create_element('strong', content = move))
      content_row.add_child(td_move)

      # Column 2: Price
      price = "$#{price}" if price.is_a?(Integer)
      td_price = doc.create_element('td', style: 'text-align: center')
      td_price.content = price
      content_row.add_child(td_price)
    end

    html_output = doc.to_html
    html_output.split("\n")[1..].join("\n")
  end

  def generate_raid_den_markdown(den_num, num_badges)
    res = []

    [:common, :rare].each do |rarity|

      # Create a Nokogiri document
      doc = Nokogiri::HTML::Document.new
      div = doc.create_element('div', class: 'den_table')
      doc.add_child(div)
    
      table = doc.create_element('table')
      div.add_child(table)
    
      # Create the header for the table
      thead = doc.create_element('thead')
      table.add_child(thead)
    
      table_header = doc.create_element('th', colspan: 4)
      thead.add_child(table_header)

      # Header Row 2: Actual table headers
      thead_row = doc.create_element('tr')

      # Add table headers for Pokemon, Shadow Moves, Stat Details, and %
      ['Pokemon', 'Shadow Moves', 'Stat Details', 'Rate'].each do |col|
        th = doc.create_element('th', col)
        th['style'] = 'text-align: center; vertical-align: middle;'
        thead_row.add_child(th)
      end

      thead.add_child(thead_row)  # Add the header row to thead
    
      bold = doc.create_element('strong')
      bold.content = "Encounters: Den \##{den_num} (#{num_badges} Badges): #{rarity.to_s.capitalize}"
      table_header.add_child(bold)
      table_header['class'] = 'table-header'
      table_header['style'] = 'text-align: center;'
    
      # Create the body of the table
      tbody = doc.create_element('tbody')
      table.add_child(tbody)
    
      # Add encounters for common and rare
      @raidDenHash["Den#{den_num}"][rarity][num_badges].each do |mon, atts|
        content_row = doc.create_element('tr')
        tbody.add_child(content_row)
        base_form = @pokemonHash[mon].keys.find_all { |key| key.is_a?(String) }[0]
        pokemon_name_formatted = @pokemonHash[mon][base_form][:name]

        if atts[:Form] != 0
          form_key = @pokemonHash[mon].keys.find_all { |key| key.is_a?(String) }[atts[:Form]]
          pokemon_name_formatted += " (#{form_key})".sub(' Form', '')
        end
        pokemon_name_formatted = "Shadow #{pokemon_name_formatted}"

        # Column 1: Pokémon Name & Details
        td_pokemon = doc.create_element('td')
        td_pokemon.add_child(doc.create_element('strong', pokemon_name_formatted))
        mon_details_parts = [", Lv. #{atts[:level]}"]
        if atts[:Ability] 
          mon_details_parts.push("Ability: #{atts[:Ability]}")
        end
        if atts[:ShinyChance] > 0 
          mon_details_parts.push("Shiny Chance Increase: #{atts[:ShinyChance] * 100}%")
        end
        td_pokemon.add_child(mon_details_parts.reject { |s| s.empty? }.join("\n"))
        content_row.add_child(td_pokemon)

        # Column 2: Movesets
        moves_edited = []
        atts[:Moves].each do |move|
          next if move == nil
          name = @moveHash[move][:name]
          moves_edited.push(name)
        end
        final = "- " + moves_edited.join("\n- ")
        content_row.add_child(doc.create_element('td', final))

        # Column 3: Stat Attributes (e.g., Form, ShinyChance)
        td_attributes = doc.create_element('td')
        stat_details_parts = []
        if atts[:IVs] 
          stat_details_parts.push(get_iv_str(atts[:IVs]))
        end
        if atts[:EVs]
          stat_details_parts.push(get_ev_str(atts[:EVs]))
        end
        td_attributes.add_child(stat_details_parts.reject { |s| s.empty? }.join("\n"))
        content_row.add_child(td_attributes)
        
        # Column 4: Odds
        td_odds = doc.create_element('td')
        td_odds.add_child(sprintf('%.2f', atts[:odds]) + "%")
        content_row.add_child(td_odds)
      end
    
      # Convert to HTML and format
      html_output = doc.to_html
      res.push(html_output.split("\n")[1..].join("\n"))
    end
    res.join("\n\n")
  end
end

def main
  fw = FunctionWrapper.new('reborn')
  # puts fw.generate_wild_held_markdown
end

main if __FILE__ == $PROGRAM_NAME
