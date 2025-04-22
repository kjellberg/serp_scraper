# frozen_string_literal: true

require "test_helper"
require "serp_scraper/parser"

class ParserTest < Minitest::Test
  def setup
    @artrora_html = File.read("test/mocks/artrora-se-sv.html")
    @casino_no_html = File.read("test/mocks/casino-no-no.html")
    @casino_us_html = File.read("test/mocks/casino-online-com-us.html")
  end

  def test_parses_artrora_search
    parser = SerpScraper::Parser.new(@artrora_html)
    result = parser.parse

    assert_equal :google, result[:search_engine]
    assert_equal "ärtröra toast", result[:query]
  end

  def test_parses_casino_no_search
    parser = SerpScraper::Parser.new(@casino_no_html)
    result = parser.parse

    assert_equal :google, result[:search_engine]
    assert_equal "casino", result[:query]
  end

  def test_parses_casino_us_search
    parser = SerpScraper::Parser.new(@casino_us_html)
    result = parser.parse

    assert_equal :google, result[:search_engine]
    assert_equal "casino online", result[:query]
  end

  def test_handles_unknown_search_engine
    parser = SerpScraper::Parser.new("<html><body>Unknown search engine</body></html>")
    result = parser.parse

    assert_equal :unknown, result[:search_engine]
    assert_equal "unknown", result[:query]
  end
end
