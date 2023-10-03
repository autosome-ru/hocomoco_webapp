//= require ./tablesorter_defaults.js
//= require ./select_columns.js
//= require ./motif_families_map.js

var page_ready = function() {
  HocomocoDB.app_prefix = $('body').data('app-prefix');

  $('.download').click(function(){
    $('table.tablesorter').get(0).config.widgetOptions.output_saveFileName = $('.csv-filename').val();
    $('table.tablesorter').trigger('outputTable');
  });

  $("#motifs").filter('table.tablesorter').tablesorter(
    $.extend(true, {},
      HocomocoDB.defaultConfig,
      HocomocoDB.configForWidgets(['saveSort', 'zebra', 'columnSelector', 'stickyHeaders', 'filter', 'output', 'formatter', /*, 'resizable'*/]),
      { } // custom options
    )
  );

  HocomocoDB.ui.applyColumnSelector();

  $('.help-icon').on('click mousedown mouseup',function(e){
    e.stopPropagation();
  });
  $('.help-icon, button.work_as_link').click(function(e){
    e.stopPropagation();
    var href = $(e.target).data('href');
    if (href) window.location = href;
  });

  if ($('#motif_families_map').length > 0) {
    var family_tree_data_url = $('#motif_families_map').data('url');
    draw_families_tree(family_tree_data_url, d3.select("#motif_families_map"));
  }
};

$(document).ready(page_ready);
$(document).on('page:load', page_ready);
