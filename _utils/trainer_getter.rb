require_relative 'common'
require 'set'

class TrainerGetter
  attr_accessor :game, :trainer_hash, :trainer_type_hash, :item_hash, :move_hash, :ability_hash, :pokemon_hash

  def initialize(game, scripts_dir, trainer_hash = nil, boss_hash = nil, trainer_type_hash = nil, item_hash = nil, move_hash = nil, ability_hash = nil,
                 pokemon_hash = nil, type_hash = nil)
    @game = game
    @trainerHash = trainer_hash ||= load_trainer_hash(@game, @scriptsDir)
    @bossHash = boss_hash ||= load_boss_hash(@game, @scriptsDir)
    @trainerTypeHash = trainer_type_hash ||= load_trainer_type_hash(@game, @scriptsDir)
    @itemHash = item_hash ||= load_item_hash(@game, @scriptsDir)
    @moveHash = move_hash ||= load_move_hash(@game, @scriptsDir)
    @abilityHash = ability_hash ||= load_ability_hash(@game, @scriptsDir)
    @pokemonHash = pokemon_hash ||= load_pokemon_hash(@game, @scriptsDir)
    @typeHash = type_hash ||= load_type_hash(@game, @scriptsDir)
    @trainerStore = Set[]
  end

  def generate_trainer_markdown(trainer_id, field = nil, second_trainer_id = nil, type_mod = 0, name_mod = '')
    raise "Trainer ID #{trainer_id} not in Trainer Hash" unless @trainerHash[trainer_id]
    raise "Trainer ID #{second_trainer_id} not in Trainer Hash" if second_trainer_id && !@trainerHash[second_trainer_id]
    raise "Not a field - probably put trainer 2 in field arg: #{field}" if field && !field.index('[').nil?

    trainer_data = @trainerHash[trainer_id]
    second_trainer_data = second_trainer_id ? @trainerHash[second_trainer_id] : nil

    # puts "Trainer Data #{trainer_id} already in Store" if @trainerStore.include?(trainer_id)
    # puts "Trainer Data #{second_trainer_id} already in Store" if second_trainer_id && @trainerStore.include?(second_trainer_id)

    @trainerStore.add(trainer_id)
    @trainerStore.add(second_trainer_id) if second_trainer_id

    trainer_name = "#{@trainerTypeHash[trainer_id[1]][:title]} #{trainer_id[0]}"
    trainer_name += " #{name_mod}" unless name_mod.nil?
    second_trainer_name = second_trainer_id ? "#{@trainerTypeHash[second_trainer_id[1]][:title]} #{second_trainer_id[0]}" : nil

    item_symbols = Hash.new(0)
    item_symbols.merge!(trainer_data[:items].tally) if trainer_data[:items]

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
    table.add_child(table_header)

    # Header Row 1: Trainer Names, Field, Items
    thead_row = doc.create_element('tr')
    table_header.add_child(thead_row)

    th = doc.create_element('th', colspan: 3, class: 'header-th')

    # First TD for main content (VS, Field, Items)
    td_main_content = doc.create_element('div')

    bold = doc.create_element('strong')
    bold.content = if second_trainer_name
                    "VS: #{trainer_name} & #{second_trainer_name}"
                   elsif type_mod == 0
                    "VS: #{trainer_name}"
                   elsif type_mod == 1
                    "Partner: #{trainer_name}"
                   elsif type_mod == 2
                    "POV Trainer: #{name_mod}"
                   end

    td_main_content.add_child(bold)

    if type_mod == 0 # we don't need field for partners or selves
      field_div = doc.create_element('div')
      field_div.content = "Field: #{field || 'No Field'}"
      td_main_content.add_child(field_div)
    end

    if type_mod == 0 && !item_symbols.empty?
      item_str = item_symbols.map { |sym, count| "#{@itemHash[sym][:name]} #{count > 1 ? "(#{count})" : ''}" }
      items_div = doc.create_element('div')
      items_div.content = "Items: #{item_str.join(', ')}"
      td_main_content.add_child(items_div)
    end

    th.add_child(td_main_content)

    # Second TD for [show] or [hide] text
    td_show_hide = doc.create_element('div', class: 'show-hide-container') # style: 'text-align: right;')
    show_hide_text = doc.create_element('span', class: 'show-hide-text', style: 'cursor: pointer;')
    show_hide_text.content = '[show]'
    td_show_hide.add_child(show_hide_text)

    th.add_child(td_show_hide)

    thead_row.add_child(th)

    # Header Row 2: Actual table headers
    thead_row = doc.create_element('tr')

    ['Pokemon', 'Moves', 'Stat Info'].each do |col|
      thead_row.add_child(doc.create_element('th', col, style: 'text-align: center;vertical-align : middle'))
    end
    table_header.add_child(thead_row)

    # Trainer Mon data
    [trainer_data, second_trainer_data].compact.each do |trainer|
      trainer[:mons].each do |mon|
        content_row = doc.create_element('tr')
        table.add_child(content_row)

        if mon[:boss] # Here we handle some overrides for boss mons in otherwise normal teams....
          boss_data = @bossHash[mon[:boss]]
          # Override whatever junk is in the trainer file, if its a boss
          mon[:moves] = boss_data[:moninfo][:moves]
          mon[:ability] = boss_data[:moninfo][:ability]
          mon[:level] = boss_data[:moninfo][:level]
          mon[:form] = boss_data[:moninfo][:form]
          mon[:item] = boss_data[:moninfo][:item]
        end

        form = mon[:form] || 0
        form_key = @pokemonHash[mon[:species]].keys.find_all { |key| key.is_a?(String) }[form]
        form_data = @pokemonHash[mon[:species]][form_key]

        form_1_key = @pokemonHash[mon[:species]].keys.find_all { |key| key.is_a?(String) }[0]
        form_1_data = @pokemonHash[mon[:species]][form_1_key]
        pokemon_name = "#{mon[:shadow] ? "Shadow " : ""}#{@pokemonHash[mon[:species]][form_1_key][:name]}"
        pokemon_name = "#{mon[:boss] ? "Boss " : ""}#{pokemon_name}"

        mon_details_parts = [
          "#{mon[:gender] ? " (#{mon[:gender]})" : ''}, Lv. #{mon[:level]}",
          "#{form > 0 ? @pokemonHash[mon[:species]].keys.find_all { |key| key.is_a?(String) }[mon[:form]] : ''}",
          "#{mon[:item] ? "@#{@itemHash[mon[:item]][:name]}" : ''}",
          "#{mon[:ability] ? "Ability: #{@abilityHash[mon[:ability]][:name]}" : ''}"
        ]

        custom_form_bool = is_custom_form(form_key)

        type1 = form_data[:Type1] ? @typeHash[form_data[:Type1]][:name] : @typeHash[form_1_data[:Type1]][:name]
        type2 = form_data[:Type2] ? @typeHash[form_data[:Type2]][:name] : (form_1_data[:Type2] ?  @typeHash[form_1_data[:Type2]][:name] : nil)
        if type2.nil? 
          typeStr = "Typing: #{type1}"
        else
          typeStr = "Typing: #{type1}/#{type2}"
        end

        # Add typing only for custom formes
        mon_details_parts.push(typeStr) if custom_form_bool

        if mon[:boss]
          # Handles text parts of boss data
          mon_details_parts.push("Shields: #{boss_data[:shieldCount]}")
          mon_details_parts.push("Immunities to #{boss_data[:immunities].join(", ")}") if boss_data[:immunities] != {}
          boss_data[:onBreakEffects].each do |shield_count, effect_obj| 
            threshold_text = "#{effect_obj[:threshold] != 0 ? " ( at #{effect_obj[:threshold] * 100}% HP)" : ""}"
            result = "Shield Break #{shield_count}#{threshold_text}: \n"
  
            effects = []
            # TODO: These will all need custom code............
            effects.push(effect_obj[:bossEffect]) if effect_obj[:bossEffect]
            effects.push(effect_obj[:weatherChange]) if effect_obj[:weatherChange]
            effects.push(effect_obj[:formchange]) if effect_obj[:formchange]
            if effect_obj[:fieldChange]
              effects.push("Field becomes #{FIELDS[effect_obj[:fieldChange]]}") 
            end
            effects.push(effect_obj[:abilitychange]) if effect_obj[:abilitychange]
            if effect_obj[:typeChange]
              effects.push("Type becomes #{effect_obj[:typeChange].map {|type| @typeHash[type][:name]}.join("/")}")
            end
            effects.push(effect_obj[:movesetChange]) if effect_obj[:movesetChange]
            effects.push(effect_obj[:speciesChange]) if effect_obj[:speciesChange]
            effects.push(effect_obj[:statusCure]) if effect_obj[:statusCure]
            effects.push(effect_obj[:effectClear]) if effect_obj[:effectClear]
            effects.push(effect_obj[:bossSideStatusChanges]) if effect_obj[:bossSideStatusChanges]
            effects.push(effect_obj[:playerSideStatusChanges]) if effect_obj[:playerSideStatusChanges]
            if effect_obj[:statDropCure]
              effects.push("Stat drops are cured") 
            end
            effects.push(effect_obj[:playerEffects]) if effect_obj[:playerEffects]
            effects.push(effect_obj[:stateChanges]) if effect_obj[:stateChanges]
            effects.push(effect_obj[:playersideChanges]) if effect_obj[:playersideChanges]
            effects.push(effect_obj[:bosssideChanges]) if effect_obj[:bosssideChanges]
            effects.push(effect_obj[:itemchange]) if effect_obj[:itemchange]
            if effect_obj[:bossStatChanges]
              effect_obj[:bossStatChanges].each do |stat, levels|
                effects.push("#{stat} stat is raised #{levels} stage(s)")
              end
            end
            effects.push(effect_obj[:playerSideStatChanges]) if effect_obj[:playerSideStatChanges]
            
            result += "- #{effects.join("\n- ")}"
            mon_details_parts.push(result)
          end
        end

        mon_details_td = doc.create_element('td')
        mon_details_td.add_child(doc.create_element('strong', pokemon_name))
        mon_details_td.add_child(mon_details_parts.reject { |s| s.empty? }.join("\n"))
        content_row.add_child(mon_details_td)

        # Create list of default moves
        unless mon[:moves]
          mon[:moves] = []
          moveset = form_data[:Moveset] || form_1_data[:Moveset]
          movelist = []
          for i in moveset
            movelist.push(i[1]) if i[0] <= mon[:level]
          end
          movelist |= [] # Remove duplicatesx
          listend = movelist.length - 4
          listend = 0 if listend < 0
          for i in listend...listend + 4
            next if i >= movelist.length

            mon[:moves].push(movelist[i])
          end
        end

        moves_str = '- ' + mon[:moves].compact.map do |move|
                             @moveHash[move][:name] + hp_str(@moveHash[move][:name], mon[:hptype])
                           end.join("\n- ")
        content_row.add_child(doc.create_element('td', moves_str))

        ev_str = if mon[:ev] && mon[:ev].uniq == [252]
                   'EVs: All 252'
                 elsif mon[:ev] && mon[:ev].uniq.sort == [0, 252]
                   'EVs: All 252 (0 Spe)'
                 elsif mon[:ev]
                   'EVs: ' + mon[:ev].zip(EV_ARRAY).reject do |ev, _|
                               ev.zero?
                             end.map { |ev, position| "#{ev} #{position}" }.join(', ')
                 else
                   "EVs: All #{[85, mon[:level] * 3 / 2].min}"
                 end

        iv_str = if mon[:iv]
                   mon[:iv] == 32 ? 'IVs: All 31 (0 Spe)' : "IVs: All #{mon[:iv]}"
                 else
                   'IVs: All 10'
                 end

        base_stats = form_data[:BaseStats] ? form_data[:BaseStats] : form_1_data[:BaseStats]
        base_stats_str = 'Base Stats: ' + base_stats.zip(EV_ARRAY).map { |stat, position| "#{stat} #{position}" }.join(', ')

        stat_details_parts = []
        
        # Only add base stats when custom form
        stat_details_parts.push(base_stats_str) if custom_form_bool
        
        stat_details_parts.push(mon[:nature] ? "#{mon[:nature].capitalize} Nature" : 'Hardy Nature',)
        stat_details_parts.push(ev_str)
        stat_details_parts.push(iv_str)
        stat_details_td = doc.create_element('td', stat_details_parts.join("\n"))
        content_row.add_child(stat_details_td)
      end
    end

    doc.to_html.gsub(/<td>\s*\n\s*<strong>/, '<td><strong>').split("\n")[1..].join("\n")
  end

  def generate_boss_markdown(boss_symbol, field = nil)
    raise "Boss Name #{boss_symbol} not in Trainer Hash" unless @bossHash[boss_symbol]

    boss_data = @bossHash[boss_symbol]
    boss_name = boss_data[:name]

    @trainerStore.add(boss_symbol)

    # Creates nokogiri HTML
    doc = Nokogiri::HTML::Document.new
    div = doc.create_element('div', class: 'trainer_section')
    doc.add_child(div)

    table = doc.create_element('table')
    div.add_child(table)

    # Creates the header for the table
    table_header = doc.create_element('thead')
    table_header['class'] = 'table-header'
    table.add_child(table_header)

    # Header Row 1: Trainer Names, Field, Items
    thead_row = doc.create_element('tr')
    table_header.add_child(thead_row)

    th = doc.create_element('th', colspan: 3, class: 'header-th')

    # First TD for main content (VS, Field, Items)
    td_main_content = doc.create_element('div')

    bold = doc.create_element('strong')
    bold.content = "VS Boss: #{boss_name}"
    td_main_content.add_child(bold)

    field_div = doc.create_element('div')
    field_div.content = "Field: #{field || 'No Field'}"
    td_main_content.add_child(field_div)

    th.add_child(td_main_content)

    # Second TD for [show] or [hide] text
    td_show_hide = doc.create_element('div', class: 'show-hide-container') # style: 'text-align: right;')
    show_hide_text = doc.create_element('span', class: 'show-hide-text', style: 'cursor: pointer;')
    show_hide_text.content = '[show]'
    td_show_hide.add_child(show_hide_text)

    th.add_child(td_show_hide)

    thead_row.add_child(th)


    # Header Row 2: Actual table headers
    thead_row = doc.create_element('tr')

    ['Pokemon', 'Moves', 'Stat Info'].each do |col|
      thead_row.add_child(doc.create_element('th', col, style: 'text-align: center;vertical-align : middle'))
    end
    table_header.add_child(thead_row)

    # Trainer Mon data
    boss = boss_data[:moninfo]
    reinfs = boss_data[:sosDetails] ? boss_data[:sosDetails][:moninfos].values : []
    ([boss] + reinfs).each_with_index do |mon, idx|
      is_boss = idx == 0

      content_row = doc.create_element('tr')
      table.add_child(content_row)

      form = mon[:form] || 0
      form_key = @pokemonHash[mon[:species]].keys.find_all { |key| key.is_a?(String) }[form]
      form_data = @pokemonHash[mon[:species]][form_key]

      form_1_key = @pokemonHash[mon[:species]].keys.find_all { |key| key.is_a?(String) }[0]
      form_1_data = @pokemonHash[mon[:species]][form_1_key]
      pokemon_name = "#{is_boss ? "Boss " : "SOS "}#{@pokemonHash[mon[:species]][form_1_key][:name]}"

      mon_details_parts = [
        "#{mon[:gender] ? " (#{mon[:gender]})" : ''}, Lv. #{mon[:level]}",
        "#{form > 0 ? @pokemonHash[mon[:species]].keys.find_all { |key| key.is_a?(String) }[mon[:form]] : ''}",
        "#{mon[:item] ? "@#{@itemHash[mon[:item]][:name]}" : ''}",
        "#{mon[:ability] ? "Ability: #{@abilityHash[mon[:ability]][:name]}" : ''}"
      ]

      custom_form_bool = is_custom_form(form_key)

      type1 = form_data[:Type1] ? @typeHash[form_data[:Type1]][:name] : @typeHash[form_1_data[:Type1]][:name]
      type2 = form_data[:Type2] ? @typeHash[form_data[:Type2]][:name] : (form_1_data[:Type2] ?  @typeHash[form_1_data[:Type2]][:name] : nil)
      if type2.nil? 
        typeStr = "Typing: #{type1}"
      else
        typeStr = "Typing: #{type1}/#{type2}"
      end

      # Add typing only for custom forms
      mon_details_parts.push(typeStr) if custom_form_bool
      
      if is_boss
        mon_details_parts.push("Shields: #{boss_data[:shieldCount]}")
        mon_details_parts.push("Immunities to #{boss_data[:immunities].join(", ")}") if boss_data[:immunities] != {}
        boss_data[:onBreakEffects].each do |shield_count, effect_obj| 
          threshold_text = "#{effect_obj[:threshold] != 0 ? " ( at #{effect_obj[:threshold] * 100}% HP)" : ""}"
          result = "Shield Break #{shield_count}#{threshold_text}: \n"

          effects = []
          # TODO: These will all need custom code............
          effects.push(effect_obj[:bossEffect]) if effect_obj[:bossEffect]
          effects.push(effect_obj[:weatherChange]) if effect_obj[:weatherChange]
          if effect_obj[:fieldChange]
            effects.push("Field becomes #{FIELDS[effect_obj[:fieldChange]]}") 
          end
          effects.push(effect_obj[:formchange]) if effect_obj[:formchange]
          effects.push(effect_obj[:abilitychange]) if effect_obj[:abilitychange]
          if effect_obj[:typeChange]
            effects.push("Type becomes #{effect_obj[:typeChange].map {|type| @typeHash[type][:name]}.join("/")}")
          end
          effects.push(effect_obj[:movesetChange]) if effect_obj[:movesetChange]
          effects.push(effect_obj[:speciesChange]) if effect_obj[:speciesChange]
          effects.push(effect_obj[:statusCure]) if effect_obj[:statusCure]
          effects.push(effect_obj[:effectClear]) if effect_obj[:effectClear]
          effects.push(effect_obj[:bossSideStatusChanges]) if effect_obj[:bossSideStatusChanges]
          effects.push(effect_obj[:playerSideStatusChanges]) if effect_obj[:playerSideStatusChanges]
          if effect_obj[:statDropCure]
            effects.push("Stat drops are cured") 
          end
          effects.push(effect_obj[:playerEffects]) if effect_obj[:playerEffects]
          effects.push(effect_obj[:stateChanges]) if effect_obj[:stateChanges]
          effects.push(effect_obj[:playersideChanges]) if effect_obj[:playersideChanges]
          effects.push(effect_obj[:bosssideChanges]) if effect_obj[:bosssideChanges]
          effects.push(effect_obj[:itemchange]) if effect_obj[:itemchange]
          if effect_obj[:bossStatChanges]
            effect_obj[:bossStatChanges].each do |stat, levels|
              effects.push("#{stat} stat is raised #{levels} stage(s)")
            end
          end
          effects.push(effect_obj[:playerSideStatChanges]) if effect_obj[:playerSideStatChanges]
          
          result += "- #{effects.join("\n- ")}"
          mon_details_parts.push(result)
        end
      else
        oper, shields = boss_data[:sosDetails][:activationRequirement].split(" ").slice(1,2)
        cont = boss_data[:continuous] != nil
        shield_text = case oper
          when "<" then "Less than #{shields} Shield(s)"
          when "<=" then "Less than #{shields + 1} Shield(s)"
          when "==" then "Exactly #{shields} Shield(s)"
        end
        mon_details_parts.push("Appears: #{shield_text} #{cont ? " (Continuous)" : ""}")
        # Here we detail when the reinforcement shows up, among other little things?
      end

      mon_details_td = doc.create_element('td')
      mon_details_td.add_child(doc.create_element('strong', pokemon_name))
      mon_details_td.add_child(mon_details_parts.reject { |s| s.empty? }.join("\n"))
      content_row.add_child(mon_details_td)

      # Create list of default moves
      unless mon[:moves]
        mon[:moves] = []
        moveset = form_data[:Moveset] || form_1_data[:Moveset]
        movelist = []
        for i in moveset
          movelist.push(i[1]) if i[0] <= mon[:level]
        end
        movelist |= [] # Remove duplicatesx
        listend = movelist.length - 4
        listend = 0 if listend < 0
        for i in listend...listend + 4
          next if i >= movelist.length

          mon[:moves].push(movelist[i])
        end
      end
      moves_str = '- ' + mon[:moves].compact.map do |move|
                            @moveHash[move][:name] + hp_str(@moveHash[move][:name], mon[:hptype])
                          end.join("\n- ")
      content_row.add_child(doc.create_element('td', moves_str))
      
      ev_str = if mon[:ev] && mon[:ev].uniq == [252]
                  'EVs: All 252'
                elsif mon[:ev] && mon[:ev].uniq.sort == [0, 252]
                  'EVs: All 252 (0 Spe)'
                elsif mon[:ev] == [0,0,0,0,0,0]
                  'EVs: None'
                elsif mon[:ev]
                  'EVs: ' + mon[:ev].zip(EV_ARRAY).reject do |ev, _|
                              ev.zero?
                            end.map { |ev, position| "#{ev} #{position}" }.join(', ')
                else
                  "EVs: All #{[85, mon[:level] * 3 / 2].min}"
                end

      iv_str = if mon[:iv]
                  mon[:iv] == 32 ? 'IVs: All 31 (0 Spe)' : "IVs: All #{mon[:iv]}"
                else
                  'IVs: All 10'
                end

      base_stats = form_data[:BaseStats] ? form_data[:BaseStats] : form_1_data[:BaseStats]
      base_stats_str = 'Base Stats: ' + base_stats.zip(EV_ARRAY).map { |stat, position| "#{stat} #{position}" }.join(', ')

      stat_details_parts = []
      
      # Only add base stats when custom form
      stat_details_parts.push(base_stats_str) if custom_form_bool
      
      stat_details_parts.push(mon[:nature] ? "#{mon[:nature].capitalize} Nature" : 'Hardy Nature',)
      stat_details_parts.push(ev_str)
      stat_details_parts.push(iv_str)
      stat_details_td = doc.create_element('td', stat_details_parts.join("\n"))
      content_row.add_child(stat_details_td)
    end

    doc.to_html.gsub(/<td>\s*\n\s*<strong>/, '<td><strong>').split("\n")[1..].join("\n")
  end

  def report_missing_trainers
    puts 'UNUSED TRAINER IDs: '
    @trainerHash.each do |trainer_id, _data|
      next if @trainerStore.include?(trainer_id)

      p trainer_id
    end
  end
end

def main
  e = TrainerGetter.new('reborn')
  puts e.generate_trainer_markdown(["Ace of Clubs", :ACECLUBS, 0])
  # puts e.generate_trainer_markdown(['Cain', :Cain, 5], 'Chess Board')
  # puts e.generate_trainer_markdown(["Arlo", :SWIMMERBOI, 0])
  # puts e.generate_trainer_markdown(["Yan", :TechNerd, 0])
  # puts e.generate_trainer_markdown(["Jackson", :COOLTRAINER_Male, 0], nil, ["Mack", :StreetRat, 0])
  # puts e.generate_trainer_markdown(["Aster", :AsterKnight, 0], nil, ["Eclipse", :EclipseDame, 0])
end

main if __FILE__ == $PROGRAM_NAME
