require 'capybara/poltergeist'

class Scrapper
  DATA_IDENTIFIERS = {
    category: {
      xpath: '.merchant-menu-category_header',
      children: {
        item_name: 'offer-tile_name',
        modifiers: '.offer-tile_description',
        price: '.offer-tile_price'
      }
    }
  }.freeze

  def initialize(url)
    @url = url
    @html = nil
    @result = []
  end

  def call
    fetch_html
    scrape_data
    @result
  end

  private

  def config
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, {
        timeout: 10000,
        phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes', '--ssl-protocol=any']
      })
    end
  end

  def fetch_html
    config
    session = Capybara::Session.new(:poltergeist)
    session.visit(@url)
    @html = session.html
  end

  def scrape_data
    doc = Nokogiri::HTML(@html)
    doc.css(DATA_IDENTIFIERS[:category][:xpath]).each do |category|
      category_result = {}
      category_result[category.text] = []
      DATA_IDENTIFIERS[:category][:children].each do |name, child_element_path|
        child_data = {}
        child_data[name] = doc.css(doc.css(child_element_path)).text || 'N/A'
        category_result[category.text] << child_data
      end
      @result << category_result
    end
  end
end
