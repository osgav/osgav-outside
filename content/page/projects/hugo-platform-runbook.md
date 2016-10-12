+++
author = "osgav"
date = "2016-06-12T21:33:09Z"
draft = false
image = "images/hugo-logo2.png"
share = true
slug = "hugo-platform-runbook"
title = "Hugo Platform Runbook"

+++

[< back to projects](/page/projects.html)<br />
**`created: 12/06/2016`**

---

This is my runbook for operating my blog, based on the scripts I wrote to help with hugo building and publishing, you can read about these here:

[Hugo Build and Publish Workflow](/page/projects/hugo-build-and-publish-workflow.html)<br />
[Hugo Markdown Cheatsheet](/page/projects/hugo-markdown-cheatsheet.html)

> download source and website --><br />

```
> HTTPS authentication until I set up SSH authentication
> Run from vagrant virtual machine at /vagrant/workbench
$ git clone https://osgav@github.com/osgav/osgav-source.git osgav-source
$ git clone https://osgav@github.com/osgav/osgav.github.io.git osgav-root-public
```

> view cheatsheet --><br />

```
$ cd osgav-source
$ ./hugo/01-serve-withdrafts
> view blog in browser at http://192.168.56.2:1313 - cheatsheet is latest post
```

> create new content and iterate on it --><br />

```
$ cd osgav-source
$ ./hugo/01-serve-withdrafts
```
```
> open another terminal
$ vagrant ssh
$ cd /vagrant/workbench/osgav-source
$ hugo -t casper new post/next-new-post.md
$ vi content/post/next-new-post.md
> update content and save
> view blog in browser
> update content and save
> view blog in browser...
```
> publish content --><br />

```
$ ./hugo/02-serve
> preview content locally
> if your post/page is missing, then try
$ hugo undraft post/next-new-post.md
$ ./hugo/03-publish-stage
$ ./hugo/04-publish-prod "posting next new post!"
```

> unpublish content --><br />

```
> same as publishing content
> but set draft = true in post/page front matter
> then publish again
```

> update existing content (typo, update image) --><br />

```
> edit image accordingly and save it
```
```
> if image filename has changed, update posts/pages referencing filename
> update posts/pages with typo
```
```
$ ./hugo/02-serve
> preview content locally if necessary - unlikely for typo
$ ./hugo/03-publish-stage
$ ./hugo/04-publish-prod "update typo in last post"
```



