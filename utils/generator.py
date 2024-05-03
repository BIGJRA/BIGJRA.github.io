from common import *

current_directory = os.path.dirname(os.path.abspath(__file__))
root_directory = os.path.dirname(current_directory)

def generate_md_text(version="reborn"):
    def generate_md_pre_contents(version="reborn"):
        return f'''---
title: |
Pokemon {version.capitalize()} Walkthrough
---

<p id="title-text">Pokemon {version.capitalize()} Walkthrough </p>

'''

    def generate_toc_contents(sections_list):
        toc = ""
        q = deque()
        for section in sections_list[::-1]:
            q.appendleft((section, 0))
        while q:
            section, indents = q.popleft()
            next_line = f"""{"  " * indents}- [{section['title']}](#{
                section['title']
                .lower()
                .translate(str.maketrans('', '', string.punctuation.replace('-', '')))
                .replace(' ', '-')
            })\n"""
            toc += next_line
            if 'subsections' in section:
                for subsection in section['subsections'][::-1]:
                    q.appendleft((subsection, indents + 1))
        return toc

    def generate_md_post_contents(version="reborn"):
        # TODO
        return ''
    
    game_contents_dir = os.path.join(root_directory, version)

    section_data = load_sections_yaml(os.path.join(game_contents_dir, 'sections.yml'))['sections']

    res = ''
    res += generate_md_pre_contents(version)
    res += generate_toc_contents(section_data)
    res += generate_md_post_contents(version)

    return res


if __name__ == "__main__":
    md = generate_md_text()
    print(md)
