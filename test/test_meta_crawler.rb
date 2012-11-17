require 'helper'

class TestMetaCrawler < Test::Unit::TestCase
  context "The Meta crawler" do
    should "respond to crawl" do
      assert_respond_to Scapeshift::Crawlers::Meta.new(:type => "fake"), :crawl
    end

    context "when passed no options" do
      should "raise the appropriate exception" do
        assert_raise Scapeshift::Errors::InsufficientOptions do
          Scapeshift::Crawlers::Meta.new
        end
      end
    end

    context "when passed a bad meta type" do
      should "raise the appropiate exception" do
        assert_raise Scapeshift::Errors::UnknownMetaType do
          crawler = Scapeshift::Crawlers::Meta.new :type => :not_a_real_type
          VCR.use_cassette 'meta' do
            crawler.crawl
          end
        end
      end
    end

    context "when crawling expansion Sets" do
      setup do
        VCR.use_cassette 'meta' do
          @sets = Scapeshift::Crawler.crawl :meta, :type => :sets
        end
      end

      should "return a SortedSet" do
        assert_instance_of SortedSet, @sets
      end

      should "return valid expansion sets" do
        check = Set.new %w{Darksteel Coldsnap Zendikar Shadowmoor Lorwyn Nemesis Onslaught}
        assert check.proper_subset?(@sets)
      end

      should "not contain empty sets" do
        @sets.each do |set|
          assert !set.empty?
        end
      end
    end

    context "when crawling Formats" do
      setup do
        VCR.use_cassette 'meta' do
          @formats = Scapeshift::Crawler.crawl :meta, :type => :formats
        end
      end

      should "return a SortedSet" do
        assert_instance_of SortedSet, @formats
      end

      should "return valid formats" do
        check = Set.new %w{Standard Classic Legacy Extended Freeform Vintage}
        assert check.proper_subset?(@formats)
      end
    end

    context "when crawling Card Types" do
      setup do
        VCR.use_cassette 'meta' do
          @types = Scapeshift::Crawler.crawl :meta, :type => :types
        end
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

