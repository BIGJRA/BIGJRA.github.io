require 'json'
require 'yaml'

UTILS_DIR = File.dirname(File.expand_path(__FILE__))
ROOT_DIR = File.dirname(UTILS_DIR)
CONFIG = YAML.safe_load(File.open(File.join(ROOT_DIR, "_config.yml")))

SCRIPTS_DIR = CONFIG['scripts_dir']

GAMES = ["reborn", "rejuv"]
SECTIONS = {"reborn" => [["main", 19], ["post", 9], ["appendices", 1]], "rejuv" => [["main", 15]]}

MON_NAME_FIX_DICT = {
  "Nidoranma" => ["Nidoran M.", "Nidoran-M"],
  "Nidoranfe" => ["Nidoran F.", "Nidoran-F"],
  "Mimejr" => ["Mime Jr.", "Mime-Jr"],
  "Mrmime" => ["Mr. Mime", "Mr-Mime"],
  "Typenull" => ["Type: Null", "Type-Null"],
  "Tapukoko" => ["Tapu Koko", "Tapu-Koko"],
  "Tapubulu" => ["Tapu Bulu", "Tapu-Bulu"],
  "Tapufini" => ["Tapu Fini", "Tapu-Fini"],
  "Tapulele" => ["Tapu Lele", "Tapu-Lele"],
  "Mrrime" => ["Mr. Rime", "Mr-Rime"],
  "Hooh" => ["Ho-oh", "Ho-oh"],
  "Porygonz" => ["Porygon-Z", "Porygon-Z"],
  "Jangmoo" => ["Jangmo-o", "Jangmo-o"],
  "Hakamoo" => ["Hakamo-o", "Hakamo-o"],
  "Kommoo" => ["Kommo-o", "Kommo-o"],
  "Farfetchd" => ["Farfetch'd", "Farfetchd"],
  "Sirfetchd" => ["Sirfetch'd", "Sirfetchd"],
  "Porygon2" => ["Porygon2", "Porygon2"],
  "Flabebe" => ["Flabebe", "Flabebe"]
}

def get_game_contents_dir(version)
  File.join(ROOT_DIR, "raw", version)
end

def load_chapter_md(version, type, chapter_num)
  game_contents_dir = get_game_contents_dir(version)
  if type != 'appendices'
    file_path = File.join(game_contents_dir, "#{type}_ep_#{chapter_num.to_s.rjust(2, '0')}.md")
  else
    file_path = File.join(game_contents_dir, 'appendices.md')
  end
  File.read(file_path)
end

def generate_image_markdown(filename, **kwargs)
  version = kwargs[:version]
  #v = kwargs[:version] || "reborn"
  "<img class=\"tabImage\" src=\"/static/images/#{version}/#{filename}\"/>"
end