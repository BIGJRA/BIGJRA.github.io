require_relative 'common'
require_relative 'function_wrapper'

def generate_md_text(game = 'reborn', scripts_dir)
  func_wrapper = FunctionWrapper.new(game, scripts_dir)

  def generate_md_pre_contents(game = 'reborn')
    <<~PRE_CONTENTS
      ---
      title: Pokemon #{LONGNAMES[game].capitalize} Walkthrough
      permalink: /#{LONGNAMES[game]}/
      ---

      <p id="title-text">Pokemon #{LONGNAMES[game].capitalize} Walkthrough </p>
      <h5> Walkthrough last updated #{Time.now.strftime("%d %b %Y @ %H:%M")} GMT</h5>
      <h5> Based on game ver. #{VERSIONS[game]}</h5>
    PRE_CONTENTS
  end

  def generate_toc_contents(game)
    toc = ''
    ['main', 'post', 'appendices'].each do |chapter_type|
      chapter_num = 1
      loop do
        raw_md = load_chapter_md(game, chapter_type, chapter_num)
        break if !raw_md
        raw_md.each_line do |line|
          next unless line.start_with?('#')
          indents = line[/^#+/].length - 1
          title = line.strip[indents + 1..].strip # Remove the leading '#' and any extra spaces
          anchor_link = title.downcase.gsub(/[^a-z0-9e\s-]/, '').gsub(/\s/, '-') # Convert title to lowercase, remove non-alphanumeric characters except spaces and dashes, and replace spaces with dashes
          toc += "#{'  ' * indents}- [#{title}](##{anchor_link})\n"
        end
        chapter_num += 1
        break if chapter_type == "appendices"
      end
    end
    toc + "\n"
  end

  def generate_md_post_contents
    ''
  end

  def generate_chapter_contents(game, scripts_dir, type, num, func_wrapper)
    raw_md = load_chapter_md(game, type, num)
    return nil if !raw_md

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
  ['main', 'post', 'appendices'].each do |chapter_type|
    chapter_num = 1
    loop do
      curr = generate_chapter_contents(game, scripts_dir, chapter_type, chapter_num, func_wrapper)
      break if !curr
      res += "#{curr}\n"
      chapter_num += 1
      break if chapter_type == "appendices"
    end
  end
  res += generate_md_post_contents
  res.strip

  # func_wrapper.trainerGetter.report_missing_trainers()

  res
end
