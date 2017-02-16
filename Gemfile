source 'https://rubygems.org'

group :test do
  if RUBY_VERSION >= '2.2'
    gem 'rake'
    gem 'codecov', :require => false
  else
    gem 'rake', '~> 10.4'    
  end
end

if (defined?(RUBY_ENGINE) && 
    RUBY_ENGINE == 'ruby' && 
    RUBY_VERSION >= '2.2' &&
    !ENV['CI'])
  group :doc do
    gem 'yard'
    gem 'redcarpet'
    gem 'github-markup'
  end
end

gemspec
