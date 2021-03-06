# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

require 'rubygems'
require 'bundler/setup'
Bundler.setup

#require 'byebug'
require 'flirt'

RSpec.configure do |config|

  config.run_all_when_everything_filtered = true

  config.filter_run :focus

  config.before(:each) do
    Flirt.clear
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

end
