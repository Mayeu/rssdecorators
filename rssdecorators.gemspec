Gem::Specification.new do |s|
  s.name        = 'rssdecorators'
  s.version     = '0.1.1'
  s.summary     = 'Decorate RSS feeds'
  s.description = 'Sick of incomplete RSS'
  s.authors     = ['Mayeu']
  s.email       = 'm@6x9.fr'
  s.homepage    = 'https://github.com/Mayeu/rssdecorators'
  s.license     = 'AGPLv3'

  # Files
  s.executables = ['rssdecorators']
  s.files       = Dir[File.join('lib','**','*.rb')]

  # Dependancies
  s.add_dependency 'contracts', '~> 0.4'
  s.add_dependency 'nokogiri',  '~> 1.6'
end
