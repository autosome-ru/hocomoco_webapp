import $ from 'jquery'

window.$ = $
window.jQuery = $

import * as bootstrap from "bootstrap"
import { initBootstrapWidgets } from "./initializers/bootstrap";
import {draw_families_tree} from './features/motif_families_map.js'

// window.bootstrap ||= {}
// window.bootstrap.Tooltip = bootstrap.Tooltip
// window.bootstrap.Popover = bootstrap.Popover
// window.bootstrap.Tab = bootstrap.Tab


// import * as d3 from "d3";
// window.d3 = d3;


document.addEventListener('DOMContentLoaded', (ev) => initBootstrapWidgets(document));
document.addEventListener('DOMContentLoaded', (ev) => {
  $('#motif_families_map').each( (idx, element) => {
    draw_families_tree(element.dataset.url, element);
  });
});

console.log('Hello World from Webpacker')
