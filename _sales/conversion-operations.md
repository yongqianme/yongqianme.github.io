# Website inquiry and sales tracking

## Current implementation

- Four initial fields: name, work email, company, and robot/customer workflow/decision.
- Optional details: site, impact, deadline, budget owner, available data, and referral.
- Email draft and copy fallback; no form-submission service, as requested.
- Each draft includes a reference and, when available, the first landing path, UTM source/medium/campaign, and external referrer hostname from the current tab's session.
- Source capture uses sessionStorage, with an in-memory fallback if storage is blocked. It stores no contact fields, full referrer URL, or arbitrary query parameters. Closing the session may discard attribution.
- Physical AI, diligence, diagnostic, recovery, and support links preserve the selected service in the email draft.
- Attribution travels only when the visitor chooses to send the email. This is not a web analytics dashboard or a record of sent messages.

## Campaign links

Examples to use in permitted outreach:

- Humanoid founder outreach: `https://qianyong.me/physical-ai/?utm_source=linkedin&utm_medium=outbound&utm_campaign=founder_sprint`
- Investor introduction: `https://qianyong.me/physical-ai/?utm_source=partner&utm_medium=referral&utm_campaign=robotics_diligence`
- Physical AI field note: `https://qianyong.me/physical-ai/?utm_source=linkedin&utm_medium=organic&utm_campaign=deployment_readiness`
- Robot deployment partner: `https://qianyong.me/services/?utm_source=partner&utm_medium=referral&utm_campaign=robot_deployment`
- Existing-customer Physical AI expansion: `https://qianyong.me/contact/?service=physical-ai&utm_source=customer&utm_medium=referral&utm_campaign=physical_ai_expansion`

Use generic campaign names, not personal information or confidential customer names. Ask direct-email and calendar leads how they heard about you if the source is missing.

## One-core-business rules

- **Core business:** Physical AI Deployment & Production Recovery.
- **Primary customers:** robot companies with a blocked customer deployment and industrial operators with a costly robot workflow, each with a decision inside 90 days.
- **Entry offer:** a two-week deployment diagnostic with a $30K planning price. Equivalent documented evidence allows direct implementation scoping, as required by the annual plan's direct/partner acquisition route.
- **Expansion path:** a three-month deployment-recovery program with a $400K planning price, followed where justified by a three-month $100K reliability block.
- **Diagnostic variants:** founder product-readiness and investor diligence questions are accepted only when they test the same workflow, deployment, evidence, and economic model.
- **Decline or refer:** standalone strategy sessions, general AI strategy, fundraising support, hardware resale, component sourcing, open-ended engineering staffing, and factory optimization unrelated to a robot deployment.

For the next 90 days, direct all proactive business-development time to the core business. Existing profitable obligations can continue, but every new outbound campaign, partner conversation, qualification call, and proposal must enter the same diagnostic-to-recovery funnel. Review compliance each Friday using qualified pipeline value and founder time, not page traffic.

## Pipeline register template

Keep completed records in a private CRM or private document, not this public repository. Copy this blank structure there:

| Inquiry ID | Received date | Account / owner | Source / campaign | Service | Stage | Qualified date | Meeting date | Proposal date / value | Won date / fee | Cash collected | Next action / date | Loss reason |
|---|---|---|---|---|---|---|---|---|---|---|---|---|

Stages: received, qualifying, qualified, meeting held, proposal sent, won, lost. Use one record per opportunity; link additional sites without counting the same budget twice.

Qualification means a named sponsor, defined robot and customer workflow, accessible operating evidence, a deployment decision within 90 days, credible economic impact, budget path, and decision date. A $400K recovery opportunity should have a customer-validated path to at least $1.2M in annual benefit. A generated draft, mailto click, or calendar click is not a received or qualified inquiry. Record a meeting as held only after it takes place. Count won work when an agreement is signed; record cash separately when collected.

## Friday review

1. Record actual received inquiries and reconcile duplicates by reference/account.
2. Count qualified opportunities, meetings held, proposals, signed work, and collected cash.
3. Group by source/campaign and review time-to-close and lost-deal reasons.
4. Calculate qualified/received, proposal/qualified, and won/proposal for matched cohorts. Mark immature cohorts; avoid dividing unrelated weekly totals.
5. Assign a dated next action to every open opportunity.

Use the existing core customer to seek one funded expansion, one approved case study, and two introductions. Website changes support those conversations; they do not establish demand or achieve the annual revenue target themselves.
