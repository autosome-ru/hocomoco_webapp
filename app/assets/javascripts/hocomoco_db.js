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

  // $('.toggle-sample-format').click(function(e){
  //   var $table = $('.toggle-sample-format-target')
  //       $sample_header = $table.find('thead th.sample_link'),
  //       sample_format = $sample_header.data('sample-format');
  //   e.preventDefault();
  //   if (!sample_format || sample_format == 'short') {
  //     $sample_header.data('sample-format', 'full')
  //   } else {
  //     $sample_header.data('sample-format', 'short')
  //   }

  //   $sample_header.trigger('applyFormatter');
  //   return false;
  // });

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
