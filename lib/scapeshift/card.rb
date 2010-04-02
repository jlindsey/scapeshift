module Scapeshift

  ##
  # Represents a single Magic: The Gathering card. These are created automatically
  # by the various {Crawlers}, but can be instantiated by end-users if they desire.
  #
  # @author Josh Lindsey
  #
  # @since 0.1.0
  #
  class Card

    ##
    # Base URI for card images. Interpolated with the "multiverse id" of the
    # card to be imaged.
    Image_URI = 'http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=%d&type=card'

    ##
    # List of possible Supertypes a Card can have
    Supertypes = %w(Basic Legendary Snow World)

    ##
    # List of possible Base Types a Card can have
    Base_Types = %w(Artifact Creature Enchantment Land Planeswalker Instant Sorcery Tribal Plane Vanguard)

    ##
    # The card name
    attr_accessor :name

    ##
    # The mana cost of the card, specified as a
    # String in the form "2BR".
    attr_accessor :cost

    ##
    # An array of the card's base types. 
    # eg ["Artifact", "Creature"]
    attr_accessor :base_types

    ##
    # An array of the card's subtypes.
    # eg ["Human", "Wizard"]
    attr_accessor :subtypes

    ##
    # An array of the card's supertypes.
    # eg ["Snow", "Legendary"]
    attr_accessor :supertypes

    ## Attack power for creature cards
    attr_accessor :pow

    ## Toughness for creature cards
    attr_accessor :tgh

    ## The card's body text
    attr_accessor :text

    ##
    # The sets and rarities of this card. A multidimensional array 
    # of the form [[Set, Rarity]]
    attr_accessor :sets

    ## The interpolated Image_URI string
    attr_accessor :image_uri

    ##
    # Instantiate a new Card object.
    #
    # @param [Hash] params Default values for the object.
    #   Similar to ActiveRecord::Base.
    #
    # @return [Card] The new Card object
    #
    # @raise [NoMethodError] If a key is passed in for which there is no corresponding
    #   setter method.
    #
    # @author Josh Lindsey
    #
    # @since 0.1.0
    #
    def initialize params = {}
      self.supertypes = []
      self.subtypes = []
      self.base_types = []
      self.sets = [[]]

      return if params.empty?

      params.each_pair do |var, val| 
        method = (var.to_s + "=").to_sym
        self.send method, val
      end
    end

    ##
    # Interpolates the Image_URI with the "multiverse id".
    #
    # @param [Integer] id The "multiverse id" for this card
    #
    # @author Josh Lindsey
    #
    # @since 0.1.0
    #
    def image_uri_from_id= id
      self.image_uri = Image_URI % id
    end

    ## To make Hash instantiation more readable
    alias :image_id= :image_uri_from_id=

    ##
    # Sets the Card's {#subtypes}, {#supertypes}, and {#base_types}
    # from a correctly formatted String.
    #
    # @param [String] types_str The types string
    #
    # @author Josh Lindsey
    #
    # @since 0.1.3
    #
    def types= types_str
      ary = [[], []]

      # From the Cards crawler
      if types_str.include? ' &mdash; ' 
        ary = _split_base_and_subtypes types_str, ' &mdash; '
      # Also from the Cards crawler
      elsif types_str.include? ' – '
        ary = _split_base_and_subtypes types_str, ' – '

      # From manual text input.
      # Note that this is a hyphen. Above is a dash (Alt + - in OS X).
      elsif types_str.include? ' - '
        ary = _split_base_and_subtypes types_str, ' - '

      # If it doesn't contain one of these delimiters, it has no subtypes
      else
        ary[0] = types_str.split(' ')
      end
      
      self.supertypes = ary[0] & Supertypes
      self.base_types = ary[0] & Base_Types
      self.subtypes = ary[1]
    end

    ##
    # The types of this card in string form.
    #
    # @return [String] The formatted Type string.
    #   Should be a valid input for {#types=}
    #
    # @author Josh Lindsey
    #
    # @since 0.1.3
    #
    def types
      type = ''
      unless self.supertypes.empty?
        type << self.supertypes.join(' ')
        type << ' '
      end

      type << self.base_types.join(' ')

      unless self.subtypes.empty?
        type << ' - '
        type << self.subtypes.join(' ')
      end

      type
    end

    ##
    # The most recent rarity of this card.
    #
    # @return [String] The rarity.
    #
    # @author Josh Lindsey
    #
    # @since 0.1.0
    #
    def rarity
      self.sets.first[1]
    end

    ##
    # The most recent set this card appeared in.
    #
    # @return [String] The set.
    #
    # @author Josh Lindsey
    #
    # @since 0.1.0
    #
    def set
      self.sets.first[0]
    end

    ##
    # Set the power and toughness from an Array.
    #
    # @param [Array [Power, Toughness]] pt The power and toughness array
    # 
    # @author Josh Lindsey
    #
    # @since 0.1.0
    #
    def pow_tgh=(pt)
      return if pt.nil?
      self.pow = pt[0]
      self.tgh = pt[1]
    end

    ##
    # Operator method to determine sort order. Sorts based
    # on {#name}.
    #
    # @param [Card] other_card The other Card to compare with
    #
    # @return [Integer] 1, 0, or -1
    #
    # @author Josh Lindsey
    #
    # @since 0.1.2
    #
    def <=> other_card
      self.name <=> other_card.name
    end

    ##
    # Operator method to determine equality.
    #
    # @param [Card] other_card The other Card to compare with
    #
    # @return [Boolean] Whether or not they are equal
    #
    # @author Josh Lindsey
    #
    # @since 0.1.2
    #
    def == other_card
      if self.name == other_card.name and
        self.cost == other_card.cost and
        self.sets == other_card.sets and
        self.image_uri == other_card.image_uri and
        self.text == other_card.text and
        self.types == other_card.types

        return true
      end

      return false
    end

    private

    ##
    # Used by {#types=} to split the types line string into an array
    # of types and subtypes.
    #
    # @param [String] types_str The correctly formatted types line string
    # @param [String] split_on The string that delimits super/base types and subtypes
    #
    # @return [Array] First element is the base (and possibly super) types.
    #   Second element is the subtypes.
    #
    # @author Josh Lindsey
    #
    # @since 0.1.3
    #
    def _split_base_and_subtypes types_str, split_on
      ary = types_str.split(split_on)
      ary[0] = ary[0].split(' ')
      ary[1] = ary[1].split(' ')
      ary
    end
  end
end

