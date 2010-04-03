require 'set'
require 'nokogiri'
require 'open-uri'

module Scapeshift
  module Crawlers
    
    ##
    # The Meta crawler scrapes meta data such as expansion sets and formats 
    # from the Oracle main search page. Like the other Crawlers, it has 
    # one public class method: {crawl}.
    #
    # @todo DRY up these private methods a bit?
    #
    # @example
    #   @sets = Scapeshift::Crawlers::Meta.crawl :sets
    #
    # @author Josh Lindsey
    #
    # @since 0.1.4
    #
    class Meta
      
      ## The Oracle homepage, which is what we are scraping from
      Meta_URI = 'http://gatherer.wizards.com/Pages/Default.aspx'
      
      ## The SortedSet containing the metadata found
      @@meta = SortedSet.new

      ##
      # Scrapes the Oracle homepage for the specified data.
      #
      # @param [Hash] options Options for specifying the metadata to scrape
      # @option options [Symbol] :type The type of metadata to scrape.
      #
      # @return [SortedSet <String>] A SortedSet containing the data
      #
      # @raise [Scapeshift::Errors::UnknownMetaType] If an unsupported metadata type is supplied
      #
      # @author Josh Lindsey
      #
      # @since 0.1.0
      #
      def self.crawl options
        doc = Nokogiri::HTML open(Meta_URI)
        
        case options[:type]
        when :sets
          _scrape_sets doc
        when :formats
          _scrape_formats doc
        when :types
          _scrape_types doc
        else
          raise Scapeshift::Errors::UnknownMetaType.new "unknown metadata type: '#{type}'"
        end

        @@meta
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
      def self._scrape_sets doc
        sets = doc.css 'select#ctl00_ctl00_MainContent_Content_SearchControls_setAddText'
        sets.children.each { |set| @@meta << set['value'] } 
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
      def self._scrape_formats doc
        formats = doc.css 'select#ctl00_ctl00_MainContent_Content_SearchControls_formatAddText'
        formats.children.each { |format| @@meta << format['value'] }
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
      def self._scrape_types doc
        types = doc.css'select#ctl00_ctl00_MainContent_Content_SearchControls_typeAddText'
        types.children.each { |type| @@meta << type['value'] }
      end
    end
  end
end
