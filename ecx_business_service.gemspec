# frozen_string_literal: true

require_relative 'lib/ecx_business_service/version'

Gem::Specification.new do |spec|
  spec.name        = 'ecx_business_service'
  spec.version     = EcxBusinessService::VERSION
  spec.authors     = ['Freibuis']
  spec.email       = ['freibuis@gmail.com']
  spec.homepage    = 'https://git.strategenics.com.au/SG451/engines/ecx_business_service'
  spec.summary     = 'Summary of EcxBusinessService.'
  spec.description = 'Description of EcxBusinessService.'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://git.strategenics.com.au/SG451/engines/ecx_business_service'
  spec.metadata['changelog_uri'] = 'https://git.strategenics.com.au/SG451/engines/ecx_business_service/CHANGELOG.md'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'rails', '>= 7.0.4'
  spec.add_dependency 'kaminari', '>= 1.2.2'
  spec.add_dependency 'yajl-ruby', '>= 1.4.3'
  spec.add_dependency 'hiredis', '>= 0.6.3'
end
