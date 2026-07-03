---
title: Why So Many Embodied AI Startups Start with RealSense Cameras ?
date: '2026-06-22'
permalink: "/posts/2026/06/why-so-many-embodied-ai-startups/"
categories:
- Writing
tags:
- physical AI
- Product Manager
- startups
substack_id: 203021708
substack_slug: why-so-many-embodied-ai-startups
substack_url: https://yongqianme.substack.com/p/why-so-many-embodied-ai-startups
excerpt: If π0.5 (Physical Intelligence) can learn from videos as small as 240×320,
  why do so many embodied AI startups begin with RealSense cameras instead of using
  a cheap webcam or building their own camera solution?
image: https://substackcdn.com/image/fetch/$s_!KFIP!,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Ffe9d7815-2ff0-42af-9a2e-97e43138789e_1536x1024.heic
---

> Originally published on [Substack](https://yongqianme.substack.com/p/why-so-many-embodied-ai-startups).

<p>If π0.5 (Physical Intelligence) can learn from videos as small as 240×320, why do so many embodied AI startups begin with RealSense cameras instead of using a cheap webcam or building their own camera solution?</p>
<div><figure><a href="https://substackcdn.com/image/fetch/%24s_!KFIP!,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Ffe9d7815-2ff0-42af-9a2e-97e43138789e_1536x1024.heic"><div><img src="https://substackcdn.com/image/fetch/%24s_!KFIP!,w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Ffe9d7815-2ff0-42af-9a2e-97e43138789e_1536x1024.heic" width="1456" height="971" alt=""></div>
</a></figure>
</div>
<p>The more time I spend in robotics, the more I think this isn’t really a camera question.</p>
<p>It’s a startup-stage question.</p>
<p>Early-stage startups are rarely buying hardware.</p>
<p>They’re buying time.</p>
<p>A basic camera can absolutely capture video. But once you start building a robot, the camera itself is only a small part of the problem.</p>
<p>You still need drivers, calibration, synchronization, ROS integration, data pipelines, debugging tools, and long-term maintenance.</p>
<p>None of these problems are particularly difficult on their own, but together they can consume weeks or months of engineering effort.</p>
<p>For a startup trying to validate a product, a few months of engineering time are usually far more expensive than a few hundred dollars of hardware.</p>
<p>That’s why RealSense became so common.</p>
<p>You plug it in and immediately get RGB images, depth information, calibration tools, SDK support, and a huge community that has already solved many of the problems you’re about to encounter.</p>
<p>Instead of becoming camera experts, teams can focus on collecting data, training models, and understanding customer needs.</p>
<p>What’s interesting is that recent progress in imitation learning and VLA models has also shown that many robotics tasks don’t require the visual quality people once assumed.</p>
<p>For tasks like grasping objects, opening drawers, organizing items, or basic manipulation, stable data often matters more than ultra-high-resolution images.</p>
<p>In that sense, RealSense is often a very reasonable choice for the validation stage.</p>
<p>But that doesn’t mean it should stay forever.</p>
<p>One mistake I occasionally see is treating a development tool as a product component.</p>
<p>When a company begins productization, the conversation changes completely.</p>
<p>The question is no longer:</p>
<p>“Can this work?”</p>
<p>The questions become:</p>
<p>* Can we manufacture it at scale?</p>
<p>* Is the supply chain reliable?</p>
<p>* Is the power consumption acceptable?</p>
<p>* Does it fit the industrial design?</p>
<p>* Is the cost appropriate for our target market?</p>
<p>* Can it be serviced and maintained efficiently?</p>
<p>These are product questions, not research questions.</p>
<p>At that point, the vision system should be re-evaluated from the ground up.</p>
<p>The best camera for development is not necessarily the best camera for production.</p>
<p>Some products may only need low-cost RGB cameras. Others may require custom stereo systems. Some may use multiple cameras distributed across the robot. The right answer depends entirely on the product and its use case.</p>
<p>Personally, I think the transition should happen much earlier than many teams expect.</p>
<p>Not at the thousandth robot.</p>
<p>Not after mass production starts.</p>
<p>The moment a company commits to a product direction and enters productization, it should begin designing the vision system around manufacturing, cost, power consumption, industrial design, and supply-chain realities.</p>
<p>RealSense is an excellent development tool.</p>
<p>A product, however, should be designed for customers, manufacturing, and scale.</p>
<p>Those are very different goals.</p>
<p>In robotics startups, it’s easy to optimize too early for hardware cost and miss the bigger picture.</p>
<p>The real objective in the beginning is not building the perfect camera system.</p>
<p>It’s finding something customers actually want.</p>
<p>Once you’ve found that, then it’s time to build the camera system your product truly needs.</p>
