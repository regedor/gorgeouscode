generate_code_coverage_svg = function(code_coverage_json) {
  // Set the dimensions of the canvas / graph
  var margin = {top: 30, right: 20, bottom: 30, left: 50},
    base_width = 850,
    base_height = 370,
    width  = base_width - margin.left - margin.right,
    height = base_height - margin.top - margin.bottom;

  // Parse the date / time
  var parseDate = d3.time.format("%d-%b-%y").parse;

  // Set the ranges
  var x = d3.time.scale().range([0, width]);
  var y = d3.scale.linear().range([height, 0]);

  // Define the axes
  var xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom")
    .ticks(5)
    .innerTickSize(-height)
    .outerTickSize(0)
    .tickPadding(10);

  var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left")
    .ticks(10)
    .innerTickSize(-width)
    .outerTickSize(0)
    .tickPadding(10);

  // Define the line
  var valueline = d3.svg.line()
    .x(function(d) { return x(d.info.created_at); })
    .y(function(d) { return y(d.info.percent); });

  // Adds the svg canvas
  var svg =
    d3.select("div#svg-code-coverage-diagram")
    .append("div")
    .classed("svg-container", true)
    .append("svg")
    .attr("preserveAspectRatio", "xMinYMin meet")
    .attr("viewBox", "0 0 " + base_width + " " + base_height)
    .classed("svg-content-responsive", true)
    .append("g")
    .attr("transform",
      "translate(" + margin.left + "," + margin.top + ")");

  // Get the data
  data = code_coverage_json
  data.forEach(function(d) {
    d.info.created_at = parseDate(d.info.created_at);
    d.info.percent = +d.info.percent;
  });

  // Scale the range of the data
  x.domain(d3.extent(data, function(d) { return d.info.created_at; }));
  y.domain([0, 100]);

  // Add the valueline path.
  svg.append("path")
    .attr("class", "line")
    .attr("d", valueline(data));

  // Add the X Axis
  svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis);

  // Add the Y Axis
  svg.append("g")
    .attr("class", "y axis")
    .call(yAxis);
};

if (typeof code_coverage_json !== "undefined") {
  generate_code_coverage_svg(code_coverage_json);
}
