require 'helper'

class TestCrawlerMain < Test::Unit::TestCase
  context "The Crawler router class" do
    should "have a crawl method" do
      assert_respond_to Scapeshift::Crawler, :crawl
    end

    should "raise an exception for an invalid crawler type" do
      assert_raise Scapeshift::Errors::InvalidCrawlerType do
        Scapeshift::Crawler.crawl :invalid
      end
    end
  end
end

