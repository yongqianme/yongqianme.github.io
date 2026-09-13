(function () {
  'use strict';
  var key = 'yq-inquiry-source-v1';
  var source;
  try { source = JSON.parse(sessionStorage.getItem(key)); } catch (error) { /* Storage is optional. */ }
  if (!source || typeof source !== 'object' || Array.isArray(source)) {
    source = { landing_page: location.pathname.slice(0, 200) };
    var query = new URLSearchParams(location.search);
    ['utm_source', 'utm_medium', 'utm_campaign'].forEach(function (name) {
      var value = query.get(name);
      if (value) source[name] = value.slice(0, 100);
    });
    try {
      var referrer = new URL(document.referrer);
      if (referrer.origin !== location.origin) source.referrer_host = referrer.hostname;
    } catch (error) { /* No referring page. */ }
    try { sessionStorage.setItem(key, JSON.stringify(source)); } catch (error) { /* Private browsing fallback. */ }
  }
  window.getInquirySource = function () {
    var clean = {};
    ['landing_page', 'utm_source', 'utm_medium', 'utm_campaign', 'referrer_host'].forEach(function (name) {
      if (typeof source[name] === 'string') clean[name] = source[name].slice(0, 200);
    });
    return clean;
  };
}());
