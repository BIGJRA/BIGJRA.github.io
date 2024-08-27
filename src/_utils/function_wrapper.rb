require_relative 'common'
require_relative 'encounter_getter'
require_relative 'shop_getter'
require_relative 'trainer_getter'

# This is the magic class of the rewrite.
# Each function should return a string of some kind (can be multiline)
class FunctionWrapper
  attr_accessor :game, :shortnames, :encGetter, :shopGetter, :trainerGetter

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
    @typeHash = load_type_hash(game)
    @moveHash = load_move_hash(game)
    @abilityHash = load_ability_hash(game)
    @pokemonHash = load_pokemon_hash(game)
    @encMapWrapper = EncounterMapWrapper.new(game)

    @encGetter = EncounterGetter.new(game, @encHash, @mapNames, @encMapWrapper, @pokemonHash)
    @shopGetter = ShopGetter.new(game, @itemHash)
    @trainerGetter = TrainerGetter.new(game, @trainerHash, @trainerTypeHash, @itemHash, @moveHash, @abilityHash,
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
      'partner' => 'generate_partner_markdown'
    }
  end

  def evaluate_function_from_string(s)
    s = s.strip[1..-2]
    func_shortname, args = s.split('(', 2)

    # Shortnames should make things quicker while coding - full function names work too
    func = @shortNames[func_shortname] || func_shortname

    run_str = "#{func}(#{args})"
    # puts run_str
    eval(run_str) + "\n" # evaluates function, preserves its newline
  end

  def generate_image_markdown(filename)
    "<img class=\"tabImage\" src=\"/assets/images/#{@game}/#{filename}\"/>"
  end

  def generate_mining_markdown
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

  def generate_encounter_markdown(map_id, include_list = nil, rods = nil, custom_map_name = nil)
    @encGetter.get_encounter_md(map_id, include_list, rods, custom_map_name)
  end

  def generate_shop_markdown(shop_title, shop_items)
    @shopGetter.generate_shop_markdown(shop_title, shop_items)
  end

  def generate_trainer_markdown(trainer_id, field = nil)
    @trainerGetter.generate_trainer_markdown(trainer_id, field)
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
    @trainerGetter.generate_trainer_markdown(trainer_id, field = field_text, nil, false, name_ext = team_name)
  end

  def generate_double_markdown(trainer_id1, trainer_id2, field = nil)
    @trainerGetter.generate_trainer_markdown(trainer_id1, field, trainer_id2)
  end

  def generate_partner_markdown(trainer_id)
    @trainerGetter.generate_trainer_markdown(trainer_id, nil, nil, true)
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
end

def main
  fw = FunctionWrapper.new('reborn')
  # puts fw.generate_wild_held_markdown
end

main if __FILE__ == $PROGRAM_NAME
