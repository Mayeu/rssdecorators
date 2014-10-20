require 'open-uri'
require 'contracts'
require 'nokogiri'

include Contracts

feeds = [ { :name => 'gws', :url => 'http://www.girlswithslingshots.com/feed/'} ]
#feeds = [ { :name => 'gws', :url => './feed.xml'} ]
FEED_PATH = '/srv/http/feeds'

# Type alias
XmlDoc     = Nokogiri::XML::Document
HtmlDoc    = Nokogiri::HTML::Document
XmlElement = Nokogiri::XML::Element

Contract String => XmlDoc
def parse_feed path
  Nokogiri::XML open path
end

#Contract XmlDoc => ArrayOf[XmlElement]
def select_item(feed)
  feed.xpath("//item")
end

Contract XmlElement => String
def page_link(item)
  item.at_css('link').children.text
end

Contract XmlElement => HtmlDoc
def item_description(item)
  Nokogiri::HTML(item.at_css('description').children.first.content)
end

Contract String => HtmlDoc
def parse_page(url)
  Nokogiri::HTML open url
end

Contract XmlDoc => String
def comics_url(page)
  page.at_css("img#comic")['src']
end

Contract XmlDoc => String
def comics_title(page)
  page.at_css("img#comic")['title']
end

Contract XmlDoc, String => XmlElement
def img_node(doc, src)
  node = Nokogiri::XML::Node.new("img", doc)
  node['src'] = src
  node
end

Contract XmlDoc, String => XmlElement
def caption_node(doc, caption)
  node = Nokogiri::XML::Node.new "p", doc
  node.content = caption
  node
end

Contract XmlDoc, HtmlDoc => XmlDoc
def new_desc(desc, page)
  desc.at_css("body>a").add_previous_sibling img_node(desc, comics_url(page))
  desc.at_css("body>a").add_previous_sibling caption_node(desc, comics_title(page))
  desc
end

Contract XmlElement, String => String
def inject_content(item, html)
  item.at_css('description').children.first.content = html
end

Contract XmlElement => HtmlDoc
def fetch_page(item)
  parse_page(page_link(item))
end

feeds.each do |feed|

  parsed_feed = parse_feed(feed[:url])

  select_item(parsed_feed).each do |it|
    # Replace old desc
    inject_content(it, new_desc(item_description(it), fetch_page(it)).to_html)
  end

  #File.write "#{FEED_PATH}/feed[:name]" parsed_feed.to_xml
  puts parsed_feed.to_xml
end
