require 'helper'

class TestMetaCrawler < Test::Unit::TestCase
  context "The Meta crawler class" do
    should "respond to crawl" do
      assert_respond_to Scapeshift::Crawlers::Meta, :crawl
    end

    context "crawling expansion Sets" do
      setup do
        @sets = Scapeshift::Crawlers::Meta.crawl :type => :sets
      end

      should "return a SortedSet" do
        assert_instance_of SortedSet, @sets
      end

      should "return valid expansion sets" do
        check = Set.new %w{Darksteel Coldsnap Zendikar Shadowmoor Lorwyn Nemesis Onslaught}
        assert check.proper_subset?(@sets)
      end
    end

    context "crawling Formats" do
      setup do
        @formats = Scapeshift::Crawlers::Meta.crawl :type => :formats
      end

      should "return a SortedSet" do
        assert_instance_of SortedSet, @formats
      end

      should "return valid formats" do
        check = Set.new %w{Standard Classic Legacy Extended Freeform Vintage}
        assert check.proper_subset?(@formats)
      end
    end

    context "crawling Card Types" do
      setup do
        @types = Scapeshift::Crawlers::Meta.crawl :type => :types
      end

      should "return a SortedSet" do
        assert_instance_of SortedSet, @types
      end

      should "return valid card types" do
        check = Set.new %w{Artifact World Tribal Plane Land}
        assert check.proper_subset?(@types)
      end
    end
  end
end

