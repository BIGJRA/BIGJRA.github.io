from collections import defaultdict

t = '''|Pokemon|Condition|
|---|---|
|**Hitmonchan**|20, Atk\<Def|
|**Hitmonlee**|20, Atk\>Def|
|**Hitmontop**|20, Atk=Def|
|**Weavile**|Razor Claw + Level @ Night|
|**Gliscor**|Razor Fang + Level @ Night|
|**Magnezone**|Level in: Generator Room|
|**Probopass**|Level in: Generator Room|
|**Leafeon**|Level in: Terajuma Jungle: Moss Rock|
|**Glaceon**|Level in: Evergreen Cave: Icy Rock|
|**Mamoswine**|Relearn Ancient Power + Level|
|**Tyrantrum**|39, Daytime|
|**Aurorus**|39, Nighttime|
|**Goodra**|50, Requires overworld rain (Sheridan Wetlands!)|
|**Gumshoos**|20, Daytime|
|**Vikavolt**|Level in: Terajuma Jungle|
|**Obstagoon**|35, Nighttime|
|**Sirfetch'd**|Get 3 crits in one battle|
|**Runerigus**|Take at least 49 damage without dying during a battle in Wispy Ruins|
|**Alolan Raticate**|20, Nighttime|
|**Alolan Marowak**|28, Nighttime|
|**Galarian Mr. Mime**|Level with Mimic (L.15) at Icy Rock|'''

lines = t.split('\n')
out = []
max_lengths = defaultdict(int)
for line in lines[0:1] + lines[2:]:
    parts = line.split('|')[1:-1]
    for pos, part in enumerate(parts):
        parts[pos] = part.lstrip().rstrip()
        max_lengths[pos] = max(max_lengths[pos], len(parts[pos]))
    #print (max_lengths)
for line in lines[0:1] + lines[2:]:
    parts = line.split('|')[1:-1]
    for pos, part in enumerate(parts):
        parts[pos] = part.lstrip().rstrip()
    out.append(f"|{'|'.join([part.ljust(max_lengths[pos]) for pos, part in enumerate(parts)])}|")
out = out[:1] + [f"|{'|'.join(['-' * max_lengths[idx] for idx in range(len(parts))])}|"] + out[1:]
print ('\n'.join(out))


