require 'contracts'

include Contracts

# Page
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
