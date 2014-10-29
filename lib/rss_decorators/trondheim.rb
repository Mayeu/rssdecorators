require 'contracts'

include Contracts

# SMBC
class Trondheim < Item

  def need_original_page?
    true
  end

  Contract XmlElement => String
  def page_link
    content.at_css('link').children.text
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
class TrondheimPage < Page
  Contract Page => String
  def comics_url
    # Trondheim's HTML page are really weird and ugly (mostly because it try to
    # prevent you to mess with the images). Those step need to be taken:
    #
    #  - Get the a tag with the comic id
    #  - Get the parent of this tag
    #  - Get the first image in this parent
    #  - Get the rel tag of this image
    #  - Expand the url
    expand_url parent_tag.at_css('img')['rel']
  end

  private

  def parent_tag
    content.at_css('a#' + comics_id).parent
  end

  def comics_id
    url.split('#').last
  end

  def expand_url(img_url)
    url.split('#').first.sub('index.php', '').concat(img_url)
  end
end
