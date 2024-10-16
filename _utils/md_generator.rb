require_relative 'common'
require_relative 'function_wrapper'

def generate_md_text(game = 'reborn', scripts_dir)
  func_wrapper = FunctionWrapper.new(game, scripts_dir)

  def generate_md_pre_contents(game = 'reborn')
    <<~PRE_CONTENTS
      ---
      title: Pokemon #{game.capitalize} Walkthrough
      permalink: /#{game}/
      ---

      <p id="title-text">Pokemon #{game.capitalize} Walkthrough </p>
      <h5> Walkthrough last updated #{Time.now.strftime("%d %b %Y @ %H:%M")} GMT</h5>
      <h5> Based on game ver. #{VERSIONS[game]}</h5>
    PRE_CONTENTS
  end

  def generate_toc_contents(game)
    toc = ''
    SECTIONS[game].each do |chapter_type, total_chapters|
      (1..total_chapters).each do |chapter_num|
        raw_md = load_chapter_md(game, chapter_type, chapter_num)
        raw_md.each_line do |line|
          next unless line.start_with?('#')

          indents = line[/^#+/].length - 1
          title = line.strip[indents + 1..].strip # Remove the leading '#' and any extra spaces
          anchor_link = title.downcase.gsub(/[^a-z0-9e\s-]/, '').gsub(/\s/, '-') # Convert title to lowercase, remove non-alphanumeric characters except spaces and dashes, and replace spaces with dashes
          toc += "#{'  ' * indents}- [#{title}](##{anchor_link})\n"
        end
      end
    end
    toc + "\n"
  end

  def generate_md_post_contents
    ''
  end

  def generate_chapter_contents(game, scripts_dir, type, num, func_wrapper)
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
    res.join
  end

  res = ''
  res += generate_md_pre_contents(game)
  res += generate_toc_contents(game)
  SECTIONS[game].each do |chapter_type, total_chapters|
    (1..total_chapters).each do |chapter_num|
      res += generate_chapter_contents(game, scripts_dir, chapter_type, chapter_num, func_wrapper)
      res += "\n"
    end
  end
  res += generate_md_post_contents
  res.strip

  # func_wrapper.trainerGetter.report_missing_trainers()

  res
end
