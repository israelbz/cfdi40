# frozen_string_literal: true

require_relative "lib/cfdi40/version"

Gem::Specification.new do |spec|
  spec.name = "cfdi40"
  spec.version = Cfdi40::VERSION
  spec.authors = ["Israel Benítez"]
  spec.email = ["israel.benitez@i2j.mx"]

  spec.summary = "Create, sign and read CFDi."
  spec.description = "Tool for create, read and edit XML files of CFDI " \
                     "(Comprobantes Fiscales Digitales por Internet) " \
                     "regulated by Mexican Government"
  spec.homepage = "https://github.com/israelbz/cfdi40"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/israelbz/cfdi40"
  spec.metadata["changelog_uri"] = "https://github.com/israelbz/cfdi40/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "nokogiri", "~> 1.13", ">= 1.13.9"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
