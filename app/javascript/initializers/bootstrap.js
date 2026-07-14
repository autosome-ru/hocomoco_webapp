import $ from "jquery";
import { Tooltip, Popover } from "bootstrap";

const TOOLTIP_SELECTOR = '[data-bs-toggle="tooltip"], .has-tooltip, a[rel~="tooltip"]';
const POPOVER_SELECTOR = '[data-bs-toggle="popover"], .has-popover, a[rel~="popover"]';

export function initBootstrapWidgets(root = document) {
  $(root).find(TOOLTIP_SELECTOR).addBack(TOOLTIP_SELECTOR).each((idx, element) => {
    Tooltip.getOrCreateInstance(element);
  });

  $(root).find(POPOVER_SELECTOR).addBack(POPOVER_SELECTOR).each((idx, element) => {
    Popover.getOrCreateInstance(element);
  });
}

export function disposeBootstrapWidgets(root = document) {
  $(root).find(TOOLTIP_SELECTOR).addBack(TOOLTIP_SELECTOR).each((idx, element) => {
    Tooltip.getInstance(element)?.dispose();
  });
  $(root).find(POPOVER_SELECTOR).addBack(POPOVER_SELECTOR).each((idx, element) => {
    Popover.getInstance(element)?.dispose();
  });
}
