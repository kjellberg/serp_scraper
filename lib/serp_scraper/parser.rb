# frozen_string_literal: true

require "nokogiri"

module SerpScraper
  class Parser
    SEARCH_ENGINE_SELECTORS = {
      google: [
        "#search", # Main search container
        ".g",      # Search results
        "#rso"     # Results container
      ],
      bing: [
        "#b_results",
        ".b_algo"
      ],
      yahoo: [
        "#web",
        ".searchCenterMiddle"
      ]
    }.freeze

    def initialize(html)
      @doc = Nokogiri::HTML(html)
    end

    def parse
      {
        query: extract_query,
        search_engine: detect_search_engine,
        results: nil
      }
    end

    private

    def detect_search_engine
      SEARCH_ENGINE_SELECTORS.each do |engine, selectors|
        return engine if selectors.any? { |selector| @doc.css(selector).any? }
      end
      :unknown
    end

    def extract_query
      # Try to find the search query in various ways
      query = @doc.css('input[name="q"]').first&.[]("value") ||
              @doc.css('input[name="p"]').first&.[]("value") ||
              @doc.css("title").first&.text&.split("-")&.first&.strip

      query || "unknown"
    end
  end
end
