$(function() {
  $(document).on('show.bs.tab', '[data-bs-toggle="tab"], [data-bs-toggle="pill"], [data-bs-toggle="list"]', function(event) {
    let targetAnchor = $(event.target).attr("href")
    document.location.href = targetAnchor;
  });

  let switchToTab = function(url) {
    let urlHashPos = url.indexOf('#');
    if (urlHashPos != -1) {
      let urlHash = url.slice(urlHashPos);
      let tabToShow = document.querySelector(`a[data-bs-toggle="tab"][href="${urlHash}"]`);
      if (tabToShow) {
        bootstrap.Tab.getOrCreateInstance(tabToShow).show();
      }
    } else {
      let defaultTab = $('a.default-tab[data-bs-toggle="tab"]')
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
