module Scapeshift
  module Crawlers
    class Sets
      require 'nokogiri'
      require 'set'
      require 'open-uri'

      Card_Sets_URI = 'http://gatherer.wizards.com/Pages/Default.aspx'

      def self.crawl
        @@sets = Set.new
        
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
