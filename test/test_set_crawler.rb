require 'helper'

class TestSetCrawler < Test::Unit::TestCase
  context "The Set crawler class" do
    should "respond to crawl" do
      assert_respond_to Scapeshift::Crawlers::Sets, :crawl
    end
  end

  context "The Set crawler return values" do
    setup do
      @sets = Scapeshift::Crawler.crawl :sets
    end

    should "be proper format" do
      assert_instance_of Set, @sets
    end

    should "be sets" do
      # Just take a random sampling to check
      check = Set.new %w(Prophecy Shadowmoor Mirrodin Morningtide Guildpact)
      assert @sets.proper_superset?(check)
    end
  end
end

