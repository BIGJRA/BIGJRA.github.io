# The Markdown to be processed by Jekyll is not committed directly - instead, it is processed
# by this script to ensure game data is being pulled effectively.
# Run with arguments <game>, <scripts directory>, <outputfile path>, to generate markdown appropriately.

require 'fileutils'
require_relative '_utils/md_generator'

# Check for correct number of arguments
if ARGV.length != 3
  puts "Usage: ruby wt_generator.rb <game> <scripts directory> <output file>"
  exit 1
end

# Assign arguments to variables
game = ARGV[0]
scripts_dir = ARGV[1]
output_file = ARGV[2]

# Validate game type
unless ['reborn', 'rejuv', 'deso'].include?(game)
  puts "Invalid game type. Please specify 'reborn', 'deso', or 'rejuv'."
  exit 1
end

# Generate markdown content based on the game type
result = generate_md_text(game, scripts_dir)
markdown_contents = result[:monolithic]
chapters = result[:chapters]
puts "Generated markdown contents for #{game}!"
puts "Generated #{chapters.length} paginated chapters"

# Write monolithic content to the specified file
begin
  if File.exist?(output_file)
    timestamp = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    dir = File.dirname(output_file)
    base = File.basename(output_file, "")
    new_name = File.join(dir, "_arch", "#{base}.#{timestamp}")
    File.rename(output_file, new_name)
    puts "Existing file renamed to #{new_name}"
  end

  File.open(output_file, 'w') do |f|
    f.write(markdown_contents)
  end

  puts "Wrote contents to #{output_file}!"
rescue => e
  STDERR.puts "Error writing output file: #{e.message}"
  exit 1
end

# Write paginated chapter files
begin
  chapters_dir = File.dirname(output_file)
  paginated_dir = File.join(chapters_dir, "#{game}-chapters")
  FileUtils.mkdir_p(paginated_dir)

  chapters.each do |chapter|
    page_title = if chapter[:slug] == 'appendices'
                   "#{LONGNAMES[game].capitalize} Appendices"
                 elsif chapter[:slug] == 'karma-files-paragon'
                   "#{LONGNAMES[game].capitalize} Karma Files (Paragon)"
                 elsif chapter[:slug] == 'karma-files-renegade'
                   "#{LONGNAMES[game].capitalize} Karma Files (Renegade)"
                 elsif chapter[:slug].start_with?('postgame-episode-')
                   episode_num = chapter[:slug].sub('postgame-episode-', '')
                   "#{LONGNAMES[game].capitalize} Postgame Episode #{episode_num}"
                 elsif chapter[:slug].start_with?('episode-')
                   episode_num = chapter[:slug].sub('episode-', '')
                   "#{LONGNAMES[game].capitalize} Episode #{episode_num}"
                 elsif chapter[:slug].start_with?('chapter-')
                   chapter_num = chapter[:slug].sub('chapter-', '')
                   "#{LONGNAMES[game].capitalize} Chapter #{chapter_num}"
                 else
                   "#{LONGNAMES[game].capitalize} #{chapter[:title]}"
                 end

    page_content = <<~PAGE_CONTENTS
      ---
      title: "#{page_title}"
      permalink: /#{game}/#{chapter[:slug]}/
      ---

      #{chapter[:content]}
    PAGE_CONTENTS

    page_file = File.join(paginated_dir, "#{chapter[:slug]}.md")
    File.write(page_file, page_content.strip)
  end

  puts "Generated #{chapters.length} paginated chapter files in #{paginated_dir}"
rescue => e
  STDERR.puts "Error writing paginated chapter files: #{e.message}"
  exit 1
end
