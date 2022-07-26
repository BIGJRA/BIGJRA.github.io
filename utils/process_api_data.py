from mimetypes import common_types
from pokebase import ability
import requests
import json
from common import *

NUM_POKEMON = 905

def write_api_data_json(data, filename):
    name = os.path.join(os.path.abspath(os.pardir), 'bigjra.github.io',
     'resources', filename)
    try:
        with open(name, 'w') as f:
            f.write(json.dumps(data))
        return name
    except FileNotFoundError as e:
        print (e)
        return

def pokeapi_request_json(body):
    url = fr'https://pokeapi.co/api/v2/' + body
    try:
        response = requests.get(url)
        return response.json()
    except requests.exceptions.RequestException as e:
        print (e)
        return

def generate_form_id_lookup(verbose=False):
    print ("Pulling Form data from pokeapi...")
    lookup = {}
    # keys are pokemon name string
    # value is dict: form_no int, pokemon form name string
    for pokemon_no in range(1, NUM_POKEMON + 1):
        d = pokeapi_request_json(f"pokemon-species/{pokemon_no}")
        if d is None:
            continue
        name = d['name']
        lookup[name] = {}
        for form_no in range(len(d['varieties'])):
            lookup[name][form_no] = d['varieties'][form_no]['pokemon']['name']
        if verbose:
            print (name, lookup[name])
    return lookup

def generate_ability_id_lookup(form_data, verbose=False):
    print ("Pulling Ability data from pokeapi...")
    lookup = {}
    # keys are pokemon name string
    # value is dict: ability_id int, ability name string
    for pokemon_name in form_data:
        form_dict = form_data[pokemon_name]
        for form_name in form_dict.values():
            d = pokeapi_request_json(f"pokemon/{form_name}")
            if d is None:
                continue
            lookup[form_name] = {}
            for ability_id in range(len(d['abilities'])):
                lookup[form_name][ability_id] = d['abilities'][ability_id]['ability']['name'].replace('-',' ').title()
        if verbose:
            print (form_name, lookup[form_name])

    # HARD FIXES
    fixes = [
        ('hawlucha', '0', '1')
        ]
    for name, id1, id2 in fixes:
        lookup[name][id1], lookup[name][id2] = lookup[name][id2], lookup[name][id1]
        if verbose:
            print (name, lookup[name])

    return lookup

def main(verbose=True):
    form_data = generate_form_id_lookup(verbose)
    write_api_data_json(form_data, "api_form_data.json")
    ability_data = generate_ability_id_lookup(form_data, verbose)
    write_api_data_json(ability_data, "api_ability_data.json")

if __name__ == "__main__":
    main()