# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in affected_tests.gemspec
gemspec

gem "rake", "~> 13.0"
gem "rspec"

# Optional engines, which users choose by themselves
gem "calleree"
# rotoscope 0.3.0 cannot be built on Ruby 4.1+, which removed Data_Make_Struct
gem "rotoscope" if RUBY_VERSION < "4.1"
