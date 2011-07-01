require 'helper'

class TestSingleCrawler < Test::Unit::TestCase
  context "The Single crawler" do
    should "respond to crawl" do
      assert_respond_to Scapeshift::Crawlers::Single.new(:name => "fake"), :crawl
    end

    context "when no name is supplied" do
      should "raise the proper exception" do
        assert_raise Scapeshift::Errors::InsufficientOptions do
          crawler = Scapeshift::Crawlers::Single.new
          crawler.crawl
        end
      end
    end

    context "when an ambiguous card name is supplied" do
      should "raise the proper exception" do
        assert_raise Scapeshift::Errors::CardNameAmbiguousOrNotFound do
          crawler = Scapeshift::Crawlers::Single.new :name => "vial"
          crawler.crawl
        end
      end
    end
 
    context "when an invalid card name is supplied" do
      should "raise the proper exception" do
        assert_raise Scapeshift::Errors::CardNameAmbiguousOrNotFound do
          # Vulgar, but we can be assured that this search
          # will always be empty.
          crawler = Scapeshift::Crawlers::Single.new :name => "fuck"
          crawler.crawl
        end
      end
    end

    context "when a valid name is supplied" do
      setup do
        @card = Scapeshift::Crawler.crawl :single, :name => "Akroma, Angel of Wrath"
      end

      should "return a Card object" do
        assert_instance_of Scapeshift::Card, @card
      end

      should "return the proper Card" do
        assert_equal "Akroma, Angel of Wrath", @card.name
        assert_equal "5WWW", @card.cost
        assert_equal "Legendary Creature - Angel", @card.types
        assert_equal "Flying, first strike, vigilance, trample, haste, protection from black and from red", @card.text
        assert_equal "Duel Decks: Divine vs. Demonic", @card.set
        assert_equal "Mythic Rare", @card.rarity
        assert_equal [["Duel Decks: Divine vs. Demonic", "Mythic Rare"], ["Legions", "Rare"], 
          ['Time Spiral "Timeshifted"', "Special"]], @card.sets
        assert_equal "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=193871&type=card", @card.image_uri
        assert_equal "6", @card.pow
        assert_equal "6", @card.tgh
        assert_equal nil, @card.loyalty
        assert_equal "Chippy", @card.artist
      end
    end

    context "when a planeswalker name is supplied" do
      setup do
        @card = Scapeshift::Crawler.crawl :single, :name => "Jace Beleren"
      end

      should "return a Card object" do
        assert_instance_of Scapeshift::Card, @card
      end

      should "correclty set the loyalty" do
        assert_equal "3", @card.loyalty
      end

      should "return the proper Card" do
        assert_equal "Jace Beleren", @card.name
        assert_equal "1UU", @card.cost
        assert_equal "Planeswalker - Jace", @card.types
        assert_equal "+2: Each player draws a card.\n-1: Target player draws a card.\n-10: Target player puts the top twenty cards of his or her library into his or her graveyard.", @card.text
        assert_equal "Magic 2011", @card.set
        assert_equal "Mythic Rare", @card.rarity
        assert_equal [["Magic 2011", "Mythic Rare"], ["Magic 2010", "Mythic Rare"], ["Lorwyn", "Rare"],
          ["Duel Decks: Jace vs. Chandra", "Mythic Rare"]], @card.sets
        assert_equal "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=205960&type=card", @card.image_uri
        assert_equal nil, @card.pow
        assert_equal nil, @card.tgh
        assert_equal "3", @card.loyalty
        assert_equal "Aleksi Briclot", @card.artist
      end
    end
  end
end

