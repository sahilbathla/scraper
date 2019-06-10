require 'selenium/webdriver'

class Scrapper
  DATA_IDENTIFIERS = {
    category: {
      xpath: '.merchant-menu-category_header',
      children: {
        item_name: '.offer-tile_name',
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
    Capybara.register_driver :chrome do |app|
      Capybara::Selenium::Driver.new(app, browser: :chrome)
    end

    Capybara.register_driver :headless_chrome do |app|
      capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
          chromeOptions: { args: %w(headless no-sandbox disable-gpu) }
      )

      Capybara::Selenium::Driver.new app,
                                     browser: :chrome,
                                     desired_capabilities: capabilities
    end

    Capybara.javascript_driver = :headless_chrome
  end

  def fetch_html
    config
    session = Capybara::Session.new(:headless_chrome)
    session.visit(@url)
    @html = session.html
  end

  def scrape_data
    doc = Nokogiri::HTML(@html)
    doc.css(DATA_IDENTIFIERS[:category][:xpath]).each do |category|
      category_result = {}
      category_result[category.text] = []
      child_element_path = DATA_IDENTIFIERS[:category][:children][:item_name]
      length = category.parent.css(child_element_path).count
      length.times do |i|
        children_paths = DATA_IDENTIFIERS[:category][:children]
        category_result[category.text] << {
          item_name: category.parent.css(children_paths[:item_name])[i]&.text || 'N/A',
          modifiers: category.parent.css(children_paths[:modifiers])[i]&.text || 'N/A',
          price: category.parent.css(children_paths[:price])[i]&.text || 'N/A'
        }
      end
      @result << category_result
    end
  end
end
