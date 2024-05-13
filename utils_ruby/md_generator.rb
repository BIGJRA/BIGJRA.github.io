require_relative 'common'
require_relative 'function_wrapper'

def generate_md_text(game = "reborn")
  func_wrapper = FunctionWrapper.new(game)

  def generate_md_pre_contents(game = "reborn")
    <<~PRE_CONTENTS
      ---
      title: Pokémon #{game.capitalize} Walkthrough
      ---

      <p id="title-text">Pokémon #{game.capitalize} Walkthrough </p>

    PRE_CONTENTS
  end
  
  def generate_toc_contents(game)
    toc = ""
    SECTIONS[game].each do |chapter_type, total_chapters|
      (1..total_chapters).each do |chapter_num|
        raw_md = load_chapter_md(game, chapter_type, chapter_num)
        raw_md.each_line do |line|
          if line.start_with?('#')
            indents = line[/^#+/].length - 1
            title = line.strip[indents + 1..].strip  # Remove the leading '#' and any extra spaces
            anchor_link = title.downcase.gsub(/[^a-z0-9 -]/, '').tr(' ', '-')  # Convert title to lowercase, remove non-alphanumeric characters except spaces, and replace spaces with dashes
            toc += "#{'  ' * indents}- [#{title}](##{anchor_link})\n"
          end
        end
      end
    end
    toc + "\n"
  end

  def generate_md_post_contents
    # TODO
    ''
  end
  
  def generate_chapter_contents(game, type, num, func_wrapper)
    raw_md = load_chapter_md(game, type, num) 

    # Store chapter text as an array of lines - join them at the end
    res = []
    raw_md.each_line do |line|
      if line.strip.empty? || line[0] != '!'
        res << line
      elsif line[0] == '!'
        # Function Wrapper class does the magic of taking a line 
        # beginning with ! and transforming it into a dynamic output:
        # taking a shortened function name, arguments, and globals
        function_result = func_wrapper.evaluate_function_from_string(line)
        res << function_result
      end
    end
    return res.join
  end

  res = ''
  res += generate_md_pre_contents(game)
  res += generate_toc_contents(game)
  SECTIONS[game].each do |chapter_type, total_chapters|
    (1..total_chapters).each do |chapter_num|
      res += generate_chapter_contents(game, chapter_type, chapter_num, func_wrapper)
      res += "\n"
    end
  end
  res += generate_md_post_contents
  res.strip
  res
end