# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "serp_scraper"

require "minitest/autorun"
require "minitest/reporters"

Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new(
    color: true,
    detailed_skip: false
  )
]
