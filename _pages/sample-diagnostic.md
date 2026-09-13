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

## 4. Acceptance checklist

- [ ] Define the process boundary, operating conditions, product mix, and test duration.
- [ ] Agree baseline and target metrics before implementation.
- [ ] Specify how repeat faults, cycle-time variation, and recovery time will be measured.
- [ ] Identify safety review, backups, test permissions, and rollback responsibilities.
- [ ] Record unresolved issues, operator handover, and support ownership.
- [ ] Name the customer's acceptance owner and evidence required for sign-off.

## 5. Decision review

Close with a recommendation, alternatives, remaining uncertainty, and the next decision. A finding that more evidence is needed should be explicit. Implementation scope and commercial terms are agreed separately.

<div class="conversion-cta"><h2>Apply this approach to your process.</h2><p>Share the issue and what your team has already tried.</p><div class="conversion-actions"><a class="btn btn--primary" href="/contact/#project-brief">Prepare a project brief</a><a class="btn" href="/services/">Return to diagnostic scope</a></div></div>
