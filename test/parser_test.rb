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

    assert_operator result[:results].size, :>, 90, "Expected more than 90 results, got #{result[:results].size}\nFull results: #{result[:results].inspect}"

    result[:results].each_with_index do |search_result, index|
      assert search_result[:title], "Result ##{index}: Expected title to exist, got nil\nFull result: #{search_result.inspect}"
      assert search_result[:url], "Result ##{index}: Expected URL to exist, got nil\nFull result: #{search_result.inspect}"
      assert search_result[:snippet], "Result ##{index}: Expected snippet to exist, got nil\nFull result: #{search_result.inspect}"
      assert search_result[:html], "Result ##{index}: Expected HTML to exist, got nil\nFull result: #{search_result.inspect}"

      refute search_result[:title].empty?, "Result ##{index}: Expected title to be non-empty, got empty string\nFull result: #{search_result.inspect}"
      refute search_result[:url].empty?, "Result ##{index}: Expected URL to be non-empty, got empty string\nFull result: #{search_result.inspect}"
      refute search_result[:snippet].empty?, "Result ##{index}: Expected snippet to be non-empty, got empty string\nFull result: #{search_result.inspect}"
      refute search_result[:html].empty?, "Result ##{index}: Expected HTML to be non-empty, got empty string\nFull result: #{search_result.inspect}"

      assert search_result[:url].start_with?("http"), "Result ##{index}: Expected URL to start with 'http', got #{search_result[:url].inspect}\nFull result: #{search_result.inspect}"
      assert search_result[:html].include?("<"), "Result ##{index}: Expected HTML to contain HTML tags, got #{search_result[:html].inspect}\nFull result: #{search_result.inspect}"
    end
  end

  def test_parses_casino_no_search
    parser = SerpScraper::Parser.new(@casino_no_html)
    result = parser.parse

    assert_equal :google, result[:search_engine], "Expected search engine to be :google, got #{result[:search_engine].inspect}"
    assert_equal "casino", result[:query], "Expected query to be 'casino', got #{result[:query].inspect}"

    assert_operator result[:results].size, :>, 90, "Expected more than 90 results, got #{result[:results].size}\nFull results: #{result[:results].inspect}"

    result[:results].each_with_index do |search_result, index|
      assert search_result[:title], "Result ##{index}: Expected title to exist, got nil\nFull result: #{search_result.inspect}"
      assert search_result[:url], "Result ##{index}: Expected URL to exist, got nil\nFull result: #{search_result.inspect}"
      assert search_result[:snippet], "Result ##{index}: Expected snippet to exist, got nil\nFull result: #{search_result.inspect}"
      assert search_result[:html], "Result ##{index}: Expected HTML to exist, got nil\nFull result: #{search_result.inspect}"

      refute search_result[:title].empty?, "Result ##{index}: Expected title to be non-empty, got empty string\nFull result: #{search_result.inspect}"
      refute search_result[:url].empty?, "Result ##{index}: Expected URL to be non-empty, got empty string\nFull result: #{search_result.inspect}"
      refute search_result[:snippet].empty?, "Result ##{index}: Expected snippet to be non-empty, got empty string\nFull result: #{search_result.inspect}"
      refute search_result[:html].empty?, "Result ##{index}: Expected HTML to be non-empty, got empty string\nFull result: #{search_result.inspect}"

      assert search_result[:url].start_with?("http"), "Result ##{index}: Expected URL to start with 'http', got #{search_result[:url].inspect}\nFull result: #{search_result.inspect}"
      assert search_result[:html].include?("<"), "Result ##{index}: Expected HTML to contain HTML tags, got #{search_result[:html].inspect}\nFull result: #{search_result.inspect}"
    end
  end

  def test_parses_casino_us_search
    parser = SerpScraper::Parser.new(@casino_us_html)
    result = parser.parse

    assert_equal :google, result[:search_engine], "Expected search engine to be :google, got #{result[:search_engine].inspect}"
    assert_equal "casino online", result[:query], "Expected query to be 'casino online', got #{result[:query].inspect}"

    assert_operator result[:results].size, :>, 90, "Expected more than 90 results, got #{result[:results].size}\nFull results: #{result[:results].inspect}"

    result[:results].each_with_index do |search_result, index|
      assert search_result[:title], "Result ##{index}: Expected title to exist, got nil\nFull result: #{search_result.inspect}"
      assert search_result[:url], "Result ##{index}: Expected URL to exist, got nil\nFull result: #{search_result.inspect}"
      assert search_result[:snippet], "Result ##{index}: Expected snippet to exist, got nil\nFull result: #{search_result.inspect}"
      assert search_result[:html], "Result ##{index}: Expected HTML to exist, got nil\nFull result: #{search_result.inspect}"

      refute search_result[:title].empty?, "Result ##{index}: Expected title to be non-empty, got empty string\nFull result: #{search_result.inspect}"
      refute search_result[:url].empty?, "Result ##{index}: Expected URL to be non-empty, got empty string\nFull result: #{search_result.inspect}"
      refute search_result[:snippet].empty?, "Result ##{index}: Expected snippet to be non-empty, got empty string\nFull result: #{search_result.inspect}"
      refute search_result[:html].empty?, "Result ##{index}: Expected HTML to be non-empty, got empty string\nFull result: #{search_result.inspect}"

      assert search_result[:url].start_with?("http"), "Result ##{index}: Expected URL to start with 'http', got #{search_result[:url].inspect}\nFull result: #{search_result.inspect}"
      assert search_result[:html].include?("<"), "Result ##{index}: Expected HTML to contain HTML tags, got #{search_result[:html].inspect}\nFull result: #{search_result.inspect}"
    end
  end

  def test_handles_unknown_search_engine
    parser = SerpScraper::Parser.new("<html><body>Unknown search engine</body></html>")
    result = parser.parse

    assert_equal :unknown, result[:search_engine], "Expected search engine to be :unknown, got #{result[:search_engine].inspect}"
    assert_equal "unknown", result[:query], "Expected query to be 'unknown', got #{result[:query].inspect}"
    assert_empty result[:results], "Expected results to be empty, got #{result[:results].inspect}"
  end
end
