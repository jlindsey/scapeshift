module Scapeshift
  module Crawlers
    class Cards
      require 'nokogiri'
      require 'set'
      require 'open-uri'
      require 'uri'

      Text_Spoiler_URI = 'http://gatherer.wizards.com/Pages/Search/Default.aspx?output=spoiler&method=text%s'
      Block_Search_Frag = '&format=["%s"]'
      Set_Search_Frag = '&set=["%s"]'

      def self.crawl options = {}
        @@cards = Set.new

        search_frag = ''
        unless options[:block].nil?
          search_frag << Block_Search_Frag % options[:block]
        end
        unless options[:set].nil?
          search_frag << Set_Search_Frag % options[:set]
        end

        doc = Nokogiri::HTML open(URI.escape(Text_Spoiler_URI % search_frag))
        rows = doc.xpath('//div[@class="textspoiler"]/table/tr')

        @@current_card = nil

        rows.each do |row|
          if row.children.length == 2
            @@cards << @@current_card
            @@current_card = nil
            next
          end

          @@current_card = Scapeshift::Card.new if @@current_card.nil?
          _parse_row row
        end

        @@cards
      end

      def self._parse_row row
        case _row_type(row)
        when :name
          @@current_card.name = _parse_name row
          @@current_card.image_uri_from_id = _parse_image_uri row
        when :cost
          @@current_card.cost = _parse_cost row
        when :type
          @@current_card.types = _parse_type row
        when :'pow/tgh'
          @@current_card.pow_tgh = _parse_pow_tgh row
        when :'rules text'
          @@current_card.text = _parse_rules_text row
        when :'set/rarity'
          @@current_card.sets = _parse_set_rarity row
        else
          raise Scapeshift::Errors::UnknownCardAttribute.new "Unable to parse attribute: '#{_row_type(row)}'"
        end
      end

      def self._row_type row
        row./('td[1]').children.first.to_s.strip.chop.downcase.to_sym
      end

      def self._parse_name row
        row./('td[2]/a').children.last.to_s
      end

      def self._parse_image_uri row
        row./('td[2]/a').first[:href] =~ /multiverseid=(\d+)/
        $1
      end

      def self._parse_cost row
        row./('td[2]').children.last.to_s.strip
      end

      def self._parse_type row
        types = row./('td[2]').children.first.to_s.strip.split(' ')
        types.delete('&mdash;')
        types
      end

      def self._parse_pow_tgh row
        pt_str = row./('td[2]').children.first.to_s.strip
        return nil if pt_str.empty?
        pt_str =~ /\((.*?)\/(.*?)\)/
          [$1, $2]
      end

      def self._parse_rules_text row
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

      def self._parse_set_rarity row
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
    end
  end
end

