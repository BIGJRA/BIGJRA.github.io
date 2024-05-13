import re
import json

def create_item_lookup():
    with open(rf"utils\reborn_pbs\items.txt") as f:
        data = f.read()
    d = {}
    for line in data.splitlines()[1:]:
        parts = line.split(',')
        d[parts[1]] = parts[2]
    return d

def read_me(game_name='reborn', file="pokemon"):
    with open(rf"utils\{game_name}_pbs\{file}.txt", encoding='utf8') as f:
        data = f.read()
    return data

def write_me(content, game_name="reborn"):
    with open(f"{game_name}_wild_held.txt", 'w') as f:
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

def get_data(text):
    blocks = []
    for block in re.split('\n\[\d+\]\n', text):
        if block == "":
            continue
        blocks.append(block)
    d = {}
    for block in blocks:
        lines = block.splitlines()
        for line in lines:
            if "InternalName" in line:
                int_name = line.split('=')[1].strip()
                name = get_correct_pokemon_name(int_name)[0]
                d[name] = ['', '', '']
                break
        for line in lines:        
            for pos, kind in enumerate(["WildItemCommon", "WildItemUncommon", "WildItemRare"]):
                if kind in line:
                    int_item_name = line.split('=')[1].strip()
                    item_name = f'*{item_lookup[int_item_name]}*'
                    d[name][pos] = item_name
    return d
    

def generate_table(data):
    p_len = i_len = 0
    for pokemon, items in data.items():
        p_len = max(p_len, len(pokemon))
        i_len = max(i_len, max([len(item) if item else 0 for item in items]))
    lines = [
        f'|{"Pokémon".ljust(p_len)}|{"Common (50%)".ljust(i_len)}|{"Uncommon (5%)".ljust(i_len)}|{"Rare (1%)".ljust(i_len)}|',
        f"|{'-' * p_len}|{'-' * i_len}|{'-' * i_len}|{'-' * i_len}|"
    ]
    for pokemon, items in data.items():
        if items == ['', '', '']:
            continue
        line = f'|{pokemon.ljust(p_len)}'
        for item in items:
            line += f'|{item.ljust(i_len)}'
        line += "|"
        lines.append(line)
    return '\n'.join(lines)

item_lookup = create_item_lookup()
# print(item_lookup)

text = read_me()
data = get_data(text)
#print (generate_table(data))
write_me(generate_table(data))
print ("DONE")