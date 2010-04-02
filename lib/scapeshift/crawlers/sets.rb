require 'set'
require 'nokogiri'
require 'open-uri'

module Scapeshift
  module Crawlers
    
    ##
    # The Sets crawler scrapes expansion set data from the Oracle main search page.
    # Like the other Crawlers, it has one public class method: {crawl}.
    #
    # @example
    #   @sets = Scapeshift::Crawlers::Sets.crawl
    #
    # @author Josh Lindsey
    #
    # @since 0.1.0
    #
    class Sets
      
      ## The Oracle homepage, which is what we are scraping from
      Card_Sets_URI = 'http://gatherer.wizards.com/Pages/Default.aspx'
      
      ## The Set containing the expansion sets found
      @@sets = Set.new

      ##
      # Scrapes the Oracle homepage for the expansion set list.
      #
      # @return [Set <String>] A Set containing the expansion set list
      #
      # @author Josh Lindsey
      #
      # @since 0.1.0
      #
      def self.crawl
        doc = Nokogiri::HTML open(Card_Sets_URI)
        select = doc.css('select#ctl00_ctl00_MainContent_Content_SearchControls_setAddText')
        select.children.each do |child|
          @@sets << child['value']
        end

        @@sets
      end
    end
  end
end
