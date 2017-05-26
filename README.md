= Gorgeous Code (alpha)

### Model overview:

* Project: has the git information about each project
* Report: represents a full report with RBP analysis and Model Diagram analysis. Stores the commit hash, branch and the gc_config for each report.
* RailsBestPracticesAnalysis: belongs to one report and has the score and nbp_report for the analysis.
* ModelDiagramAnalysis: has the json_data attribute for the analysed project, representing the model diagram.

### Service overview:
* Create Project: Creates new project and deals with github hooks.
* Start Report: Creates new report and associated ModelDiagram and RBP analyses.

### lib/modules:
* VM Connection: Establishes new VM connection, prepares repository and gemsets, runs commands, generates DOT and JSON files. All around badass.

### Other:
* Use posgresql as your database
