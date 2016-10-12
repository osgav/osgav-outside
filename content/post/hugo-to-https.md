+++
author = "osgav"
comments = true
date = "2016-06-12T11:33:49Z"
draft = false
image = "images/hugo-logo2.png"
share = true
slug = "hugo-to-https"
tags = ["hugo"]
title = "hugo --> https://osgav.run"

+++

I stumbled across the Hugo static site generator recently and after reading a little and watching a [short video](https://gohugo.io/overview/quickstart/) (01:08) I thought it looked pretty interesting and worth trying out. It's a fairly light blogging platform which can be used with GitHub Pages, which can then be topped with another service to provide SSL via a Let's Encrypt certificate.

I'm still not 100% sure about the service hooking me up with the Let's Encrypt SSL at the moment - we'll see how it goes. Otherwise it looks like Hugo & GitHub Pages will provide a smooth experience for maintaining a blog of posts and pages.

The main steps I went through after clicking some link about *hugo*...

- discovered [Hugo](https://gohugo.io/)
- tested blog locally with `hugo server`
- found really awesome responsive [theme](https://github.com/vjeantet/hugo-theme-casper)
- wrote initial content
- uploaded to GitHub Pages **`https://osgav.github.io`**
- purchased domain **`osgav.run`**
- configured [osgav.github.io](https://github.com/osgav/osgav.github.io) repo with [CNAME](https://github.com/osgav/osgav.github.io/blob/master/CNAME) file
- registered for Kloudsec CDN service to provide Let's Encrypt SSL
- configured Kloudsec website to point at GitHub Pages site
- configured `NS` records with domain provider (provider's nameservers)
- configured `A` records with domain provider (Kloudsec's IPs)
- updated Hugo site configuration to use **`https://osgav.run`** domain name

I didn't necessarily perform these in that exact order towards the end (and I'm not entirely certain that would be an optimum order) so consequently I did have a little bit of downtime between switching my site from osgav.github.io to osgav.run but I believe it was due to the new DNS not being fully live yet - so not the kind of downtime Kloudsec's documentation advises they mitigate against.


> wrote initial content

...actually consisted of thoroughly digging through the project files and getting a grasp of its structure, setting up the menu and theming and looking at changes I'd like to make that aren't so simple. While doing this I also started writing a few short scripts and created a cheatsheet to help make writing and publishing blog posts easier.

I still have plenty to learn about Hugo so I will no doubt revisit these in future, but I've written a bit about the build process (yet to automate publishing) and the cheatsheet I've started here:

[Hugo Build and Publish Workflow](/page/projects/hugo-build-and-publish-workflow.html) (in progress)<br />
[Hugo Markdown Cheatsheet](/page/projects/hugo-markdown-cheatsheet.html)

GitHub has a lot of relevant help pages for setting up a GitHub Pages site and configuring a custom domain. I read through many of them, which I've listed below - if you're thinking about setting up GitHub Pages with a custom domain and powering it with Hugo, hopefully some of the hints I've mentioned will be useful alongside the GitHub documentation and other material you read... 

https://gohugo.io/tutorials/github-pages-blog/<br />
https://help.github.com/articles/quick-start-setting-up-a-custom-domain/<br />
https://help.github.com/articles/setting-up-your-pages-site-repository/<br />
https://help.github.com/articles/setting-up-an-apex-domain-and-www-subdomain/<br />
https://help.github.com/articles/about-supported-custom-domains/#apex-domains<br />
https://help.github.com/articles/using-a-custom-domain-with-github-pages/<br />
https://help.github.com/articles/about-supported-custom-domains/<br />
https://help.github.com/articles/setting-up-an-apex-domain/<br />
https://help.github.com/articles/user-organization-and-project-pages/<br />
https://help.github.com/articles/creating-project-pages-manually/<br />
https://help.github.com/articles/securing-your-github-pages-site-with-https/<br />

The extra layer - Kloudsec - providing the Let's Encrypt SSL is necessary because GitHub Pages do not currently support SSL on custom domains.

You can have SSL on a \*.github.io domain or plain HTTP on a custom domain.

While reading into this I gathered CloudFlare is a popular solution but people do have some concerns over certain configuration options - by using Kloudsec I am by no means using the most optimally configurable and secure solution but it is *very easy* to get SSL enabled for the visitor --> Kloudsec edge portion of the journey.

I haven't dug particularly deep into this but it may be possible for CloudFlare to serve out a HTTPS custom domain from the edge and communicate with a HTTPS GitHub Pages origin (where you haven't configured a custom domain so are still on HTTPS \*.github.io) - so for those who want a particularly secure static blog that may be the thing to do...

> Also while reading into all of this, I stumbled across a colleague's personal blog that amusingly has the same theme (the original) for another blogging platform - Ghost. And is hosted in an entirely different way, but produces a very similar output :) https://iainjp.com/ - [From Jekyll to Ghost](https://iainjp.com/from-jekyll-to-ghost/)
