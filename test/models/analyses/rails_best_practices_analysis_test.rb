require "test_helper"

class Analyses::RailsBestPracticesAnalysisTest < ActiveSupport::TestCase
  should have_one(:report)
end
