require 'open-uri'
require 'contracts'
require 'nokogiri'

include Contracts

feeds = [ { :name => 'gws', :url => 'http://www.girlswithslingshots.com/feed/'} ]
FEED_PATH = '/srv/http/feeds'

class Feed
  attr_accessor :name, :content

  def initialize name, content
    @name    = name
    @content = content
  end

  def select_item
    content.xpath("//item")
  end
end

class Item
  attr_accessor :content

  def initialize content
    @content = content
  end
end

Contract String => Nokogiri::XML::Document
def parse_feed feed_path
  open feed_path do |content|
    Nokogiri::XML content
  end
end

feeds.each do |f|

  feed = Feed.new f[:name], parse_feed(f[:url])

  feed.select_item.each do |it|
    # Get the link
    link = it.at_css('link').children.text
    # Get the html page
    html = Nokogiri::HTML (open link)
    # Get the URL of the comic
    url = html.at_css("img#comic")['src']
    # Get the title attribute of the image
    title = html.at_css("img#comic")['title']
    # Get the description
    desc = Nokogiri::HTML(it.at_css('description').children.first.content)
    # Insert the image before the link to new comics
    img = Nokogiri::XML::Node.new "img", desc
    img['src'] = url
    desc.at_css("body>a").add_previous_sibling img
    caption = Nokogiri::XML::Node.new "p", desc
    caption.content = title
    desc.at_css("body>a").add_previous_sibling caption
    # Replace old desc
    it.at_css('description').children.first.content = desc.to_html
  end

  #File.write "#{FEED_PATH}/feed.name" feed.to_xml
  puts feed.content.to_xml
end
