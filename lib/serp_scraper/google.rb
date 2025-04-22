# frozen_string_literal: true

require "selenium/webdriver"
require "webdrivers"
require "nokogiri"

module SerpScraper
  class Google
    BASE_URL = "https://www.google.com/search"

    def initialize(query:, params: {}, proxy: nil)
      @query = query
      @params = params
      @proxy = proxy
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
          {
            status: "success",
            raw_html: clean_html(driver.page_source),
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
      
      # Use a common user agent
      options.add_argument("--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36")
      
      # Disable automation flags
      options.add_argument("--disable-blink-features=AutomationControlled")
      
      # Set window size to a common resolution
      options.add_argument("--window-size=1920,1080")
      
      if @proxy
        options.add_argument("--proxy-server=#{@proxy}")
      end

      driver = Selenium::WebDriver.for(:chrome, options: options)
      
      # Remove webdriver flag
      driver.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")
      
      driver
    end

    def build_url
      query_params = {
        q: @query
      }.merge(@params)

      "#{BASE_URL}?#{URI.encode_www_form(query_params)}"
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
      
      # Remove all style tags
      doc.css("style").remove
      
      # Remove all noscript tags
      doc.css("noscript").remove
      
      # Remove all iframe tags
      doc.css("iframe").remove
      
      # Remove all link tags with rel="stylesheet"
      doc.css('link[rel="stylesheet"]').remove
      
      # Remove navigation and header elements
      doc.css("header, nav, .gb_wa, .gb_1d, .gb_3d, .gb_3c, .gb_3a, .gb_3b").remove
      
      # Remove footer elements
      doc.css("footer, .fbar, .fbar a, .fbar span").remove
      
      # Remove ads
      doc.css(".ads, .adsbygoogle, .ad, .ads-fr, .ads-ad, .ads-feed").remove
      
      # Remove cookie consent and other popups
      doc.css(".cookie-consent, .popup, .modal, .overlay").remove
      
      # Remove social media buttons and sharing elements
      doc.css(".social, .share, .social-share, .social-buttons").remove
      
      # Remove tracking pixels and analytics elements
      doc.css("img[width='1'][height='1'], img[style*='display:none']").remove
      
      # Remove empty divs and spans
      doc.css("*").each do |node|
        node.remove if node.text.strip.empty? && node.children.empty?
      end
      
      # Remove comments
      doc.xpath("//comment()").remove
      
      # Remove data attributes
      doc.css("*").each do |node|
        node.attributes.each do |name, _|
          node.remove_attribute(name) if name.start_with?("data-")
        end
      end
      
      # Remove class and id attributes from non-essential elements
      doc.css("*:not(.g):not(.tF2Cxc):not(.yuRUbf):not(.IsZvec):not(.VwiC3b):not(.r):not(.s):not(.kp-wholepage)").each do |node|
        node.remove_attribute("class")
        node.remove_attribute("id")
      end
      
      doc.to_html
    end
  end
end 