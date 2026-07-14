import {Tab} from "bootstrap";

$(function() {
  const switchToTab = function(url) {
    const urlHashPos = url.indexOf('#');
    if (urlHashPos != -1) {
      const urlHash = url.slice(urlHashPos);
      const tabToShow = document.querySelector(`a[data-bs-toggle="tab"][href="${urlHash}"]`);
      if (tabToShow) {
        Tab.getOrCreateInstance(tabToShow).show();
      }
    } else {
      const defaultTab = $('a.default-tab[data-bs-toggle="tab"]')
      if (defaultTab.attr('href')) {
        document.location.href = defaultTab.attr('href');
      }
    }
  };

  $(document).on('show.bs.tab', '[data-bs-toggle="tab"], [data-bs-toggle="pill"], [data-bs-toggle="list"]', function(event) {
    const targetAnchor = $(event.target).attr("href")
    document.location.href = targetAnchor;
  });

  window.addEventListener('hashchange', function(event){
    event.preventDefault();
    switchToTab(event.newURL);
  });

  switchToTab(document.location.href);
});
