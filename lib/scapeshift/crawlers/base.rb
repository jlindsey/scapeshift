module Scapeshift
  module Crawlers
    
    ##
    # Base crawler class that all other crawlers should extend.
    #
    # @author Josh Lindsey
    #
    # @since 0.3.0
    #
    # @abstract
    #
    class Base
      ## Hash of callback blocks
      @@callbacks = {}

      ## Options hash. Keys will differ between crawlers.
      attr_accessor :options

      ##
      # Returns a new instance of a Crawler.
      #
      # @param [Hash] opts The options hash. Keys will differ between crawlers.
      #
      # @return [Crawlers::Base] The Crawler instance
      #
      # @raise [Scapeshift::Errors::InsufficientOptions] If the opts hash is empty
      #
      # @author Josh Lindsey
      #
      # @since 0.3.0
      #
      def initialize opts = {}
        if opts.empty?
          raise Scapeshift::Errors::InsufficientOptions.new "The options hash must not be null"
        end

        self.options = opts
      end
    
      ##
      # Abstract required method for each subclass.
      #
      # @raise [Scapeshift::Errors::InvalidSubclass] If any subclass fails to implement this method
      #
      # @author Josh Lindsey
      #
      # @since 0.3.0
      #
      def crawl
        raise Scapeshift::Errors::InvalidSubclass.new "Subclasses of Crawlers::Base must implement #crawl"
      end

      ##
      # Calls every Proc in {@@callbacks} for the specified symbol,
      # yielding any objects passed in as args.
      #
      # @param [Symbol] symbol The symbol for the hook to call
      # @param [Object] *args The splatted list of objects to yield to each Proc
      #
      # @author Josh Lindsey
      #
      # @since 0.3.0
      #
      def hook symbol, *args
        @@callbacks[symbol].each { |p| p.call *args }
      end

      ##
      # Adds the named callback hook to the class. Calling this method
      # adds another new method to the class with the same name as the 
      # symbol passed in. This new method accepts a block, converts it
      # to a Proc object, and pushes it onto {@@callbacks} for that symbol.
      # It can be called using {#hook} and passing in the same symbol.
      #
      # @example Add a callback hook named "before_foo" to a class
      #   class Test < Crawlers::Base
      #     has_callback_hook :before_foo
      #
      #     def foo
      #       str = "Hello, world!"
      #       self.hook :before_foo, str
      #       puts str
      #     end
      #   end
      #
      #   test = Test.new
      #   test.before_foo { |str| str.replace "Baz" }
      #   test.foo  # => Baz
      #
      # @author Josh Lindsey
      #
      # @since 0.3.0
      #
      def self.has_callback_hook symbol
        @@callbacks[symbol] = []

        self.class_eval %Q{
          def #{symbol} &block
            @@callbacks[:#{symbol}] << Proc.new(&block)
          end
        }
      end
    end
  end
end

