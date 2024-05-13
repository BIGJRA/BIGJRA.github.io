require_relative 'common'

class TrainerGetter
  attr_accessor :game
  attr_accessor :trainer_hash
  attr_accessor :trainer_type_hash
  attr_accessor :item_hash
  attr_accessor :move_hash
  attr_accessor :ability_hash
  attr_accessor :pokemon_hash

  def initialize(game, trainer_hash=nil, trainer_type_hash=nil, item_hash=nil, move_hash=nil, ability_hash=nil, pokemon_hash=nil)
    @game = game
    @trainer_hash = trainer_hash ||= load_trainer_hash(@game)
    @trainer_type_hash = trainer_type_hash ||= load_trainer_type_hash(@game)
    @item_hash = item_hash ||= load_item_hash(@game)
    @move_hash = move_hash ||= load_move_hash(@game)
    @ability_hash = ability_hash ||= load_ability_hash(@game)
    @pokemon_hash = pokemon_hash ||= load_pokemon_hash(@game)
  end

  def generate_trainer_markdown(trainer_id, field=nil, second_trainer_id=nil)
    raise "Trainer ID #{trainer_id} not in Trainer Hash" if not @trainer_hash[trainer_id]
    trainer_data = @trainer_hash[trainer_id]
    second_trainer_data = second_trainer_id ? @trainer_hash[second_trainer_id] : nil

    trainer_name = "#{@trainer_type_hash[trainer_id[1]][:title]} #{trainer_id[0]}"
    second_trainer_name = second_trainer_id ? "#{@trainer_type_hash[second_trainer_id[1]][:title]} #{second_trainer_id[0]}" : nil
  
    item_symbols = Hash.new(0)
    if trainer_data[:items]
      item_symbols.merge!(trainer_data[:items].tally)
    end
  
    if second_trainer_id && second_trainer_data && second_trainer_data[:items]
      second_trainer_data[:items].tally.each do |item, count|
        item_symbols[item] += count
      end
    end
  
    # Creates nokogiri HTML
    doc = Nokogiri::HTML::Document.new
    div = doc.create_element('div', class: 'trainer_section')
    doc.add_child(div)
    
    table = doc.create_element('table')
    div.add_child(table)
  
    # Creates the header for the table
    table_header = doc.create_element('thead')    
    table_header['class'] = 'table-header'
    table_header['style'] = 'text-align: center;'
    table.add_child(table_header)
  
    # Header Row 1: Trainer Names, Field, Items
    thead_row = doc.create_element('tr')
    table_header.add_child(thead_row)
  
    th = doc.create_element('th', colspan: 3)
    thead_row.add_child(th)
  
    bold = doc.create_element('strong')
    if second_trainer_name
      bold.content = "VS: #{trainer_name} & #{second_trainer_name}"
    else
      bold.content = "VS: #{trainer_name}"
    end
    th.add_child(bold)
  
    field_div = doc.create_element('div')
    field_div.content = "Field: #{field ? field : "No Field"}"
    th.add_child(field_div)
  
    if !item_symbols.empty?
      item_str = item_symbols.map { |sym, count| "#{@item_hash[sym][:name]} #{count > 1 ? "(#{count})" : ""}" }
      items_div = doc.create_element('div')
      items_div.content = "Items: #{item_str.join(', ')}"
      th.add_child(items_div)
    end
  
    # Header Row 2: Actual table headers
    thead_row = doc.create_element('tr')
  
    ["Pokémon", "Moves", "Stat Info"].each do |col|
      thead_row.add_child(doc.create_element('th', col, style: 'text-align: center;vertical-align : middle'))
    end
    table_header.add_child(thead_row)
    
    # Trainer Mon data
    [trainer_data, second_trainer_data].compact.each do |trainer|
      trainer[:mons].each do |mon|
        content_row = doc.create_element('tr')
        table.add_child(content_row)

        form = mon[:form] ? mon[:form] : 0
        form_key = @pokemon_hash[mon[:species]].keys.find_all { |key| key.is_a?(String) }[form]
        form_data = @pokemon_hash[mon[:species]][form_key]
    
        mon_details_parts = [
          "#{mon[:gender] ? " (#{mon[:gender]})" : ""}, Lv. #{mon[:level]}",
          "#{form > 0 ? @pokemon_hash[mon[:species]].keys.find_all { |key| key.is_a?(String) }[mon[:form]]: ""}",
          "#{mon[:item] ? "@#{@item_hash[mon[:item]][:name]}" : ""}",
          "#{mon[:ability] ? "Ability: #{@ability_hash[mon[:ability]][:name]}" : ""}",
        ]

        form_1_key = @pokemon_hash[mon[:species]].keys.find_all { |key| key.is_a?(String) }[0]
        form_1_data = @pokemon_hash[mon[:species]][form_1_key]
        pokemon_name = "#{@pokemon_hash[mon[:species]][form_1_key][:name]}"

        mon_details_td = doc.create_element('td')
        mon_details_td.add_child(doc.create_element('strong', pokemon_name))
        mon_details_td.add_child(mon_details_parts.reject{ |s| s.empty? }.join("\n"))
        content_row.add_child(mon_details_td)
    
        # Create list of default moves
        if !mon[:moves]
          mon[:moves] = []
          moveset = form_data[:Moveset] ? form_data[:Moveset] : form_1_data[:Moveset]
          movelist = []
          for i in moveset
            if i[0] <= mon[:level]
              movelist.push(i[1])
            end
          end
          movelist |= [] # Remove duplicatesx
          listend = movelist.length - 4
          listend = 0 if listend < 0
          for i in listend...listend + 4
            next if i >= movelist.length
            mon[:moves].push(movelist[i])
          end
        end
      
        moves_str = "- " + mon[:moves].compact.map { |move| @move_hash[move][:name] }.join("\n- ")
        content_row.add_child(doc.create_element('td', moves_str))
    
        ev_str = mon[:ev] ? "EVs: " + mon[:ev].zip(EV_ARRAY).reject { |ev, _| ev.zero? }.map { |ev, position| "#{ev} #{position}" }.join(", ") : "EVs: all #{[85, mon[:level] * 3 / 2].min}"
        iv_str = mon[:iv] ? (mon[:iv] == 32 ? "IVs: 31 (0 Spe)" : "IVs: #{mon[:iv]}") : "IVs: 10"
        stat_details_parts = [
          mon[:nature] ? "#{mon[:nature].capitalize} Nature" : "Hardy Nature",
          ev_str,
          iv_str
        ]
        stat_details_td = doc.create_element('td', stat_details_parts.join("\n"))
        content_row.add_child(stat_details_td)
      end
    end
  
    html_output = doc.to_html 
    return html_output.gsub(/\<td\>\s*\n\s*\<strong\>/, "<td><strong>").split("\n")[1..].join("\n")
  end  
  
end

def main
  e = TrainerGetter.new('reborn')
  puts e.generate_trainer_markdown(["Cain", :Cain, 5], "Chess Board")
  puts e.generate_trainer_markdown(["Arlo", :SWIMMERBOI, 0])
  puts e.generate_trainer_markdown(["Yan", :TechNerd, 0])
  puts e.generate_trainer_markdown(["Jackson", :COOLTRAINER_Male, 0], nil, ["Mack", :StreetRat, 0])
  puts e.generate_trainer_markdown(["Aster", :AsterKnight, 0], nil, ["Eclipse", :EclipseDame, 0])
end

main if __FILE__ == $PROGRAM_NAME
