import re
import os

with open(r'c:/Users/jakes/OneDrive/Documents/BIGJRA.github.io/rejuv.md', encoding='ISO-8859-1') as f:
    text = f.read()
#print ("finished reading")

chars = []
for char in text:
    if ord(char) > 128:
        chars.append(char)
        
print (len(chars))
for char in set(chars):
    print(text[text.index(char) - 100 : text.index(char) + 100])

