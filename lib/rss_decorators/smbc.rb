require 'contracts'

include Contracts

# SMBC
class SMBC < Item
  attr_reader :content

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

  Contract Page => XmlDoc
  def new_description(page)
    desc = description
    desc.at_css('img').add_next_sibling(img_node(desc, page.comics_url))
    desc
  end

  # Mutation
  Contract Page => String
  def inject_content(page)
    content.at_css('description').children.first.content = new_description(page).to_html
  end
end

# Page
class SMBCPage < Page
  Contract Page => String
  def comics_url
    content.at_css('#aftercomic > img')['src']
  end
end
