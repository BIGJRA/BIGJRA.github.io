require_relative 'common'

class ShopGetter
  attr_accessor :version
  attr_accessor :itemhash


  def initialize(version)
    @version = version
    @itemhash = load_item_hash(@version)
    @price_lookup = load_price_lookup()
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
      
    thead_row = doc.create_element('tr')
    thead.add_child(thead_row)
    
    table_header = doc.create_element('th', colspan: 2)
    thead_row.add_child(table_header)

    bold = doc.create_element('strong')
    bold.content = "Shop: #{shop_title}"
    table_header.add_child(bold)
    table_header['class'] = 'table-header'
    table_header['style'] = 'text-align: center;'
    
    shop_items.each do |item|
      content_row = doc.create_element('tr')
      table.add_child(content_row)
      
      # Column 1: Item Name (italicized)
      td_item = doc.create_element('td', style: 'text-align: center')
      td_item.add_child(doc.create_element('em', content=item))
      table.add_child(td_item)
    
      # Column 2: Price
      td_price = doc.create_element('td', style: 'text-align: center')
      td_price.content = "$#{@price_lookup[item]}"
      table.add_child(td_price)
    end

      
    #     # Add Pokemon's name to the first column
    #     td_name = doc.create_element('td', style: 'text-align: center')
        
    #     # Apply bold style to the content
    #     bold = doc.create_element('strong')
    #     bold.content = pokemon_name.to_s.capitalize
    #     td_name.add_child(bold)
    #     tr.add_child(td_name)
        
    #     # Add levels to the second column
    #     td_levels = doc.create_element('td', style: 'text-align: center')
    #     td_levels.content = mon_data["levels"]
    #     tr.add_child(td_levels)
        
    #     # Add encounter types to additional columns
    #     types.each do |encounter_type|
    #     # [:LandMorning, :LandDay, :LandNight].each do |encounter_type|
    #       td_encounter_type = doc.create_element('td', style: 'text-align: center')
    #       td_encounter_type.content = mon_data[encounter_type].to_s + "%"
    #       tr.add_child(td_encounter_type)
    #     end

    #     table.add_child(tr)
    #   end
    # end

    html_output = doc.to_html 
    return html_output.split("\n")[1..].join("\n")

  end

  private 

  def load_price_lookup()
    prices = {}
    @itemhash.each do |symbol, contents|
      prices[contents[:name]] = contents[:price]
    end
    prices
  end

end

def main
  e = ShopGetter.new('reborn')
  puts e.get_shop_items("Opal Ward Ice Cream Store", ["Vanilla Ice Cream", "Choc Ice Cream", "Berry Ice Cream", "Blue Moon Ice Cream"])
end

main if __FILE__ == $PROGRAM_NAME
