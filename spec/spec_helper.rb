$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'zensana'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.order = 'random'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
