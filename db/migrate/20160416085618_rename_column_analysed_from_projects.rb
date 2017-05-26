class RenameColumnAnalysedFromProjects < ActiveRecord::Migration
  def change
    rename_column :projects, :analysed, :has_last_report_analyses
  end
end
