//= require d3

draw_families_tree = function(tree_url, svg_container){
  var width = 730,
      height = 700;

  var treeLayout = d3.tree()
      .size([height, width - 270])
      .separation(function(a,b){
        if (Math.max( Math.sqrt(a.data.total_tfs), Math.sqrt(b.data.total_tfs) ) > 10) {
          return 4;
        } else {
          return (a.parent == b.parent) ? 1.5 : 2;
        }
      });

  var diagonal = d3.linkHorizontal()
    .x(function(d) { return d.y; })
    .y(function(d) { return d.x; });

  var svg = svg_container.append("svg")
      .attr("viewBox", [0, 0, width, height].join(' ') )
    .append("g")
      .attr("transform", "translate(40,0)");

  d3.json(tree_url).then(function(data) {
    var root = d3.hierarchy(data);
    var nodes = root.descendants(),
        links = root.links();
    treeLayout(root);

    var link = svg.selectAll(".link")
        .data(links)
      .enter().append("path")
        .attr("class", "link")
        .attr("d", diagonal);

    var node = svg.selectAll(".node")
        .data(nodes)
      .enter()
        .append("svg:a")
        .attr('xlink:href', function(d){return (HocomocoDB.app_prefix + d.data.url).replace(/\/+/g,'/');})
        .append("g")
          .attr("class", "node")
          .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

    var tooltip_div = d3.select("body").append("div")
      .attr("class", "map-tooltip")
      .style("opacity", 0);

    node
      .on("mouseover", function(d) {
        var info_text = '';
        if (d.data.name.length > 0) {
          var family_name
          if (String(d.data.family_id).length > 0) {
            family_name = '<span class="family_name">' + d.data.name + '{' + d.data.family_id + '}</span>';
          } else {
            family_name = '<span class="family_name">' + d.data.name + '</span>';
          }
          // info_text = '<a href="http://tfclass.bioinf.med.uni-goettingen.de/?tfclass=' + d.data.family_id + '">' + family_name + '</a>' +
          info_text = family_name;
          info_text += '<br/>';
        }
        info_text += '<br/>' + 'HOCOMOCO / Total TFs:<br/>' +
                  '<span class="covered_tfs">' + d.data.covered_tfs + '</span>' + ' / ' + '<span class="total_tfs">' + d.data.total_tfs + '</span>';
        if (d.data.comment) {
          info_text += '<br/>' + '<i>' + d.data.comment + '</i>';
        }
        tooltip_div.transition()
            .duration(200)
            .style("opacity", 1);
        tooltip_div.html(info_text)
           .style("left", (d3.event.pageX + 15) + "px")
           .style("top", (d3.event.pageY - 30) + "px");
      })
      .on("mouseout", function(d) {
          tooltip_div.transition()
              .duration(500)
              .style("opacity", 0);
      });

    node.append("circle")
        .attr("r", function(d) { return Math.pow(d.data.total_tfs, 0.5) + 1; } ) // 1 is an addition to make circles visually more comparable
        .attr("class", "total_tfs");

    node.append("circle")
        .attr("r", function(d) { return Math.pow(d.data.covered_tfs, 0.5); } ) // we don't add 1 to inner circle
        .attr("class", "covered_tfs");

    node.append("text")
        .attr("dx", function(d) {
          var radius = Math.pow(d.data.total_tfs, 0.5) + 1;
          return d.children ? -(radius + 5) : (radius + 5); }
        )
        .attr("dy", 3)
        .style("text-anchor", function(d) { return d.children ? "end" : "start"; })
        .text(function(d) { return d.data.name; });
  });

  d3.select(self.frameElement).style("height", height + "px");
};
