# frozen_string_literal: true

require "nokogiri"
require "json"
require "yaml"

module SerpScraper
  class Parser
    def initialize(html)
      @doc = Nokogiri::HTML(html)
      @schemas = load_schemas
    end

    def parse
      {
        query: extract_query,
        search_engine: detect_search_engine,
        results: extract_results
      }
    end

    private

    def load_schemas
      schemas_dir = File.join(File.dirname(__FILE__), "schemas")
      schemas = {}

      Dir.glob(File.join(schemas_dir, "*.{json,yaml}")).each do |file|
        engine = File.basename(file, ".*").to_sym
        content = File.read(file)
        schemas[engine] = if file.end_with?(".json")
          JSON.parse(content)
        else
          YAML.safe_load(content)
        end
      end

      schemas
    end

    def detect_search_engine
      @schemas.each do |engine, schema|
        return engine if schema["container_selectors"].any? { |selector| @doc.css(selector).any? }
      end
      :unknown
    end

    def extract_query
      engine = detect_search_engine
      return "unknown" if engine == :unknown

      selectors = @schemas[engine]["query_selectors"]
      query = selectors.map do |selector|
        if selector == "title"
          @doc.css(selector).first&.text&.split("-")&.first&.strip
        else
          @doc.css(selector).first&.[]("value")
        end
      end.compact.first

      query || "unknown"
    end

    def find_first_matching_element(element, selectors)
      selectors = [ selectors ].flatten # Handle both single string and array of strings
      selectors.each do |selector|
        result = element.css(selector).first
        return result if result
      end
      nil
    end

    def extract_results
      engine = detect_search_engine
      return [] if engine == :unknown

      config = @schemas[engine]["result_selectors"]
      @doc.css(config["container"].first).map.with_index(1) do |result, position|
        title_element = find_first_matching_element(result, config["title"])
        url_element = find_first_matching_element(result, config["url"])
        snippet_element = find_first_matching_element(result, config["snippet"])

        {
          position: position,
          title: title_element&.text&.strip,
          url: url_element&.[]("href")&.strip,
          snippet: snippet_element&.text&.strip,
          html: result.to_html
        }
      end
    end
  end
end
