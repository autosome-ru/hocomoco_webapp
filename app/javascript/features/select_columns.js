import $ from "jquery";
import { Popover } from "bootstrap";
import "../initializers/tablesorter";

;(function(HocomocoDB, $, undefined){

  const COLUMN_SELECTOR_BUTTON = ".select-columns-btn";

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
  HocomocoDB.ui.applyColumnSelector = function() {
    $(COLUMN_SELECTOR_BUTTON).each((idx, button) => {
      if (Popover.getInstance(button))  return;

      let outsideClickHandler = null;

      const removeOutsideClickHandler = function() {
        if (outsideClickHandler) {
          document.removeEventListener("click", outsideClickHandler);
          outsideClickHandler = null;
        }
      };

      const popover = new Popover(button, {
        placement: 'right',
        container: document.body,
        html: true,
        content: '<div class="column-selector-target"></div>'
      });

      const show_columns_selector = function(popover, button, event) {
        const popoverId = button.getAttribute("aria-describedby");
        const popoverElement = popoverId ? document.getElementById(popoverId) : null;
        const columnSelectorTarget = popoverElement?.querySelector(".column-selector-target");
        if (!columnSelectorTarget)  return;
        const $columnSelector = $(columnSelectorTarget);

        // call this function to copy the column selection code into the popover
        $.tablesorter.columnSelector.attachTo($('table.attach-column-selector'), $columnSelector);
        const buttons_html =  '<div class="column-selector-actions">' +
                            '<a href="#" class="default-columns">Default</a> / ' +
                            '<a href="#" class="hide-all">Hide all</a> / ' +
                            '<a href="#" class="show-all">Show all</a>' +
                            '</div>'
        $columnSelector.prepend($(buttons_html));

        $columnSelector.find('.show-all').click(function(e) {
          e.preventDefault();
          $columnSelector.find('input:checkbox').check();
        });

        $columnSelector.find('.hide-all').click(function(e) {
          e.preventDefault();
          $columnSelector.find('input:checkbox').uncheck();
        });

        $columnSelector.find('.default-columns').click(function(e) {
          e.preventDefault();
          $('table.attach-column-selector thead th').each(function(index, el) {
            const column_index = $(el).data('column');
            const $checkbox = $columnSelector.find('input:checkbox[data-column=' + column_index + ']');
            if ($(el).is('.columnSelector-false')) {
              $checkbox.uncheck();
            } else {
              $checkbox.check();
            }
          });
        });

        removeOutsideClickHandler();
        outsideClickHandler = function(event) {
          const clickedInsideButton = button.contains(event.target);
          const clickedInsidePopover = popoverElement?.contains(event.target);

          if (!clickedInsideButton && !clickedInsidePopover) {
            popover.hide();
          }
        };

        document.addEventListener("click", outsideClickHandler);
      };



      button.addEventListener('shown.bs.popover', (event) => show_columns_selector(popover, button, event));
      button.addEventListener('hidden.bs.popover', (event) => removeOutsideClickHandler());
    });
  }
})(window.HocomocoDB = window.HocomocoDB || {}, $);
