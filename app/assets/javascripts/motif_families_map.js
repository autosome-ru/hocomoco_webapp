//= require d3

jQuery(function(){
  var width = 730,
      height = 700,
      tree_url = HocomocoDB.app_prefix + "tree_level_2.json";

  var tree = d3.layout.tree()
      .size([height, width - 300])
      .separation(function(a,b){
        if (Math.max( Math.sqrt(a.total_tfs), Math.sqrt(b.total_tfs) ) > 10) {
          return 4;
        } else {
          return (a.parent == b.parent) ? 1.5 : 2;
        }
      });

  var diagonal = d3.svg.diagonal()
      .projection(function(d) { return [d.y, d.x]; });

  var svg = d3.select("#motif_families_map").append("svg")
      .attr("width", width)
      .attr("height", height)
    .append("g")
      .attr("transform", "translate(40,0)");

  d3.json(tree_url, function(error, root) {
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
        .attr('xlink:href', function(d){return (HocomocoDB.app_prefix + d.url).replace(/\/+/g,'/');})
        .append("g")
          .attr("class", "node")
          .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

    var div = d3.select("body").append("div")
      .attr("class", "map-tooltip")
      .style("opacity", 0);

    node
      .on("mouseover", function(d) {
        var info_text = '';
        if (d.name.length > 0) {
          var family_name = '<span class="family_name">' + d.name + '{' + d.family_id + '}</span>';
          // info_text = '<a href="http://tfclass.bioinf.med.uni-goettingen.de/tfclass?uniprot=' + d.family_id + '">' + family_name + '</a>' + 
          info_text = family_name;
          info_text += '<br/>';
        }
        info_text += '<br/>' + 'HOCOMOCO models / Total TFs:<br/>' +
                  '<span class="covered_tfs">' + d.covered_tfs + '</span>' + ' / ' + '<span class="total_tfs">' + d.total_tfs + '</span>';
        if (d.comment) {
          info_text += '<br/>' + '<i>' + d.comment + '</i>';
        }
        div.transition()
            .duration(200)
            .style("opacity", 1);
        div.html(info_text)
           .style("left", (d3.event.pageX + 15) + "px")
           .style("top", (d3.event.pageY - 30) + "px");
      })
      .on("mouseout", function(d) {
          div.transition()
              .duration(500)
              .style("opacity", 0);
      });

    node.append("circle")
        .attr("r", function(d) { return Math.pow(d.total_tfs, 0.5) + 1; } ) // 1 is an addition to make circles visually more comparable
        .attr("class", "total_tfs");

    node.append("circle")
        .attr("r", function(d) { return Math.pow(d.covered_tfs, 0.5); } ) // we don't add 1 to inner circle
        .attr("class", "covered_tfs");

    node.append("text")
        .attr("dx", function(d) {
          var radius = Math.pow(d.total_tfs, 0.5) + 1;
          return d.children ? -(radius + 5) : (radius + 5); }
        )
        .attr("dy", 3)
        .style("text-anchor", function(d) { return d.children ? "end" : "start"; })
        .text(function(d) { return d.name; });
  });

  d3.select(self.frameElement).style("height", height + "px");
});
