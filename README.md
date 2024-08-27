# BIGJRA.github.io

Welcome to the BIGJRA.github.io repository! This is my ever-evolving Pokemon Reborn and Rejuvenation walkthrough project, forged through years of experience with web development and learning new tips and tricks.

The project is built using Jekyll and includes scripts that generate dynamic content based on a local copy of game files - instructions for building the project are below.

There actually two major steps being done in this build process:

1. Ruby-based markdown build that imports data straight from the game's files and raw walkthrough markdown files, creating `<walkthrough>.md`.
2. Jekyll converts the `<walkthrough>.md` files into browser-ready `<walkthrough>.html` files. 

## Prerequisites

Before you get started, make sure you have the following:

- **Ruby**: Installed on your machine. [Install Ruby](https://www.ruby-lang.org/en/documentation/installation/)
- **Bundler**: For managing Ruby gems. Install it with `gem install bundler`.
- **Git**: For version control and cloning repositories. [Install Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

## Preparing Walkthrough Markdown via Ruby Command

The primary Ruby script in this project, `wt_generator.rb`, generates markdown files based on the scripts and game data. You need to run this script with the appropriate arguments.

### Command Syntax

ruby wt_generator.rb <game> <scripts directory> <output file>

- `<game>`: Specify the game type (`reborn` or `rejuv`).
- `<scripts directory>`: Path to the directory containing the scripts. This project relies on Reborn and Rejuvenation's Scripts directories - those found in the (most recent) game's files itself will work locally for most purposes.
- `<output file>`: Path to the file where the generated markdown will be saved. To serve with Jekyll later, this by default should be `./src/<game>.md`.

## Building and Running Locally

Jekyll is configured in this project to serve appropriate files in the `src` directory. To build and run the site locally, use the following commands:

1. **Install Dependencies**:

   `bundle install`

2. **Build the Jekyll Site**:

   `bundle exec jekyll build --source src --destination _site`

3. **Serve the Site Locally**:

   `bundle exec jekyll serve --source src --destination _site`

   Open [http://localhost:4000](http://localhost:4000) in your web browser to view the site.

## Contributing

If you want to contribute to this project, please follow the standard open-source practices: fork, create a branch, commit your changes, push, and open a pull request back to my repository. In particular, 99% of errors with walkthrough information can be solved by editing the appropriate raw markdown section in the `src/_raw` directory.

Please join my [Discord Server](https://discord.gg/3r83avH4sv) with any questions or for more significant contributions! Thank you.