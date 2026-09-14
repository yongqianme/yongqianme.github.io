---
layout: single
title: "写作"
permalink: /zh/writing/
author_profile: true
lang: zh
translation:
  en_url: /categories/
---

这里整理了 Yong 关于机器人、Physical AI、创业和 AI 产品的中文文章，并自动同步微信公众号 `yongqian_insight` 的公开内容。

{% include base_path %}

{% assign zh_posts = site.posts | where: "lang", "zh" | sort: "date" | reverse %}

{% if zh_posts.size > 0 %}
  {% for post in zh_posts %}
    {% include archive-single.html show_image=true %}
  {% endfor %}
{% else %}
暂时还没有同步的中文文章。
{% endif %}

[查看英文文章分类](/categories/){: .btn}
[出版与演讲](/zh/publications/){: .btn}
