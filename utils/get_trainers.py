from common import *
import re
from collections import Counter

ODD_ONES = ['']
ODD_ONES.extend([f"Minior-{color}-Meteor" for color in [
    "Blue", "Red", "Indigo", "Violet", "Yellow", "Green", "Orange"
    ]])
ODD_ONES.extend([   
    "Nidoran-M",
    "Nidoran-F", 
    "Farfetchd",
    'Mimikyu-Disguised', 
    "Mr-Mime",
    "Aegislash-Shield",
    "Aegislash-Blade",
    "Ribombee-Totem",
    "Ho-Oh", 
    "Ho-oh",
    "Keldeo-Ordinary",
    "Keldeo-Resolute",
    "Tapu-Bulu",
    "Tapu-Fini",
    "Tapu-Koko",
    "Tapu-Lele",
    "Kommo-O",
    "Darmanitan-Standard",
    "Jangmo-O",
    "Hakamo-O",
    "Magearna-Original",
    "Wishiwashi-Solo"
])

def create_lookup(pbs_type):
    data = read_pbs_file(pbs_type)
    d = {}
    start_line = 1
    if pbs_type in ["moves"]:
        start_line = 0
    for line in data.splitlines()[start_line:]:
        parts = line.split(',')
        d[parts[1].strip()] = parts[2].strip()
    return d

def split_text_into_blocks(text):
    blocks = []
    for block in re.split('\n*#[-]+\n*', text):
        if block == "":
            continue
        blocks.append(block)

    curated_blocks = []
    for block in blocks:
        if '#-------------------------------#' in block:
            continue
        if '# trainer categories:' in block:
            continue
        if block[0] == '#' and block[-1] == '#':
            continue
        curated_blocks.append(block)
    return curated_blocks

def get_data_from_block(block: str, lookup: dict):
    raw_lines = block.splitlines()
    lines = []
    # Takes out comments and extra whitespace per line
    for pos in range(len(raw_lines)):
        
        line = raw_lines[pos]
        match = re.search("\#.*", line)
        if match is not None:
            found = match.group(0)
            line = line.replace(found, "")
        line = line.strip()
        if line != '':
            lines.append(line)

    data = {
        "trainer_class": lookup['trainertypes'][lines[0]],
        "trainer_name": lines[1].split(',')[0]
        }

    # This code ended up being unused
    # try:
    #     data["encounter_number"] = int(lines[1].split(',')[1])
    # except IndexError:
    #     data["encounter_number"] = 0

    num_mons = int(lines[2].split(',')[0])

    # gets item data
    data['items'] = []
    for item in lines[2].split(',')[1:]:
        if item != '':
            data['items'].append(lookup['items'][item])

    # does all pokemon data.
    data['pokemon'] = []
    p_list = data['pokemon']
    for line in lines[3:3 + num_mons]:
        if '###########################' in line:
            continue
        line_parts = line.split(',')

        # default pokemon values
        p_list.append({
            "name": '',
            "level":0,
            "item": '',
            "moves":[],
            "ability_id":'-1',
            "ability": '',
            "gender": "",
            "form_id": '0',
            "form": '',
            #"shininess": False,
            "nature": "Serious",
            "ivs": 10,
            #"happiness": 70,
            #"nickname": "",
            "shadow": False,
            "evs": [0,0,0,0,0,0],
            "style_name": '',
            "api_name": ''
            })

        #fixes name
        p_list[-1]["name"] = get_correct_pokemon_name(line_parts[0])[0]
        p_list[-1]["style_name"], p_list[-1]["api_name"] = get_correct_pokemon_name(line_parts[0])

        # fixes level
        p_list[-1]["level"] = int(line_parts[1])

        # adds held item if there is one
        try:
            if line_parts[2] != '': 
                p_list[-1]["item"] = lookup['items'][line_parts[2]]
        except IndexError:
            continue

        # adds moves if they are there
        for pos in range(3, 7):
            try:
                if line_parts[pos] != '':
                    p_list[-1]["moves"].append(lookup['moves'][line_parts[pos]])
            except IndexError:
                continue

        # gets form id if there is one
        try:
            if line_parts[9] == '':
                p_list[-1]["form_id"] = '0'
            else:
                if line_parts[9] == "O":
                    p_list[-1]["form_id"] = '0'
                else:
                    p_list[-1]["form_id"] = line_parts[9]
        except (IndexError):
            p_list[-1]["form_id"] = '0'

        # gets ability id if there is one
        try: 
            if line_parts[7] == '':
                pass
            else:
                p_list[-1]["ability_id"] = line_parts[7]
        except (IndexError):
            continue

        # adds form
        run_again = True
        working_name = p_list[-1]["name"].lower().replace(' ', '-').replace('.','').replace("'",'')
        id = int(p_list[-1]["form_id"])
        while run_again:
            try:    
                p_list[-1]["form"] = lookup['pokemon_forms'][working_name][str(id)]
                run_again = False
            except KeyError as e:
                id -= 1

        # adds ability
        if p_list[-1]["ability_id"] != '-1':
            id = int(p_list[-1]["ability_id"])
            try:
                p_list[-1]["ability"] = lookup['pokemon_abilities'][p_list[-1]["form"].lower()][str(id)].capitalize()
            except KeyError:
                try:                 
                    p_list[-1]["ability"] = lookup['pokemon_abilities'][p_list[-1]["form"].lower()][str(id - 1)].capitalize()
                except KeyError:
                    p_list[-1]["ability"] = lookup['pokemon_abilities'][p_list[-1]["form"].lower()][str(id - 2)].capitalize()
            except (IndexError, ValueError) as e:
                continue

        #adds gender
        try:
            p_list[-1]["gender"] = line_parts[8]
        except IndexError:
            continue

        # adds shininess. unused later in the program.
        # try:
        #     p_list[-1]["shininess"] = bool(line_parts[10])
        # except IndexError:
        #     continue
        
        # adds nature
        try:
            p_list[-1]["nature"] = line_parts[11].capitalize()
        except IndexError:
            continue

        # adds IVs
        try:
            p_list[-1]["ivs"] = int(line_parts[12])
        except (IndexError, ValueError):
            continue

        # adds happiness. unused in program
        # try:
        #     p_list[-1]["happiness"] = int(line_parts[13])
        # except (IndexError, ValueError):
        #     continue

        # adds nickname. unused in program.
        # try:
        #     p_list[-1]["nickname"] = line_parts[14]
        # except IndexError:
        #     continue

        # adds shadowness
        try:
            p_list[-1]["shadow"] = bool(line_parts[15])
        except (IndexError, ValueError):
            continue

        # adds EVs
        for pos in range(18, 24):
            try:
                p_list[-1]["evs"][pos - 18] = int(line_parts[pos])
            except (IndexError, ValueError):
                continue
        
    return data
    
