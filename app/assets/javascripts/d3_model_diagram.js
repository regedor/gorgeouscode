const ELIPSE_WIDTH_FACTOR  = 5,
  RECT_WIDTH_FACTOR = 3,
  EXPANDED_TOP_PADDING = -10,
  TYPE_COLORS = [
    ['Integer' , 'blue'],
    ['Boolean' , 'darkGreen'],
    ['Float'   , 'darkBlue'],
    ['String'  , 'brown'],
    ['Json'    , 'green'],
    ['Datetime', 'darkOrange']
  ];

function expandedWidth(maxLengthAttribute) {
  return maxLengthAttribute * 3 + 10
}

function drawStub() {
  return 'M 0,0 m -1,-5 L 1,-5 L 1,5 L -1,5 Z'
}

function drawDiamond() {
  return 'M -10,0 L 0,6 L 10,0 L 0,-6 Z'
}

function drawSingleArrow() {
  return 'M -3,-5 L 7,0 L -3,5'
}

function drawDoubleArrow() {
  return 'M -3,-5 L 7,0 L -3,5 M 7,-5 L 17,0 L 7,5'
}

function drawDoubleArrowBackwards() {
  return 'M 7,-5 L -3,0 L 7,5 M 17,-5 L 7,0 L 17,5'
}

function drawTripleArrow() {
  return 'M -3,-5 L 7,0 L -3,5 M 7,-5 L 17,0 L 7,5 M 17,-5 L 27,0 L 17,5'
}

function drawDot() {
  return 'M 0, 0  m -3, 0  a 3,3 0 1,0 6,0  a 3,3 0 1,0 -6,0'
}

function drawCrow() {
  return 'M 0,-5 L 10,0 L 0,5'
}

function drawOdot() {
  return "M 0, 0  m -5, 0  a 5,5 0 1,0 10,0  a 5,5 0 1,0 -10,0"
}

function drawRect(x, y, width, height) {
  return "M" + x  + "," + y
    + "h" + (width)
    + "v" + (height)
    + "h" + (width)
    + "v" + (-height)
    + "z";
}

function drawNodeElipse(attrLength) {
  return "M -" + (attrLength + ELIPSE_WIDTH_FACTOR) * 2.5 + ",0 "
    + "a" + (attrLength + ELIPSE_WIDTH_FACTOR) * 2.5 + ",10 0 1,0 " + (attrLength + ELIPSE_WIDTH_FACTOR) * 5 + ",0"
    + "a" + (attrLength + ELIPSE_WIDTH_FACTOR) * 2.5 + ",10 0 1,0 -" + (attrLength + ELIPSE_WIDTH_FACTOR) * 5 + ",0"
}

function drawNodeRect(attrLength) {
  return "M 0,0 m " + -(attrLength * RECT_WIDTH_FACTOR) +",-10 "
    + "L " + (attrLength * RECT_WIDTH_FACTOR) + ",-10 "
    + "L " + (attrLength * RECT_WIDTH_FACTOR) + ",10 "
    + "L " + -(attrLength * RECT_WIDTH_FACTOR) + ",10 "
    + " Z"
}

function drawNodeExpandedRect(numOfAttributes, expandedWidth) {
  return "M " + -expandedWidth + "," + EXPANDED_TOP_PADDING
    + "L " + expandedWidth + "," + EXPANDED_TOP_PADDING
    + "L " + expandedWidth + "," + (numOfAttributes * 21 + 20)
    + "L " + -expandedWidth + "," + (numOfAttributes * 21 + 20)
    + " Z"
}

function drawNodeExpandedRoundedRect(numOfAttributes, expandedWidth, radius) {
  return "M" + (radius - expandedWidth - 12) + "," + EXPANDED_TOP_PADDING
    + " h" + (2 * expandedWidth - radius)
    + " a" + radius + "," + radius + " 0 0 1 " + radius + "," + radius
    + " v" + (numOfAttributes * 21 + 25 - (2 * radius))
    + " a" + radius + "," + radius + " 0 0 1 " + -radius + "," + radius
    + " h" + (2 * radius - (2 * expandedWidth))
    + " a" + radius + "," + radius + " 0 0 1 " + -radius + "," + -radius
    + " v" + (-numOfAttributes * 21 - 25 + (2 * radius))
    + " a" + radius + "," + radius + " 0 0 1 " + radius + "," + -radius
    + " Z"
}

