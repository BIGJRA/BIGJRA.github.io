require_relative 'common'
require_relative 'function_wrapper'

def generate_md_text(version = "reborn")
  function_wrapper = FunctionWrapper.new(version)

  def generate_md_pre_contents(version = "reborn")
    <<~PRE_CONTENTS
      ---
      title: Pokemon #{version.capitalize} Walkthrough
      ---

      <p id="title-text">Pokemon #{version.capitalize} Walkthrough </p>

    PRE_CONTENTS
  end
  
  def generate_toc_contents(version)
    toc = ""
    SECTIONS[version].each do |chapter_type, total_chapters|
      (1..total_chapters).each do |chapter_num|
        raw_md = load_chapter_md(version, chapter_type, chapter_num)
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
    toc + "\n\n"
  end
  
  
  

  def generate_md_post_contents
    # TODO
    ''
  end
  
  def generate_chapter_contents(version, type, num, function_wrapper)
    raw_md = load_chapter_md(version, type, num) 

    # Store chapter text as an array of lines - join them at the end
    res = []
    raw_md.each_line do |line|
      if line.strip.empty? || line[0] != '!'
        res << line
      elsif line[0] == '!'
        # Function Wrapper class does the magic of taking a line 
        # beginning with ! and transforming it into a dynamic output:
        # taking a shortened function name, arguments, and globals
        function_result = function_wrapper.evaluate_function_from_string(line)
        res << function_result
      end
    end
    res.join
  end

  res = ''
  res += generate_md_pre_contents(version)
  res += generate_toc_contents(version)
  SECTIONS[version].each do |chapter_type, total_chapters|
    (1..total_chapters).each do |chapter_num|
      res += generate_chapter_contents(version, chapter_type, chapter_num, function_wrapper)
    end
  end
  res += generate_md_post_contents

  res
end

md = generate_md_text
# puts(md)
