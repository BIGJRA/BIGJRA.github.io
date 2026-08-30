require_relative 'common'

class ShopGetter
  attr_reader :game, :item_hash, :move_hash

  def initialize(game, scripts_dir, item_hash = nil, move_hash = nil)
    @game = game
    @scriptsDir = scripts_dir
    @itemHash = item_hash || load_item_hash(@game, @scriptsDir)
    @moveHash = move_hash || load_move_hash(@game, @scriptsDir)
    @priceLookup = load_price_lookup
    @shopHash = load_shop_hash(@game, @scriptsDir)
  end

  def generate_shop_markdown(shop_title, shop_items)
    # Creates nokogiri HTML
    doc = Nokogiri::HTML::Document.new
    div = doc.create_element('div', class: 'shop_section')
    doc.add_child(div)

    table = doc.create_element('table')
    div.add_child(table)

    # Creates the header for the table
    thead = doc.create_element('thead')
    table.add_child(thead)

    # thead_row = doc.create_element('tr')
    # thead.add_child(thead_row)

    table_header = doc.create_element('th', colspan: 2)
    thead.add_child(table_header)

    bold = doc.create_element('strong')
    bold.content = "Shop: #{shop_title}"
    table_header.add_child(bold)
    table_header['class'] = 'table-header'
    table_header['style'] = 'text-align: center;'

    shop_items.each_with_index do |thing, _position|
      if thing.is_a?(String)
        item = thing
        price = nil
        bold_flag = false
      else
        item = thing[0]
        price = thing[1]
        bold_flag = thing[2]
      end
      content_row = doc.create_element('tr')
      table.add_child(content_row)

      # Column 1: Item Name (italicized)
      td_item = doc.create_element('td', style: 'text-align: center')
      if bold_flag
        td_item.add_child(doc.create_element('strong', content = item))
      else
        td_item.add_child(doc.create_element('em', content = item))
      end
      content_row.add_child(td_item)

      # Column 2: Price
      price = price.nil? ? @priceLookup[item] : price
      price = "$#{price}" if price.is_a?(Integer)
      td_price = doc.create_element('td', style: 'text-align: center')
      td_price.content = price
      raise "Missing price for item #{item}" if price == '' 
      content_row.add_child(td_price)
    end

    html_output = doc.to_html
    html_output.split("\n")[1..].join("\n")
  end

  def generate_cshop_markdown(shop_key, shop_title, badges: 0)
    shop = @shopHash.fetch(shop_key) do
      raise "Unknown shop #{shop_key.inspect}"
    end

    inventory = shop.fetch(:Inventory) do
      raise "Shop #{shop_key.inspect} has no inventory"
    end

    unless inventory.is_a?(Array)
      raise "Shop #{shop_key.inspect} is a shop menu, not an item inventory"
    end

    shop_items = inventory
      .select { |stock| stock_available?(stock, badges: badges) }
      .map do |stock|
        [
          stock_display_name(stock),
          stock_display_price(stock),
          false
        ]
      end

    generate_shop_markdown(shop_title, shop_items)
  end

  private

  def stock_available?(stock, badges:)
    conditions = stock.properties_hash[:conditions]

    return true if conditions.nil? || conditions.empty?

    conditions.all? do |condition|
      condition_met?(condition, badges: badges)
    end
  end

  def condition_met?(condition, badges:)
    condition = condition.strip

    badge_match = condition.match(
      /\A\$Trainer\.numbadges\s*(>=|>|==|<=|<)\s*(\d+)\z/
    )

    if badge_match
      operator = badge_match[1]
      required_badges = badge_match[2].to_i

      return compare_values(badges, operator, required_badges)
    end

    # unique items that buy once, no distinction in wt needed
    if condition.include?("!$game_switches[self.item]")
      return true
    end

    warn "Unrecognized shop condition: #{condition}"
    true
  end

  def compare_values(actual, operator, expected)
    case operator
    when '>=' then actual >= expected
    when '>'  then actual > expected
    when '==' then actual == expected
    when '<=' then actual <= expected
    when '<'  then actual < expected
    else false
    end
  end

  def inspect_cshop(shop_key)
    shop = @shopHash.fetch(shop_key)
    inventory = shop.fetch(:Inventory)

    inventory.each do |stock|
      puts({
        type: stock.stock_type,
        item: stock.item,
        quantity: stock.quantity,
        cost: stock.cost,
        currency: stock.currency,
        properties: stock.properties_hash
      })
    end
  end

  def load_price_lookup
    prices = {}
    @itemHash.each do |_symbol, contents|
      prices[contents[:name].gsub("é", "e")] = contents[:price]
    end
    prices
  end

  def stock_display_name(stock)
    prefix = stock.quantity == 1 ? '' : "#{stock.quantity}x "

    case stock.stock_type
    when :item
      prefix + item_display_name(stock.item)
    when :move
      prefix + move_display_name(stock.item)
    when :currency
      prefix + humanize_symbol(stock.item)
    when :pokemon
      prefix + pokemon_display_name(stock.item)
    else
      prefix + humanize_symbol(stock.item)
    end
  end

  def stock_display_price(stock)
    amount = stock.cost

    # No explicit cost means use the normal item price.
    if amount.nil? && stock.stock_type == :item
      return nil
    end

    # A missing currency represents regular money.
    return amount if stock.currency.nil?

    currency_name = currency_display_name(stock.currency, amount)
    "#{amount} #{currency_name}"
  end

  def item_display_name(item_symbol)
    item_data =
      @itemHash[item_symbol] ||
      @itemHash[item_symbol.to_s] ||
      @itemHash[item_symbol.to_s.upcase]

    return humanize_symbol(item_symbol) unless item_data

    name = item_data[:name] || item_data['name']

    if item_data[:tm]
      move = move_display_name(item_data[:tm])
      name = "#{name} #{move}"
    end

    name.gsub('é', 'e')
  end

  def move_display_name(move_symbol)
  move_data =
    @moveHash[move_symbol] ||
    @moveHash[move_symbol.to_s] ||
    @moveHash[move_symbol.to_s.upcase]

  return humanize_symbol(move_symbol) unless move_data

  move_data[:name] || move_data['name'] || humanize_symbol(move_symbol)
