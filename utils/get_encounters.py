
from multiprocessing.sharedctypes import Value
import os
import re
import sys
from collections import defaultdict
from turtle import write_docstringdict
from common import *

POKEMON_WIDTH = 19 # width of pokemon name column for encounter md tables
PERCENT_WIDTH = 3 # width of percent for encounter md tables. 
# (always 3 for vals <= 100)

ENC_TYPES = {
    # stores probability array per encounter type as defined in 
    # pokemon essentials
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
    # Keys are internal name concatenations
    # Values are readable representations of each grouping
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

CORR_MON_NAMES = {
        # keys are internal names, values are formatted names
        # for usage: if not listed, use internal name
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

def split_text_into_blocks(text):
    blocks = []
    for block in re.split('\n*#[#]+\n*', text):
        if block == "":
            continue
        blocks.append(block)
    return blocks

def get_correct_pokemon_name(string):
    ans = string.capitalize()
    if ans in CORR_MON_NAMES:
        return CORR_MON_NAMES[ans]
    return ans

def get_data_from_block(block):
    content = block.split('\n')
    data = {}
    data['area_code'], data['area_name'] = content[0].split(' # ')
    if data['area_name'][-1] == ' ':
        data['area_name'] = data['area_name'][:-1]
    data['encounter_rates'] = tuple(content[1].split(','))
    for line in content[2:]:
        if line == '':
            continue
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
    #print (len(land_ones), len(other_ones))
    if len(land_ones) + len(other_ones) <= 3 and len(land_ones) > 0:
        land_ones.extend(other_ones)
        other_ones = []

    finals = []
    for x in [land_ones, rod_ones, other_ones]:
        x.sort(key = lambda y: list(ENC_NAMES.values()).index(y[1: 1 + POKEMON_WIDTH].rstrip())) 
        if x != []:
            finals.append(combine_tables(x))
    return finals

def process_encounters(data, game="reborn"):
    out = []
    s = {}
    blocks = split_text_into_blocks(data)

    for block in blocks:
        data = get_data_from_block(block)
        tables = get_markdown_tables(data)
        string_tables = '\n\n'.join(process_mini_tables(tables))
        if not string_tables in s:
            s[string_tables] = []
        s[string_tables].append((data["area_code"], data["area_name"]))

    for thing, l in s.items():
        codes = ', '.join([thing[0] for thing in l])
        names = '**' + ', '.join(sorted(list(set([thing[1] for thing in l])))) + '**'
        out.append(codes)
        out.append('\n')
        out.append(names)
        out.append("\n\n")
        out.append(thing)
        out.append("\n\n")

    return(''.join(out))

def main():
    game = process_game_arg()

    data = read_pbs_file("encounters", game)
    outfile = write_resource_file(process_encounters(data, game), "encounters")
    print (f"Generated encounters textfile at {outfile}.")


if __name__ == "__main__":
    main()