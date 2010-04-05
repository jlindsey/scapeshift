require 'uri'
require 'nokogiri'
require 'open-uri'

module Scapeshift
  module Crawlers

    ##
    # Scrapes the card detail Oracle page for a single card. Like
    # the other {Crawlers}, it has one public class method: {crawl}.
    #
    # @author Josh Lindsey
    #
    # @since 0.2.0
    #
    class Single

      ## The base search page for card names. Joined to {Card_Name_Frag}.
      Card_Name_Search_URI = 'http://gatherer.wizards.com/Pages/Search/Default.aspx?name='

      ## The search fragment for each word in the name. Interpolated
      ## with each word in the Card name.
      Card_Name_Frag = '+[%s]'

      ## The {Card} object representing the scraped data
      @@card = nil

      ##
      # Scrapes the Oracle card detail page for the specified  card name.
      # 
      # @param [Hash] options The options to determine what to scrape.
      # @option options [String] :name ('') The name of the card to scrape
      #
      # @return [Scapeshift::Card] The Card containing the scraped data
      #
      # @raise [Scapeshift::Errors::CardNameAmbiguousOrNotFound] 
      #   If instead of being redirected to the Card detail page, this crawler
      #   finds itself on a search results page.
      #
      # @author Josh Lindsey
      #
      # @since 0.2.0
      #
      def self.crawl options = {}
        if options[:name].nil?
          raise Scapeshift::Errors::InsufficientOptions.new "This crawler MUST be passed :name as an option."
        end

        @@card = Scapeshift::Card.new

        uri_str = Card_Name_Search_URI
        options[:name].split(' ').each { |word| uri_str << Card_Name_Frag % word }

        doc = Nokogiri::HTML open(URI.escape uri_str)
        
        # Check to make sure we're actually on the card detail page.
        unless doc.css('div.filterList').empty?
          raise Scapeshift::Errors::CardNameAmbiguousOrNotFound.new "Unable to find card: '#{options[:name]}'"
        end
        
        @@card.name = _parse_name doc
        @@card.cost = _parse_cost doc
        @@card.types = _parse_types doc
        @@card.text = _parse_text doc
        @@card.sets = _parse_sets doc
        @@card.pow_tgh = _parse_pow_tgh doc
        @@card.image_uri_from_id = _parse_multiverse_id doc

        @@card
      end

      private

      ##
      # Scrape the card name from the detail page.
      #
      # @param [Nokogiri::HTML::Document] doc The detail page document
      #
      # @return [String] The card's name
      #
      # @author Josh Lindsey
      #
      # @since 0.2.0
      #
      def self._parse_name doc
        doc.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_nameRow')./('div[2]').
          children.first.to_s.strip
      end
      
      ##
      # Scrape the card's mana cost from the detail page.
      #
      # @param [Nokogiri::HTML::Document] doc The detail page document
      #
      # @return [String] The formatted string representation of the card's cost. 
      #   (eg. "2BU")
      #
      # @see Scapeshift::Card.cost_symbol_from_str
      #
      # @author Josh Lindsey
      #
      # @since 0.2.0
      #
      def self._parse_cost doc
        str = ''
        costs = doc.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_manaRow')./('div[2]/img')
        costs.each { |cost| str << Scapeshift::Card.cost_symbol_from_str(cost['alt']) }
        str
      end
      
      ##
      # Scrape the card's types from the detail page.
      #
      # @param [Nokogiri::HTML::Document] doc The detail page document
      #
      # @return [String] The types line string
      #
      # @see Scapeshift::Card#types=
      #
      # @author Josh Lindsey
      #
      # @since 0.2.0
      #
      def self._parse_types doc
        doc.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_typeRow')./('div[2]').
          children.first.to_s.strip
      end

      ##
      # Scrape the card's rules text from the detail page.
      #
      # @param [Nokogiri::HTML::Document] doc The detail page document
      #
      # @return [String] The rules text
      #
      # @author Josh Lindsey
      #
      # @since 0.2.0
      #
      def self._parse_text doc
        text = ''
        blocks = doc.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_textRow')./('div[2]/div[@class=cardtextbox]')
        _recursive_parse_text blocks, 0, nil, text
        text.strip
      end
      
      ##
      # Scrapes the printings (sets and rarities) of the card.
      #
      # @param [Nokogiri::HTML::Document] doc The detail page document
      #
      # @return [Array] The array of sets and rarities
      #
      # @author Josh Lindsey
      #
      # @since 0.2.0
      #
      def self._parse_sets doc
        regex = /^(.*?) \((.*?)\)$/
        sets_ary = []

        current = doc.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_setRow')./('img').first['title']
        current =~ regex
        sets_ary << [$1, $2]

        others = doc.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_otherSetsRow')./('img')
        others.each do |other|
          other['title'] =~ regex
          sets_ary << [$1, $2]
        end

        sets_ary
      end

      ##
      # Scapes the card's Power and Toughness (if a creature card).
      #
      # @param [Nokogiri::HTML::Document] doc The detail page document
      #
      # @return [Array] The power and toughness
      # @return [nil] If it's not a creature
      #
      # @author Josh Lindsey
      #
      # @since 0.2.0
      #
      def self._parse_pow_tgh doc
        pt_row = doc.css('div#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ptRow')
        return nil if pt_row.empty?

        pt_str = pt_row./('div[2]').children.first.to_s.strip
        pt_str =~ /^(.*?) \/ (.*?)$/
        [$1, $2]
      end

      ##
      # Scapes the multiverse ID of this card so the Card object can
      # interpolate it into the image URI.
      #
      # @param [Nokogiri::HTML::Document] doc The detail page document
      #
      # @return [String] The mutliverse ID of this card
      #
      # @author Josh Lindsey
      #
      # @since 0.2.0
      #
      def self._parse_multiverse_id doc
        src = doc.css('img#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_cardImage').first['src']
        src =~ /multiverseid=(.*?)&/
        $1
      end

      ##
      # Recursively parse the detail page text, since it's contained within
      # elements of its own. Also converts mana images to symbols. Called from
      # {_parse_text}.
      #
      # @param [Array] node_ary The array of nodes for the current recursion
      # @param [Integer] pos The current position in the current node_ary
      # @param [Symbol] last_element The last element traversed, used for formatting
      # @param [String] text A pointer to the text string we're building
      #
      # @see _parse_text
      # @see Scapeshift::Card.cost_symbol_from_str
      #
      # @author Josh Lindsey
      #
      # @since 0.2.0
      #
      def self._recursive_parse_text node_ary, pos, last_element, text
        node = node_ary[pos]
        return if node.nil?

        # Text holder div
        if node.is_a?(Nokogiri::XML::Element) and node['class'] == 'cardtextbox'
          text << "\n"
          _recursive_parse_text node.children, 0, :div, text

        # Mana image
        elsif node.is_a?(Nokogiri::XML::Element) and node.name == 'img'
          text << ' ' unless last_element == :img
          text << Scapeshift::Card.cost_symbol_from_str(node['alt'])
          last_element = :img

        # Keyword text
        elsif node.is_a?(Nokogiri::XML::Element) and node.name == 'i'
          text << ' ' if last_element == :img
          _recursive_parse_text node.children, 0, :i, text

        # Regular text
        elsif node.is_a? Nokogiri::XML::Text
          text << ' ' if last_element == :img
          text << node.to_s.strip
          last_element = :text
        end

        _recursive_parse_text node_ary, pos+1, last_element, text
      end
    end
  end
end

