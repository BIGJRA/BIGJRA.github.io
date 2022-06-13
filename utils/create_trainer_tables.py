import json
from collections import Counter

odd_ones = ['']
odd_ones.extend([f"Minior-{color}-Meteor" for color in [
    "Blue", "Red", "Indigo", "Violet", "Yellow", "Green", "Orange"
    ]])
odd_ones.extend([
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

def read_me():
    with open(f"reborn_trainer_data.txt") as f:
        data = f.read()
    return data

def write_me(content):
    with open(f"reborn_trainer_lists.txt", 'w') as f:
        f.write(content)

def generate_trainer(trainer):
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
    lines.append(f'{trainer["trainer_class"]} {trainer["trainer_name"]}{get_item_string()}. Field: ')
    
    def ev_print(evs_list):
        return '/'.join([str(ev) for ev in evs_list])

    for pokemon in trainer["pokemon"]:
        str_parts = []

        if pokemon["name"] == pokemon["form"] or pokemon["form"] in odd_ones:
            str_parts.append(pokemon["name"])
        else:
            text = f"{pokemon['name']} ({pokemon['form']})"
            if text[-2:] == "()":
                print (pokemon)
            str_parts.append(f"{pokemon['name']} ({pokemon['form']})")

        str_parts.append(f"Lv. {pokemon['level']}")
        
        if pokemon['item']:
            str_parts.append(f"@{pokemon['item']}")

        if pokemon['ability_id'] != -1 and pokemon['ability'] != '':
            str_parts.append(f"Ability: {pokemon['ability']}")
        
        if pokemon['nature']: 
            str_parts.append(f"{pokemon['nature']} Nature")

        if pokemon['ivs']: 
            str_parts.append(f"IVs: {pokemon['ivs']}")

        if pokemon['evs'] != [0,0,0,0,0,0]:
            str_parts.append(f"EVs: {ev_print(pokemon['evs'])}")
        
        lines.append("- " + ', '.join(str_parts))

        for move in pokemon["moves"]:
            lines.append("    - " + move)

    return '\n'.join(lines)

data = json.loads(read_me())
out = []
for trainer in data[:]:
    #print(trainer)
    out.append(generate_trainer(trainer))

write_me('\n\n'.join(out))
print ("done")