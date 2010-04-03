module Scapeshift
  
  ##
  # Contains any custom exceptions this gem might throw.
  #
  # @author Josh Lindsey
  #
  # @since 0.1.0
  #
  module Errors
    
    ##
    # Thrown when an unrecognized crawler is specified in
    # {Scapeshift::Crawler.crawl}
    #
    # @author Josh Lindsey
    #
    # @since 0.1.0
    #
    class InvalidCrawlerType < StandardError; end

    ##
    # Thrown when an unknown card attribute is encountered in
    # {Scapeshift::Crawlers::Cards._parse_row}
    #
    # @author Josh Lindsey
    #
    # @since 0.1.0
    #
    class UnknownCardAttribute < StandardError; end

    ##
    # Thrown when an unknown metadata type is supplied to
    # the Meta crawler.
    #
    # @author Josh Lindsey
    #
    # @since 0.1.4
    #
    class UnknownMetaType < StandardError; end
  end
end
