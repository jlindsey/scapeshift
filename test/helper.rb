require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'fakeweb'
require 'fakeweb_helper'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'scapeshift'
require 'set'

FakeWeb.allow_net_connect = false
FakeWebHelper.fake_all_urls

class Test::Unit::TestCase
end
