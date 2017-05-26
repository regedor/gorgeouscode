require "json"

class Dotojson
  JSON_HASH = { models: { nodes: [], links: [] } }.freeze

  def compute_model_nodes(line)
    node_name = line.match(/^\s"[A-Z]\w+((::[A-Z]\w+)+)?"(.+shape=)/)
    return nil unless node_name

    node_name = node_name[0].gsub(/("|\s)/, "").gsub(/\[shape=/)
    node_shape = line.match(/shape=\w+/) || nil
    node_shape = node_shape[0].gsub(/shape=/) unless node_shape.nil?
    node_fillcolor = line.match(/fillcolor="#[0-9a-fA-F]+"/) || nil
    node_fillcolor = node_fillcolor[0].gsub(/fillcolor=|"/, "") unless node_fillcolor.nil?
    node_fontcolor = line.match(/fontcolor="#[0-9a-fA-F]+"/) || nil
    node_fontcolor = node_fontcolor[0].gsub(/fontcolor=|"/, "") unless node_fontcolor.nil?
    node_attributes_filter = line.match(/label="\{(\w(::\w)?)+\|.+\}"/) || nil

    unless node_attributes_filter.nil?
      node_attributes =
        node_attributes_filter[0]
        .gsub(/label="\{(\w(::\w)?)+\|/, "")
        .gsub(/\\l}"/, "")
        .gsub(/\\l/, ",")
        .split(",")
      node_attributes_array = []
      node_attributes.each do |attribute|
        node_attributes_array << attribute.split(/\s:/)
        node_attributes_array.last[1].capitalize!
      end
    end

    JSON_HASH[:models][:nodes] << {
      "name" => node_name,
      "shape" => node_shape,
      "fillcolor" => node_fillcolor,
      "fontcolor" => node_fontcolor,
      "attributes" => node_attributes_array
    }
  end

  def compute_model_links(line)
    link_name = line.match(/^\s"[A-Z]\w+((::[A-Z]\w+)+)?"\s->\s"[A-Z]\w+((::[A-Z]\w+)+)?"/)
    return unless link_name

    link_name = link_name[0].gsub(/("|\s)/, "").gsub(/\[shape=/)
    link_pair = link_name.split(/->/)
    link_arrowtail = line.match(/arrowtail=\w+/) || nil
    link_arrowhead = line.match(/arrowhead=\w+/) || nil
    link_color = line.match(/color="#[0-9a-fA-F]+"/) || nil
    link_arrowtail = link_arrowtail[0].gsub(/arrowtail=/) unless link_arrowtail.nil?
    link_arrowhead = link_arrowhead[0].gsub(/arrowhead=/) unless link_arrowhead.nil?
    link_color = link_color[0].gsub(/color=|"/, "") unless link_color.nil?

    JSON_HASH[:models][:links] << {
      "source" => link_pair[0],
      "target" => link_pair[1],
      "arrowtail" => link_arrowtail,
      "arrowhead" => link_arrowhead,
      "color" => link_color
    }
  end

  def to_json
    raise ArgumentError, "No file passed as argument to dotojson.rb" unless ARGV[0]

    dot_file_text = File.open(File.dirname(__FILE__) + "/" + ARGV[0]).read

    dot_file_text.each_line do |line|
      compute_model_nodes(line) || compute_model_links(line)
    end

    File.open(ARGV[0] + ".json", "w") do |f|
      f.write(JSON_HASH.to_json)
    end
  end
end

dotojson = Dotojson.new
dotojson.to_json
