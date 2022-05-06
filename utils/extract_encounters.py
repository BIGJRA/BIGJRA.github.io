from asyncore import write
from gettext import find
import os
import re
from collections import defaultdict

POKEMON_WIDTH = 18
PERCENT_WIDTH = 3
ENC_TYPES = {
    "Land": [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
    "LandMorning": [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
    "LandDay": [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
    "LandNight": [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
    "Water": [60, 30, 5, 4, 1],
    "RockSmash": [60, 30, 5, 4, 1],
    "Cave": [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
    "OldRod": [70, 30],
    "GoodRod": [60, 20, 20],
    "SuperRod": [40, 40, 15, 4, 1],
    "HeadbuttLow": [30, 25, 20, 10, 5, 5, 4, 1],
    "HeadbuttHigh": [30, 25, 20, 10, 5, 5, 4, 1]
}
ENC_NAMES = {
    "OldRod": "Old Rod",
    "GoodRod": "Good Rod",
    "SuperRod": "Super Rod",
    "WaterGoodRodSuperRod": "Water/G+S Rods",

    "Land": "Land",
    "LandMorningLandDayLandNight": "Land",
    "LandMorning": "Land (Morning)",
    "LandDay": "Land (Day)",
    "LandMorningLandDay": "Land (Morning/Day)",
    "LandNight": "Land (Night)",

    "Cave": "Cave",
    "Water": "Water",
    "RockSmash": "Rock Smash",
    "HeadbuttLow": "Headbutt Rare",
    "HeadbuttHigh": "Headbutt Common",
    "HeadbuttLowHeadbuttHigh": "Headbutt"
}


def read_me(game_name='reborn'):
    with open(f"utils\{game_name}_pbs\encounters.txt") as f:
        data = f.read()
    return data

def write_me(content, game_name="reborn"):
    with open(f"{game_name}_encounter_tables.txt", 'w') as f:
        f.write(content)

def split_text_into_blocks(text):
    blocks = []
    for block in re.split('\n*#[#]+\n*', text):
        if block == "":
            continue
        blocks.append(block)
    return blocks

def get_correct_pokemon_name(string):
    ans = string.capitalize()
    d = {
        "Nidoranma": "Nidoran M.",
        "Nidoranfe": "Nidoran F.",
        "Mimejr": "Mime Jr.",
        "Mrmime": "Mr. Mime",
        "Typenull": "Type: Null",
        "Tapukoko": "Tapu Koko",
        "Tapubulu": "Tapu Bulu",
        "Tapufini": "Tapu Fini",
        "Tapulele": "Tapu Lele",
        "Mrrime": "Mr. Rime",
        "Hooh": "Ho-oh",
        "Porygonz": "Porygon-Z",
        "Jangmoo": "Jangmo-o",
        "Hakamoo": "Hakamo-o",
        "Kommoo": "Kommo-o",
        "Farfetchd": "Farfetch'd",
        "Sirfetchd": "Sirfetch'd",
        "Porygon2": "Porygon2",
        "Flabebe": "Flabebe"
    }
    if ans in d:
        return d[ans]
    return ans
    
def get_data_from_block(block):
    content = block.split('\n')
    data = {}
    data['area_code'], data['area_name'] = content[0].split(' # ')
    #print (content[0].split(' # '))
    data['encounter_rates'] = tuple(content[1].split(','))
    for line in content[2:]:
        if line in ENC_TYPES:
            curr_type = line
            data[curr_type] = defaultdict(list)
            pos = 0
        else:
            pokemon = line.split(',')[0]
            pokemon = get_correct_pokemon_name(pokemon)
            data[curr_type][pokemon] += [pos]
            pos += 1
    for enc_type in ENC_TYPES:
        if enc_type in data:
            for pokemon in data[enc_type]:
                enc_percent = 0
                for pos in data[enc_type][pokemon]:
                    enc_percent += ENC_TYPES[enc_type][pos]
                data[enc_type][pokemon] = enc_percent
    return data

def get_markdown_tables(data):
    mini_tables = []
    equalities = find_equalities(data)
    for equality in equalities:
        data[equality.replace(' ','')] = data[equality.split(' ')[0]]
        for item in equality.split(' '):
            del data[item]
    for enc_type in data:
        if enc_type not in ["area_code", "area_name", "encounter_rates"]:
            lines = [f"|{ENC_NAMES[enc_type].ljust(POKEMON_WIDTH)}|{'%'.ljust(PERCENT_WIDTH)}|"]
            lines.append(f'|{"-" * POKEMON_WIDTH}|{"-" * PERCENT_WIDTH}|')
            for pokemon in sorted(data[enc_type], key= lambda x: -data[enc_type][x]):
                lines.append(f"|{pokemon.ljust(POKEMON_WIDTH)}|{str(data[enc_type][pokemon]).ljust(PERCENT_WIDTH)}|")
            mini_tables.append('\n'.join(lines))
    return mini_tables

def find_equalities(data):
    d = {}
    groups = defaultdict(list)
    for enc_type in data:
        if enc_type not in ["area_code", "area_name", "encounter_rates"]:
            if tuple(data[enc_type]) in d:
                groups[d[tuple(data[enc_type])]].append(enc_type)
                #print (d[tuple(data[enc_type])], enc_type)
            else:
                d[tuple(data[enc_type])] = enc_type
    return [f"{item} {' '.join(groups[item])}" for item in groups]

def combine_tables(mini_tables):
    rows = 0
    #print (*mini_tables, sep = '\n\n')
    for table in mini_tables:
        rows = max(rows, len(table.split('\n')))
    for pos, table in enumerate(mini_tables):
        for gap in range(rows - len(table.split('\n'))):
            table += f"\n|{' '* POKEMON_WIDTH}|{' '* PERCENT_WIDTH}|"
        mini_tables[pos] = table
    #print (*mini_tables, sep = '\n\n')
    groups = zip(*(s.splitlines() for s in mini_tables))
    result = '\n'.join(''.join(pair) for pair in groups)
    result = result.replace('||','|')
    return result

def process_mini_tables(mini_tables):
    land_ones = []
    rod_ones = []
    other_ones = []
    for table in mini_tables:
        if "Land" in table:
            land_ones.append(table)
        elif "Rod" in table:
            rod_ones.append(table)
        else:
            other_ones.append(table)
    #print (land_ones, other_ones, rod_ones)
    finals = []
    for x in [land_ones, rod_ones, other_ones]:
        x.sort(key = lambda y: list(ENC_NAMES.values()).index(y[1: 1 + POKEMON_WIDTH].rstrip())) 
        if x != []:
            finals.append(combine_tables(x))
    return finals

text = read_me()
out = []
blocks = split_text_into_blocks(text)
for block in blocks:
    data = get_data_from_block(block)
    #print (data)
    tables = get_markdown_tables(data)
    #print (*tables)
    out.append(data["area_code"])
    out.append('\n')
    out.append(data["area_name"])
    out.append("\n\n")
    #print (data["area_code"])
    for thing in process_mini_tables(tables):
        #print (thing)
        out.append(thing)
        out.append('\n\n')
    #print (*process_mini_tables(tables), sep = '\n\n')
    out.append("\n")
#print (*tables, sep='\n\n')
write_me(''.join(out))

