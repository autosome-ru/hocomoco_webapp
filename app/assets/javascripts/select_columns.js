;(function(HocomocoDB, $, undefined){

  $.fn.check = function() {
    this.each(function(ind, el) {
      if (! $(el).is(':checked')) {
        this.click();
      }
    });
  };
  $.fn.uncheck = function() {
    this.each(function(ind, el) {
      if ($(el).is(':checked')) {
        this.click();
      }
    });
  };

  HocomocoDB.ui = HocomocoDB.ui || {}

  HocomocoDB.ui.restoreDefaultColumns = function($table, $columnSelector) {
    $table.find('thead th').each(function(index, el) {
      var column_index = $(el).data('column'),
          $checkbox = $columnSelector.find('input:checkbox[data-column=' + column_index + ']');
      if ($(el).is('.columnSelector-false')) {
        $checkbox.uncheck();
      } else {
        $checkbox.check();
      }
    });
  };

  HocomocoDB.ui.applyColumnSelector = function() {
    $('.select-columns-btn')
      .popover({
        placement: 'right',
        html: true, // required if content has HTML
        content: '<div id="column-selector-target"></div>'
      }
    )
    .on('shown.bs.popover', function () { // bootstrap popover event triggered when the popover opens
      var $table = $('table.attach-column-selector'),
          $columnSelector = $('#column-selector-target');

      // call this function to copy the column selection code into the popover
      $.tablesorter.columnSelector.attachTo($table, $columnSelector);
      var buttons_html =  '<div>' +
                          '<a href="#" class="default-columns">Default</a> / ' +
                          '<a href="#" class="hide-all">Hide all</a> / ' +
                          '<a href="#" class="show-all">Show all</a>' +
                          '</div>';
      $columnSelector.prepend($(buttons_html));

      $columnSelector.find('.show-all').click(function(e) {
        $columnSelector.find('input:checkbox').check();
      });

      $columnSelector.find('.hide-all').click(function(e) {
        $columnSelector.find('input:checkbox').uncheck();
      });

      $columnSelector.find('.default-columns').click(function(e) {
        HocomocoDB.ui.restoreDefaultColumns($table, $columnSelector);
      });

      $('body').on('click', function(e) {
        if (! $(e.target).closest('#column-selector-target').length ) { // click outside
          $('.select-columns-btn').popover('hide');
        }
      });
    })
    .on('hidden.bs.popover', function () { // bootstrap popover event triggered when the popover opens
      $('body').off('click');
    });

    $('.resetColumns').click(function(e) {
      $.tablesorter.columnSelector.attachTo($('table.attach-column-selector'), $('#hidden_select_columns'));
      HocomocoDB.ui.restoreDefaultColumns($('table.attach-column-selector'), $('#hidden_select_columns'));
      $('#hidden_select_columns').html('');
    });
  }
})(window.HocomocoDB = window.HocomocoDB || {}, jQuery);
