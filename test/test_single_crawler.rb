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
          VCR.use_cassette 'single/vial' do
            crawler.crawl
          end
        end
      end
    end
 
    context "when an invalid card name is supplied" do
      should "raise the proper exception" do
        assert_raise Scapeshift::Errors::CardNameAmbiguousOrNotFound do
          # Vulgar, but we can be assured that this search
          # will always be empty.
          crawler = Scapeshift::Crawlers::Single.new :name => "fuck"
          VCR.use_cassette 'single/fuck' do
            crawler.crawl
          end
        end
      end
    end

    context "when a valid name is supplied" do
      setup do
        VCR.use_cassette 'single/Akroma, Angel of Wrath' do
          @card = Scapeshift::Crawler.crawl :single, :name => "Akroma, Angel of Wrath"
        end
      end

      should "return a Card object" do
        assert_instance_of Scapeshift::Card, @card
      end

      should "return the proper Card" do
        assert_equal "Akroma, Angel of Wrath", @card.name
        assert_equal "5WWW", @card.cost
        assert_equal "Legendary Creature - Angel", @card.types
        assert_equal "Flying, first strike, vigilance, trample, haste, protection from black and from red", @card.text
        assert_equal "\"Wrath is no vice when inflicted upon the deserving.\"", @card.flavour_text
        assert_equal "Duel Decks: Divine vs. Demonic", @card.set
        assert_equal "Mythic Rare", @card.rarity
        assert_equal [["Duel Decks: Divine vs. Demonic", "Mythic Rare"], ["Legions", "Rare"], 
          ['Time Spiral "Timeshifted"', "Special"]], @card.sets
        assert_equal "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=193871&type=card", @card.image_uri
        assert_equal "193871", @card.multiverse_id
        assert_equal "6", @card.pow
        assert_equal "6", @card.tgh
        assert_equal nil, @card.loyalty
        assert_equal "Chippy", @card.artist
        assert_equal "1", @card.number
      end
    end

    context "when a planeswalker name is supplied" do
      setup do
        VCR.use_cassette 'single/Jace Beleren' do
          @card = Scapeshift::Crawler.crawl :single, :name => "Jace Beleren"
        end
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
        assert_equal "205960", @card.multiverse_id
        assert_equal nil, @card.pow
        assert_equal nil, @card.tgh
        assert_equal "3", @card.loyalty
        assert_equal "Aleksi Briclot", @card.artist
        assert_equal "58", @card.number
      end
    end

    context "when a card with two or color mana is supplied" do
      setup do
        VCR.use_cassette 'single/Beseech the Queen' do
          @card = Scapeshift::Crawler.crawl :single, :name => "Beseech the Queen"
        end
      end

      should "return a Card object" do
        assert_instance_of Scapeshift::Card, @card
      end

      should "correclty set the mana cost" do
        assert_equal "(2/B)(2/B)(2/B)", @card.cost
      end

      should "return the proper Card" do
        assert_equal "Beseech the Queen", @card.name
        assert_equal "(2/B)(2/B)(2/B)", @card.cost
        assert_equal "Sorcery", @card.types
        assert_equal "( (2/B) can be paid with any two mana or with B . This card's converted mana cost is 6.)\nSearch your library for a card with converted mana cost less than or equal to the number of lands you control, reveal it, and put it into your hand. Then shuffle your library.", @card.text
        assert_equal "Planechase", @card.set
        assert_equal "Uncommon", @card.rarity
        assert_equal [["Planechase", "Uncommon"], ["Shadowmoor", "Uncommon"]], @card.sets
        assert_equal "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=205399&type=card", @card.image_uri
        assert_equal "205399", @card.multiverse_id
        assert_equal nil, @card.pow
        assert_equal nil, @card.tgh
        assert_equal nil, @card.loyalty
        assert_equal "Jason Chan", @card.artist
        assert_equal "19", @card.number
      end
    end

    context "when a card with phyrexian mana is supplied" do
      setup do
        VCR.use_cassette 'single/Act of Aggression' do
          @card = Scapeshift::Crawler.crawl :single, :name => "Act of Aggression"
        end
      end

      should "return a Card object" do
        assert_instance_of Scapeshift::Card, @card
      end

      should "correclty set the mana cost" do
        assert_equal "3(R/P)(R/P)", @card.cost
      end

      should "return the proper Card" do
        assert_equal "Act of Aggression", @card.name
        assert_equal "3(R/P)(R/P)", @card.cost
        assert_equal "Instant", @card.types
        assert_equal "( (R/P) can be paid with either R or 2 life.)\nGain control of target creature an opponent controls until end of turn. Untap that creature. It gains haste until end of turn.", @card.text
        assert_equal "New Phyrexia", @card.set
        assert_equal "Uncommon", @card.rarity
        assert_equal [["New Phyrexia", "Uncommon"]], @card.sets
        assert_equal "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=230076&type=card", @card.image_uri
        assert_equal "230076", @card.multiverse_id
        assert_equal nil, @card.pow
        assert_equal nil, @card.tgh
        assert_equal nil, @card.loyalty
        assert_equal "Whit Brachna", @card.artist
        assert_equal "78", @card.number
      end
    end

    context "when a card with snow mana is supplied" do
      setup do
        VCR.use_cassette 'single/Adarkar Windform' do
          @card = Scapeshift::Crawler.crawl :single, :name => "Adarkar Windform"
        end
      end

      should "return a Card object" do
        assert_instance_of Scapeshift::Card, @card
      end

      should "return the proper Card" do
        assert_equal "Adarkar Windform", @card.name
        assert_equal "4U", @card.cost
        assert_equal "Snow Creature - Illusion", @card.types
        assert_equal "Flying\n 1S}i : Target creature loses flying until end of turn.( S}i can be paid with one mana from a snow permanent.)", @card.text
        assert_equal "Coldsnap", @card.set
        assert_equal "Uncommon", @card.rarity
        assert_equal [["Coldsnap", "Uncommon"]], @card.sets
        assert_equal "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=121268&type=card", @card.image_uri
        assert_equal "121268", @card.multiverse_id
        assert_equal "3", @card.pow
        assert_equal "3", @card.tgh
        assert_equal nil, @card.loyalty
        assert_equal "Randy Gallegos", @card.artist
        assert_equal "26", @card.number
      end
    end
  end
end

