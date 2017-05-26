# rubocop:disable all
class Analyses::RailsBestPracticesAnalysis < ActiveRecord::Base
  has_one :report

  # Renders a big csv containing projects information
  def self.big_csv
    first.nbp_report.split("\n").first + "\n" + select("nbp_report").find_all do |p|
      !p.nbp_report.blank?
    end.map { |p| p.nbp_report.split("\n").last }.join("\n")
  end

  # TODO: needs a lot of validations
  def self.create_from_urls(urls)
    begin
      urls.each { |url| create!(url: url) }
    rescue
      return false
    end
    true
  end

  def final_score
    score.to_i > 0 ? score : 0
  end

  def nbp_report_headers_array
    begin; nbp_report.split("\n").first.split(","); rescue; []; end
  end

  def nbp_report_values_array
    begin; nbp_report.split("\n").last.split(","); rescue; []; end
  end

  def nbp_report_to_hash
    headers = nbp_report_headers_array
    values = nbp_report_values_array
    hash = {}
    headers.size.times { |i| hash[headers[i]] = values[i] }
    @nbp_report_to_hash ||= hash
  end

  def nbp_report_to_mx_hash
    # headers = nbp_report_headers_array
    values = nbp_report_values_array
    hash = {}
    nbp_report_headers_array.each_with_index do |header, i|
      if header =~ /^m(...)_([onr])_(.*)/
        if $2 == "o"
          hash[$1.to_i] = { o: values[i] }
          hash[$1.to_i][:l] = $3
        else
          hash[$1.to_i][$2.to_sym] = values[i]
        end
      else
        hash[header.to_sym] = values[i]
      end
    end
    @nbp_report_to_mx_hash ||= hash
  end

  # Runs best practices
  include RailsBestPractices

  def run
    @options = {}
    connection = VMConnection.new(report)
    @path = connection.rails_fullpath

    Core::Runner.base_path = @path
    @runner = Core::Runner.new

    %w(lexical prepare review).each { |process| send(:process, process) }
    # @runner.on_complete
    @runner.after_review

    # self.nbp_report = json_results
    self.nbp_report = results_csv
    # self.nbp_report = add_more_logic_to_nbp_report
    self.score = nbp_report_to_hash["rbp_score"]

    save
    nbp_report && score ? true : false
  end

  def add_more_logic_to_nbp_report
    headers = nbp_report_headers_array
    values = nbp_report_values_array
    new_values = []
    new_headers = []
    metric = 0
    nbps = 0
    total_files = 0
    headers.each_with_index do |header, i|
      if header == "Number of files analyzed"
        new_headers << "m#{'%03d' % (metric += 1)}_n_" + header.tr(" ", "_").downcase.underscore
        new_headers << "m#{'%03d' % metric}_r_" + headers[i - 1].tr(" ", "_").underscore

        new_values << values[i]
        new_values << ((values[i - 1].to_i + 0.000000001) / (values[i].to_i + 0.0000001) * 1000).to_i.to_s

        total_files += values[i].to_i
        nbps += new_values.last.to_i
      else
        new_headers << header.tr(" ", "_").underscore
        new_values << values[i]
      end
    end

    new_headers << "total_files_analyzed"
    new_values << total_files
    new_headers << "nbps"
    new_values << nbps
    new_headers << "rbp_score"
    new_values << (5 - ((nbps - 200) * 0.001)).round
    require "csv"
    CSV.generate do |csv|
      csv << new_headers
      csv << new_values
    end
  end

  # ignore specific files.
  # @param [Array] files
  # @param [Regexp] pattern files match the pattern will be ignored
  # @return [Array] files that not match the pattern
  def self.file_ignore files, pattern
    files.reject { |file| file.index(pattern) }
  end

  # Output results in json format.
  def json_results
    @runner.results.map do |result|
      result[:error_ratio] = result[:error_count].to_f / (result[:files_checked] + 1)
      result
    end.to_json
  end

  def results_csv
    # headers = nbp_report_headers_array
    # values = nbp_report_values_array
    new_values = []
    new_headers = []
    metric = 0
    total_nbps = 0
    total_files = 0

    @runner.results.each do |result|
      checker_name = result[:checker_name].tr(" ", "_").underscore
      nbps = ((result[:error_count].to_i + 0.000000001) / (result[:files_checked].to_i + 0.0000001) * 1000).to_i
      new_headers += [
        "m#{'%03d' % (metric += 1)}_o_" + checker_name,
        "m#{'%03d' % metric}_n_" + checker_name,
        "m#{'%03d' % metric}_r_" + checker_name
      ]
      new_values += [
        result[:error_count],
        result[:files_checked],
        nbps.to_s
      ]
      total_files += result[:files_checked].to_i
      total_nbps += nbps
    end

    new_headers << "total_files_analyzed"
    new_values << total_files
    new_headers << "nbps"
    new_values << total_nbps
    new_headers << "rbp_score"
    new_values << (5 - ((total_nbps - 200) * 0.001)).round

    require "csv"
    CSV.generate do |csv|
      csv << new_headers
      csv << new_values
    end
  end

  # process lexical, prepare or reivew.
  # get all files for the process, analyze each file.
  # @param [String] process the process name, lexical, prepare or review.
  def process(process)
    files = send("#{process}_files")
    files.each do |file|
      @runner.send("#{process}_file", file)
    end
  end

  # get all files for prepare process.
  # @return [Array] all files for prepare process
  def prepare_files
    @prepare_files ||= begin
                         %w(app/models app/mailers db/schema.rb app/controllers).inject([]) do |files, name|
                           files += expand_dirs_to_files(File.join(@path, name))
                         end.compact
                       end
  end

  # get all files for review process.
  # @return [Array] all files for review process
  def review_files
    @review_files ||= begin
                        files = expand_dirs_to_files(@path)
                        files = file_sort(files)

                        # By default, tmp, vender, spec, test, features are ignored.
                        %w(vendor spec test features tmp).each do |pattern|
                          files = file_ignore(files, "#{pattern}/") unless @options[pattern]
                        end

                        files.compact
                      end
  end

  alias :lexical_files :review_files

  # expand all files with extenstion rb, erb, haml and builder under the dirs
  # @param [Array] dirs what directories to expand
  # @return [Array] all files expanded
  def expand_dirs_to_files(*dirs)
    extensions = %w(rb erb rake rhtml haml builder)

    dirs.flatten.map do |entry|
      next unless File.exist? entry
      if File.directory? entry
        Dir[File.join(entry, "**", "*.{#{extensions.join(",")}}")]
      else
        entry
      end
    end.flatten
  end

  # sort files, models first, then mailers, and sort other files by characters.
  # models and mailers first as for prepare process.
  # @param [Array] files
  # @return [Array] sorted files
  def file_sort(files)
    models = []
    mailers = []
    files.each do |a|
      models << a if a =~ Core::Check::MODEL_FILES
    end
    files.each do |a|
      mailers << a if a =~ Core::Check::MAILER_FILES
    end
    files.collect! do |a|
      if a =~ Core::Check::MAILER_FILES || a =~ Core::Check::MODEL_FILES
        # nil
      else
        a
      end
    end
    files.compact!
    models.sort
    mailers.sort
    files.sort
    models + mailers + files
  end

  # ignore specific files.
  # @param [Array] files
  # @param [Regexp] pattern files match the pattern will be ignored
  # @return [Array] files that not match the pattern
  def file_ignore(files, pattern)
    files.reject { |file| file.index(pattern) }
  end
end
