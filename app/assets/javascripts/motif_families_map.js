//= require d3

jQuery(function(){
  var width = 960,
      height = 2200;

  var tree = d3.layout.tree()
      .size([height, width - 270])
      .separation(function(a,b){
        if (Math.max( Math.sqrt(a.total_tfs), Math.sqrt(b.total_tfs) ) > 10) {
          return 3;
        } else {
          return (a.parent == b.parent) ? 1.35 : 2;
        }
      });

  var diagonal = d3.svg.diagonal()
      .projection(function(d) { return [d.y, d.x]; });

  var svg = d3.select("#motif_families_map").append("svg")
      .attr("width", width)
      .attr("height", height)
    .append("g")
      .attr("transform", "translate(40,0)");

  d3.json("/tree.json", function(error, root) {
    if (error) throw error;

    var nodes = tree.nodes(root),
        links = tree.links(nodes);

    var link = svg.selectAll(".link")
        .data(links)
      .enter().append("path")
        .attr("class", "link")
        .attr("d", diagonal);

    var node = svg.selectAll(".node")
        .data(nodes)
      .enter()
        .append("svg:a")
        .attr('xlink:href', function(d){return d.url;})
        .append("g")
          .attr("class", "node")
          .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

    var div = d3.select("body").append("div")
      .attr("class", "tooltip")
      .style("opacity", 0);

    node
      .on("mouseover", function(d) {
        var info_text = "TFs in family total: " + d.total_tfs + "<br/>" +
                        "TFs in family covered by HOCOMOCO: " + d.covered_tfs;
        div.transition()
            .duration(200)
            .style("opacity", .9);
        div.html(info_text)
           .style("left", (d3.event.pageX - 130) + "px")
           .style("top", (d3.event.pageY - 30) + "px");
      })
      .on("mouseout", function(d) {
          div.transition()
              .duration(500)
              .style("opacity", 0);
      });

    node.append("circle")
        .attr("r", function(d) { return Math.pow(d.total_tfs, 0.5); } );

    node.append("circle")
        .attr("r", function(d) { return Math.pow(d.covered_tfs, 0.5); } )
        .style("fill", "red");

    node.append("text")
        .attr("dx", function(d) { return d.children ? -8 : 8; })
        .attr("dy", 3)
        .style("text-anchor", function(d) { return d.children ? "end" : "start"; })
        .text(function(d) { return d.name; });
  });

  d3.select(self.frameElement).style("height", height + "px");
});
