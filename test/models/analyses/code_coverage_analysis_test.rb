require 'test_helper'

class Analyses::CodeCoverageAnalysisTest < ActiveSupport::TestCase
  should have_one(:report)
  should validate_presence_of(:report)
end
