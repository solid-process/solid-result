# frozen_string_literal: true

require_relative 'lib/solid/result/version'

Gem::Specification.new do |spec|
  spec.name = 'solid-result'
  spec.version = Solid::Result::VERSION
  spec.authors = ['Rodrigo Serradura']
  spec.email = ['rodrigo.serradura@gmail.com']

  'Unleash a pragmatic and observable use of Result Pattern and Railway-Oriented Programming in Ruby.'
    .then do |summary|
      spec.summary     = summary
      spec.description = summary
    end

  spec.homepage = 'https://github.com/solid-process/solid-result'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/solid-process/solid-result'
  spec.metadata['changelog_uri'] = 'https://github.com/solid-process/solid-result/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
