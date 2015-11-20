var page_ready = function() {
  $('.expand .toggle').click(function(ev){
    // window.ev = ev;
    $(ev.target).closest('.expand').children().toggle();
  })
};

$(document).ready(page_ready);
$(document).on('page:load', page_ready);
