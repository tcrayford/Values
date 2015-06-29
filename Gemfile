source 'https://rubygems.org'

group :test do
  gem 'rake', '>= 10.4'
  gem 'codecov', :require => false
end

if RUBY_ENGINE == 'ruby' && RUBY_VERSION >= '1.9'
  group :doc do
    gem 'yard'
    gem 'redcarpet'
    gem 'github-markup'
  end
end

gemspec
