require 'open-uri'
require 'contracts'
require 'nokogiri'

require_relative 'rss_decorators/contract_type'

# Item
class Item ; end
# Page
class Page ; end

require_relative 'rss_decorators/gws'
require_relative 'rss_decorators/smbc'

include Contracts

# I/O, parse XML feed from the net
Contract String => XmlDoc
def parse_feed(path)
  Nokogiri::XML open path
end

# I/O, parse HTML page from the net
Contract Item => HtmlDoc
def parse_page(item)
  Nokogiri::HTML open(item.page_link)
end

# Feed
class Feed
  attr_reader :content, :name

  def initialize(name, content)
    @name    = name
    @content = content
  end

  Contract XmlDoc => Nokogiri::XML::NodeSet
  def select_item
    content.xpath('//item')
  end

  def to_xml
    content.to_xml
  end
end

Contract XmlDoc, String => XmlElement
def img_node(doc, src, title = "")
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
