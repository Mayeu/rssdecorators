require 'contracts'

include Contracts

# SMBC
class Dilbert < Item
  attr_reader :content

  def initialize(content)
    @content = content
  end

  Contract XmlElement => String
  def page_link
    content.xpath('feedburner:origLink').first.children.text
  end

  Contract XmlElement => Or[XmlElement,HtmlDoc]
  def description
    content.at_css('description')
  end

  Contract Page => Or[XmlDoc, XmlElement]
  def new_description(page)
    desc = description
    new_desc = Nokogiri::XML::Node.new('description', content)
    new_desc.add_child(Nokogiri::XML::CDATA.new(new_desc, img_node(new_desc, page.comics_url).to_html))
    desc.swap(new_desc)
    desc
  end

  # Mutation
  Contract Page => XmlElement
  def inject_content(page)
    new_description(page)
  end
end

# Page
class DilbertPage < Page
  Contract Page => String
  def comics_url
    expand_url content.at_css('div.STR_Image img')['src']
  end

  private

  def expand_url(img_url)
    "http://dilbert.com/" + img_url
  end
end