function drawRoundedRect(x, y, width, height, radius) {
  return "M" + x + radius + "," + y
    + " h" + (width - radius)
    + " a" + radius + "," + radius + " 0 0 1 " + radius + "," + radius
    + " v" + (height - 2 * radius)
    + " a" + radius + "," + radius + " 0 0 1 " + -radius + "," + radius
    + " h" + (2 * radius - width)
    + " a" + radius + "," + radius + " 0 0 1 " + -radius + "," + -radius
    + " v" + (-height + 2 * radius)
    + " a" + radius + "," + radius + " 0 0 1 " + radius + "," + -radius
    + " Z"
}

generate_model_diagram_svg = function(model_diagram_json) {
  var nodes = {};

  var width  = 780,
    height = 400;

  var padding        = 20,
    linkDistance   = 70,
    charge         = -5000,
    gravity        = .3,
    friction       = .6,
    linkStrength   = 0.5,
    chargeDistance = 4000;

  var zoom =
    d3.behavior.zoom()
    .scaleExtent([0,10])
    .on("zoom", zoomed);

  // Compute the distinct nodes from the links.
  links = model_diagram_json["models"].links

  model_diagram_json["models"].nodes.forEach(function(node){
    var nodeShape = "";
    var shapeType = "";
    var nodeNameLength = node.name.length;

    if (node.shape == "Mrecord") {
      nodeShape = drawNodeElipse(nodeNameLength);
      shapeType = "Mrecord";
    } else if (node.shape == "record") {
      nodeShape = drawNodeRect(nodeNameLength);
      shapeType = "record";
    } else {
      nodeShape = drawNodeRect(nodeNameLength);
      shapeType = "other";
    }

    nodes[node.name] = {
      name: node.name.replace(/::/g,'_'),
      attributes: node.attributes,
      fillcolor: node.fillcolor,
      fontcolor: node.fontcolor,
      shape: nodeShape,
      shapetype: shapeType
    };

    if (node.attributes == node.fillcolor == node.fontcolor == null) {
      nodes[node.name].fillcolor = "#FFF";
      nodes[node.name].fontcolor = "#000";
    } else if (node.fillcolor == null) {
      nodes[node.name].fillcolor = "#DDD";
      nodes[node.name].fontcolor = "#000";
    }
  });

  links.forEach(function(link) {
    link.source = nodes[link.source] ||
      (nodes[link.source] = {name: link.source, fillcolor: "#FFF", fontcolor: "#000", attributes: null, shape: drawNodeRect(link.source.length)});
    link.target = nodes[link.target] ||
      (nodes[link.target] = {name: link.target, fillcolor: "#FFF", fontcolor: "#000", attributes: null, shape: drawNodeRect(link.target.length)});
  });

  function linkDoubleClicked(link) {
    linkPath = d3.select(this)[0][0];
    linkText = $("textpath#text" + linkPath.id);

    if (linkText.is(":visible")) {
      linkText.css("display","none");
    } else {
      linkText.css("display","inline");
    }
  }

  function clickGitSource(node){
    window.open('http://www.sapo.pt');
  }

  function drawEntireNodeExpanded(nodePathShape, maxLengthAttribute, node) {
    var expWidth = expandedWidth(maxLengthAttribute),
      numberOfAttributes = node.attributes.length;
    // inside node
    d3.select(nodePathShape).attr('d', function (d) {
      switch (d.shapetype) {
        case 'Mrecord':
          return drawNodeExpandedRoundedRect(numberOfAttributes, expWidth, 10);
          break;
        case 'record':
          return drawNodeExpandedRect(numberOfAttributes, expWidth);
          break;
        default:
          return drawNodeExpandedRect(numberOfAttributes, expWidth);
          break;
      }
    });

    d3.select(nodePathShape.parentNode)
    //.append('a')
      .append('rect')
    //.attr('xlink:href', 'http://www.sapo.pt', '_blank')
      .classed('node-git-link', true)
      .attr('x', 5 - expWidth)
      .attr('y', '7')
      .attr('rx', '1')
      .attr('ry', '1')
      .attr('width', '10')
      .attr('height', '10')
      .style('fill', 'blue')
      .style('stroke-width', 0.3)
      .style('stroke', 'darkBlue');
    //.on('click', clickGitSource(node));
    //.on('dblclick', dblclickSource(node));

    for (i = 0; i < numberOfAttributes; i++) {
      d3.select(nodePathShape.parentNode)
        .append('text')
        .attr('class', node.name + 'AttributeText')
        .attr("dy", (i + 1) * 20 + 10)
        .attr('text-anchor', 'left')
        .attr('x', 5 - expWidth)
        .attr('font-size', 8)
        .attr('font-family', 'sans-serif')
        .attr('fill', node.fontcolor)
        .text(function(d) {
          return d.attributes[i][0];
        });

      d3.select(nodePathShape.parentNode)
        .append("text")
        .attr("class", node.name + "AttributeText")
        .attr("dy", (i + 1) * 20 + 10)
        .attr("text-anchor", "right")
        .attr("x", expWidth - 58)
        .attr("font-size", 8)
        .attr("font-family", "sans-serif")
        .attr('fill', function(d) {
          for (var it = 0, l = TYPE_COLORS.length; it < l; it ++) {
            if (d.attributes[i][1] == TYPE_COLORS[it][0]) {
              return TYPE_COLORS[it][1];
            }
          }
        })
        .text(function(d) {
          return " :: " + d.attributes[i][1];
        });
    }
  }

  function appendDataToInfoDiv(numberOfAttributes, node) {
    var numberOfAttributes = node.attributes.length;

    $("div#model-diagram-info").append("<p style='display: inline-block; padding-right: 5px;'><strong>" + node.name.replace(/_/g,'::') + "</strong>: </p>");

    for (i = 0; i < numberOfAttributes; i++) {
      if (i == numberOfAttributes - 1) {
        $("div#model-diagram-info").append("<p style='display: inline-block; padding-right: 5px;'>" + node.attributes[i][0] + "<span style='color: gray;'>:" + node.attributes[i][1] + "</span></p>");
      } else {
        $("div#model-diagram-info").append("<p style='display: inline-block; padding-right: 5px;'>" + node.attributes[i][0] + "<span style='color: gray;'>:" + node.attributes[i][1] + "</span>, </p>");
      }
    }
  }

  function getShapeHeight(nodePathShape) {
    var element = d3.select(nodePathShape)[0][0],
      elementPath = element.getAttribute('d');

    return parseFloat(/[0-9]+\sZ/.exec(elementPath)[0].replace(' Z',''));
  }

  function getMaxLengthAttribute(node) {
    var numberOfAttributes = node.attributes.length,
      maxLengthAttribute = 0;

    for (i = 0; i < numberOfAttributes; i++){
      var currentNodeLength = node.attributes[i][0].length + node.attributes[i][1].length;

      if (currentNodeLength > maxLengthAttribute){
        maxLengthAttribute = currentNodeLength;
      }
    }

    if (node.name.length > maxLengthAttribute) {
      return node.name.length;
    } else {
      return maxLengthAttribute;
    }
  }

  function minimizeNode(node, nodePathShape) {
    d3.select(nodePathShape).attr('d', node.shape);
    $("div#model-diagram-info").empty().append("<p style='display: inline-block; padding-right: 5px;' class='text-muted'>Model information</p>");
    $('text.' + node.name + "AttributeText").remove();
    $("rect.node-git-link").remove();
    $("rect." + node.name + "AttributeBackground").remove();
  }

  function nodeDoubleClicked(node) {
    // node refers node object
    // this refers to node path shape

    if (node.attributes !== null) {
      var numberOfAttributes = node.attributes.length
      var maxLengthAttribute = getMaxLengthAttribute(node)

      $("div#model-diagram-info").empty();

      if ($("text." + node.name + "AttributeText").length < 1) {
        var n = $(this).parent();
        n.parent().append(n.detach());

        drawEntireNodeExpanded(this, maxLengthAttribute, node);
        appendDataToInfoDiv(numberOfAttributes, node);

        shapeHeight = getShapeHeight(this);

        force.charge(function(d){
          nodeCharge = /([0-9]+\sZ)/.exec(d.shape)

          if (d == node) {
            return (-200 * shapeHeight) - 4000;
          } else {
            return -5000;
          }
        });

        force.start();

      } else {
        force.charge(function(d){
          return -5000;
        });

        force.start();

        minimizeNode(node, this);
      }
    } else {
      $("div#model-diagram-info").empty().append("<p style='display: inline-block; padding-right: 5px;'>No attributes for " + node.name.replace(/_/g,'::') + "</p>");
    }
  }

  var force =
    d3.layout.force()
    .nodes(d3.values(nodes))
    .links(links)
    .size([width, height])
    .charge(charge)
    .gravity(gravity)
    .friction(friction)
    .linkDistance(linkDistance)
    .linkStrength(linkStrength)
    .chargeDistance(chargeDistance)
    .on("tick", tick)
    .start();

  function dragstarted(d) {
    d3.event.sourceEvent.stopPropagation();
    d3.select(this).classed("dragging", true);
  }

  function dragged(d) {
    d3.select(this).attr("cx", d.x = d3.event.x).attr("cy", d.y = d3.event.y);
  }

  function dragended(d) {
    d3.select(this).classed("dragging", false);
  }

  var drag = force.drag()
    .origin(function(d) { return d; })
    .on("dragstart", dragstarted)
    .on("drag", dragged)
    .on("dragend", dragended);

  var svg =
    d3.select("div#svg-model-diagram")
    .append("div")
    .classed("svg-container", true)
    .append("svg")
    .call(zoom)
    .on("dblclick.zoom", null)
    .attr("preserveAspectRatio", "xMinYMin meet")
    .attr("viewBox", "0 0 600 400")
  //class to make it responsive
    .classed("svg-content-responsive", true);

  var viz =
    svg.append('g')
    .attr('id', 'viz');

  function zoomed() {
    viz.attr("transform",
      "translate(" + d3.event.translate + ")" + "scale(" + d3.event.scale + ")");
  };

  function helpToggle() {
    $('svg > image.help-image').toggleClass('no-opacity');
    $('svg > g > rect.help-btn').toggleClass('inactive-help-btn');
  }

  path = '/gc-help.png'
  var gcHelpImg = svg.selectAll('image').data([0]);
  gcHelpImg.enter()
    .append('svg:image')
    .attr('xlink:href', path)
    .classed('help-image', true)
    .attr('x', '0')
    .attr('y', '30')
    .attr('width', '170')
    .attr('height', '170')

  var helpBtn =
    svg.append('g')
    .attr('id', 'help-btn-group')
    .attr('transform', 'translate(45,10)');

  helpBtn.append('rect')
    .classed('help-btn', true)
    .attr('width', '31')
    .attr('height', '7')
    .style('fill', 'lightGray')
    .style('stroke-width', 0.3)
    .style('stroke', 'darkGreen')
    .attr("float", "left")
    .on("dblclick", helpToggle);

  helpBtn.append('text')
    .classed('help-btn-text', true)
    .attr('x', 3)
    .attr('y', 5)
    .style('fill', 'black')
    .style('font-size', '5px')
    .attr("font-family", "Verdana, Helvetica, sans-serif")
    .text('Help toggle');

  // build the stub
  viz.append("viz:defs")
    .selectAll("marker")
    .data(["stub"]) // Different link/path types can be defined here
    .enter().append("viz:marker") // This section adds in the arrows
    .attr("id", String)
    .attr("viewBox", "-1 -5 2 10")
    .attr("refX", 17)
    .attr("refY", 0)
    .attr("markerWidth", 6)
    .attr("markerHeight", 6)
    .attr("orient", "auto")
    .append("viz:path")
    .attr("d", drawStub);

  // build the diamond (ex-crow)
  viz.append("viz:defs")
    .selectAll("marker")
    .data(["crow"]) // Different link/path types can be defined here
    .enter().append("viz:marker") // This section adds in the marker
    .attr("id", String)
    .attr("viewBox", "-10 -6 20 12")
    .attr("refX", 30)
    .attr("refY", 0)
    .attr("markerWidth", 6)
    .attr("markerHeight", 6)
    .attr("orient", "auto")
    .attr('fill', '#7B0000')
    .append("viz:path")
    .attr("d", drawDiamond);

  // build the light gray single_arrow
  viz.append("viz:defs")
    .selectAll("marker")
    .data(["single_arrow_light_gray"])
    .enter().append("viz:marker")
    .attr("id", String)
    .attr("viewBox", "-5 -5 20 30")
    .attr("refX", 25)
    .attr("refY", 0)
    .attr("markerWidth", 10)
    .attr("markerHeight", 10)
    .attr("orient", "auto")
    .append("viz:path")
    .attr("d", drawSingleArrow)
    .attr("fill", "#BBB");

  // build the blue double_arrow
  viz.append("viz:defs")
    .selectAll("marker")
    .data(["double_arrow_blue"])
    .enter().append("viz:marker")
    .attr("id", String)
    .attr("viewBox", "-5 -5 20 30")
    .attr("refX", 35)
    .attr("refY", 0)
    .attr("markerWidth", 10)
    .attr("markerHeight", 10)
    .attr("orient", "auto")
    .append("viz:path")
    .attr("d", drawDoubleArrow)
    .attr("fill", "#1c7a9b");

  // build the green double_arrow
  viz.append("viz:defs")
    .selectAll("marker")
    .data(["double_arrow_green"])
    .enter().append("viz:marker")
    .attr("id", String)
    .attr("viewBox", "-5 -5 20 30")
    .attr("refX", 35)
    .attr("refY", 0)
    .attr("markerWidth", 10)
    .attr("markerHeight", 10)
    .attr("orient", "auto")
    .append("viz:path")
    .attr("d", drawDoubleArrow)
    .attr("fill", "#789e2d");

  // build the green double_arrow_backwards
  viz.append("viz:defs")
    .selectAll("marker")
    .data(["double_arrow_backwards_green"])
    .enter().append("viz:marker")
    .attr("id", String)
    .attr("viewBox", "-5 -5 20 30")
    .attr("refX", -20)
    .attr("refY", 0)
    .attr("markerWidth", 10)
    .attr("markerHeight", 10)
    .attr("orient", "auto")
    .append("viz:path")
    .attr("d", drawDoubleArrowBackwards)
    .attr("fill", "#789e2d");

  // build the blue triple_arrow
  viz.append("viz:defs")
    .selectAll("marker")
    .data(["triple_arrow_blue"])
    .enter().append("viz:marker")
    .attr("id", String)
    .attr("viewBox", "-5 -5 20 45")
    .attr("refX", 43)
    .attr("refY", 0)
    .attr("markerWidth", 17)
    .attr("markerHeight", 17)
    .attr("orient", "auto")
    .append("viz:path")
    .attr("d", drawTripleArrow)
    .attr("fill", "#1c7a9b");

  // build the crow
  //  viz.append("viz:defs")
  //    .selectAll("marker")
  //      .data(["crow"])
  //    .enter().append("viz:marker")
  //      .attr("id", String)
  //      .attr("viewBox", "0 -5 10 10")
  //      .attr("refX", 20)
  //      .attr("refY", 0)
  //      .attr("markerWidth", 6)
  //      .attr("markerHeight", 6)
  //      .attr("orient", "auto")
  //    .append("viz:path")
  //      .attr("d", drawCrow);

  // build the light gray dot
  viz.append("viz:defs")
    .selectAll("marker")
    .data(["dot_light_gray"])
    .enter().append("viz:marker")
    .attr("id", String)
    .attr("viewBox", "-5 -5 10 10")
    .attr("refX", -13)
    .attr("refY", 0)
    .attr("markerWidth", 6)
    .attr("markerHeight", 6)
    .attr("orient", "auto")
    .append("viz:path")
    .attr("d", drawDot)
    .attr("fill", "#BBB");

  // build the blue dot
  viz.append("viz:defs")
    .selectAll("marker")
    .data(["dot_blue"])
    .enter().append("viz:marker")
    .attr("id", String)
    .attr("viewBox", "-5 -5 10 10")
    .attr("refX", -13)
    .attr("refY", 0)
    .attr("markerWidth", 6)
    .attr("markerHeight", 6)
    .attr("orient", "auto")
    .append("viz:path")
    .attr("d", drawDot)
    .attr("fill", "#1c7a9b");

  // build the dark gray dot
  viz.append("viz:defs")
    .selectAll("marker")
    .data(["dot_dark_gray"])
    .enter().append("viz:marker")
    .attr("id", String)
    .attr("viewBox", "-5 -5 10 10")
    .attr("refX", -13)
    .attr("refY", 0)
    .attr("markerWidth", 6)
    .attr("markerHeight", 6)
    .attr("orient", "auto")
    .append("viz:path")
    .attr("d", drawDot)
    .attr("fill", "#383838");

  // build the light gray odot
  viz.append("viz:defs")
    .selectAll("marker")
    .data(["odot_light_gray"])
    .enter().append("viz:marker")
    .attr("id", String)
    .attr("viewBox", "-5 -5 10 10")
    .attr("refX", -20)
    .attr("refY", 0)
    .attr("markerWidth", 4)
    .attr("markerHeight", 4)
    .attr("orient", "auto")
    .append("viz:path")
    .attr("d", drawOdot)
    .attr("fill", "#F9F9F9")
    .attr("stroke", "#BBB")
    .attr('stroke-width', 2);

  // build the blue odot
  viz.append("viz:defs")
    .selectAll("marker")
    .data(["odot_blue"])
    .enter().append("viz:marker")
    .attr("id", String)
    .attr("viewBox", "-5 -5 10 10")
    .attr("refX", -20)
    .attr("refY", 0)
    .attr("markerWidth", 4)
    .attr("markerHeight", 4)
    .attr("orient", "auto")
    .append("viz:path")
    .attr("d", drawOdot)
    .attr("fill", "#F9F9F9")
    .attr("stroke", "#1c7a9b")
    .attr('stroke-width', 2);

  // add the links and the arrows
  var path =
    viz.append("viz:g")
    .selectAll("path")
    .data(force.links())
    .enter()
    .append("viz:path")
    .attr("class", "link")
    .attr('id', function(d, i){
      return "linkPathId" + i;
    })
    .style("stroke", function(d) { return d.color; })
    .style("stroke-width", 2)
    .attr("marker-start", function(d) { return "url(#" + d.arrowtail + ")"; })
    .attr("marker-end", function(d) { return "url(#" + d.arrowhead + ")"; })
    .on("dblclick", linkDoubleClicked);

  var linktext =
    viz.append("viz:g")
    .selectAll("g.linklabelholder")
    .data(force.links())
    .enter()
    .append("g")
    .attr("class", "linklabelholder")
    .append("text")
    .attr("class", "linklabel")
    .style("font-size", "6px")
    .attr("font-family", "sans-serif")
    .attr("dy", -5)
    .attr("text-anchor", "start")
    .style("fill","#000")
    .append("textPath")
    .attr("id", function(d, i){
      return "textlinkPathId" + i;
    })
    .attr("xlink:href", function(d, i) { return "#linkPathId" + i;})
    .style("display", "none")
    .text(function(d) {
      linkText = d.source.name + " # " + d.target.name
      return linkText.replace(/_/g,'::');
    });

  // define the nodes
  var viz_nodes =
    viz.selectAll(".node")
    .data(force.nodes())
    .enter().append("g")
    .attr("class", "node")
    .call(force.drag);

  // add the nodes
  viz_nodes.append("path")
    .attr("d", function(d) { return d.shape; })
    .attr("fill", function(d){
      return d.fillcolor;
    })
    .on("dblclick", nodeDoubleClicked);

  // add the text
  viz_nodes.append("text")
    .attr("text-anchor", "middle")
    .attr("dy", ".35em")
    .style("font-size", 8)
    .attr("font-family", "sans-serif")
    .attr("fill", function(d) { return d.fontcolor; })
    .text(function(d) { return d.name.replace(/_/g,'::'); });

  function tick() {
    path.attr("d", function(d) {
      var dx         = d.target.x - d.source.x,
        dy           = d.target.y - d.source.y,
        dr           = 0,
        slopeFactor  = 0.5 / ((d.source.y - d.target.y) / (d.source.x - d.target.x)),
        finalSourceX = 0,
        finalTargetX = 0,
        moveX        = 0;

      if (slopeFactor >= 1) {
        slopeFactor = 1;
      } else if (slopeFactor < -1) {
        slopeFactor = -1;
      }

      moveSourceX = (d.source.name.length - 1) * (slopeFactor * 2.7)
      moveTargetX = (d.target.name.length - 1) * (slopeFactor * 2.7)

      if (d.source.y >= d.target.y) {
        finalSourceX = d.source.x - moveSourceX;
        finalTargetX = d.target.x + moveTargetX;
      } else {
        finalSourceX = d.source.x + moveSourceX;
        finalTargetX = d.target.x - moveTargetX;
      }

      if (isNaN(finalSourceX)) {
        finalSourceX = d.source.x
      }

      if (isNaN(finalTargetX)) {
        finalTargetX = d.target.x
      }

      return "M " +
        finalSourceX + "," +
        d.source.y + "A" +
        dr + "," + dr + " 0 0,1 " +
        finalTargetX + "," +
        d.target.y;
    });

    viz_nodes.attr("transform", function(d) {
      return "translate(" + d.x + "," + d.y + ")";
    });
  }
};

if (typeof model_diagram_json !== "undefined") {
  generate_model_diagram_svg(model_diagram_json);
}
