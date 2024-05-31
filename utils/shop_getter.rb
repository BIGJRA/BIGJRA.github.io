require_relative 'common'

class ShopGetter
  attr_accessor :game
  attr_accessor :item_hash

  def initialize(game, item_hash=nil)
    @game = game
    @itemHash = item_hash ||= load_item_hash(@game)
    @priceLookup = load_price_lookup()
  end

  def generate_shop_markdown(shop_title, shop_items, price_overrides=nil, bold_items=nil)
    price_overrides ||= [nil] * shop_items.length

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
    
    shop_items.each_with_index do |item, position|
      content_row = doc.create_element('tr')
      table.add_child(content_row)
      
      # Column 1: Item Name (italicized)
      td_item = doc.create_element('td', style: 'text-align: center')
      if bold_items
        td_item.add_child(doc.create_element('strong', content=item))
      else
        td_item.add_child(doc.create_element('em', content=item))
      end
      content_row.add_child(td_item)
    
      # Column 2: Price
      price = price_overrides[position].nil? ? @priceLookup[item] : price_overrides[position]
      if price_overrides[position].nil? || price_overrides[position].is_a?(Integer)
        price = "$#{price}"
      end
      td_price = doc.create_element('td', style: 'text-align: center')
      td_price.content = price
      content_row.add_child(td_price)
    end

    html_output = doc.to_html 
    return html_output.split("\n")[1..].join("\n")

  end

  private 

  def load_price_lookup()
    prices = {}
    @itemHash.each do |symbol, contents|
      prices[contents[:name]] = contents[:price]
    end
    prices
  end

end

def main
  e = ShopGetter.new('reborn')
  puts e.generate_shop_markdown("Opal Ward Ice Cream Store", ["Vanilla Ice Cream", "Choc Ice Cream", "Berry Ice Cream", "Blue Moon Ice Cream"])
  puts e.generate_shop_markdown("Opal Ward Ice Cream Store", ["Vanilla Ice Cream", "Choc Ice Cream", "Berry Ice Cream", "Blue Moon Ice Cream"], [1,2,nil,4])

end

main if __FILE__ == $PROGRAM_NAME
