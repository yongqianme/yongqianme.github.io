(function () {
  'use strict';
  var form = document.getElementById('submission-form');
  var submit = document.getElementById('submit');
  var status = document.getElementById('status');
  var language = document.getElementById('language');
  var locale = 'en';
  var turnstileToken = '';
  var query = new URLSearchParams(window.location.search);
  var allowedContexts = ['diagnostic', 'recovery', 'support', 'physical-ai', 'diligence'];
  var inquiryContext = allowedContexts.indexOf(query.get('service')) >= 0 ? query.get('service') : 'diagnostic';

  function applyLanguage(next) {
    locale = next;
    document.documentElement.lang = next === 'zh' ? 'zh-CN' : 'en';
    document.querySelectorAll('[data-en]').forEach(function (node) {
      node.textContent = node.dataset[next];
    });
    language.textContent = next === 'zh' ? 'EN' : '中文';
    language.setAttribute('aria-label', next === 'zh' ? 'Switch to English' : '切换到中文');
  }

  language.addEventListener('click', function () { applyLanguage(locale === 'en' ? 'zh' : 'en'); });

  fetch('/api/config').then(function (response) { return response.json(); }).then(function (config) {
    if (!config.turnstileSiteKey || !window.turnstile) throw new Error('Protection unavailable');
    window.turnstile.render('#turnstile', {
      sitekey: config.turnstileSiteKey,
      action: 'physical_ai_inquiry',
      theme: 'light',
      callback: function (token) { turnstileToken = token; submit.disabled = false; },
      'expired-callback': function () { turnstileToken = ''; submit.disabled = true; },
      'error-callback': function () { turnstileToken = ''; submit.disabled = true; }
    });
  }).catch(function () {
    status.textContent = locale === 'zh' ? '提交保护尚未配置。' : 'Submission protection is not configured.';
  });

  form.addEventListener('submit', function (event) {
    event.preventDefault();
    if (!form.reportValidity() || !turnstileToken) return;
    submit.disabled = true;
    status.textContent = locale === 'zh' ? '正在安全提交…' : 'Submitting securely…';
    var data = new FormData(form);
    data.set('locale', locale);
    data.set('inquiryContext', inquiryContext);
    data.set('turnstileToken', turnstileToken);
    fetch('/api/submissions', {
      method: 'POST',
      body: data
    }).then(function (response) {
      return response.json().then(function (body) { return { ok: response.ok, body: body }; });
    }).then(function (result) {
      if (!result.ok) throw new Error(result.body.error || 'Submission failed');
      form.reset();
      status.textContent = (locale === 'zh' ? '已安全提交。参考编号：' : 'Submitted securely. Reference: ') + result.body.reference;
      turnstileToken = '';
      if (window.turnstile) window.turnstile.reset();
    }).catch(function (error) {
      status.textContent = error.message;
      submit.disabled = false;
      if (window.turnstile) window.turnstile.reset();
    });
  });

  if (query.get('lang') === 'zh') applyLanguage('zh');
}());
