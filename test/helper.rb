require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :fakeweb
  c.allow_http_connections_when_no_cassette = false
  c.default_cassette_options = { :serialize_with => :syck }
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'scapeshift'
require 'set'

class Test::Unit::TestCase
end
