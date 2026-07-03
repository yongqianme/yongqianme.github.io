---
title: Vision–Language–Action Models in Humanoid Robotics Practical Limits, Strategic
  Bets, and Market Implications
date: '2025-08-11'
permalink: "/posts/2025/08/visionlanguageaction-models-in-humanoid/"
categories:
- Writing
tags:
- AI
- VLA
- Humanoid
substack_id: 170602931
substack_slug: visionlanguageaction-models-in-humanoid
substack_url: https://yongqianme.substack.com/p/visionlanguageaction-models-in-humanoid
excerpt: A fixed space is friendly for VLA.
image: https://substackcdn.com/image/fetch/$s_!85bm!,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F17b23dbd-f7f6-4719-9434-62b66b0befc4_1536x1024.heic
---

> Originally published on [Substack](https://yongqianme.substack.com/p/visionlanguageaction-models-in-humanoid).

<div><figure><a href="https://substackcdn.com/image/fetch/%24s_!85bm!,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F17b23dbd-f7f6-4719-9434-62b66b0befc4_1536x1024.heic"><div><img src="https://substackcdn.com/image/fetch/%24s_!85bm!,w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F17b23dbd-f7f6-4719-9434-62b66b0befc4_1536x1024.heic" width="1456" height="971" alt=""></div>
</a></figure>
</div>
<p>The humanoid robotics sector is entering a commercial-ready phase. Declining component costs, expanded manufacturing infrastructure, and incremental improvements in embodied cognition make targeted deployments plausible. One of the most debated decisions for product strategy is whether to build around Vision–Language–Action (VLA) models or adopt a hybrid architecture that combines high-level reasoning with robust low-level controllers and simulation-trained skills. In the recent speech, Unitree’s founder pointed out that the bigger problem is model architecture, not data quantity, and he also commented that the VLA is too limited. However, there is another startup Spirit AI is betting its roadmap on a VLA- first approach.</p>
<p>The strategic divergence is clear.</p>
<p><strong>What “VLA” Means in Practice</strong></p>
<p>VLA models attempt to unify three layers of robot cognition into a single model:</p>
<p>Vision: interpreting raw visual data from cameras.<br>Language: parsing human instructions or textual goals.<br>Action: generating motor control sequences directly from the perception– instruction input through the <a href="https://x.com/yongqianme/status/1954420801094177080?s=46">EtherCAT protocol</a>.</p>
<p>The promise is appealing: one end-to-end model, a natural-language interface, and fewer bespoke engineering layers. But in physical robotics, the abstraction hides operational constraints that determine whether a product can scale.</p>
<p><strong>Where VLA Performs Well — Spirit AI’s Rationale</strong></p>
<p>VLA’s strongest commercial case is in constrained domains with repeatable layouts and predictable task types. Benchmarks and deployments show clear advantages in:</p>
<p>Natural UX: Users can issue instructions in plain language without learning system-specific commands.</p>
<p>Task decomposition: Strong performance in breaking down high-level instructions into a coherent sequence of subtasks.<br>Rapid iteration: With focused data collection, VLA can generalize well across similar environments (e.g., hotel lobbies, warehouse aisles). Simpler product stack: One core model reduces integration complexity.</p>
<p>Spirit AI’s Moz1 platform leverages these benefits, focusing on targeted verticals where environmental variation is limited, and the cost of retraining is acceptable.</p>
<p><strong>Unitree’s Critique — The Structural Limits of VLA</strong></p>
<p>The counterargument is rooted in engineering realities:</p>
<ol>
<li><p>Zero-shot generalization remains unreliable in messy, unfamiliar environments.</p>
</li>

<li><p>Low-level control fidelity is brittle when generated directly from high- dimensional multimodal models.</p>
</li>

<li><p>Skill accumulation via reinforcement learning has no proven scaling law; each new skill often requires retraining from scratch.</p>
</li>

<li><p>Compute and latency constraints make high-capacity VLA challenging to deploy on-board without costly edge or cluster solutions.</p>
</li>

</ol>
<p>Unitree’s position: the true market breakthrough will come when a robot can enter an unknown space, understand a request like “organize the living room,” and execute it reliably without preprogramming. My readers remembered my past article: <a href="https://yongqianme.substack.com/p/why-i-walked-away-from-a-7-million">Why I Walked Away from a $7 Million Robotics Deal</a>, which mentioned a real unknown space for mining exploration, the current limitation was the key reason why I stopped the project. And yes, Current VLAs are not yet at that threshold.</p>
<p><strong>Benchmark Evidence — The Current State of Play</strong></p>
<p>While simulation benchmarks overstate readiness, several datasets and projects clarify the gap:</p>
<div><figure><a href="https://substackcdn.com/image/fetch/%24s_!IiMC!,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F060913fb-0126-4321-9512-d93549329ab1_1462x814.png"><div><img src="https://substackcdn.com/image/fetch/%24s_!IiMC!,w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F060913fb-0126-4321-9512-d93549329ab1_1462x814.png" width="1456" height="811" alt=""></div>
</a></figure>
</div>
<p>VLA models work in bounded domains today, but hybrid approaches offer more robustness when scaling beyond those domains. Years ago before the seed round of SpiritAI, I have talked to the founder and CEO of SpiritAI, Han Fengtao, he mentioned SpiritAI will focus on help elder in a nearly fixed space, which makes more sense for them to embrace VLA.</p>
<p><strong>Alternative Path — Video-Driven World Models</strong></p>
<p>Some companies are pursuing predictive video-based world models that simulate physics and visual dynamics to test candidate actions before execution.</p>
<p>Pros: Better modeling of environmental dynamics, potential for more efficient skill transfer.<br>Cons: Heavy GPU demand, simulation–reality gaps, slower productization.</p>
<p>This path aligns more closely with Unitree’s stance and may offer longer- term advantages for general-purpose robots, albeit with higher upfront investment.</p>
<p><strong>Market Outlook &amp; Strategic Recommendation</strong></p>
<p>Short-Term Push: Use a VLA-first approach to land initial deployments and validate commercial value quickly. Limit scope (e.g., specific venues, controlled environments), and invest just enough to prove ROI and customer appetite.</p>
<p>Parallel Long-Term Investment: While pilots run, build hybrid infrastructure—world-model simulations, RL skill libraries, and modular controllers. Gradually shift higher-value or broad-market products onto this more scalable architecture.</p>
<p>Compute &amp; Infrastructure Planning: For VLA-first, budget for edge inference or localized server racks. For hybrid, allocate cloud/GPU clusters for simulation and model training, but expect lower per-unit costs over time.</p>
<p>Combined, this hybrid strategy provides both a short-term runway and a long-term value corridor. Personal opinion, spirit AI choose a right way at the very beginning, let's see how their AI will evolve, while Unitree has the huge education market and will soon leverage the new Video-Driven World Models developed by Companies like Google.</p>
