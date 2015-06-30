source 'https://rubygems.org'

group :test do
  gem 'rake', '>= 10.4'
  if RUBY_VERSION >= '1.9'
    gem 'codecov', :require => false
  end
end

if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ruby' && RUBY_VERSION >= '1.9'
  group :doc do
    gem 'yard'
    gem 'redcarpet'
    gem 'github-markup'
  end
end

gemspec
