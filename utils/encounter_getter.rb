require_relative 'common'

class EncounterGetter
  attr_accessor :game
  attr_accessor :enc_hash
  attr_accessor :map_names

  def initialize(game, enc_hash=nil, map_names=nil, enc_map_wrapper=nil, mon_hash=nil)
    @game = game
    @encHash = enc_hash ||= load_enc_hash(game)
    @mapNames = map_names ||= get_map_names(game)
    @encMapWrapper = enc_map_wrapper ||= EncounterMapWrapper.new(game)
    @monHash = mon_hash ||= load_pokemon_hash(game)
  end

  def get_encounter_md(map_id, include_list = nil, rods=nil, custom_map_name=nil)
    include_list ||= []
    rods ||= ["Old", "Good", "Super"]

    data = @encHash[map_id]
    map_name = @mapNames[map_id]

    enc_groups = {
      "Grass": [:LandMorning, :LandDay, :LandNight],
      "Land": [:Land],
      "Headbutt": [:Headbutt],
      "Fishing": [:OldRod, :GoodRod, :SuperRod],
      "Surfing": [:Water],
      "Cave": [:Cave],
      "Rock Smash": [:RockSmash]
    }

    # Creates nokogiri HTML
    doc = Nokogiri::HTML::Document.new
    div = doc.create_element('div', class: 'encounter_section')
    doc.add_child(div)

    found_group = false

    table = doc.create_element('table')
    div.add_child(table)

    enc_groups.each do |group, types|
      next unless types.any? { |type| data.key?(type) }
      next if !include_list.empty? && !include_list.include?(group.to_s)
      if group == :Fishing
        new_types = rods.map { |rod| "#{rod}Rod".to_sym if ["Old", "Good", "Super"].include?(rod) }.compact
        types = new_types unless new_types.empty?
      end

      found_group = true

      # I group Land M/D/N together, and also fishing rods. This num_cols thus keeps the number of columns 
      # in the ultimate table together.
      num_cols = types.length + 2

      # Creates a hash where mons will note every possible level, and rates per encounter type
      mons = Hash.new { |hash, key| hash[key] = { "levels" => Set.new }.merge(types.map { |type| [type, 0] }.to_h) }
      
      types.each do |type|
        next if !data[type]
        data[type].each do |mon, arr|
          arr.each do |chance, min_value, max_value|
            mons[mon][type] += chance
            (min_value..max_value).each { |num| mons[mon]["levels"].add(num) }
          end
        end
      end
      
      mons.dup.each do |pokemon, data|
        mons[pokemon]["levels"] = set_to_range_string(mons[pokemon]["levels"])
      end

      # Creates the header for the table
      thead = doc.create_element('thead')
      
      # Adds first row of header: encounter type
      thead_row = doc.create_element('tr')
      
      th = doc.create_element('th', colspan: num_cols)
      bold = doc.create_element('strong')
      bold.content = "#{custom_map_name ? custom_map_name : map_name} Encounters: #{group}"
      th.add_child(bold)
      th['class'] = 'table-header'
      th['style'] = 'text-align: center;'
      
      thead_row.add_child(th)
      thead.add_child(thead_row)
      
      # Adds second row of header: column names
      thead_row = doc.create_element('tr')
      
      th_pokemon = doc.create_element('th', colspan: 1, class: 'table-header', style: 'text-align: center;vertical-align : middle')
      th_pokemon.content = "Pokémon"

      th_levels = doc.create_element('th', colspan: 1, class: 'table-header', style: 'text-align: center;vertical-align : middle')
      th_levels.content = "Level"

      th_rate = doc.create_element('th', colspan: num_cols - 2, class: 'table-header', style: 'text-align: center;')
      th_rate.content = "Rate"

      if num_cols > 3 || group == :Fishing # need to use two rows in one if Morning/Day/Nite
        th_pokemon['rowspan'] = 2
        th_levels['rowspan'] = 2
        th_rate['colspan'] = num_cols - 2
      end
      
      thead_row.add_child(th_pokemon)
      thead_row.add_child(th_levels)
      thead_row.add_child(th_rate)
      thead.add_child(thead_row)

      # Adds third row of header: if necessary
      if num_cols > 3 || group == :Fishing
        thead_row_extended = doc.create_element('tr')
        
        types.each do |type|
          th = doc.create_element('th', class:'table_header', style:'text-align: center')
          image = doc.create_element('img', class:'encounter_image', alt: TYPE_IMGS[type])
          image['src'] = "/static/images/#{TYPE_IMGS[type]}.png"
          th.add_child(image)
          thead_row_extended.add_child(th)
        end
        
        thead.add_child(thead_row_extended)
      end
      
      table.add_child(thead)

      mons.each do |mon, mon_data|
        # Create a table row element
        tr = doc.create_element('tr')
        
        # Add Pokémon's name to the first column
        td_name = doc.create_element('td', style: 'text-align: center')

        base_form = @monHash[mon].keys.find_all { |key| key.is_a?(String) }[0]
        pokemon_name_formatted = @monHash[mon][base_form][:name]

        if @encMapWrapper.get_enc_maps(mon) and @encMapWrapper.get_enc_maps(mon)[map_id]
          form = @encMapWrapper.get_enc_maps(mon)[map_id]
          form_key = @monHash[mon].keys.find_all { |key| key.is_a?(String) }[form]

          pokemon_name_formatted += " (#{form_key})".sub(" Form", "")
        end

        bold = doc.create_element('strong')
        bold.content = pokemon_name_formatted
        td_name.add_child(bold)
        tr.add_child(td_name)
        
        # Add levels to the second column
        td_levels = doc.create_element('td', style: 'text-align: center')
        td_levels.content = mon_data["levels"]
        tr.add_child(td_levels)
        
        # Add encounter types to additional columns
        types.each do |encounter_type|
        # [:LandMorning, :LandDay, :LandNight].each do |encounter_type|
          td_encounter_type = doc.create_element('td', style: 'text-align: center')
          if mon_data[encounter_type] == 0
            td_encounter_type.content = "--"
          else
            td_encounter_type.content = mon_data[encounter_type].to_s + "%"
          end
          tr.add_child(td_encounter_type)
        end

        table.add_child(tr)
      end
    end

    throw "No encounter tables found for specified" if !found_group 

    html_output = doc.to_html 
    return html_output.split("\n")[1..].join("\n")

  end

end

def main
  e = EncounterGetter.new('reborn')
  #puts e.get_encounter_md(29, ["Grass"])
  #puts e.get_encounter_md(29, ["Headbutt"])
  #puts e.get_encounter_md(29)
  puts e.get_encounter_md(170, ["Cave"])
  puts e.get_encounter_md(229, ["Headbutt"])
end

main if __FILE__ == $PROGRAM_NAME
