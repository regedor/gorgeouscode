class Analyses::CodeCoverageAnalysis < ActiveRecord::Base
  has_one :report
  validates :report, presence: true

  # Creates a new VMConnection to generate project JSON data.
  # Returns true if json_data attributes is present.
  def run
    connection = VMConnection.new(report)
    last_percent = connection.get_simplecov_last_percent

    if last_percent && last_percent.is_a?(Float)
      self.percent = last_percent.to_f
      save
      return true
    end

    false
  end
end
