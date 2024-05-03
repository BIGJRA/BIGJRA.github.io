import generator

reborn_md = generator.generate_md_text()

with open('dummy_reborn.md', 'w') as f:
    f.write(reborn_md)