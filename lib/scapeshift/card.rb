module Scapeshift

  ##
  # Represents a single Magic: The Gathering card. These are created automatically
  # by the various {Crawlers}, but can be instantiated by end-users if they desire.
  # 
  # @todo Figure out a way to take Supertypes into account.
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
    # The card name
    attr_accessor :name
    
    ##
    # The mana cost of the card, specified as a
    # String in the form "2BR".
    attr_accessor :cost
    
    ##
    # The card types of this card. An array, where the
    # first element is the base type.
    attr_accessor :types
   
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
    # The base type of this card.
    #
    # @return [String] The base type.
    #
    # @author Josh Lindsey
    #
    # @since 0.1.0
    #
    def type
      self.types.first
    end
    
    ##
    # The subtypes of this card, if any.
    #
    # @return [Array] The subtypes, or an empty Array
    #
    # @author Josh Lindsey
    #
    # @since 0.1.0
    #
    def subtypes
      self.types[1..(self.types.length - 1)]
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
  end
end