def generate_trainer_string(trainer):
    lines = []

    def get_item_string():
        c = Counter(trainer["items"])
        if not c:
            return ''
        strs = []
        for item in c:
            if c[item] == 1:
                strs.append(item)
            else:
                strs.append(f"{c[item]}x {item}")
        return f" ({', '.join(strs)})"
    lines.append(f'**{trainer["trainer_class"]} {trainer["trainer_name"]}{get_item_string()}. Field: **')
    
    def ev_print(evs_list):
        # Here I assume EVs come in as HP/ATK/DEF/SPE/SPA/SPD but will
        # Print them in the format HP/ATK/DEF/SPA/SPD/SPE
        clone = list(evs_list)
        speed = clone.pop(3)
        clone.append(speed)
        return '/'.join([str(ev) for ev in clone])

    for pokemon in trainer["pokemon"]:
        str_parts = []
        if pokemon["form"].title() in ODD_ONES:
            str_parts.append(pokemon["name"])
        else:
            str_parts.append(f"{pokemon['form'].title()}")

        str_parts.append(f"Lv. {pokemon['level']}")
        
        if pokemon['item']:
            str_parts.append(f"@{pokemon['item']}")

        if pokemon['ability_id'] != '-1':
            str_parts.append(f"Ability: {pokemon['ability'].title()}")
            
            # Fixes small format issues 
            str_parts[-1] = str_parts[-1].replace("Rks", "RKS").replace("Soul Heart", "Soul-Heart")
        
        # meowstic handling - just replace form name and ability if 2
        if pokemon["name"].upper() == "MEOWSTIC" and pokemon["gender"] == "F":
            str_parts[0] = "Meowstic-Female"
            if pokemon["ability_id"] == '2':
                str_parts[-1] = "Ability: Competitive"

        if pokemon['nature']: 
            str_parts.append(f"{pokemon['nature']} Nature")

        if pokemon['ivs']: 
            # abusing python typing because i don't remember type, like a boss
            if pokemon['ivs'] in (32, '32'):
                str_parts.append(f"IVs: 31 (0 Speed)")
            else:
                str_parts.append(f"IVs: {pokemon['ivs']}")


        if pokemon['evs'] != [0,0,0,0,0,0]:
            str_parts.append(f"EVs: {ev_print(pokemon['evs'])}")
        
        lines.append("- " + ', '.join(str_parts))

        for move in pokemon["moves"]:
            lines.append("    - " + move)

    return '\n'.join(lines)

def generate_trainer_text(text, game='reborn'):

    lookup = {}
    for pbs in ['moves', 'items', 'abilities', 'trainertypes']:
        lookup[pbs] = create_lookup(pbs)
    
    lookup["pokemon_abilities"] = read_api_json("api_ability_data.json")
    lookup["pokemon_forms"] = read_api_json("api_form_data.json")

    #print (lookup["pokemon_abilities"])
    #print (lookup["pokemon_forms"])



    data = []
    blocks = split_text_into_blocks(text)
    print (f"Total blocks found: {len(blocks)}. Processing...")
    for block in blocks:
        data.append((get_data_from_block(block, lookup)))
    
    out = []
    for trainer in data[:]:
        #print(trainer)
        out.append(generate_trainer_string(trainer))
    
    return '\n\n'.join(out)

def main():
    game = process_game_arg()

    data = read_pbs_file("trainers", game)
    outfile = write_resource_file(generate_trainer_text(data, game), "trainers")
    print (f"Generated encounters textfile at {outfile}.")

    
if __name__ == "__main__":
    main()