require 'set'
require 'nokogiri'
require 'open-uri'

module Scapeshift
  module Crawlers
    
    ##
    # The Meta crawler scrapes meta data such as expansion sets and formats 
    # from the Oracle main search page. Like the other Crawlers, it overrides
    # the {#crawl} method from {Base}.
    #
    # @example Directly instantiating the crawler
    #   crawler = Scapeshift::Crawlers::Meta.new :type => :sets
    #   @sets = crawler.crawl
    #
    # @author Josh Lindsey
    #
    # @since 0.1.4
    #
    class Meta < Base
      has_callback_hook :before_scrape
      has_callback_hook :after_scrape

      ## The Nokogiri document representing the page
      attr_reader :doc

      ## The SortedSet containing the scraped data
      attr_reader :meta

      ## The Oracle homepage, which is what we are scraping from
      Meta_URI = 'http://gatherer.wizards.com/Pages/Default.aspx'

      ##
      # Creates a new Meta crawler instance.
      #
      # @param [Hash] opts Options for specifying the metadata to scrape
      # @option opts [Symbol (:sets|:formats|:types)] :type ('')  The type of metadata to scrape
      #
      # @return [Scapeshift::Crawlers::Meta] The Meta crawler object
      #
      # @raise [Scapeshift::Errors::InsufficientOptions] If :type isn't passed
      #
      # @author Josh Lindsey
      #
      # @since 0.3.0
      #
      def initialize opts = {}
        super opts

        @meta = SortedSet.new

        if self.options[:type].nil?
          raise Scapeshift::Errors::InsufficientOptions.new "This crawler MUST be passed :type"
        end
      end

      ##
      # Scrapes the Oracle homepage for the specified data.
      #
      # @return [SortedSet <String>] A SortedSet containing the data
      #
      # @raise [Scapeshift::Errors::UnknownMetaType] If an unsupported metadata type is supplied
      #
      # @author Josh Lindsey
      #
      # @since 0.1.0
      #
      def crawl
        @doc = Nokogiri::HTML open(Meta_URI)
       
        self.hook :before_scrape, @doc

        case @options[:type]
        when :sets
          _scrape_sets @doc
        when :formats
          _scrape_formats @doc
        when :types
          _scrape_types @doc
        else
          raise Scapeshift::Errors::UnknownMetaType.new "Unknown metadata type: '#{options[:type]}'"
        end

        self.hook :after_scrape, @meta

        @meta
      end

      private
      
      ##
      # Scrapes the expansion set data from the document.
      #
      # @param [Nokogiri::HTML::Document] doc The full document of the Oracle page
      #
      # @author Josh Lindsey
      #
      # @since 0.1.4
      #
      def _scrape_sets doc
        sets = doc.css 'select#ctl00_ctl00_MainContent_Content_SearchControls_setAddText'
        sets.children.each { |set| @meta << set['value'] } 
      end
      
      ##
      # Scrapes the Format data from the document.
      #
      # @param [Nokogiri::HTML::Document] doc The full document of the Oracle page
      #
      # @author Josh Lindsey
      #
      # @since 0.1.4
      #
      def _scrape_formats doc
        formats = doc.css 'select#ctl00_ctl00_MainContent_Content_SearchControls_formatAddText'
        formats.children.each { |format| @meta << format['value'] }
      end
      
      ##
      # Scrapes the card types data from the document.
      #
      # @param [Nokogiri::HTML::Document] doc The full document of the Oracle page
      #
      # @author Josh Lindsey
      #
      # @since 0.1.4
      #
      def _scrape_types doc
        types = doc.css'select#ctl00_ctl00_MainContent_Content_SearchControls_typeAddText'
        types.children.each { |type| @meta << type['value'] }
      end
    end
  end
end
