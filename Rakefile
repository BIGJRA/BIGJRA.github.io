require 'rake'
require 'json'
require 'fileutils'

require 'dotenv'
Dotenv.load

CONFIG_FILE = ".scripts_versions.json"

def ensure_scripts_repo(name)
  private_repo_pat = ENV["PRIVATE_REPO_PAT"]
  private_repo_git_url = ENV["PRIVATE_REPO_GIT_URL"]

  if private_repo_pat.nil? || private_repo_git_url.nil?
    abort "❌ Missing PRIVATE_REPO_PAT or PRIVATE_REPO_GIT_URL environment variables."
  end

  config = JSON.parse(File.read(CONFIG_FILE))
  commit = config[name]
  dir = "_scripts_#{name}"

  repo_url = "https://x-access-token:#{private_repo_pat}@#{private_repo_git_url}"

  unless Dir.exist?(dir)
    puts "Cloning #{repo_url} into #{dir}..."
    sh "git clone #{repo_url} #{dir}"
  end

  Dir.chdir(dir) do
    puts "Fetching latest changes..."
    sh "git fetch --all"
    puts "Checking out #{commit} for #{name}..."
    sh "git checkout #{commit}"
  end

  dir
end

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
  dir = ensure_scripts_repo("reborn")
  sh "ruby wt_generator.rb reborn #{dir} src/reborn.md"
end

desc "Generate Markdown for Rejuvenation"
task :generate_rejuv do
  dir = ensure_scripts_repo("rejuv")
  sh "ruby wt_generator.rb rejuv #{dir} src/rejuv.md"
end

desc "Generate Markdown for Desolation"
task :generate_deso do
  dir = ensure_scripts_repo("deso")
  sh "ruby wt_generator.rb deso #{dir} src/deso.md"
end