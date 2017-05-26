class AddCodeCoverageAnalysisBelongsToToReports < ActiveRecord::Migration
  def change
    add_reference :reports, :code_coverage_analysis, index: true, foreign_key: true
  end
end
