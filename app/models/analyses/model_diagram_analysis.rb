class Analyses::ModelDiagramAnalysis < ActiveRecord::Base
  has_one :report

  validates :report, presence: true

  # Creates a new VMConnection to generate project JSON data.
  # Returns true if json_data attributes is present.
  def run
    connection = VMConnection.new(report)
    json_data = connection.generate_files_and_read_json

    if json_data
      self.json_data = json_data
      save
      return true
    end

    false
  end
end
