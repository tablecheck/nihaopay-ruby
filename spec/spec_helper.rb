require 'rubygems'
require 'bundler'

require 'nihaopay'

# require 'shoulda'

RSpec.configure do |config|
  ActiveSupport::Deprecation.silenced = true

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.before(:each) do
    I18n.locale = :en
    Time.zone = 'Asia/Tokyo'
  end

  config.order = 'random'
end
