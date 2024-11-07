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
                      "POV Trainer: #{name_ext != "" ? name_ext : trainer_name}"
                    end

    td_main_content.add_child(bold)

    if type_mod == 0 # we don't need field for partners or selves
      field_div = doc.create_element('div')
      field_div.content = "Field: #{field || 'No Field'}"
      td_main_content.add_child(field_div)
    end

    if type_mod == 0 && !item_symbols.empty? # Adds count of enemy trainer items
      item_str = item_symbols.map { |sym, count| "#{@itemHash[sym][:name]}#{count > 1 ? " (#{count})" : ''}" }
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
        type2 = form_data[:Type2] ? @typeHash[form_data[:Type2]][:name] : (form_1_data[:Type2] ? @typeHash[form_1_data[:Type2]][:name] : nil)
        if type2.nil? || type1 == type2
          typeStr = "Typing: #{type1}"
        else
          typeStr = "Typing: #{type1}/#{type2}"
        end
        mon_details_parts.push(typeStr)
      end

      # Handles display of SOS Mons for full-boss fights
      if mon[:sos]
        oper, shields = boss_data[:sosDetails][:activationRequirement].split(" ").slice(1,2)
        refresh = boss_data[:sosDetails][:refreshingRequirement]
        cont = boss_data[:sosDetails][:continuous] != nil
        shield_text = case oper
          when "<" then "Less than #{shields} Shield(s)"
          when "<=" then "Less than #{shields.to_i + 1} Shield(s)"
          when "==" then "Exactly #{shields} Shield(s)"
        end
        mon_details_parts.push("Appears: #{shield_text} #{cont ? " (Continuous)" : ""}")
        mon_details_parts.push("Refreshes when boss @ #{refresh.join(", ")} shields") if refresh
      end        
      
      # Handles display of boss mon - including shield info
      if mon[:boss]
        boss_data[:onBreakEffects] ||= {}

        # Workaround for onEntryEffects note "100 shields"
        if boss_data[:onEntryEffects] && boss_data[:onEntryEffects].keys != [:message]
          boss_data[:onBreakEffects][100] = boss_data[:onEntryEffects]
        end

        # Handles text parts of boss data
        mon_details_parts.push("Shields: #{boss_data[:shieldCount]}")
        if boss_data[:immunities] != {}
          if boss_data[:immunities][:moves] && boss_data[:immunities][:moves] != []
            mon_details_parts.push("Immunities to moves: #{boss_data[:immunities][:moves].join(", ")}") 
          end
          if boss_data[:immunities][:fieldEffectDamage] && boss_data[:immunities][:fieldEffectDamage] != []
            fields = boss_data[:immunities][:fieldEffectDamage].map {|f| FIELDS[f]}
            mon_details_parts.push("Immunities to field damage: #{fields.join(", ")}") 
          end
        end
        boss_data[:onBreakEffects].keys.sort.reverse.each do |shield_count|
          effs = boss_data[:onBreakEffects][shield_count]         
          if shield_count == 100
            result = "On Entry: \n"  
          else
            threshold_text = "#{effs[:threshold] != 0 ? " (Regenerates Shield Infinitely)" : ""}"
            result = "Shield Break #{shield_count}#{threshold_text}: \n"  
          end

          eff_strs = []
          if effs[:bossEffect]
            eff_strs.push("Effect added to boss's side: #{effs[:bossEffect].to_s.gsub(/([a-z])([A-Z])/, '\1 \2')}") 
          end
          if effs.key?(:weatherChange)
            if effs[:weatherChange] == nil
              eff_strs.push("Weather is nullified")
            else
              eff_strs.push("Weather becomes #{@moveHash[effs[:weatherChange]][:name]}")
            end
          end
          if effs[:speciesUpdate]
            new_form_1_key = @pokemonHash[effs[:speciesUpdate]].keys.find_all { |key| key.is_a?(String) }[0]
            eff_strs.push("Boss becomes #{@pokemonHash[effs[:speciesUpdate]][new_form_1_key][:name]}")
          end
          if effs[:formchange]
            new_form = effs[:formchange]
            new_form_key = @pokemonHash[mon[:species]].keys.find_all { |key| key.is_a?(String) }[new_form]
            new_form_data = @pokemonHash[mon[:species]][new_form_key]

            form_changes = []

            if is_custom_form(form_key)

              new_type1 = new_form_data[:Type1] ? @typeHash[new_form_data[:Type1]][:name] : nil
              new_type2 = new_form_data[:Type2] ? @typeHash[new_form_data[:Type2]][:name] : (form_1_data[:Type2] ?  @typeHash[form_1_data[:Type2]][:name] : nil)
              types = [new_type1, new_type2].compact
              if !new_type1 || (type1 != new_type1 || type2 != new_type2)
                form_changes.push("Typing => #{types.join("/")}")
              end

              new_base_stats = new_form_data[:BaseStats] ? new_form_data[:BaseStats] : form_1_data[:BaseStats]
              if new_base_stats != base_stats
                form_changes.push('Base Stats => ' + new_base_stats.zip(EV_ARRAY).map { |stat, position| "#{stat} #{position}" }.join(', '))
              end
              eff_strs.push("Form changes to #{new_form_key} (#{form_changes.join('; ')})") 
            else
              eff_strs.push("Form changes to #{new_form_key}") 
            end
          end
          if effs[:fieldChange]
            eff_strs.push("Field becomes #{FIELDS[effs[:fieldChange]]}") 
          end
          if effs[:abilitychange]
            eff_strs.push("Boss's ability becomes #{@abilityHash[effs[:abilitychange]][:name]}") 
          end
          if effs[:typeChange]
            eff_strs.push("Boss's type becomes #{effs[:typeChange].map {|type| @typeHash[type][:name]}.join("/")}")
          end
          if effs[:movesetUpdate]
            eff_strs.push("Boss's moveset becomes #{effs[:movesetUpdate].compact.map{|m|@moveHash[m][:name]}.join(', ')}")
          end
          if effs[:statDropRefresh]
            eff_strs.push("Boss's stat changes are reset")
          end
          if effs[:statusCure]
            eff_strs.push("Boss's status effects cured") 
          end
          if effs[:effectClear]
            eff_strs.push("Effects are cleared") 
          end
          if effs[:bossSideStatusChanges]
            eff_strs.push("Effect added to boss's side: #{effs[:bossSideStatusChanges].to_s.gsub(/([a-z])([A-Z])/, '\1 \2')}") 
          end
          if effs[:playerSideStatusChanges]
            eff_strs.push("Status added to player's side: #{effs[:playerSideStatusChanges][1].to_s.gsub(/([a-z])([A-Z])/, '\1 \2')}")
          end
          if effs[:statDropCure]
            eff_strs.push("Boss's stat drops are cured")
          end
          if effs[:playerEffects]
            eff_strs.push("Effect added to player's side: #{effs[:playerEffects].to_s.gsub(/([a-z])([A-Z])/, '\1 \2')}") 
          end
          if effs[:stateChanges]
            eff_strs.push("Effect added to battle: #{effs[:stateChanges].to_s.gsub(/([a-z])([A-Z])/, '\1 \2')}")
          end
          if effs[:playersideChanges]
            if effs[:playersideChanges].class == Array
              eff_strs.push("Effects added to player side: #{effs[:playersideChanges].join(', ').gsub(/([a-z])([A-Z])/, '\1 \2')}") 
            else
              eff_strs.push("Effect added to player side: #{effs[:playersideChanges].to_s.gsub(/([a-z])([A-Z])/, '\1 \2')}") 
            end
          end
          if effs[:bosssideChanges]
            if effs[:bosssideChanges].class == Array
              eff_strs.push("Effects added to boss's side: #{effs[:bosssideChanges].join(', ').gsub(/([a-z])([A-Z])/, '\1 \2')}") 
            else
              eff_strs.push("Effect added to boss's side: #{effs[:bosssideChanges].to_s.gsub(/([a-z])([A-Z])/, '\1 \2')}") 
            end
          end
          if effs[:itemchange]
            eff_strs.push("Boss's held item becomes #{@itemHash[effs[:itemchange]][:name]}")
          end
          if effs[:bossStatChanges]
            groups = {}
            effs[:bossStatChanges].each do |stat, lvl|
              groups[lvl] ||= []
              groups[lvl].push(stat)
            end
            groups.each do |lvl, stats|
              eff_strs.push("Boss's #{stats.join(', ')} stat#{stats.length == 1 ? "" : "s"} #{lvl > 0 ? "raised" : "lowered"} #{lvl.abs} stage#{lvl.abs == 1 ? "" : "s"}")
            end
          end
          if effs[:playerSideStatChanges]
            groups = {}
            effs[:playerSideStatChanges].each do |stat, lvl|
              groups[lvl] ||= []
              groups[lvl].push(stat)
            end
            groups.each do |lvl, stats|
              eff_strs.push("Player's #{stats.join(', ')} stat#{stats.length == 1 ? "" : "s"} #{lvl > 0 ? "raised" : "lowered"} #{lvl.abs} stage#{lvl.abs == 1 ? "" : "s"}")
            end
          end
          if effs[:CustomMethod] && effs[:CustomMethod].match(/^battlesnapshot/)
            eff_strs.push("A snapshot in time is taken...")
          end
          if effs[:CustomMethod] && effs[:CustomMethod].match(/^timewarp/)
            eff_strs.push("A timewarp to the last snapshot occurs...")
          end
          # The way delayed effects work is... janky. In any case I will deal with it here.
          if effs[:delayedaction]
            actions = []
            tc = 0
            curr = effs[:delayedaction]
            while curr
              tc += curr[:delay]
              actions.push([tc, curr])
              curr = curr[:delayedaction]
            end
            actions.each do |tc, act|
              if act[:repeat] && !act[:typeSequence]
                ts = "After every #{tc} turn#{tc == 1 ? "" : "s"}: "
              else
                ts = "After #{tc} turn#{tc == 1 ? "" : "s"}: "
              end
              if act[:playerSideStatChanges]
                groups = {}
                act[:playerSideStatChanges].each do |stat, lvl|
                  groups[lvl] ||= []
                  groups[lvl].push(stat)
                end
                groups.each do |lvl, stats|
                  eff_strs.push("#{ts}Player's #{stats.join(', ')} stat#{stats.length == 1 ? "" : "s"} #{lvl > 0 ? "raised" : "lowered"} #{lvl.abs} stage#{lvl.abs == 1 ? "" : "s"}")
                end
              end
              if act[:playerEffects]
                if act[:playerEffects].class == Array
                  eff_strs.push("#{ts}Effects added to player side: #{act[:playerEffects][0].to_s.gsub(/([a-z])([A-Z])/, '\1 \2')}") 
                else
                  eff_strs.push("#{ts}Effect added to player side: #{act[:playerEffects].to_s.gsub(/([a-z])([A-Z])/, '\1 \2')}") 
                end
              end
              if act[:bossStatChanges] 
                groups = {}
                act[:bossStatChanges].each do |stat, lvl|
                  groups[lvl] ||= []
                  groups[lvl].push(stat)
                end
                groups.each do |lvl, stats|
                  eff_strs.push("#{ts}Boss's #{stats.join(', ')} stat#{stats.length == 1 ? "" : "s"} #{lvl > 0 ? "raised" : "lowered"} #{lvl.abs} stage#{lvl.abs == 1 ? "" : "s"}")
                end
              end
              if act[:bossEffect]
                eff_strs.push("#{ts}Effect added to boss's side: #{act[:bossEffect].to_s.gsub(/([a-z])([A-Z])/, '\1 \2')}") 
              end
              if act[:playerSideStatusChanges]
                eff_strs.push("#{ts}Status added to player's side: #{act[:playerSideStatusChanges][1].to_s.gsub(/([a-z])([A-Z])/, '\1 \2')}")
              end
              if act[:typeSequence]
                typeCycles = []
                act[:typeSequence].each do |num, obj|
                  typeCycles.push(obj[:typeChange].map {|type| @typeHash[type][:name]}.uniq.join("/"))
                end
                eff_strs.push("#{ts}Begins cycling types each turn: #{typeCycles.join(" -> ")}")
              end
              if act[:CustomMethod] && act[:CustomMethod].match(/^battlesnapshot/)
                eff_strs.push("#{ts}A snapshot in time is taken...")
              end
              if act[:CustomMethod] && act[:CustomMethod].match(/^timewarp/)
                eff_strs.push("#{ts}A timewarp to the last snapshot occurs...")
              end
            end
          end

          result += "- #{eff_strs.join("\n- ")}"
          shield_break_details.push(result)
        end
      end

      # Trainer Data and party size offset
      trainer_effects = [[trainer_data[:trainereffect], 0]]
      if second_trainer_data
        trainer_effects.push([second_trainer_data[:trainereffect], trainer_data[:mons].length])
      end
      trainer_effects.each do |trainerEffect, offset|
        next if trainerEffect == nil
        next if ![:Party].include?(trainerEffect[:effectmode])
        if trainerEffect[idx - offset]
          effs = trainerEffect[idx - offset]
          if effs[:pokemonStatChanges]
            groups = {}
            effs[:pokemonStatChanges].each do |stat, lvl|
              groups[lvl] ||= []
              groups[lvl].push(stat)
            end
            if groups != {}
              groups.each do |lvl, stats|
                mon_details_parts.push("#{stats.join(', ')} stat#{stats.length == 1 ? "" : "s"} #{lvl > 0 ? "raised" : "lowered"} #{lvl.abs} stage#{lvl.abs == 1 ? "" : "s"}")
              end
            end
          end
          if effs[:instantMove]
            m = effs[:instantMove][0]
            mon_details_parts.push("Instantly uses #{@moveHash[m][:name]}")
          end
          if effs[:fieldChange]
            field = FIELDS[effs[:fieldChange][0].to_sym]
            mon_details_parts.push("Field changes to #{field}")
          end
          if effs[:pokemonEffect]
            effs[:pokemonEffect].each do |eff, _arr|
              eff = eff.to_s.gsub(/([a-z])([A-Z])/, '\1 \2')
              mon_details_parts.push("Effect applied: #{eff}")
            end
          end
          if effs[:typeChange]
            mon_details_parts.push("Typing changed to: #{effs[:typeChange].map {|type| @typeHash[type][:name]}.join("/")}")
          end
          if effs[:trainersideChanges]
            mon_details_parts.push("Effects added to trainer's side: #{effs[:trainersideChanges].keys.map{|k| k.to_s}.join(", ").gsub(/([a-z])([A-Z])/, '\1 \2')}") 
          end
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

      stat_details_parts.push(get_ev_str(mon[:ev], mon[:level]))
      stat_details_parts.push(get_iv_str(mon[:iv]))
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

    # TrainerEffects that are not party based
    if trainer_data[:trainereffect] && trainer_data[:trainereffect][:effectmode] == :Fainted
      teff_details = []
      teff = trainer_data[:trainereffect]
      (1..6).each do |idx|
        fs = "After #{idx} Pokemon have fainted: "
        next if !teff[idx]
        effs = teff[idx]
        if effs[:fieldChange]
          field = FIELDS[effs[:fieldChange][0].to_sym]
          teff_details.push("#{fs}Field changes to #{field}")
        end
        if effs[:delayedaction]
          actions = []
          tc = 0
          curr = effs[:delayedaction]
          while curr
            tc += curr[:delay]
            actions.push([tc, curr])
            curr = curr[:delayedaction]
          end
          actions.each do |tc, act|
            if act[:repeat] && !act[:typeSequence]
              ts = "After every #{tc} turn#{tc == 1 ? "" : "s"}: "
            else
              ts = "After #{tc} turn#{tc == 1 ? "" : "s"}: "
            end
            if act[:playerSideStatChanges]
              groups = {}
              act[:playerSideStatChanges].each do |stat, lvl|
                groups[lvl] ||= []
                groups[lvl].push(stat)
              end
              groups.each do |lvl, stats|
                teff_details.push("#{ts}Player's #{stats.join(', ')} stat#{stats.length == 1 ? "" : "s"} #{lvl > 0 ? "raised" : "lowered"} #{lvl.abs} stage#{lvl.abs == 1 ? "" : "s"}")
              end
            end
            if act[:fieldChange]
              field = FIELDS[act[:fieldChange][0].to_sym]
              teff_details.push("#{ts}Field changes to #{field}")
            end
            if act[:playerEffects]
              teff_details.push("#{ts}Effect added to player's side: #{act[:playerEffects].to_s.gsub(/([a-z])([A-Z])/, '\1 \2')}") 
            end
            if act[:bossStatChanges] 
              groups = {}
              act[:bossStatChanges].each do |stat, lvl|
                groups[lvl] ||= []
                groups[lvl].push(stat)
              end
              groups.each do |lvl, stats|
                teff_details.push("#{ts}Boss's #{stats.join(', ')} stat#{stats.length == 1 ? "" : "s"} #{lvl > 0 ? "raised" : "lowered"} #{lvl.abs} stage#{lvl.abs == 1 ? "" : "s"}")
              end
            end
            if act[:bossEffect]
              teff_details.push("#{ts}Effect added to boss's side: #{act[:bossEffect].to_s.gsub(/([a-z])([A-Z])/, '\1 \2')}") 
            end
            if act[:playerSideStatusChanges]
              teff_details.push("#{ts}Status added to player's side: #{act[:playerSideStatusChanges][1].to_s.gsub(/([a-z])([A-Z])/, '\1 \2')}")
            end
            if act[:typeSequence]
              typeCycles = []
              act[:typeSequence].each do |num, obj|
                typeCycles.push(obj[:typeChange].map {|type| @typeHash[type][:name]}.uniq.join("/"))
              end
              teff_details.push("#{ts}Begins cycling types each turn: #{typeCycles.join(" -> ")}")
            end
          end
        end
      end

      teff_row = doc.create_element('tr')
      table.add_child(teff_row)
      teff_td = doc.create_element('td', colspan: 3)
      teff_td.add_child(teff_details.reject { |s| s.empty? }.join("\n-> "))
      teff_row.add_child(teff_td)
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
