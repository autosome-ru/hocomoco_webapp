//= require ./tablesorter_defaults.js
//= require ./select_columns.js

var page_ready = function() {
  HocomocoDB.app_prefix = $('body').data('app-prefix');

  $('.download').click(function(){
    $('table.tablesorter').get(0).config.widgetOptions.output_saveFileName = $('.csv-filename').val();
    $('table.tablesorter').trigger('outputTable');
  });

  HocomocoDB.apply_formatters( $('table:not(.tablesorter) tbody td') );

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
  $('.help-icon').click(function(e){
    e.stopPropagation();
    var href = $(e.target).data('href');
    if (href) window.location = href;
  });
};

$(document).ready(page_ready);
$(document).on('page:load', page_ready);
