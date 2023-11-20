$(function() {
  $("a[rel~=popover], .has-popover").popover()
  $("a[rel~=tooltip], .has-tooltip").tooltip()

  $(document).on('show.bs.tab', '[data-toggle="tab"], [data-toggle="pill"], [data-toggle="list"]', function(event) {
    let targetAnchor = $(event.target).attr("href")
    document.location.href = targetAnchor;
  });

  let switchToTab = function(url) {
    let urlHashPos = url.indexOf('#');
    if (urlHashPos != -1) {
      let urlHash = url.slice(urlHashPos);
      $(`a[data-toggle="tab"][href="${urlHash}"]`).trigger('click');
    } else {
      let defaultTab = $('a.default-tab[data-toggle="tab"]')
      if (defaultTab.attr('href')) {
        document.location.href = defaultTab.attr('href');
      }
    }
  };

  switchToTab(document.location.href);

  window.addEventListener('hashchange', function(event){
    event.preventDefault();
    switchToTab(event.newURL);
  });
});
