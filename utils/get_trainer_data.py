
from dataclasses import dataclass
import os
import re
from collections import defaultdict
from pokebase import pokemon
import requests
import json
from functools import cache

@cache


@cache


# @cache
# def get_ability_from_id_native(id, pokemon_name):
#     pokemon_data = read_me('reborn', 'pokemon')
#     split = re.split(r'\[\d+\]\n', data)
#     for idx in range(len(split)):
#         lines = split[idx].splitlines()
#         if lines[1] == f"InternalName={pokemon_name.upper()}":
#             return lines[11].split('=')[1].split()[id]


def create_trainertype_lookup():
    filename = os.path.join(os.path.abspath(os.pardir), 'bigjra.github.io', '_datafiles', 'reborn_pbs', 'trainertypes.txt')
    with open(filename) as f:
        data = f.read()
    d = {}
    for line in data.splitlines()[1:]:
        parts = line.split(',')
        d[parts[1].strip()] = parts[2].strip()
    return d

def create_item_lookup():
    filename = os.path.join(os.path.abspath(os.pardir), 'bigjra.github.io', '_datafiles', 'reborn_pbs', 'items.txt')
    with open(filename) as f:
        data = f.read()
    d = {}
    for line in data.splitlines()[1:]:
        parts = line.split(',')
        d[parts[1].strip()] = parts[2].strip()
    return d

def create_move_lookup():
    filename = os.path.join(os.path.abspath(os.pardir), 'bigjra.github.io', '_datafiles', 'reborn_pbs', 'moves.txt')
    with open(filename) as f:
        data = f.read()
    d = {}
    for line in data.splitlines():
        parts = line.split(',')
        d[parts[1].strip()] = parts[2].strip()
    return d

def create_ability_lookup():
    filename = os.path.join(os.path.abspath(os.pardir), 'bigjra.github.io', '_datafiles', 'reborn_pbs', 'abilities.txt')
    with open(filename) as f:
        ability_data = f.read()
    ability_dict = {}
    for line in ability_data.splitlines():
        parts = line.split(',')
        ability_dict[parts[1]] = parts[2]

    filename2 = os.path.join(os.path.abspath(os.pardir), 'bigjra.github.io', '_datafiles', 'reborn_pbs', 'pokemon.txt')
    with open(filename2, encoding='utf8') as f:
        data = f.read()
    d = {}
    split = re.split(r'\[\d+\]\n', data)
    del split[0]
    for idx in range(len(split)):
        lines = split[idx].splitlines()
        name = lines[1][13:]
        d[name] = {}
        for idx in range(len(lines)):
            if lines[idx][:4] == "Abil":
                found = idx
                break
        for idx, ability in enumerate(lines[found].split('=')[1].split(',')):
            d[name][idx] = ability_dict[ability]
    return d

def read_me(game_name='reborn', file="trainers"):
    filename = os.path.join(os.path.abspath(os.pardir), 'bigjra.github.io', '_datafiles', 'reborn_pbs', 'trainers.txt')
    with open(filename) as f:
        data = f.read()
    return data

def write_me(content, game_name="reborn"):
    with open(f"{game_name}_trainer_data.txt", 'w') as f:
        f.write(content)

def get_correct_pokemon_name(string):
    ans = string.capitalize()
    d = {
        "Nidoranma": ["Nidoran M.", "Nidoran-M"],
        "Nidoranfe": ["Nidoran F.", "Nidoran-F"],
        "Mimejr": ["Mime Jr.", "Mime-Jr"],
        "Mrmime": ["Mr. Mime", "Mr-Mime"],
        "Typenull": ["Type: Null", "Type-Null"],
        "Tapukoko": ["Tapu Koko", "Tapu-Koko"],
        "Tapubulu": ["Tapu Bulu", "Tapu-Bulu"],
        "Tapufini": ["Tapu Fini", "Tapu-Fini"],
        "Tapulele": ["Tapu Lele", "Tapu-Lele"],
        "Mrrime": ["Mr. Rime", "Mr-Rime"],
        "Hooh": ["Ho-oh", "Ho-oh"],
        "Porygonz": ["Porygon-Z", "Porygon-Z"],
        "Jangmoo": ["Jangmo-o", "Jangmo-o"],
        "Hakamoo": ["Hakamo-o", "Hakamo-o"],
        "Kommoo": ["Kommo-o", "Kommo-o"],
        "Farfetchd": ["Farfetch'd", "Farfetchd"],
        "Sirfetchd": ["Sirfetch'd", "Sirfetchd"],
        "Porygon2": ["Porygon2", "Porygon2"],
        "Flabebe": ["Flabebe", "Flabebe"]
    }
    if ans in d:
        return d[ans]
    return [ans, ans]

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

