---
layout: conversion
title: "Sample Robotics Diagnostic Deliverable"
permalink: /services/sample-diagnostic/
excerpt: "Preview the structure of a robotics diagnostic: baseline, evidence, action priorities, and acceptance criteria. An illustrative example, not a customer result."
lang: en
translation:
  zh_url: /zh/services/sample-diagnostic/
---

<p class="eyebrow">Inside the diagnostic</p>

# A report your team can act on.

<p class="conversion-lead">The deliverable connects operating evidence to a decision: what to investigate, what to change, and how to evaluate the result.</p>

**Illustrative example only.** The scenario below is fictional. It demonstrates the report structure, not a customer result, verified diagnosis, or performance promise.

## Example scope

A robot-assisted handling cell has recurring stops during part transfer. The diagnostic covers that transfer process and its robot/PLC/vision interfaces. Upstream production and replacement equipment are outside this example's scope.

## 1. Baseline and evidence

Record the observation period, shift and product mix, stop definitions, fault timestamps, cycle-time distribution, recovery steps, and data gaps. Agree any cost-per-hour or scrap assumptions with the customer's operations and finance owners.

### Worked baseline — fictional figures

Assume a four-week observation period with 160 scheduled hours, 20 hours of transfer-related downtime, and 120 transfer stops. Average recovery time is 10 minutes per stop. The process has sufficient customer demand to use recovered capacity; contribution per productive hour is assumed to be $2,000 after variable costs.

| Measure | Example baseline | Proposed test target |
|---|---:|---:|
| Transfer-related downtime per 160 scheduled hours | 20 hours | At most 10 hours |
| Transfer-related stops per 160 scheduled hours | 120 | At most 60 |
| Average recovery time | 10 minutes | At most 10 minutes |

Recovering 10 productive hours would represent $20,000 contribution per four-week period, or $240,000 over twelve comparable periods. These are hypothetical scenario figures, not verified savings or a guarantee. They exclude additional scrap or labor benefits to avoid double-counting. The test must check product mix, demand, maintenance costs, and any losses shifted to other stations.

| Evidence to review | Question it helps answer |
|---|---|
| Robot and PLC event logs | Which event happens first? |
| Cycle-time records by product and shift | Is variation tied to an operating condition? |
| Vision results and part presentation | Does the transfer depend on inconsistent inputs? |
| Operator recovery steps | Does the reset sequence introduce repeat faults? |

## 2. Findings and confidence

**Example observation:** the supplied event record shows a transfer timeout. **Hypothesis to test:** the handoff sequence or a delayed input may be involved. **Missing evidence:** time-aligned robot and PLC logs. The report distinguishes all three; a timeout alone does not establish the root cause.

## 3. Action plan

For each proposed action, document the evidence behind it, expected effect, priority, accountable owner, dependencies, effort estimate, and rollback approach. Begin with the smallest useful test that can confirm or reject the hypothesis.

In this example, the first action would be to agree a permitted observation window and obtain synchronized logs. Any subsequent production change needs the customer's authorization and applicable engineering review.

| Priority | Example action | Owner and dependency | Illustrative effort / cost |
|---|---|---|---|
| 1 | Align event timestamps and observe the handoff sequence | Controls lead; approved access and observation window | 2 specialist days / $2,000 |
| 2 | If evidence confirms a timing defect, test a scoped sequence correction | Robot and PLC specialists; approved change, backup, and rollback | 6 specialist days / $6,000 |
| 3 | Run the acceptance trial and document recovery procedures | Production owner with technical lead; representative production | 2 specialist days / $2,000 |

This example budgets $10,000 specialist effort plus $2,000 contingency. It excludes diagnostic fees, travel, equipment, and customer labor, and is not a service quotation. Under the assumed $20,000 benefit per comparable period, those incremental implementation costs imply 0.6 periods of simple payback. A purchase decision must include the omitted costs and validate the benefit first.

**Recommendation in this fictional scenario:** approve evidence collection first. Authorize the correction only if synchronized logs substantiate the timing hypothesis. Otherwise, revise the diagnosis before committing the implementation budget.

## 4. Acceptance checklist

- [ ] Define the process boundary, operating conditions, product mix, and test duration.
- [ ] Agree baseline and target metrics before implementation.
- [ ] Specify how repeat faults, cycle-time variation, and recovery time will be measured.
- [ ] Identify safety review, backups, test permissions, and rollback responsibilities.
- [ ] Record unresolved issues, operator handover, and support ownership.
- [ ] Name the customer's acceptance owner and evidence required for sign-off.

[Open the standalone acceptance checklist](/services/acceptance-checklist/){: .btn}

## 5. Decision review

Close with a recommendation, alternatives, remaining uncertainty, and the next decision. A finding that more evidence is needed should be explicit. Implementation scope and commercial terms are agreed separately.

<div class="conversion-cta"><h2>Apply this approach to your process.</h2><p>Share the issue and what your team has already tried.</p><div class="conversion-actions"><a class="btn btn--primary" href="/contact/#project-brief">Prepare a project brief</a><a class="btn" href="/services/">Return to diagnostic scope</a></div></div>
