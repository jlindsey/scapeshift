require 'helper'

class TestCardCrawler < Test::Unit::TestCase
  context "The Card crawler" do 
    setup do
      # Pull from a specific set instead of Type 2 so we don't have to 
      # keep updating this test when new blocks cycle in.
      @cards = Scapeshift::Crawler.crawl :cards, :set => "Darksteel"
    end

    should "return the proper format" do
      assert @cards.is_a? Set
    end

    should "parse cards into card objects" do

    end

    should "grab cards from the correct set" do
      check = Set.new %w(Coretapper Dismantle Eater\ of\ Days Soulscour Trinisphere Thunderstaff)
      names = []
      @cards.each { |card| names << card.name }

      assert check & names
    end
  end
end

