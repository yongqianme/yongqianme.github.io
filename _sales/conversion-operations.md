# Website inquiry and sales tracking

## Current implementation

- Four initial fields: name, work email, company, process/problem.
- Optional details: site, impact, deadline, budget owner, available data, and referral.
- Email draft and copy fallback; no form-submission service, as requested.
- Each draft includes a reference and, when available, the first landing path, UTM source/medium/campaign, and external referrer hostname from the current tab's session.
- Source capture uses sessionStorage, with an in-memory fallback if storage is blocked. It stores no contact fields, full referrer URL, or arbitrary query parameters. Closing the session may discard attribution.
- Recovery/support links preserve the selected service in the email draft.
- Attribution travels only when the visitor chooses to send the email. This is not a web analytics dashboard or a record of sent messages.

## Campaign links

Examples to use in permitted outreach:

- LinkedIn field note: `https://qianyong.me/services/?utm_source=linkedin&utm_medium=organic&utm_campaign=production_diagnostic`
- Partner introduction: `https://qianyong.me/services/?utm_source=partner&utm_medium=referral&utm_campaign=production_diagnostic`
- Existing-customer expansion: `https://qianyong.me/contact/?service=recovery&utm_source=customer&utm_medium=referral&utm_campaign=expansion`

Use generic campaign names, not personal information or confidential customer names. Ask direct-email and calendar leads how they heard about you if the source is missing.

## Pipeline register template

Keep completed records in a private CRM or private document, not this public repository. Copy this blank structure there:

| Inquiry ID | Received date | Account / owner | Source / campaign | Service | Stage | Qualified date | Meeting date | Proposal date / value | Won date / fee | Cash collected | Next action / date | Loss reason |
|---|---|---|---|---|---|---|---|---|---|---|---|---|

Stages: received, qualifying, qualified, meeting held, proposal sent, won, lost. Use one record per opportunity; link additional sites without counting the same budget twice.

Qualification means a named sponsor, specific problem, credible economic impact, accessible data, budget path, and decision date. A generated draft, mailto click, or calendar click is not a received or qualified inquiry. Record a meeting as held only after it takes place. Count won work when an agreement is signed; record cash separately when collected.

## Friday review

1. Record actual received inquiries and reconcile duplicates by reference/account.
2. Count qualified opportunities, meetings held, proposals, signed work, and collected cash.
3. Group by source/campaign and review time-to-close and lost-deal reasons.
4. Calculate qualified/received, proposal/qualified, and won/proposal for matched cohorts. Mark immature cohorts; avoid dividing unrelated weekly totals.
5. Assign a dated next action to every open opportunity.

Use the existing core customer to seek one funded expansion, one approved case study, and two introductions. Website changes support those conversations; they do not establish demand or achieve the annual revenue target themselves.
