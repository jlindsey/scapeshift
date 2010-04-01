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

    should "be a Set of Card objects" do
      assert_instance_of Set, @cards
      assert_instance_of Scapeshift::Card, @cards.to_a.first
    end

    should "be from the correct set" do
      check = Set.new %w(Coretapper Dismantle Eater\ of\ Days Soulscour Trinisphere Thunderstaff)
      names = Set.new
      @cards.each { |card| names << card.name }

      assert check.proper_subset?(names)
    end
  end
end

