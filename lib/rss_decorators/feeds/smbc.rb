require 'contracts'

include Contracts

# SMBC
class SMBC < Item

  def need_original_page?
    false
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
  def new_description
    desc = description
    desc.at_css('img').add_next_sibling(img_node(desc, after_comics_url))
    desc
  end

  # Mutation
  Contract Page => HtmlDoc
  def inject_content(page = nil)
    content.at_css('description').children.first.content = new_description
  end

  private
  def after_comics_url
    comics = description.at_css('img')['src']
    comics.sub('.png', 'after.png')
  end

end
