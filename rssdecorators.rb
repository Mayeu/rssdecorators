require 'open-uri'
require 'contracts'
require 'nokogiri'

include Contracts

# feeds = [{ name: 'gws', url: 'http://www.girlswithslingshots.com/feed/'}]
feeds = [{ name: 'gws', url: './feed.xml' }]
FEED_PATH = '/srv/http/feeds'

# Type alias
XmlDoc     = Nokogiri::XML::Document
HtmlDoc    = Nokogiri::HTML::Document
XmlElement = Nokogiri::XML::Element

# I/O
Contract String => XmlDoc
def parse_feed(path)
  Nokogiri::XML open path
end

# I/O
Contract String => HtmlDoc
def parse_page(url)
  Nokogiri::HTML open url
end

class Page
  attr_reader :content

  def initialize(content)
    @content = content
  end

  Contract Page => String
  def comics_url
    content.at_css('img#comic')['src']
  end

  Contract Page => String
  def comics_title
    content.at_css('img#comic')['title']
  end
end

class Item
  attr_reader :content

  # Contract XmlElement => Item
  def initialize(content)
    @content = content
  end

  Contract XmlElement => String
  def page_link
    content.at_css('link').children.text
  end

  Contract XmlElement => HtmlDoc
  def description
    Nokogiri::HTML(content.at_css('description').children.first.content)
  end

  # I/O, parse page go on the net
  Contract XmlElement => Page
  def fetch_page
    Page.new parse_page(page_link)
  end

  # Mutation
  Contract String => String
  def inject_content(html)
    content.at_css('description').children.first.content = html
  end
end

class Feed
  attr_reader :content

  def initialize(content)
    @content = content
  end

  # Contract XmlDoc => ArrayOf[XmlElement]
  def select_item
    content.xpath('//item')
  end

  def to_xml
    content.to_xml
  end
end

Contract XmlDoc, String => XmlElement
def img_node(doc, src, title)
  node = Nokogiri::XML::Node.new('img', doc)
  node['src']   = src
  node['title'] = title
  node
end

Contract XmlDoc, String => XmlElement
def caption_node(doc, caption)
  p_node = Nokogiri::XML::Node.new 'p', doc
  node = Nokogiri::XML::Node.new 'i', doc
  node.content = caption
  p_node.add_child(node)
  p_node
end

Contract XmlDoc, Page => XmlDoc
def new_desc(desc, page)
  desc.at_css('body>a').add_previous_sibling(img_node(desc, page.comics_url, page.comics_title))
  desc.at_css('body>a').add_previous_sibling(caption_node(desc, page.comics_title))
  desc
end

feeds.each do |feed|

  parsed_feed = Feed.new(parse_feed(feed[:url]))

  parsed_feed.select_item.each do |it|
    item = Item.new it
    # Replace old desc
    item.inject_content(new_desc(item.description, item.fetch_page).to_html)
  end

  # File.write "#{FEED_PATH}/#{feed[:name]}", parsed_feed.to_xml
  puts parsed_feed.to_xml
end
