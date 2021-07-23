---
title: "How to Actually Set Up Comments for BeautifulHugo template with Disqus"
date: 2021-07-23T16:51:36+01:00
tags: ["hugo", "disqus"]
---

Setting up Disqus comments with the `beautifulhugo` theme took a bit of digging that didn't seem to be documented elsewhere.

<!--more-->

According to the [Hugo documentation regarding comments](https://gohugo.io/content-management/comments/)

> Hugo ships with support for Disqus

Setting up Disqus comments should be as simple as setting your Disqus short name in your site config (at the top level).

```yaml
disqusShortname: YOUR_SITE_NAME_FROM_DISQUS
```

However this setting alone isn't enough to render the Disqus functionality. You also need comments turned on in your config params.

```yaml
params:
  comments: true
```

The comments being set to true is not mentioned by the documentation but the first condition in the `beautifulhugo` disqus template checks for this field to be a non-null value.

```
{{ if (.Params.comments) | or (and (or (not (isset .Params "comments")) (eq .Params.comments nil)) (.Site.Params.comments)) }}
```

Note: Disqus short name is the Website Name you set when creating the site under your Disqus account.

![Disqus Shortname](/img/assets/disqus-shortname.png)
