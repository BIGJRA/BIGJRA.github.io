import os
import sys

GAMES = ["reborn", "rejuv"]

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