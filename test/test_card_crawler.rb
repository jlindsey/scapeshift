require 'helper'

class TestCardCrawler < Test::Unit::TestCase
  context "The Card crawler class" do
    should "respond to crawl" do
      assert_respond_to Scapeshift::Crawlers::Cards, :crawl
    end
  end

  context "The Card crawler return values" do 
    setup do
      # Pull from a specific set instead of Type 2 so we don't have to 
      # keep updating this test when new blocks cycle in.
      @cards = Scapeshift::Crawler.crawl :cards, :set => "Darksteel"
    end

    should "be a SortedSet of Card objects" do
      assert_instance_of SortedSet, @cards
      assert_instance_of Scapeshift::Card, @cards.to_a.first
    end

    should "be from the correct set" do
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
        :types => ["Artifact"], :sets => [["Magic 2010", "Uncommon"], ["Tenth Edition", "Uncommon"], 
        ["Ninth Edition", "Uncommon"], ["Darksteel", "Uncommon"]],
        :cost => "2", :text => "Whenever a player casts a green spell, you may gain 1 life.",
        :image_uri => "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=72684&type=card"

      assert_equal check_card, card
    end
  end
end

