require 'scapeshift/crawlers'
require 'scapeshift/card'
require 'scapeshift/errors'

module Scapeshift
  
  ##
  # The main Crawler class, which handles the routing of commands
  # to the specific {Crawlers}. This is the main class that end-users
  # should be interacting with.
  #
  # @example Scraping the Sets
  #   @sets = Scapeshift::Crawler.crawl :sets
  # 
  # @example Scraping all the cards from the Shards of Alara block
  #   @cards = Scapeshift::Crawler.crawl :cards, :set => 'Shards of Alara'
  #
  # @see Scapeshift::Crawlers::Sets
  # @see Scapeshift::Crawlers::Cards
  #
  # @author Josh Lindsey
  #
  # @since 0.1.0
  #
  class Crawler
    include Scapeshift::Errors
    
    ##
    # The primary mode of interaction with the gem. Issues
    # scaping commands to the specific {Crawlers}.
    #
    # @param [Symbol] type The type of crawl operation to perform
    # @param [Hash] options Options to pass to Crawlers that support them.
    #   See {Scapeshift::Crawlers::Cards.crawl} for a list of options.
    #
    # @return [Object] See the various {Crawlers} for return types on their crawl methods.
    #
    # @raise [Scapeshift::Errors::InvalidCrawlerType] If an unrecognized crawler type is specified
    #
    # @author Josh Lindsey
    #
    # @since 0.1.0
    #
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
