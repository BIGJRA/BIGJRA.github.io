require_relative 'md_generator'

reborn_md = generate_md_text()

File.open('dummy_reborn.md', 'w') do |f|
  f.write(reborn_md)
end

puts "Wrote to dummy_reborn.md!"