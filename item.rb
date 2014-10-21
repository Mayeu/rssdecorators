require 'contracts'

require_relative 'page'

include Contracts

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

  Contract Page => XmlDoc
  def new_description(page)
    desc = description
    desc.at_css('body>a').add_previous_sibling(img_node(desc, page.comics_url, page.comics_title))
    desc.at_css('body>a').add_previous_sibling(caption_node(desc, page.comics_title))
    desc
  end

  # Mutation
  Contract Page => String
  def inject_content(page)
    content.at_css('description').children.first.content = new_description(page).to_html
  end
end
