import os
import yaml
import sys
import json
import string

from collections import defaultdict, deque

def load_sections_yaml(file_path):
    with open(file_path, 'r') as file:
        sections = yaml.safe_load(file)
    return sections

GAMES = ["reborn", "rejuv"]
MON_NAME_FIX_DICT = {
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

def read_pbs_file(pbs_file_name, game='reborn'):
    directory = game.capitalize() + "_pbs"
    file = pbs_file_name.lower() + ".txt"
    name = os.path.join(os.path.abspath(os.pardir), 'bigjra.github.io',
     '_datafiles', directory, file)
    try:
        with open(name) as f:
            data = f.read()
        return data
    except FileNotFoundError as e:
        print (e)

def write_resource_file(text, pbs_file_name, game='reborn'):

    directory = game.capitalize() + "_txt"
    file = pbs_file_name.lower() + "_resource.txt"
    name = os.path.join(os.path.abspath(os.pardir), 'bigjra.github.io',
     'resources', directory, file)
    try:
        with open(name, 'w') as f:
            f.write(text)
        return name
    except FileNotFoundError as e:
        print (e)

def get_correct_pokemon_name(string):
    ans = string.capitalize()
    if ans in MON_NAME_FIX_DICT:
        return MON_NAME_FIX_DICT[ans]
    return [ans, ans]

def process_game_arg():
    try:
        game = sys.argv[1].lower()
    except IndexError:
        print ("WARNING: Game not provided as argument. Proceeding with game='reborn'...")
        game = "reborn"
    if game not in GAMES:
        raise ValueError(f"{game} is not a valid game.")
    return game

def read_api_json(json_file_name):
    try: 
        with open(os.path.join(os.path.abspath(os.pardir), 'bigjra.github.io', 'resources', json_file_name)) as f:
            return json.load(f)
    except FileNotFoundError as e:
        print (e)