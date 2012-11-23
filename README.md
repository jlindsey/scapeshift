Scapeshift
==========

Scapeshift is a webscraper rubygem designed for the Magic: The Gathering Oracle "Gatherer" card index.
Since Wizards doesn't want to make an API for this system for various reasons, I've gone ahead and made
a pseudo-API here.

Scapeshift uses the delightful Nokogiri gem to parse and scrape the various Oracle pages, generating 
(most commonly) a SortedSet of Scapeshift::Card objects containing the card data. In the case of expansion sets, formats, 
etc. Scapeshift returns a SortedSet of strings.

Usage
-----

Usage is as simple as can be:

    # Grab the complete list of expansion sets
    @sets = Scapeshift::Crawler.crawl :meta, :type => :sets

    # Grab the card set for an expansion
    @alara_cards = Scapeshift::Crawler.crawl :cards, :set => 'Shards of Alara'

    # Grab a single named card
    @card = Scapeshift::Crawler.crawl :single, :name => 'Counterspell'

Development
-----------

This gem uses Bundler to manage its dependencies for development:

    $ sudo gem install bundler
    $ cd /path/to/scapeshift
    $ bundle install

Bundler is unlike Rubygems in that it doesn't automagically handle load paths for you. To
make stuff work, you will need to start a subshell with
    
    $ bundle exec bash

Replacing `bash` with the shell of your choice, of course.

Documentation
-------------

This gem uses Yardoc syntax for documentation. You can generate these docs
with `rake yard`. Point any webserver at the `docs/` directory to browse.

Simple, with Thin:

    $ cd /path/to/scapeshift
    $ rake yard
    $ cd docs/
    $ thin -A file -d start

Copyright
---------

Copyright (c) 2010 Josh Lindsey. See LICENSE for details.
