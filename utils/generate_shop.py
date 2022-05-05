t = '''

*Protector* $2100

*Magmarizer* $2100

*Dragon Scale* $2100

*Electrizer* $2100

*DeepSeaTooth* $200

*DeepSeaScale* $200

*Up-Grade* $2100

*Dubious Disc* $2100

*Prism Scale* $500

*Sachet* $1000

*Whipped Dream* $1000

*Razor Claw* $2100

*Oval Stone* $2100

*Razor Fang* $2100

*Reaper Cloth* $2100

'''

lines = t.split('\n')
items = []
prices = []
outs = []
for line in lines:
    if line == '':
        continue
    item, price = line.split('* ')
    item += "*"
    #print (item, price)
    items.append(item)
    prices.append(price)
lengths = max(max([len(i) for i in items]), 4), max(max([len(i) for i in prices]), 5)
outs.append(f"|{'Item'.ljust(lengths[0])}|{'Price'.ljust(lengths[1])}|")
outs.append(f"|{'-' * lengths[0]}|{'-' * lengths[1]}|")
#print (lengths)
for line in lines:
    if line == '':
        continue
    item, price = line.split('* ')
    item += "*"
    outs.append(f"|{item.ljust(lengths[0])}|{price.ljust(lengths[1])}|")
print ("\n".join(outs))
