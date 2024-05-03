from common import *



def generate_md_text(version="reborn"):
    def generate_md_pre_contents(version="reborn"):
        return f'''---
title: Pokemon {version.capitalize()} Walkthrough
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
    
    def generate_chapter_contents(type='main', num=1):
        raw_md =  load_chapter_md(version, type, num) 

        # Store chapter text as an array of lines - join them at the end
        res = []
        for line in raw_md.split('\n'):
            if line == '' or line[0] != '!':
                res.append(line)
            elif line[0] == '!':
                
                # This is the magic line of the rewrite. Using eval lets me put 
                # Python calls straight into the raw markdowns with ! before, so they
                # can execute dynamically whatever function is necessary. 
                # each eval function should return a string of some kind (can be multiline)

                function_result = eval(line[1:])
                res.append(function_result)
        return '\n'.join(res)
    
    section_data = load_sections_yaml(version)['sections']

    res = ''
    res += generate_md_pre_contents(version)
    res += generate_toc_contents(section_data)
    for chapter_no in range(1, 20):
        res += generate_chapter_contents('main', chapter_no)
    for chapter_no in range(1, 10):
        res += generate_chapter_contents('post', chapter_no)
    res += generate_chapter_contents('appendices')    
    res += generate_md_post_contents(version)

    return res


if __name__ == "__main__":
    md = generate_md_text()
    print(md)
