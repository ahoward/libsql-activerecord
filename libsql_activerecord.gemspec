# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'libsql_activerecord'
  spec.version = '0.0.0'
  spec.authors = ['Levy A.']
  spec.email = ['levyddsa@gmail.com']
  spec.summary = 'libSQL ActiveRecord Adapter'
  spec.homepage = 'https://rubygems.org/gems/libsql_activerecord'
  spec.files = Dir['lib/**/*']

  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.3'

  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activerecord', '~> 8.0'
  spec.add_runtime_dependency 'turso_libsql', '~> 0.1'
end
