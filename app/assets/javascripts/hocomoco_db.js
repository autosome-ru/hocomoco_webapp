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

  // $('.comb').find('.comb_multiple, .comb_alternative_group, .comb_optional').find('.comb_term').tooltip({
  //   container: 'body', // not to draw tooltip on an optional element opaque
  //   title: function(){
  //     var texts = [], $el = $(this);
  //     if ($el.closest('.comb_multiple').length) {
  //       texts.push('More than one member of this list can be included.');
  //     }
  //     if ($el.closest('.comb_alternative_group').length) {
  //       texts.push('These members are alternative.');
  //     }
  //     if ($el.closest('.comb_optional').length) {
  //       texts.push('This member is facultative.');
  //     }
  //     return texts.join(' ');
  //   }
  // });

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

  // var comb_alternative_terms, comb_term, comb_terms, uniprotCombTermsShown, uniprotURL;

  // comb_alternative_terms = function(comb_part) {
  //   var tokens = comb_part.split('|');
  //   return $.map(tokens, function(token) {
  //     return comb_term($.trim(token));
  //   });
  //   return Array.prototype.concat.apply([], tokens);
  // };

  // comb_term = function(term) {
  //   if (term.slice(-1) == '+') {
  //     return comb_term(term.slice(0, -1))
  //   } else if (term.slice(-1) == '?') {
  //     return comb_term(term.slice(0, -1))
  //   } else if (term.slice(0, 1) == '(' && term.slice(-1) == ')') {
  //     return comb_alternative_terms(term.slice(1, -1))
  //   } else {
  //     return term;
  //   }
  // };

  // comb_terms = function(comb) {
  //   var tokens;
  //   tokens = $.map(comb.split(','), $.trim);
  //   tokens_splitted = $.map(tokens, function(term){
  //     return comb_term(term);
  //   });
  //   return Array.prototype.concat.apply([], tokens_splitted);
  // };

  // uniprotCombTermsShown = function($header_cell) {
  //   var column, $table_not_resolved, $table, cells, not_null_cells, terms, terms_flatten;
  //   column = $header_cell.data('column');
  //   $table_not_resolved = $header_cell.closest('table'); // This can be either normal table or sticky-header copy of original table
  //   $table = $(document.getElementById($table_not_resolved[0].id.replace(/-sticky$/,''))); // So we need to address original table
  //   cells = $.tablesorter.getColumnText($table, column, function(data) {
  //     return !data.$row.hasClass('filtered');
  //   }).raw;
  //   not_null_cells = $.grep(
  //                       cells,
  //                       function(el){
  //                         return (el != '') && (el != '#');
  //                       }
  //                     );
  //   terms = [];
  //   $.each(not_null_cells, function(index, cell){
  //     Array.prototype.push.apply(terms, comb_terms(cell));
  //   });
  //   return $.grep(
  //             $.unique(terms),
  //             function(el){
  //               return (el != '') && (el != '#');
  //             }
  //           );
  // };

  // uniprotURL = function(cells, field_prefix){
  //   var maxNumberOfUniprots = 100;
  //   if (cells.length > maxNumberOfUniprots) {
  //     alert("You are trying to send a list of " + cells.length + " unique Uniprot identifiers.\n" +
  //           "Maximal number of genes to be sent to Uniprot is " + maxNumberOfUniprots + ".");
  //     return '#'; // It won't redirect us
  //   }

  //   var query = $.map(cells, function(cell){
  //     return field_prefix + cell;
  //   }).join(' OR ');
  //   return 'http://www.uniprot.org/uniprot/?query=' + encodeURIComponent(query);
  // };

  // $('th.uniprot_ac .export_uniprot').mouseup(function(e){
  //   e.stopPropagation(); // We should prevent mouseup propagation, other tablesorter will resort column
  // }).click(function(e){
  //   window.location = uniprotURL(uniprotCombTermsShown($(e.target).closest('th')), 'accession:');
  // });

  // $('th.uniprot_id, .uniprot_id_comb').find('.export_uniprot').mouseup(function(e){
  //   e.stopPropagation(); // We should prevent mouseup propagation, other tablesorter will resort column
  // }).click(function(e){
  //   window.location = uniprotURL(uniprotCombTermsShown($(e.target).closest('th')), '');
  // });

  // $('tr.uniprot_id_comb_row td .export_uniprot').mouseup(function(e){
  //   e.stopPropagation();
  // }).click(function(e){
  //   var value_cell = $(e.target).closest('tr.uniprot_id_comb_row').find('td.uniprot_id_comb').text();
  //   var terms = $.grep(
  //             $.unique(comb_terms(value_cell)),
  //             function(el){
  //               return (el != '') && (el != '#');
  //             }
  //           );
  //   window.location = uniprotURL(terms, '');
  // });
};

$(document).ready(page_ready);
$(document).on('page:load', page_ready);
