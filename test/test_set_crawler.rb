require 'helper'

class TestSetCrawler < Test::Unit::TestCase
  context "The Set crawler" do
    setup do
      @sets = Scapeshift::Crawler.crawl :sets
    end

    should "return the proper format" do
      assert @sets.is_a? Set
    end

    should "correctly grab sets" do
      # Just take a random sampling to check
      check = Set.new %w(Prophecy Shadowmoor Mirrodin Morningtide Guildpact)
      assert check & @sets
    end
  end
end

