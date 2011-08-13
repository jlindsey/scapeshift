require 'open-uri'
require 'fakeweb'

module FakeWebHelper
  def self.urls
    File.open(File.join(File.dirname(__FILE__), 'fakeweb.urls')).read.to_a.each { |u| u.strip! }
  end

  def self.filename_for(url)
    File.join File.dirname(__FILE__), 'fakeweb', url.hash.to_s + '.html'
  end

  def self.cache_url(url)
    unless File.directory? File.dirname(FakeWebHelper.filename_for(url))
      FileUtils.mkdir_p File.dirname(FakeWebHelper.filename_for(url))
    end

    puts "Caching #{url} in #{FakeWebHelper.filename_for(url)}"

    File.open(FakeWebHelper.filename_for(url), 'w') { |f| f.write(open(url).read) }
  end

  def self.cache_all_urls
    urls.each { |url| cache_url(url) }
  end

  def self.fake_url(url)
    raise "Cant fake url: #{url}. Maybe you should run `rake fakeweb:update` first" unless File.exists? FakeWebHelper.filename_for(url)

    FakeWeb.register_uri :get, url, :body => File.open(FakeWebHelper.filename_for(url)).read
  end

  def self.fake_all_urls
    urls.each { |url| fake_url(url) }
  end
end
