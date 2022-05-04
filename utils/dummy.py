import re
import os

with open(r'c:/Users/jakes/OneDrive/Documents/BIGJRA.github.io/rejuv.md', encoding='ISO-8859-1') as f:
    text = f.read()
#print ("finished reading")

found = re.findall(r'[A-Z|a-z|0-9|\.] - [A-Z|a-z|0-9|\. ]+\n', text)
print (found)

#new = []
#for thing in found:
#    if len({str(num) for num in [0,1,2,3,4,5,6,7,8,9]}.intersection(set(thing))) > 0:
#        new.append(thing)

#for thing in new:
#    text = text.replace(thing, thing[0] + '\n')

#with open("rejuv_out.md", 'w', encoding='ISO-8859-1') as f:
#    f.write(text)

#print ('done')