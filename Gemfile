source 'https://rubygems.org'

group :test do
  if RUBY_VERSION >= '2.2'
    # WORKAROUND (2017-02-17): Rake 11.0 breaks RSpec < 3.5. We stay with
    #   older RSpec to test older Rubies, so we must pin Rake version.
    # See: http://stackoverflow.com/questions/35893584/nomethoderror-undefined-method-last-comment-after-upgrading-to-rake-11
    gem 'rake', '< 11.0'

    # Only bother supporting code coverage on relatively recent Rubies
    gem 'codecov', :require => false
  else
    # Avoid incompatibilities that break builds on Ruby 1.8.7, until we drop support
    gem 'rake', '~> 10.4'    
  end
end

# Only support building documentation, and therefore supporting those
# dependencies, on recent MRI Rubies when not running on Travis CI.
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
