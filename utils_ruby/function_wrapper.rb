require_relative 'common'

# This is the magic class of the rewrite. 
# Each function should return a string of some kind (can be multiline)
class FunctionWrapper
  def initialize(version)
    # I need to pass in version to basically all of the potential functions, so 
    # here we stick it in as as an argument. Anything that is consistent
    # across the whole document (ie. Version) should be used here:
    @attrs = { version: version }

    # Shortnames (not required)
    @shortnames = { "img" => "generate_image_markdown" }
  end

  def evaluate_function_from_string(s)
    '''Transforms a walkthrough function string into a function call and returns its contents.
    s is a string that should look like:
        "!functionname(arg1,arg2)" where:
        arguments are optional, functionname is short or long
    returns a string in valid markdown format corresponding to the evaluated function.
    '''
    s = s.strip[1..-2]
    func_shortname, args = s.split('(')

    # Shortnames should make things quicker while coding - full function names work too
    func = @shortnames[func_shortname] || func_shortname

    run_str = "#{func}(#{args}, **@attrs)"
    return eval(run_str) + "\n" # evaluates function, preserves its newline
  end
end
