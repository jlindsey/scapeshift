require 'scapeshift/crawlers/cards'
require 'scapeshift/crawlers/sets'

module Scapeshift
  
  ##
  # Contains the different web scrapers. All classes
  # in this module must implement a single public class
  # method: crawl
  #
  # @todo Add a Single crawler for scraping up single cards.
  # @todo Change the Set crawler to a Meta crawler and have it
  #   scrape up Sets and Formats, and other metadata.
  #
  # @author Josh Lindsey
  #
  # @since 0.1.0
  module Crawlers; end

end
