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

  def generate_trainer_markdown(trainer_id, field = nil, second_trainer_id = nil, type_mod = 0, name_ext = '')
    
    # a cursed workaround 
    if trainer_id.class == Array 
      trainer_id[0] = trainer_id[0].gsub("okemon", "okémon") # workaround for the cursed e character I can't just type
    end

    raise "Trainer ID #{trainer_id} not in Trainer Hash" unless (@trainerHash[trainer_id] || @bossHash[trainer_id])
    raise "Trainer ID #{second_trainer_id} not in Trainer Hash" if second_trainer_id && !@trainerHash[second_trainer_id]
    raise "Not a field - probably put trainer 2 in field arg: #{field}" if field && !field.index('[').nil?

    @trainerStore.add(trainer_id)
    @trainerStore.add(second_trainer_id) if second_trainer_id

    fight_is_boss = (trainer_id.class == Symbol)

    if !fight_is_boss
      trainer_data = @trainerHash[trainer_id]
      second_trainer_data = second_trainer_id ? @trainerHash[second_trainer_id] : nil
      trainer_name = "#{@trainerTypeHash[trainer_id[1]][:title]} #{trainer_id[0]}"
      trainer_name += " #{name_ext}" unless name_ext.nil?
      second_trainer_name = second_trainer_id ? "#{@trainerTypeHash[second_trainer_id[1]][:title]} #{second_trainer_id[0]}" : nil
    else
      trainer_data = @bossHash[trainer_id]
      trainer_name = trainer_data[:name]
      second_trainer_name = nil
      boss_data = trainer_data
    end
    shield_break_details = []

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
    bold.content =  if fight_is_boss
                      "VS Boss: #{trainer_name}"
                    elsif second_trainer_name
                      "VS: #{trainer_name} & #{second_trainer_name}"
                    elsif type_mod == 0
                      "VS: #{trainer_name}"
                    elsif type_mod == 1
                      "Partner: #{trainer_name}"
                    elsif type_mod == 2
                      "POV Trainer: #{name_ext}"
                    end

    td_main_content.add_child(bold)

    if type_mod == 0 # we don't need field for partners or selves
      field_div = doc.create_element('div')
      field_div.content = "Field: #{field || 'No Field'}"
      td_main_content.add_child(field_div)
    end

    if type_mod == 0 && !item_symbols.empty? # Adds count of enemy trainer items
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
    if fight_is_boss
      list_of_mons = [trainer_data[:moninfo]] + (trainer_data[:sosDetails] ? trainer_data[:sosDetails][:moninfos].values : [])
    else
      list_of_mons = trainer_data[:mons] + (second_trainer_data ? second_trainer_data[:mons] : [])
    end

    list_of_mons.each_with_index do |mon, idx|
      content_row = doc.create_element('tr')
      table.add_child(content_row)

      if mon[:boss] # Here we handle some overrides for boss mons in otherwise normal teams....
        boss_data = @bossHash[mon[:boss]]
        # Override whatever junk is in the trainer file, if its a boss
        mon[:moves] = boss_data[:moninfo][:moves] if boss_data[:moninfo][:moves]
        mon[:ability] = boss_data[:moninfo][:ability] if boss_data[:moninfo][:ability]
        mon[:iv] = boss_data[:moninfo][:iv] if boss_data[:moninfo][:iv]
        mon[:ev] = boss_data[:moninfo][:ev] if boss_data[:moninfo][:ev]
        mon[:nature] = boss_data[:moninfo][:nature] if boss_data[:moninfo][:nature]
        mon[:level] = boss_data[:moninfo][:level] if boss_data[:moninfo][:level]
        mon[:form] = boss_data[:moninfo][:form] if boss_data[:moninfo][:form]
        mon[:item] = boss_data[:moninfo][:item] if boss_data[:moninfo][:item]
      end

      if fight_is_boss && idx == 0
        mon[:boss] = true
      elsif fight_is_boss
        mon[:sos] = true
      end

      form = mon[:form] || 0
      form_key = @pokemonHash[mon[:species]].keys.find_all { |key| key.is_a?(String) }[form]
      form_data = @pokemonHash[mon[:species]][form_key]

      form_1_key = @pokemonHash[mon[:species]].keys.find_all { |key| key.is_a?(String) }[0]
      form_1_data = @pokemonHash[mon[:species]][form_1_key]
      pokemon_name = "#{mon[:shadow] ? "Shadow " : ""}#{@pokemonHash[mon[:species]][form_1_key][:name]}"
      if fight_is_boss || mon[:boss]
        pokemon_name = "#{mon[:boss] ? "Boss " : "SOS "}#{pokemon_name}"
      end

      # Some mons, like alt color Joltik, are custom forms without form data...
      if form_key == nil 
        form_key = form_1_key
        form_data = form_1_data
      end

      base_stats = form_data[:BaseStats] ? form_data[:BaseStats] : form_1_data[:BaseStats]
      
      if mon[:ability]
        abText = @abilityHash[mon[:ability]][:name]
      else
        abs = form_data[:Abilities] ? form_data[:Abilities] : form_1_data[:Abilities]
        abText = abs.map {|a| @abilityHash[a][:name]}.join("/")
      end

      mon_details_parts = [
        "#{mon[:gender] ? " (#{mon[:gender]})" : ''}, Lv. #{mon[:level]}",
        "#{form > 0 ? @pokemonHash[mon[:species]].keys.find_all { |key| key.is_a?(String) }[mon[:form]] : ''}",
        "#{mon[:item] ? "@#{@itemHash[mon[:item]][:name]}" : ''}",
        "Ability: #{abText}"
      ]

      custom_form_bool = is_custom_form(form_key)

      if custom_form_bool # Add typing only for custom formes
        type1 = form_data[:Type1] ? @typeHash[form_data[:Type1]][:name] : @typeHash[form_1_data[:Type1]][:name]
        type2 = form_data[:Type2] ? @typeHash[form_data[:Type2]][:name] : (form_1_data[:Type2] ?  @typeHash[form_1_data[:Type2]][:name] : nil)
        if type2.nil?
          typeStr = "Typing: #{type1}"
        else
          typeStr = "Typing: #{type1}/#{type2}"
        end
        mon_details_parts.push(typeStr)
      end

      # Handles display of SOS Mons for full-boss fights
      if mon[:sos]
        oper, shields = boss_data[:sosDetails][:activationRequirement].split(" ").slice(1,2)
        cont = boss_data[:sosDetails][:continuous] != nil
        shield_text = case oper
          when "<" then "Less than #{shields} Shield(s)"
          when "<=" then "Less than #{shields + 1} Shield(s)"
          when "==" then "Exactly #{shields} Shield(s)"
        end
        mon_details_parts.push("Appears: #{shield_text} #{cont ? " (Continuous)" : ""}")
      end        
      
      # Handles display of boss mon - including shield info
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
          if effect_obj[:formchange]
            new_form = effect_obj[:formchange]
            new_form_key = @pokemonHash[mon[:species]].keys.find_all { |key| key.is_a?(String) }[new_form]
            new_form_data = @pokemonHash[mon[:species]][new_form_key]

            form_changes = []

            new_type1 = new_form_data[:Type1] ? @typeHash[new_form_data[:Type1]][:name] : nil
            new_type2 = new_form_data[:Type2] ? @typeHash[new_form_data[:Type2]][:name] : (form_1_data[:Type2] ?  @typeHash[form_1_data[:Type2]][:name] : nil)
            if !new_type1 || (type1 != new_type1 || type2 != new_type2)
              form_changes.push("Type => #{new_form_data[:Type1][:name]}")
            end

            new_base_stats = new_form_data[:BaseStats] ? new_form_data[:BaseStats] : form_1_data[:BaseStats]
            if new_base_stats != base_stats
              form_changes.push('Base Stats => ' + new_base_stats.zip(EV_ARRAY).map { |stat, position| "#{stat} #{position}" }.join(', '))
            end
    
            effects.push("Form changes to #{new_form_key} (#{form_changes.join('; ')})") 
          end
          if effect_obj[:fieldChange]
            effects.push("Field becomes #{FIELDS[effect_obj[:fieldChange]]}") 
          end
          if effect_obj[:abilitychange]
            effects.push("Ability becomes #{@abilityHash[effect_obj[:abilitychange]][:name]}") 
          end
          if effect_obj[:typeChange]
            effects.push("Type becomes #{effect_obj[:typeChange].map {|type| @typeHash[type][:name]}.join("/")}")
          end
          if effect_obj[:movesetUpdate]
            effects.push("Moveset becomes #{effect_obj[:movesetUpdate].map{|m|@moveHash[m][:name]}.join(', ')}")
          end
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
          if effect_obj[:playersideChanges]
            effects.push("Effect added to player side: #{effect_obj[:playersideChanges].to_s.gsub(/([a-z])([A-Z])/, '\1 \2')}") 
          end
          effects.push(effect_obj[:bosssideChanges]) if effect_obj[:bosssideChanges]
          effects.push(effect_obj[:itemchange]) if effect_obj[:itemchange]
          if effect_obj[:bossStatChanges]
            groups = {}
            effect_obj[:bossStatChanges].each do |stat, lvl|
              groups[lvl] ||= []
              groups[lvl].push(stat)
            end
            groups.each do |lvl, stats|
              effects.push("#{stats.join(', ')} stat#{stats.length == 1 ? "" : "s"} #{lvl > 0 ? "raised" : "lowered"} #{lvl.abs} stage#{lvl.abs == 1 ? "" : "s"}")
            end
          end
          effects.push(effect_obj[:playerSideStatChanges]) if effect_obj[:playerSideStatChanges]
          
          result += "- #{effects.join("\n- ")}"
          shield_break_details.push(result)
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

      if mon[:boss] && boss_data[:chargeAttack]
        mon[:moves].push(boss_data[:chargeAttack][:intermediateattack]) if boss_data[:chargeAttack][:intermediateattack]
        mon[:moves].push(boss_data[:chargeAttack])
      end

      moves_edited = []
      mon[:moves].each do |move|
        next if move == nil
        if move.class == Hash 
          if move[:turns] # is a charge attack
            name = "Charge Attack (#{move[:turns]} turns)"
          else # is an intermediate attack
            name = "#{move[:name]} (Intermediate attack)"
          end
        else
          name = @moveHash[move][:name]
        end
        name = name + hp_str(name, mon[:hptype])
        moves_edited.push(name)
      end
      final = "- " + moves_edited.join("\n- ")
      content_row.add_child(doc.create_element('td', final))

      # Handles stats next: base stats if applicable, IVs, Nature, EVs
      stat_details_parts = []
      if custom_form_bool # Only add base stats when custom form
        base_stats_str = 'Base Stats: ' + base_stats.zip(EV_ARRAY).map { |stat, position| "#{stat} #{position}" }.join(', ')
        stat_details_parts.push(base_stats_str) 
      end
      stat_details_parts.push(mon[:nature] ? "#{mon[:nature].capitalize} Nature" : 'Hardy Nature',)
      ev_str = if mon[:ev] && mon[:ev].uniq.length == 1
                  "EVs: All #{mon[:ev][0]}"
                elsif mon[:ev]
                  'EVs: ' + mon[:ev].zip(EV_ARRAY).reject do |ev, _|
                              ev.zero?
                            end.map { |ev, position| "#{ev} #{position}" }.join(', ')
                else
                  "EVs: All #{[85, mon[:level] * 3 / 2].min}"
                end
      stat_details_parts.push(ev_str)
      iv_str = if mon[:iv]
                  mon[:iv] == 32 ? 'IVs: All 31 (0 Spe)' : "IVs: All #{mon[:iv]}"
                else
                  'IVs: All 10'
                end


      
      stat_details_parts.push(iv_str)
      stat_details_td = doc.create_element('td', stat_details_parts.join("\n"))
      content_row.add_child(stat_details_td)

      # Adds Shield Break Details to the end
      if shield_break_details != []
        shield_break_row = doc.create_element('tr')
        table.add_child(shield_break_row)

        shield_break_td = doc.create_element('td', colspan: 3)
        shield_break_td.add_child(shield_break_details.reject { |s| s.empty? }.join("\n"))
        shield_break_row.add_child(shield_break_td)

        shield_break_details = []
      end
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
