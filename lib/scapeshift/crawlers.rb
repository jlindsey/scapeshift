require 'scapeshift/crawlers/base'
require 'scapeshift/crawlers/cards'
require 'scapeshift/crawlers/meta'
require 'scapeshift/crawlers/single'

module Scapeshift
  
  ##
  # Contains the different web scrapers. All classes
  # in this module must implement a single public class
  # method: crawl
  #
  # @todo Add callback methods to each Crawler (eg. Sets.each_card &block)
  #
  # @author Josh Lindsey
  #
  # @since 0.1.0
  module Crawlers; end

end
