require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'assert2'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'scapeshift'
require 'set'

class Test::Unit::TestCase
end
