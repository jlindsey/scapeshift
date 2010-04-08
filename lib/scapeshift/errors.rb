module Scapeshift
  
  ##
  # Contains any custom exceptions this gem might raise.
  #
  # @author Josh Lindsey
  #
  # @since 0.1.0
  #
  module Errors
    
    ##
    # Raised when an unrecognized crawler is specified in
    # {Scapeshift::Crawler.crawl}
    #
    # @author Josh Lindsey
    #
    # @since 0.1.0
    #
    class InvalidCrawlerType < StandardError; end

    ##
    # Raised when an unknown card attribute is encountered in
    # {Scapeshift::Crawlers::Cards#_parse_row}
    #
    # @author Josh Lindsey
    #
    # @since 0.1.0
    #
    class UnknownCardAttribute < StandardError; end

    ##
    # Raised when an unknown metadata type is supplied to
    # the Meta crawler.
    #
    # @author Josh Lindsey
    #
    # @since 0.1.4
    #
    class UnknownMetaType < StandardError; end

    ##
    # Raised when the card name supplied to the Single crawler
    # resolves to a Gatherer search results page instead of a 
    # Card detail page (implying that the Card name is ambiguous,
    # or doesn't exist).
    #
    # @author Josh Lindsey
    #
    # @since 0.2.0
    #
    class CardNameAmbiguousOrNotFound < StandardError; end

    ##
    # Raised when insufficient options are passed to one of the
    # Crawlers for it to continue execution.
    #
    # @author Josh Lindsey
    #
    # @since 0.2.0
    #
    class InsufficientOptions < StandardError; end


    ##
    # Raised when an unknown word is encountered in 
    # {Scapeshift::Card.cost_symbol_from_str}.
    #
    # @author Josh Lindsey
    #
    # @since 0.2.0
    #
    class UnknownCostSymbol < StandardError; end

    ##
    # Raised when a subclass of {Crawlers::Base} doesn't
    # override a required method (such as {Crawlers::Base#crawl}).
    #
    # @author Josh Lindsey
    #
    # @since 0.3.0
    #
    class InvalidSubclass < StandardError; end
  end
end
