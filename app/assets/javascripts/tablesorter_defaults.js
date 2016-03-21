//= require ./formatters.js

;(function(HocomocoDB, $, undefined) {
  HocomocoDB.defaultWidgetOptions = {
    filter: {
      filter_columnFilters : true,
      filter_hideFilters : false,
      filter_saveFilters: false,
      filter_ignoreCase : true,
      filter_liveSearch : true,
      filter_onlyAvail : 'filter-onlyAvail',
      filter_reset : 'button.reset',
      filter_searchDelay : 300,
      filter_startsWith : false,
      filter_useParsedData : false,
      filter_external : '', // Possibly it will replace server-side search (not sure it's a good idea, but leave such a variant)

      filter_formatter : {  },
      filter_functions : {  },
      filter_selectSource : {  },
    },

    formatter: {
      formatter_column: HocomocoDB.tablesorter_formatters,
    },
    stickyHeaders: {
      stickyHeaders_addResizeEvent : false,
    },
    saveSort: {},
    zebra: {},
    output: { // CSV output
      // TODO: Need fix in tablesorter to make it possible to remove group headers from output
      output_separator     : "\t",
      output_ignoreColumns : [],
      output_dataAttrib    : 'data-text', // the same attribute as is used in textAttribute config option (used by formatter widget and extractors)
      output_delivery      : 'd',         // (p)opup, (d)ownload
      output_saveRows      : 'f',         // (a)ll, (f)iltered or (v)isible
    },
    columnSelector: {
      columnSelector_saveColumns: true,
      columnSelector_mediaquery: false,
    },
    resizable: {
      resizable_addLastColumn: true,
    },
    group: {
      group_collapsible : true,
      group_collapsed : true,
      group_saveGroups : true,
    },
  };

  // It should be incorporated into widget options using deep-extend like this:
  // $.extend(true, {},
  //               HocomocoDB.defaultConfig,
  //               HocomocoDB.configForWidgets(['widget_1', 'widget_2'],
  //               {my: 'own configuration options', }
  //         )
  HocomocoDB.configForWidgets = function(widgetList) {
    var widgetConfig = {};
    $.each(widgetList, function(i, widgetName){
      return $.extend(widgetConfig, HocomocoDB.defaultWidgetOptions[widgetName] || {});
    });
    return {
      widgets: widgetList,
      widgetOptions: widgetConfig,
    };
  };

  HocomocoDB.defaultConfig = {
    theme: 'blue',
    widthFixed : false, // This is default
    ignoreCase: true,
    // delayInit: false,
    initialized : function(table){
      $('.loading_table').hide();
    },
    onRenderHeader: function(index){
      $(this).find('.has-tooltip').tooltip(); // As headers can be rerendered, collective .tooltip() call doesn't work
    }
  }
})(window.HocomocoDB = window.HocomocoDB || {}, jQuery);
