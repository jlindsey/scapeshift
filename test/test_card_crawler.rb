require 'helper'

class TestCardCrawler < Test::Unit::TestCase
  context "The Card crawler" do
    should "respond to crawl" do
      crawler = Scapeshift::Crawlers::Cards.new :set => "fake" 
      assert_respond_to crawler, :crawl
    end

    context "when passed insufficient options" do
      should "raise the appropriate exception" do
        assert_raise Scapeshift::Errors::InsufficientOptions do
          Scapeshift::Crawlers::Cards.new
        end
      end
    end

    context "when passed valid options" do
      setup do
        # Pull from a specific set instead of Type 2 so we don't have to 
        # keep updating this test when new blocks cycle in.
        @cards = Scapeshift::Crawler.crawl :cards, :set => "Darksteel"
      end
      
      should "return a SortedSet of Card objects" do
        assert_instance_of SortedSet, @cards
        assert_instance_of Scapeshift::Card, @cards.to_a.first
      end

      should "pull from the correct set" do
        check = Set.new %w(Coretapper Dismantle Eater\ of\ Days Soulscour Trinisphere Thunderstaff)
        names = Set.new
        @cards.each { |card| names << card.name }

        assert check.proper_subset?(names)
      end

      should "have created the Card objects with the correct data" do
        # Using the last entry here because the first one is 
        # Æther Snap and fuck typing that out every time.
        #
        # Also, Set and SortedSet don't implement #first or #last.
        # Which is why we're doing this little hack.
        card = @cards.entries[@cards.size - 1]

        check_card = Scapeshift::Card.new :name => "Wurm's Tooth",
          :types => "Artifact", :sets => [["Magic 2011", "Uncommon"], ["Magic 2010", "Uncommon"],
            ["Tenth Edition", "Uncommon"], ["Ninth Edition", "Uncommon"], ["Darksteel", "Uncommon"]],
            :cost => "2", :text => "Whenever a player casts a green spell, you may gain 1 life.",
            :image_uri => "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=72684&type=card",
            :multiverse_id => "72684"

            assert_equal check_card, card
      end
    end

    context "when looking in sets with planeswalkers" do
      setup do
        # Pull from a specific set instead of Type 2 so we don't have to
        # keep updating this test when new blocks cycle in.
        @cards = Scapeshift::Crawler.crawl :cards, :set => "Shards of Alara"
      end

      should "return a SortedSet of Card objects" do
        assert_instance_of SortedSet, @cards
        assert_instance_of Scapeshift::Card, @cards.to_a.first
      end

      should "pull from the correct set" do
        check = Set.new %w(Ajani\ Vengeant Archdemon\ of\ Unx Mindlock\ Orb Prince\ of\ Thralls)
        names = Set.new
        @cards.each { |card| names << card.name }

        assert check.proper_subset?(names)
      end

      should "have created the Card objects with the correct data" do
        card = @cards.entries[0]

        check_card = Scapeshift::Card.new :name => "Ad Nauseam",
          :types => "Instant", :sets => [["Shards of Alara", "Rare"]],
            :cost => "3BB", :text => "Reveal the top card of your library and put that card into your hand. You lose life equal to its converted mana cost. You may repeat this process any number of times.",
            :image_uri => "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=174915&type=card",
            :multiverse_id => "174915"

            assert_equal check_card, card
      end
    end
  end
end

