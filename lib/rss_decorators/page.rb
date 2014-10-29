# Page
class Page
  attr_reader :url, :content

  def initialize(url, content)
    @url     = url
    @content = content
  end
end
