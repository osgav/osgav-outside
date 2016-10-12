+++
author = "osgav"
comments = false
date = "2016-06-11T16:40:05Z"
draft = false
image = "images/hugo-logo2.png"
share = true
slug = "hugo-markdown-cheatsheet"
title = "Hugo Markdown Cheatsheet"

+++

[< back to projects](/page/projects.html)<br />
**`created: 11/06/2016`**<br />
**`updated: 12/06/2016`**

---

**TL;DR** there is a cheatsheet for Hugo Markdown available [in my github](https://raw.githubusercontent.com/osgav/osgav-source/master/content/post/cheatsheet.md), transcribed from [a guide here](https://sourceforge.net/p/hugo-generator/wiki/markdown_syntax/) (not all of it mind) and a couple of bits from [gohugo docs](https://gohugo.io/overview/introduction/).

You can make this particularly handy by keeping a `cheatsheet.md` post like this:

```
$ tree osgav/content
osgav/content
├── page
│   ├── hugo-markdown-cheatsheet.md 
│   └── projects.md
└── post
    ├── cheatsheet.md 
    ├── whois-osgav.md
    └── zerodots.md
```

Keep a copy of `cheatsheet.md` as a draft post, with a date in the future - this will make it the most recent post in your blog, so it will be the first post you see when testing locally with `hugo server` (and passing in the `--buildDrafts` parameter).

```
$ head content/post/cheatsheet.md
+++
author = "osgav"
date = "2070-01-01T00:00:00Z"
draft = true
slug = "cheatsheet"
tags = ["formatting-cheatsheet-dont-undraft"]
title = "cheatsheet"

+++
```
![hugo cheatsheet draft](/images/hugo_cheatsheet_draft.png)
![hugo cheatsheet](/images/hugo_cheatsheet.png)

---

[< back to projects](/page/projects.html)

