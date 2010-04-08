require 'helper'

class TestBaseCrawler < Test::Unit::TestCase
  context "The Crawler Base class" do
    should "raise the correct exception when crawl is called" do
      assert_raise Scapeshift::Errors::InvalidSubclass do
        crawler = Scapeshift::Crawlers::Base.new :fake => :hash
        crawler.crawl
      end
    end

    should "raise the correct exception when instantiated without options" do
      assert_raise Scapeshift::Errors::InsufficientOptions do
        Scapeshift::Crawlers::Base.new
      end
    end

    should "repond to has_callback_hook" do
      assert_respond_to Scapeshift::Crawlers::Base, :has_callback_hook
    end

    context "with callbacks" do
      setup do
        class CallbackTester < Scapeshift::Crawlers::Base
          has_callback_hook :before_foo

          def foo
            str = "Failure"
            self.hook :before_foo, str
            str
          end
        end

        @tester = CallbackTester.new :fake => :hash
      end

      should "generate the instance method" do
        assert_respond_to @tester, :before_foo
      end

      should "call the blocks for the hook" do
        @tester.before_foo { |str| str.replace "Success" }
        assert_equal "Success", @tester.foo
      end
    end
  end
end

