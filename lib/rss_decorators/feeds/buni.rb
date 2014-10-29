require 'contracts'

include Contracts

# SMBC
class Buni < Item

  def need_original_page?
    false
  end

  Contract XmlElement => String
  def page_link
    content.at_css('link').children.text
  end

  Contract XmlElement => XmlElement
  def description
    content.at_css('description')
  end

  Contract XmlElement => HtmlDoc
  def html_description
    Nokogiri::HTML(description.children.first.content)
  end

  Contract Page => XmlElement
  def new_description
    new_desc = Nokogiri::XML::Node.new('description', content)
    new_desc.add_child(Nokogiri::XML::CDATA.new(new_desc, img_node(new_desc, comics_url).to_html))
    new_desc
  end

  # Mutation
  Contract Page => XmlElement
  def inject_content(page = nil)
    # Remove content:encode part
    content.xpath('content:encoded').first.remove
    description.swap(new_description)
  end

  private
  def comics_url
    comics = html_description.at_css('img')['src']
    comics.sub('-150x150', '')
  end

end
