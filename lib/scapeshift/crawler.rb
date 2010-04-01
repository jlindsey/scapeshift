require 'scapeshift/crawlers'
require 'scapeshift/card'
require 'scapeshift/errors'

require 'spidr'
require 'nokogiri'

module Scapeshift
  class Crawler
    include Scapeshift::Errors

    def self.crawl type, options = {}
      case type
      when :sets
        Scapeshift::Crawlers::Sets.crawl
      when :cards
        Scapeshift::Crawlers::Cards.crawl options
      else
        raise Scapeshift::Errors::InvalidCrawlerType.new "Invalid crawler type '#{type}'"
      end
    end
  end
end
