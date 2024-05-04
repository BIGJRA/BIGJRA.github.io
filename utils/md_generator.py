from common import *
from function_wrapper import FunctionWrapper

def generate_md_text(version="reborn"):
    def generate_md_pre_contents(version="reborn"):
        return f'''---
title: Pokemon {version.capitalize()} Walkthrough
---

<p id="title-text">Pokemon {version.capitalize()} Walkthrough </p>

'''
  
    def generate_toc_contents():
        toc = ""
        for chapter_type, total_chapters in SECTIONS[version]:
            for chapter_num in range(1, total_chapters + 1):
                raw_md = load_chapter_md(version, chapter_type, chapter_num)
                for line in [line for line in raw_md.split('\n') if line.startswith('#')]:
                    indents = len(line) - len(line.lstrip('#')) - 1
                    next_line = f"""{"  " * indents}- [{line.lstrip('#')[1:]}](#{
                        line.lstrip('#')[1:]
                        .lower()
                        .translate(str.maketrans('', '', string.punctuation.replace('-', '')))
                        .replace(' ', '-')
                    })\n"""
                    toc += next_line
        return toc + '\n\n'
   
    def generate_md_post_contents():
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
                #Function Wrapper class does the magic of taking a line 
                # beginning with ! and transforming it into a dynamic output:
                # taking a shortened function name, arguments, and globals
                function_result = function_wrapper.evaluate_function_from_string(line)
                res.append(function_result)
        return '\n'.join(res)
    
    function_wrapper = FunctionWrapper(version)

    res = ''
    res += generate_md_pre_contents()
    res += generate_toc_contents()
    for chapter_type, total_chapters in SECTIONS[version]:
        for chapter_num in range(1, total_chapters + 1):
            res += generate_chapter_contents(chapter_type, chapter_num)
    res += generate_md_post_contents()

    return res


if __name__ == "__main__":
    md = generate_md_text()
    # print(md)
