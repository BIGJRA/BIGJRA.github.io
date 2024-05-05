from common import *

# This is the magic class of the rewrite. 
# Each function should return a string of some kind (can be multiline)

class FunctionWrapper:
    def __init__(self, version):
        # I need to pass in version to basically all of the potential functions, so 
        # here we stick it in as as an argument. Anything that is consistent
        # across the whole document (ie. Version) should be used here:
        self.version = version

        # Shortnames (not required)
        self.shortnames = {"img": "generate_image_markdown"}

    def evaluate_function_from_string(self, s):
        '''Transforms a walkthrough function string into a function call and returns its contents.
        s is a string that should look like:
            "!functionname(arg1,arg2)" where:
            arguments are optional, functionname is short or long
        returns a string in valid markdown format corresponding to the evaluated function.
        '''
        
        s = s.lstrip('!').strip()[:-1]
        func_shortname, args = s.split('(')

        # Shortnames should make things quicker while coding - full function names work too
        func = self.shortnames[func_shortname] if func_shortname in self.shortnames else func_shortname

        run_str = f"{func}({args})"
        return eval(run_str)
