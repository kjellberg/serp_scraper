# frozen_string_literal: true

require "selenium/webdriver"
require "webdrivers"
require "nokogiri"
require "tempfile"
require "serp_scraper/parser"

module SerpScraper
  class Google
    USER_AGENTS = [
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
      "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.3.1 Safari/605.1.15",
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Edge/123.0.0.0 Safari/537.36",
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:124.0) Gecko/20100101 Firefox/124.0",
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:124.0) Gecko/20100101 Firefox/124.0"
    ].freeze

    def initialize(query:, params: {}, proxy: nil, tld: "com")
      @query = query
      @params = params
      @proxy = proxy
      @tld = tld
    end

    def fetch
      driver = setup_driver
      url = build_url

      begin
        driver.navigate.to(url)
        sleep 2 # Give the page time to load

        if captcha_detected?(driver.page_source)
          {
            status: "error",
            error_message: "Blocked by Captcha",
            request: {
              query: @query,
              params: @params,
              proxy: @proxy
            }
          }
        else
          html = clean_html(driver.page_source)
          temp_file = Tempfile.new([ "google_serp", ".html" ])
          temp_file.write(html)
          temp_file.close

          parser = Parser.new(html)
          parsed = parser.parse

          {
            status: "success",
            html_path: temp_file.path,
            parsed: parsed,
            request: {
              query: @query,
              params: @params,
              proxy: @proxy
            }
          }
        end
      rescue StandardError => e
        {
          status: "error",
          error_message: e.message,
          request: {
            query: @query,
            params: @params,
            proxy: @proxy
          }
        }
      ensure
        driver.quit
      end
    end

    private

    def setup_driver
      options = Selenium::WebDriver::Chrome::Options.new

      # Use a random user agent
      options.add_argument("--user-agent=#{USER_AGENTS.sample}")

      # Disable automation flags
      options.add_argument("--disable-blink-features=AutomationControlled")

      # Set window size to a common resolution
      options.add_argument("--window-size=1920,1080")

      # Run in headless mode
      options.add_argument("--headless=new")

      if @proxy
        options.add_argument("--proxy-server=#{@proxy}")
      end

      driver = Selenium::WebDriver.for(:chrome, options: options)

      # Remove webdriver flag
      driver.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")

      driver
    end

    def base_url
      "https://www.google.#{@tld}/search"
    end

    def build_url
      query_params = {
        q: @query,
        num: 100,
        filter: 0
      }.merge(@params)

      "#{base_url}?#{URI.encode_www_form(query_params)}"
    end

    def captcha_detected?(html)
      captcha_indicators = [
        "unusual traffic from your computer network",
        "please type the characters below",
        "recaptcha",
        "captcha",
        "verify you're not a robot"
      ]

      captcha_indicators.any? { |indicator| html.downcase.include?(indicator) }
    end

    def clean_html(html)
      doc = Nokogiri::HTML(html)

      # Remove all script tags
      doc.css("script").remove

      # Remove all elements with role="dialog"
      doc.css('[role="dialog"]').remove

      # Remove fixed positioning and overflow restrictions
      doc.css("*").each do |node|
        style = node["style"]
        if style
          # Remove fixed positioning
          style.gsub!(/position:\s*fixed;?/, "")
          # Remove overflow restrictions
          style.gsub!(/overflow:\s*(hidden|auto|scroll);?/, "")
          # Remove z-index
          style.gsub!(/z-index:\s*\d+;?/, "")
          # Remove height restrictions
          style.gsub!(/height:\s*\d+px;?/, "")
          # Remove max-height restrictions
          style.gsub!(/max-height:\s*\d+px;?/, "")

          # If style is empty after cleaning, remove it
          node.remove_attribute("style") if style.strip.empty?
        end
      end

      # Ensure body and html elements are scrollable
      doc.css("body, html").each do |node|
        node["style"] = "overflow: auto; height: auto;"
      end

      # Ensure main content area is scrollable
      doc.css("#main, #search, .main, .search").each do |node|
        node["style"] = "overflow: auto; height: auto;"
      end

      doc.to_html
    end
  end
end