end

  def currency_display_name(currency, amount)
    names = {
      AP: ['AP', 'AP'],
      BP: ['BP', 'BP'],
      Coins: ['Coin', 'Coins'],
      PuppetCoins: ['Puppet Coin', 'Puppet Coins'],
      RedEssence: ['Red Essence', 'Red Essence'],
      BLKPRISM: ['Black Prism', 'Black Prisms'],
      UMBRALSHARD: ['Umbral Shard', 'Umbral Shards'],
      REDSHARD: ['Red Shard', 'Red Shards'],
      BLUESHARD: ['Blue Shard', 'Blue Shards'],
      GREENSHARD: ['Green Shard', 'Green Shards'],
      YELLOWSHARD: ['Yellow Shard', 'Yellow Shards'],
      BIGMUSHROOM: ['Big Mushroom', 'Big Mushrooms'],
      BALMMUSHROOM: ['Balm Mushroom', 'Balm Mushrooms']
    }

    singular, plural = names.fetch(currency) do
      name = humanize_symbol(currency)
      [name, "#{name}s"]
    end

    amount == 1 ? singular : plural
  end

  def humanize_symbol(value)
    value
      .to_s
      .gsub(/([a-z\d])([A-Z])/, '\1 \2')
      .split('_')
      .map(&:capitalize)
      .join(' ')
  end

  def pokemon_display_name(data)
    return humanize_symbol(data) unless data.is_a?(Hash)

    humanize_symbol(data[:species])
  end
end

def main
  getter = ShopGetter.new('rejuv', '_scripts_rejuv')
  puts getter.generate_cshop_markdown(:WispyShop, 'Wispy Shop')
end

main if __FILE__ == $PROGRAM_NAME
