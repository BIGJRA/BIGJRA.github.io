import os
import yaml
import sys
import json
import string

from collections import defaultdict, deque

UTILS_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(UTILS_DIR)

SECTIONS = {"reborn": (("main", 19), ("post", 9), ("appendices", 1)), "rejuv": (("main", 15),)}

def get_game_contents_dir(version):
    return os.path.join(ROOT_DIR, version)

def load_chapter_md(version, type, chapter_num):
    game_contents_dir = get_game_contents_dir(version)
    if type != 'appendices':
        file_path = os.path.join(game_contents_dir, f'{type}_ep_{str(chapter_num).zfill(2)}.md')
    else:
        file_path = os.path.join(game_contents_dir, 'appendices.md')
    with open(file_path, 'r') as f:
        contents = f.read()
    return contents

def function1(arg1):
    return f"""Function put inside of text
    This is an interpolated argument, set to "foo" in the markdown itself: {arg1}"""

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