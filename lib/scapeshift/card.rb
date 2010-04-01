module Scapeshift
  class Card
    Image_URI = 'http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=%d&type=card'

    attr_accessor :name, :cost, :types, :pow, :tgh, :text, :sets, :image_uri

    def initialize params = {}
      return if params.empty?

      params.each_pair do |var, val| 
        method = (var.to_s + "=").to_sym
        self.send method, val
      end
    end

    def image_uri_from_id= id
      self.image_uri = Image_URI % id
    end

    def rarity
      self.sets.first[1]
    end

    def set
      self.sets.first[0]
    end

    def type
      self.types.first
    end

    def subtypes
      self.types[1..(self.types.length - 1)]
    end

    def pow_tgh=(pt)
      return if pt.nil?
      self.pow = pt[0]
      self.tgh = pt[1]
    end
  end
end

