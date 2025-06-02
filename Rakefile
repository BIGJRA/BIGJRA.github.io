require 'rake'

desc "Serve Jekyll site"
task :serve do
  sh "bundle exec jekyll serve --source src --destination _site"
end

desc "Build Jekyll site"
task :build do
  sh "bundle exec jekyll build --source src --destination _site"
end

desc "Generate Markdown for Reborn"
task :generate_reborn do
  sh "ruby wt_generator.rb reborn ~/reborn/Scripts src/reborn.md"
end

desc "Generate Markdown for Rejuvenation"
task :generate_rejuv do
  sh "ruby wt_generator.rb rejuv ~/reborn/Scripts src/rejuv.md"
end