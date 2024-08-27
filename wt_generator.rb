# The Markdown to be processed by Jekyll is not committed directly - instead, it is processed
# by this script to ensure game data is being pulled effectively.
# Run with arguments <game>, <scripts directory>, <outputfile path>, to generate markdown appropriately.

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
unless ['reborn', 'rejuv'].include?(game)
  puts "Invalid game type. Please specify 'reborn' or 'rejuv'."
  exit 1
end

# Generate markdown content based on the game type
markdown_contents = generate_md_text(game, scripts_dir)
puts "Generated markdown contents for #{game}!"

# Write content to the specified file
File.open(output_file, 'w') do |f|
  f.write(markdown_contents)
end

puts "Wrote contents to #{output_file}!"
