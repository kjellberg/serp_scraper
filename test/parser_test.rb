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

    assert_equal :google, result[:search_engine], "Expected search engine to be :google, got #{result[:search_engine].inspect}"
    assert_equal "ärtröra toast", result[:query], "Expected query to be 'ärtröra toast', got #{result[:query].inspect}"

    first_result = result[:results].first
    assert first_result, "Expected at least one result, got none"
    assert first_result[:title], "Expected title to exist, got nil"
    assert first_result[:url], "Expected URL to exist, got nil"
    assert first_result[:snippet], "Expected snippet to exist, got nil"
    refute first_result[:title].empty?, "Expected title to be non-empty, got empty string"
    refute first_result[:url].empty?, "Expected URL to be non-empty, got empty string"
    refute first_result[:snippet].empty?, "Expected snippet to be non-empty, got empty string"
    assert first_result[:url].start_with?("http"), "Expected URL to start with 'http', got #{first_result[:url].inspect}"
  end

  def test_parses_casino_no_search
    parser = SerpScraper::Parser.new(@casino_no_html)
    result = parser.parse

    assert_equal :google, result[:search_engine], "Expected search engine to be :google, got #{result[:search_engine].inspect}"
    assert_equal "casino", result[:query], "Expected query to be 'casino', got #{result[:query].inspect}"

    first_result = result[:results].first
    assert first_result, "Expected at least one result, got none"
    assert first_result[:title], "Expected title to exist, got nil"
    assert first_result[:url], "Expected URL to exist, got nil"
    assert first_result[:snippet], "Expected snippet to exist, got nil"
    refute first_result[:title].empty?, "Expected title to be non-empty, got empty string"
    refute first_result[:url].empty?, "Expected URL to be non-empty, got empty string"
    refute first_result[:snippet].empty?, "Expected snippet to be non-empty, got empty string"
    assert first_result[:url].start_with?("http"), "Expected URL to start with 'http', got #{first_result[:url].inspect}"
  end

  def test_parses_casino_us_search
    parser = SerpScraper::Parser.new(@casino_us_html)
    result = parser.parse

    assert_equal :google, result[:search_engine], "Expected search engine to be :google, got #{result[:search_engine].inspect}"
    assert_equal "casino online", result[:query], "Expected query to be 'casino online', got #{result[:query].inspect}"

    first_result = result[:results].first
    assert first_result, "Expected at least one result, got none"
    assert first_result[:title], "Expected title to exist, got nil"
    assert first_result[:url], "Expected URL to exist, got nil"
    assert first_result[:snippet], "Expected snippet to exist, got nil"
    refute first_result[:title].empty?, "Expected title to be non-empty, got empty string"
    refute first_result[:url].empty?, "Expected URL to be non-empty, got empty string"
    refute first_result[:snippet].empty?, "Expected snippet to be non-empty, got empty string"
    assert first_result[:url].start_with?("http"), "Expected URL to start with 'http', got #{first_result[:url].inspect}"
  end

  def test_handles_unknown_search_engine
    parser = SerpScraper::Parser.new("<html><body>Unknown search engine</body></html>")
    result = parser.parse

    assert_equal :unknown, result[:search_engine], "Expected search engine to be :unknown, got #{result[:search_engine].inspect}"
    assert_equal "unknown", result[:query], "Expected query to be 'unknown', got #{result[:query].inspect}"
    assert_empty result[:results], "Expected results to be empty, got #{result[:results].inspect}"
  end
end
