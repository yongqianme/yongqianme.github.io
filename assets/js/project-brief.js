(function () {
  'use strict';
  var form = document.getElementById('project-brief-form');
  if (!form) return;
  var result = document.getElementById('brief-result');
  var draft = document.getElementById('brief-draft');
  var status = document.getElementById('brief-status');
  var emailLink = document.getElementById('brief-mailto');
  var fields = Array.prototype.slice.call(form.querySelectorAll('[name]'));
  var reference = '';
  var service = new URLSearchParams(location.search).get('service');
  if (['recovery', 'support', 'diagnostic'].indexOf(service) === -1) service = '';

  form.addEventListener('input', function (event) {
    if (fields.indexOf(event.target) === -1) return;
    result.hidden = true;
    draft.value = '';
    emailLink.removeAttribute('href');
    status.textContent = '';
    reference = '';
  });

  form.addEventListener('submit', function (event) {
    event.preventDefault();
    fields.forEach(function (field) { field.value = field.value.trim(); });
    if (!form.reportValidity()) return;
    reference = reference || ('YQ-' + (window.crypto && crypto.randomUUID ? crypto.randomUUID() : Date.now().toString(36) + '-' + Math.random().toString(36).slice(2)));
    var attribution = window.getInquirySource ? window.getInquirySource() : {};
    var lines = ['Reference: ' + reference];
    if (service) lines.push('Service: ' + service);
    fields.forEach(function (field) {
      if (field.value) lines.push(form.querySelector('label[for="' + field.id + '"]').textContent + ':\n' + field.value);
    });
    if (Object.keys(attribution).length) lines.push('Visit source:\n' + JSON.stringify(attribution, null, 2));
    draft.value = lines.join('\n\n');
    var subject = form.dataset.subject + ' — ' + form.elements.company.value + ' [' + reference + ']';
    emailLink.href = 'mailto:qianyong@qianyong.me?subject=' + encodeURIComponent(subject) + '&body=' + encodeURIComponent(draft.value);
    result.hidden = false;
    status.textContent = form.dataset.ready;
    document.getElementById('brief-result-title').focus();
  });

  document.getElementById('brief-copy').addEventListener('click', function () {
    function manualCopy() {
      draft.focus(); draft.select();
      status.textContent = form.dataset.copyFailed;
    }
    if (!navigator.clipboard || !navigator.clipboard.writeText) { manualCopy(); return; }
    navigator.clipboard.writeText(draft.value).then(function () {
      status.textContent = form.dataset.copied;
    }).catch(manualCopy);
  });
  form.hidden = false;
}());
