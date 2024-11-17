# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'libsql-activerecord'
  spec.version = '0.0.0'
  spec.authors = ['Levy A.']
  spec.email = ['levyddsa@gmail.com']
  spec.summary = 'libSQL ActiveRecord Adapter'

  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.3'

  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activerecord', '~> 8.0'
  spec.add_runtime_dependency 'turso_libsql', '~> 0.1.1'

  spec.add_development_dependency 'bundler', '>= 1.13.4'
  spec.add_development_dependency 'rspec', '~> 3.10'
end
