/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import $ from 'jquery'
window.$ = $
window.jQuery = $

import * as bootstrap from "bootstrap"

window.bootstrap ||= {}
window.bootstrap.Tooltip = bootstrap.Tooltip
window.bootstrap.Popover = bootstrap.Popover
window.bootstrap.Tab = bootstrap.Tab

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll('[data-bs-toggle="popover"]').forEach((el) => {
    bootstrap.Popover.getOrCreateInstance(el)
  })

  document.querySelectorAll("a[rel~=popover], .has-popover").forEach((el) => {
    bootstrap.Popover.getOrCreateInstance(el)
  })

  document.querySelectorAll("a[rel~=tooltip], .has-tooltip").forEach((el) => {
    bootstrap.Tooltip.getOrCreateInstance(el)
  })
})

import * as d3 from "d3";
window.d3 = d3;

import {draw_families_tree} from './src/motif_families_map.js'
window.draw_families_tree = draw_families_tree;

import "./styles/styles";

console.log('Hello World from Webpacker')