def get_data_from_block(block: str):
    lines = block.splitlines()
    data = {}
    data["trainer_class"] = type_lookup[lines[0]]
    data["trainer_name"] = lines[1].split(',')[0]
    try:
        data["encounter_number"] = int(lines[1].split(',')[1])
    except IndexError:
        data["encounter_number"] = 0
    num_mons = int(lines[2].split(',')[0])
    data['items'] = []
    for item in lines[2].split(',')[1:]:
        if item != '':
            data['items'].append(item_lookup[item])
    data['pokemon'] = []
    p_list = data['pokemon']
    for line in lines[3:3 + num_mons]:
        if '###########################' in line:
            continue
        line_parts = line.split(',')
        p_list.append({
            "name": '',
            "level":0,
            "item": '',
            "moves":[],
            "ability_id":-1,
            "ability": '',
            "gender": "",
            "form_id": 0,
            "form": '',
            "shininess": False,
            "nature": "Serious",
            "ivs": 10,
            "happiness": 70,
            "nickname": "",
            "shadow": False,
            "evs": [0,0,0,0,0,0],
            "style_name": '',
            "api_name": ''
            })
        p_list[-1]["name"] = get_correct_pokemon_name(line_parts[0])[0]
        p_list[-1]["style_name"], p_list[-1]["api_name"] = get_correct_pokemon_name(line_parts[0])
        p_list[-1]["level"] = int(line_parts[1])
        try:
            if line_parts[2] != '': 
                p_list[-1]["item"] = item_lookup[line_parts[2]]
        except IndexError:
            continue
        for pos in range(3, 7):
            try:
                if line_parts[pos] != '':
                    p_list[-1]["moves"].append(move_lookup[line_parts[pos]])
            except IndexError:
                continue
        try: 
            p_list[-1]["form_id"] = int(line_parts[9])
        except (IndexError, ValueError):
            pass
        try: 
            p_list[-1]["ability_id"] = int(line_parts[7])
        except (IndexError, ValueError):
            pass
        try:
            assert type(p_list[-1]["form_id"]) == int
            p_list[-1]["api-name"] = p_list[-1]["form"]
            p_list[-1]["form"] = get_form_from_id(p_list[-1]["form_id"], p_list[-1]["api_name"])

        except (IndexError, ValueError) as e:
            continue
        
        try:
            assert type(p_list[-1]["ability_id"]) == int
            p_list[-1]["ability"] = ability_lookup[p_list[-1]["form"].upper()][p_list[-1]["ability_id"]]
        except KeyError as e:
            p_list[-1]["ability"] = get_ability_from_id(p_list[-1]["ability_id"], p_list[-1]["form"])
        except (IndexError, ValueError) as e:
            continue

        try:
            p_list[-1]["gender"] = line_parts[8]
        except IndexError:
            continue
        try:
            p_list[-1]["shininess"] = bool(line_parts[10])
        except IndexError:
            continue
        try:
            p_list[-1]["nature"] = line_parts[11].capitalize()
        except IndexError:
            continue
        try:
            p_list[-1]["ivs"] = int(line_parts[12])
        except (IndexError, ValueError):
            continue
        try:
            p_list[-1]["happiness"] = int(line_parts[13])
        except (IndexError, ValueError):
            continue
        try:
            p_list[-1]["nickname"] = line_parts[14]
        except IndexError:
            continue
        try:
            p_list[-1]["shadow"] = bool(line_parts[15])
        except (IndexError, ValueError):
            continue
        for pos in range(18, 24):
            try:
                p_list[-1]["evs"][pos - 18] = int(line_parts[pos])
            except (IndexError, ValueError):
                continue
        
    return data
    

text = read_me()
type_lookup = create_trainertype_lookup()
move_lookup = create_move_lookup()
item_lookup = create_item_lookup()
ability_lookup = create_ability_lookup()
data = []
blocks = split_text_into_blocks(text)
print (f"Total blocks found: {len(blocks)}. Processing...")
count = 0
for block in blocks:
    count +=  1
    data.append((get_data_from_block(block)))
    if count < 5 or count % 25 == 0:
        print (f"Completed block: {count}...")
write_me(json.dumps(data))
print ("DONE")