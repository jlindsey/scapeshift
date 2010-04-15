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
  #   @sets = Scapeshift::Crawler.crawl :meta, :type => :sets
  # 
  # @example Scraping all the cards from the Shards of Alara block
  #   @cards = Scapeshift::Crawler.crawl :cards, :set => 'Shards of Alara'
  #
  # @see Scapeshift::Crawlers::Meta
  # @see Scapeshift::Crawlers::Cards
  # @see Scapeshift::Crawlers::Single
  #
  # @author Josh Lindsey
  #
  # @since 0.1.0
  #
  class Crawler
    
    ##
    # The primary mode of interaction with the gem. Issues
    # scaping commands to the specific {Crawlers}.
    #
    # @param [Symbol] type The type of crawl operation to perform
    # @param [Hash] opts Options to pass to Crawlers that support them.
    #   See the classes in {Scapeshift::Crawlers} for a list of options.
    #
    # @yield [Scapeshift::Crawlers::Base] The instantiated specified crawler.
    #
    # @return [Object] See the various {Crawlers} for return types on their crawl methods.
    #
    # @raise [Scapeshift::Errors::InvalidCrawlerType] If an unrecognized crawler type is specified
    #
    # @author Josh Lindsey
    #
    # @since 0.1.0
    #
    def self.crawl type, opts = {}, &block
      crawler = nil

      case type
      when :meta
        crawler = Scapeshift::Crawlers::Meta.new opts
      when :cards
        crawler = Scapeshift::Crawlers::Cards.new opts
      when :single
        crawler = Scapeshift::Crawlers::Single.new opts
      else
        raise Scapeshift::Errors::InvalidCrawlerType.new "Invalid crawler type '#{type}'"
      end

      yield crawler if block_given?
      crawler.crawl
    end
  end
end
