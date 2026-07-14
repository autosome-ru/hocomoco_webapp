import $ from 'jquery'

window.$ = $
window.jQuery = $

import "bootstrap"
import "./initializers/bootstrap_tabs";
import { initBootstrapWidgets } from "./initializers/bootstrap";
import "./initializers/tablesorter"
import {draw_families_tree} from './features/motif_families_map'
import './features/hocomoco_db'

document.addEventListener('DOMContentLoaded', (ev) => initBootstrapWidgets(document));
document.addEventListener('DOMContentLoaded', (ev) => {
  $('#motif_families_map').each( (idx, element) => {
    draw_families_tree(element.dataset.url, element);
  });
});

document.addEventListener('DOMContentLoaded', (_ev) => {
  $('.expand .toggle').click(function(ev){
    $(ev.target).closest('.expand').children().toggle();
  });
});

console.log('Hello World from Webpacker')
