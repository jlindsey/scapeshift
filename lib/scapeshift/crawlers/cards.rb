require 'set'
require 'uri'
require 'nokogiri'
require 'open-uri'

module Scapeshift
  module Crawlers

    ##
    # The Card crawler scrapes Card data from the Oracle textual
    # spoiler pages. Like the other Crawlers, it overrides the {#crawl}
    # method inherited from {Base}.
    # 
    # @example Directly instantiating the crawler
    #   crawler = Scapeshift::Crawlers::Cards.new :set => 'Shards of Alara'
    #   @cards = crawler.crawl
    #
    # @author Josh Lindsey
    #
    # @since 0.1.0
    #
    class Cards < Base
      has_callback_hook :before_scrape
      has_callback_hook :after_scrape
      has_callback_hook :every_card

      ## The Base URI we grab from. Interpolated based on options passed-in.
      Text_Spoiler_URI = 'http://gatherer.wizards.com/Pages/Search/Default.aspx?output=spoiler&method=text%s'
      
      ## The search fragment if we're searching on Blocks.
      Block_Search_Frag = '&format=["%s"]'

      ## The search fragment if we're searching on Sets.
      Set_Search_Frag = '&set=["%s"]'

      ## The search fragment if we're searching on Formats.
      Format_Search_Frag = '&format=["%s"]'
      
      ## @return [Nokogiri::HTML::Document] The Nokogiri document this instance is scraping
      attr_reader :doc

      ## @return [SortedSet <Scapeshift::Card>] The SortedSet of {Card} objects being built
      attr_reader :cards

      ## @return [Scapeshift::Card] The {Card} currently being built
      attr_reader :current_card

      ##
      # Creates a new Cards crawler object.
      #
      # @param [Hash] opts The options to determine what to set. One of these *must* be set.
      # @option opts [String] :set ('') The set to scrape (eg. "Darksteel")
      # @option opts [String] :block ('') The block to scrape (eg. "Lorwyn block")
      # @option opts [String] :format ('') The format to scrape (eg. "Legacy")
      #
      # @return [Scapeshift::Crawlers::Cards] The new Cards crawler
      #
      # @raise [Scapeshift::Errors::InsufficientOptions] If at least one of the options aren't set
      #
      # @author Josh Lindsey
      #
      # @since 0.3.0
      #
      def initialize(opts = {})
        super opts
      
        @cards = SortedSet.new

        if self.options[:set].nil? and self.options[:block].nil? and self.options[:format].nil?
          raise Scapeshift::Errors::InsufficientOptions.new "This crawler MUST be passed one of :set, :block, or :format."
        end
      end

      ##
      # Scrapes the Oracle Text Spoiler page for the specified set or block.
      # Overridden from {Base#crawl}.
      #
      # @return [SortedSet <Card>] A Set containing the {Card} objects we've scraped
      #
      # @author Josh Lindsey
      #
      # @since 0.1.0
      #
      def crawl
        search_frag = ''
        unless self.options[:block].nil?
          search_frag << Block_Search_Frag % self.options[:block]
        end
        unless self.options[:set].nil?
          search_frag << Set_Search_Frag % self.options[:set]
        end
        unless self.options[:format].nil?
          search_frag << Format_Search_Frag % self.options[:format]
        end

        @doc = Nokogiri::HTML open(URI.escape(Text_Spoiler_URI % search_frag))
        rows = doc.xpath('//div[@class="textspoiler"]/table/tr')

        self.hook :before_scrape, self.doc

        @current_card = nil

        rows.each do |row|
          # The row between cards is just a `<td><br /></td>`,
          # so when we see that we know the last card is finished.
          if row.children.length == 2
            self.hook :every_card, self.current_card
            @cards << @current_card
            @current_card = nil
            next
          end

          @current_card = Scapeshift::Card.new if @current_card.nil?
          _parse_row row
        end
        
        self.hook :after_scrape, self.cards

        @cards
      end

      private
     
      ##
      # Primary "router" method that's called on every iteration of the main
      # {#crawl} loop. Passes the current row to the specialized parser methods.
      #
      # @param [Nokogiri::XML::NodeSet] row The Nokogiri NodeSet comprising the table row to parse
      #
      # @raise [Scapeshift::Errors::UnknownCardAttribute] Raised if this method encounters a card attr 
      #   it doesn't recognize
      #
      # @author Josh Lindsey
      #
      # @since 0.1.0
      #
      def _parse_row row
        case _row_type(row)
        when :name
          @current_card.name = _parse_name row
          @current_card.multiverse_id = _parse_image_uri row
          @current_card.image_uri_from_id = @current_card.multiverse_id
        when :cost
          @current_card.cost = _parse_cost row
        when :type
          @current_card.types = _parse_type row
        when :'pow/tgh'
          @current_card.pow_tgh = _parse_pow_tgh row
        when :'rules text'
          @current_card.text = _parse_rules_text row
        when :'set/rarity'
          @current_card.sets = _parse_set_rarity row
        when :loyalty
          @current_card.loyalty = _parse_loyalty row
        when :color
          # Ignore as this should be deductible from mana cost and/or card text
        else
          raise Scapeshift::Errors::UnknownCardAttribute.new "Unable to parse attribute: '#{_row_type(row)}'"
        end
      end
      
      ##
      # Determines which Card attribute this row contains.
      #
      # @param [Nokogiri::XML::NodeSet] row The Nokogiri NodeSet comprising the table row to parse
      #
      # @return [Symbol] The data this row contains
      #
      # @author Josh Lindsey
      #
      # @since 0.1.0
      #
      def _row_type row
        row./('td[1]').children.first.to_s.strip.chop.downcase.to_sym
      end

      ##
      # Parses the Card name out of the appropriate row.
      #
      # @param [Nokogiri::XML::NodeSet] row The NodeSet containing the name data
      #
      # @return [String] The Card name
      #
      # @author Josh Lindsey
      #
      # @since 0.1.0
      #
      def _parse_name row
        row./('td[2]/a').children.last.to_s
      end
      
      ##
      # Parses the "multiverse id" (Wizards' internal card ID, I guess) out of
      # the card detail link. This can be used then to build the URI to the
      # card image.
      #
      # @param [Nokogiri::XML::NodeSet] row The NodeSet containing the link
      #
      # @return [String] The Card's "multiverse id"
      #
      # @author Josh Lindsey
      #
      # @since 0.1.0
      #
      def _parse_image_uri row
        row./('td[2]/a').first[:href] =~ /multiverseid=(\d+)/
        $1
      end

      ##
      # Parses the mana cost of the card.
      #
      # @param [Nokogiri::XML::NodeSet] row The NodeSet containing the cost
      #
      # @return [String] A string that should look something like "2BR"
      #   (for a cost of 2 colorless mana, one black mana, and one red mana).
      #
      # @author Josh Lindsey
      #
      # @since 0.1.0
      #
      def _parse_cost row
        row./('td[2]').children.last.to_s.strip
      end

      ##
      # Parses the card types of the card. Simply passes the extracted String
      # to the Card object. It handles the rest.
      #
      # @see Card#types=
      #
      # @param [Nokogiri::XML::NodeSet] row The NodeSet containing the types
      #
      # @return [String] The card type line
      #
      # @author Josh Lindsey
      #
      # @since 0.1.0
      #
      def _parse_type row
        row./('td[2]').children.first.to_s.strip
      end

      ##
      # Parses the Power and Toughness of creature cards.
      #
      # @param [Nokogiri::XML::NodeSet] row The NodeSet containing the power and toughness ratings
      #
      # @return [Array [Power, Toughness]] The array containing the power and toughness for creature cards
      # @return [nil] nil for non-creature-cards
      # 
      # @author Josh Lindsey
      #
      # @since 0.1.0
      #
      def _parse_pow_tgh row
        pt_str = row./('td[2]').children.first.to_s.strip
        return nil if pt_str.empty?
        pt_str =~ /\((.*?)\/(.*?)\)/
          [$1, $2]
      end
      
      ##
      # Parses the actual body text of the card.
      #
      # @param [Nokogiri::XML::NodeSet] row The NodeSet containing the rules text
      #
      # @return [String] The parsed body text, with <br /> tags converted into \n
      #
      # @author Josh Lindsey
      #
      # @since 0.1.0
      #
      def _parse_rules_text row
        text = ''
        row./('td[2]').children.each do |block|
          if block.name == 'br'
            text << "\n"
            next
          end

          text << block.to_s.strip 
        end

        text
      end

      ##
      # Parses the sets and rarities the card was printed in.
      #
      # @param [Nokogiri::XML::NodeSet] row The NodeSet containing the rarities and sets
      #
      # @return [Array [[Set, Rarity]]] The sets and the rarity the card was in that set
      #
      # @author Josh Lindsey
      #
      # @since 0.1.0
      #
      def _parse_set_rarity row
        ret_ary = []
        sets_ary = row./('td[2]').children.first.to_s.strip.split(', ')
        sets_ary.each do |set_str|
          if set_str.include? 'Mythic Rare'
            set_str.sub! ' Mythic Rare', ''
            ret_ary << [set_str, 'Mythic Rare']
            next
          end

          tmp = set_str.split(' ')
          ret_ary << [tmp.pop, tmp.join(' ')].reverse
        end

        ret_ary
      end

      ##
      # Parses the loyalty of a planeswalker card.
      #
      # @param [Nokogiri::XML::NodeSet] row The NodeSet containing the loyalty
      #
      # @return [String] The loyalty of the planeswalker card
      #
      # @author Eric Cohen
      #
      # @since 1.0.1
      #
      def _parse_loyalty row
        row./('td[2]').children.first.to_s.strip[1..-2]
      end
    end
  end
end

