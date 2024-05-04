import md_generator

reborn_md = md_generator.generate_md_text()

with open('dummy_reborn.md', 'w') as f:
    f.write(reborn_md)
    print("Wrote to dummy_reborn.md!")