require 'scapeshift/crawler'

##
# A webscraper gem designed for the Magic: The Gathering
# Oracle "Gatherer" card index.
#
# @example
#   # Grabs the names of all the sets
#   @sets = Scapeshift::Crawler.crawl :sets
#   
#   # Grabs all the cards out of the Shards of Alara expansion
#   @cards = Scapeshift::Crawler.crawl :cards, :set => 'Shards of Alara'
#
# @author Josh Lindsey
#
module Scapeshift; end
