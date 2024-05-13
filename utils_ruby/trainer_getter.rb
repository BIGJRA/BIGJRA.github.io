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

  def generate_trainer_markdown(trainer_id, field=nil)

    raise "Trainer ID #{trainer_id} not in Trainer Hash" if not @trainer_hash[trainer_id]
    trainer_data = @trainer_hash[trainer_id]

    trainer_name = "#{@trainer_type_hash[trainer_id[1]][:title]} #{trainer_id[0]}"

    if trainer_data[:items]
      item_symbols = trainer_data[:items].tally
      item_str = item_symbols.map { |sym, count| "#{@item_hash[sym][:name]} #{count > 1 ? "(#{count})" : ""}" }.join(', ')
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

    # Header Row 1: Trainer Name, Field, Items
    thead_row = doc.create_element('tr')
    table_header.add_child(thead_row)

    th = doc.create_element('th', colspan: 3)
    thead_row.add_child(th)

    bold = doc.create_element('strong')
    bold.content = "VS: #{trainer_name}"
    th.add_child(bold)

    field_div = doc.create_element('div')
    field_div.content = "Field: #{field ? field : "No Field"}"
    th.add_child(field_div)

    if trainer_data[:items]
      items_div = doc.create_element('div')
      items_div.content = "Items: #{item_str}"
      th.add_child(items_div)
    end

    # Header Row 2: Actual table headers
    thead_row = doc.create_element('tr')

    ["Pokémon", "Moves", "Stat Info"].each do |col|
      thead_row.add_child(doc.create_element('th', col, style: 'text-align: center;vertical-align : middle'))
    end
    table_header.add_child(thead_row)
    
    # Trainer Mon data
    trainer_data[:mons].each do |mon|
      content_row = doc.create_element('tr')
      table.add_child(content_row)

      mon_details_parts = [
        "#{mon[:gender] ? " (#{mon[:gender]})" : " "}",
        "#{mon[:form] ? @pokemon_hash[mon[:species]].keys.find_all { |key| key.is_a?(String) }[mon[:form]]: ""}",
        "Lv. #{mon[:level]}",
        "#{mon[:item] ? "@#{@item_hash[mon[:item]][:name]}" : ""}",
        "#{mon[:ability] ? "Ability: #{@ability_hash[mon[:ability]][:name]}" : ""}",
      ]

      pokemon_form_1_key = @pokemon_hash[mon[:species]].keys.find_all { |key| key.is_a?(String) }[0]
      pokemon_name = "#{@pokemon_hash[mon[:species]][pokemon_form_1_key][:name]}"

      mon_details_td = doc.create_element('td')
      mon_details_td.add_child(doc.create_element('strong', pokemon_name))
      mon_details_td.add_child(mon_details_parts.reject{ |s| s.empty? }.join("\n"))
      content_row.add_child(mon_details_td)

      if mon[:moves]
        content_row.add_child(doc.create_element('td', "- " + mon[:moves].compact.map { |move| @move_hash[move][:name] }.join("\n- ")))
      else
        content_row.add_child(doc.create_element('td', "Default level up moves"))
      end

      if mon[:ev]
        ev_str = "EVs: " + mon[:ev].zip(EV_ARRAY).reject {|ev, _|ev.zero? }.map { |ev, position| "#{ev} #{position}" }.join(", ")
      end

      if mon[:iv]
        if mon[:iv] == 32
          iv_str = "IVs: 31 (0 Spe)"
        else
          iv_str = "IVs: #{mon[:iv]}"
        end
      end

      stat_details_parts = [
        mon[:nature] ? "#{mon[:nature].capitalize} Nature" : "Hardy Nature",
        mon[:ev] ? ev_str : "EVs: all #{[85, mon[:level] * 3 / 2].min}",
        mon[:iv] ? iv_str : "IVs: 10"
      ]

      stat_details_td = doc.create_element('td', stat_details_parts.reject{ |s| s.empty? }.join("\n"))
      content_row.add_child(stat_details_td)
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
  
end

main if __FILE__ == $PROGRAM_NAME
