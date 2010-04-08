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
      end
    end
  end
end

