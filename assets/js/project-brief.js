(function () {
  'use strict';

  var form = document.getElementById('project-brief-form');
  if (!form) return;

  var result = document.getElementById('brief-result');
  var draft = document.getElementById('brief-draft');
  var status = document.getElementById('brief-status');
  var emailLink = document.getElementById('brief-mailto');
  var fields = Array.prototype.slice.call(form.querySelectorAll('[name]'));

  // Prevent stale drafts from being sent after the visitor changes the brief.
  form.addEventListener('input', function (event) {
    if (fields.indexOf(event.target) === -1) return;
    result.hidden = true;
    draft.value = '';
    emailLink.removeAttribute('href');
    status.textContent = '';
    event.target.setCustomValidity('');
  });

  form.addEventListener('submit', function (event) {
    event.preventDefault();
    fields.forEach(function (field) {
      field.value = field.value.trim();
    });
    if (!form.reportValidity()) return;

    var body = fields.filter(function (field) {
      return field.value.length > 0;
    }).map(function (field) {
      var label = form.querySelector('label[for="' + field.id + '"]').textContent;
      return label + ':\n' + field.value;
    }).join('\n\n');
    var company = form.elements.company.value.replace(/[\r\n]/g, ' ');
    var subject = form.dataset.subject + ' — ' + company;

    // User-entered content remains plain text and is never inserted as HTML.
    draft.value = body;
    emailLink.href = 'mailto:qianyong@qianyong.me?subject=' + encodeURIComponent(subject) + '&body=' + encodeURIComponent(body);
    result.hidden = false;
    status.textContent = form.dataset.ready;
    document.getElementById('brief-result-title').focus();
  });

  document.getElementById('brief-copy').addEventListener('click', function () {
    function manualCopy() {
      draft.focus();
      draft.select();
      status.textContent = form.dataset.copyFailed;
    }
    if (!navigator.clipboard || !navigator.clipboard.writeText) {
      manualCopy();
      return;
    }
    navigator.clipboard.writeText(draft.value).then(function () {
      status.textContent = form.dataset.copied;
    }).catch(manualCopy);
  });

  // Only expose the form once its local-only submit handler is installed.
  form.hidden = false;
}());
