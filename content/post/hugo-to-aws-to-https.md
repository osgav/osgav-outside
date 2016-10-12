+++
author = "osgav"
comments = true
date = "2016-10-01T14:56:12Z"
draft = false
image = "images/posts/hugo-to-aws-to-https/aws.jpg"
share = true
slug = "hugo-to-aws-to-https"
tags = ["hugo", "AWS"]
title = "hugo --> AWS --> https://osgav.run"

+++

> Why migrate to AWS?<br />
> Hugo --> S3<br />
> S3 --> CloudFront (+ ACM)<br />
> Route53<br />
> HTTP 403<br />
> HTTP 403 (moar)<br />
> www.osgav.run<br />
> References<br />


#### Why migrate to AWS?


As well as [catching up](/post/rundeck-on-aws-part-i.html) on drafted blog posts last weekend, I migrated this blog from GitHub Pages, KloudSec, Domain Registrar's DNS & Let's Encrypt to Amazon Web Services: S3, CloudFront, Route53 & Certificate Manager. I also introduced Travis CI and continued using GitHub for version control (but no longer hosting). This migration to AWS was in light of one of my apprehensions about KloudSec unfortunately materializing - it was a fairly small and new company and has recently ceased to exist. As such my Let's Encrypt certificate had expired and was no longer auto-renewed by KloudSec so my blog was showing a HTTPS error when you visited it - boo. Time to pay for a risky design choice...

<a href="/images/posts/hugo-to-aws-to-https/ssl_expired.png"><img src="/images/posts/hugo-to-aws-to-https/ssl_expired.png" /></a>

So here goes a ***how I set up this blog*** take II:

I immediately decided AWS is where I shall move to, but what is the best way to go about it? Initially I was thinking about EC2 & NGINX and perhaps having Rundeck involved in the build process but this quickly started sounding very convoluted for a simple static website and realised I have a much simpler option - no EC2 nodes, put the files in S3 and switch on the website hosting feature and fix up CloudFront & Route53 so the `osgav.run` domain serves my S3 bucket globally from CloudFront CDN - easy peasy wahey. And make sure SSL is in there somewhere as well...


#### Hugo --> S3

So the next part was researching how to build my hugo site and then sync the `public` directory to S3. I found various interesting articles about different ways to do this - some of the stuff I read is listed at the end.

After plenty of surfing I decided to go with <a href="https://travis-ci.org">Travis CI</a> - this appeared to steer towards a very simple setup by taking care of both the hugo build stage and copying the site to S3. So I started aiming for a pipeline like:

```
Hugo --> GitHub --> Travis CI --> S3
```

**Hugo**<br />
- draft and test site locally with `hugo server` as before<br />*(using my <a href="https://github.com/osgav/osgav-blog/tree/master/hugo">hugo scripts</a> 01 + 02 - no changes)*<br />

**GitHub**<br />
- commit hugo site source to repository in GitHub - just the source, no `public` directory containing a build of the site.<br />*(using my hugo scripts 03 + 04 - simplified, only 1 repo involved, no CNAME file required)*<br />
- Also contains a `.travis.yml` file to link to the next stage...<br />

**Travis CI**<br />
- on push events to master Travis CI reads `.travis.yml` build file<br />
- installs a `go` environment<br />
- installs `hugo`<br />
- runs `hugo` build command against source in `osgav-blog` repo<br />
- copies build output directory `public` to S3<br />

<a href="https://github.com/osgav/osgav-blog/blob/master/.travis.yml">my `.travis.yml`</a> looks like this:

```
language: go
go:
- 1.4
install:
- go get github.com/spf13/hugo
script: hugo -t casper
deploy:
  provider: s3
  access_key_id: $AWS_ACCESS_KEY
  secret_access_key: $AWS_SECRET_KEY
  bucket: osgav.run
  region: eu-central-1
  endpoint: osgav.run.s3-website.eu-central-1.amazonaws.com
  local-dir: public
  skip_cleanup: true
  acl: public_read
  on:
    repo: osgav/osgav-blog
```

*Travis knows AWS secrets that provide access to S3 - `$AWS_ACCESS_KEY` & `$AWS_SECRET_KEY` are entered in Travis CI web interface repository settings, but there are other methods. For example you can use Travis CI encrypted values which would let you encrypt any values e.g. if you wanted to hide the bucket name/endpoint. Although that wouldn't stop somebody figuring out the endpoint URL and accessing your S3 origin directly, if you have not locked it down properly. (Route53 DNS entries need to match bucket names, so take the domain name and append different AWS `.s3-website.` region URLs until you potentially find an insecure origin...)*


**S3**<br />
- files are overwritten on every build from Travis CI<br />
- `acl` statement in `.travis.yml` sets permissions to `public_read`<br />*(defaults will return HTTP 403 because the files are private - merely the first 403s encountered)*<br />
- hugo site is now available at a HTTP `*.s3-website.*.amazonaws.com` URL<br />
- how can we turn this into `https://osgav.run` ?<br />


#### S3 --> CloudFront (+ ACM)

Got basic CloudFront distribution configuration hints from a blog post referenced later. Then I read up on Amazon Certificate Manager on the AWS blog and was quickly convinced this would make life very simple, so I opted to use this instead of Let's Encrypt.<br />
<br />
- Created CloudFront distribution with `osgav.run` S3 bucket as the origin<br />
- Created new SSL certificate in ACM (needs to be configured while in specific US region)<br />
- Verified ownership of the domain (click a link in an email)<br />
- Enabled SSL on the CloudFront distribution by selecting newly created certificate<br />
- 1 CloudFront distribution deploy later HTTPS was enabled<br />
- Now site can be accessed at `https://cxbdbfjblaahblah.cloudfront.net` - still not `https://osgav.run`...<br />

#### Route53

Followed AWS Route53 DNS Migration docs for this portion - quite straight forward no hiccups so far (however, yet to configure `www` redirect...)<br />
<br />
- Created a hosted zone for `osgav.run`<br />
- Created `A` records type `Alias` to point `osgav.run` at CloudFront distribution URL<br />
- Changed nameservers from DNS registrar's to AWS Route53 nameservers<br />
- Waited a little while<br />

Once the DNS update had taken effect my site was now available at: `https://osgav.run`. It was now serving from AWS, using Route53 DNS to direct requests to the CloudFront CDN with S3 as its origin. Wahey!

As expected, CloudFront is much faster than my previous hosting (actually via KloudSec POPs rather than GitHub Pages CDN).

<a href="/images/posts/hugo-to-aws-to-https/before-after.png"><img src="/images/posts/hugo-to-aws-to-https/before-after.png" /></a>

So all is well? AWS is wonderful and great? Naturally there are some glitches to solve...

#### HTTP 403

After overcoming the initial HTTP 403 issue because all the S3 files were private, while smoothing the operation of Travis CI I noticed a problem with trying to visit any page beyond the main index (I had lazily just been testing the front page most of the time) - posts and project pages would try to load with a URL like `/post/rundeck-in-aws-part-i/` and it would return a HTTP 403 error - what's going on there? 

Hugo relies on a slightly more "standard behaviour" of URLs for subdirectories by expecting a default `index.html` file to be present in that subdirectory to be served when the "subdirectory URL" is accessed (e.g. `/post/rundeck-in-aws-part-i/` expects to find `/post/rundeck-in-aws-part-i/index.html` and load that page, without redirecting and explicitly including `index.html` in the address bar). While there is no problem serving a hugo website (with this default behaviour) straight out of an S3 bucket website, when you introduce CloudFront there is a problem. Due to CloudFront's handling of "[default root objects](http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/DefaultRootObject.html)" the normal way hugo builds URLs in it's sites is not compatible.

To fix this I needed to make an edit to my hugo site `config.toml` file to include `uglyurls = true` - this means URLs are now like `/post/rundeck-on-aws-part-i.html`. Essentially instead of changing the end of the URL from `/` or `/index.html` to `.html` - which means the page structure now matches the source markdown file structure, but just switching `.md` for `.html`...

#### HTTP 403 (moar)

Round III of HTTP 403 errors. So I thought everything was fine after setting `uglyurls = true` - but that was not the case. I didn't notice that the tag pages (links at the bottom of post summaries on my blog feed and top of posts, like #hugo and #AWS for this post) were still broken.

Once I noticed I googled the issue and quickly found a couple of relevant GitHub issues. One of them hinted at some edits that could be made to template files to "fix" the problem (you need to undo those changes if you set `uglyurls = false` again). 

A minor update to a handful of template files in the `theme` directory of my hugo site source fixed this issue. TTR for this bug ~40mins... just a little better than ~3wks for my SSL issue!

GitHub issues:<br />
- https://github.com/spf13/hugo/issues/1989<br />
- https://github.com/digitalcraftsman/hugo-icarus-theme/issues/41<br />


#### www.osgav.run

<s>This is currently broken - `https://www.osgav.run` - I need to fix it so this redirects to: `https://osgav.run`</s>

<s>It may involve something along the lines of setting up a `www.osgav.run` S3 bucket with a redirect on it - we shall see, I will update the post when I've configured it.</s>

If you take the time to type `www.osgav.run` or even `https://www.osgav.run` into your browser address bar you will now get redirected to the apex domain, dropping the `www` portion.

This was fairly straightforward to set up, along the lines of what I was thinking.

Firstly to enable for just HTTP was only 3 steps - create new `www.osgav.run` S3 bucket, configure for static web hosting and set option to redirect to `osgav.run` S3 bucket, and then create a Route53 entry to point `www.osgav.run` at the S3 bucket with that name.

But that didn't redirect you if you entered `https://www.osgav.run`. To fix that I needed to create a new CloudFront distribution, configured very similarly to the original one but with the origin set to the new `www` S3 bucket. I applied my wildcard SSL certificate `*.osgav.run` to this distribution to provide SSL - also there is a particular thing to note when adding the S3 origin here: you need to use the endpoint for the S3 website rather than the plain S3 reference that appears in the autosuggest dropdown when entering the origin. You can get that URL from the bucket properties in the S3 area of the console.

After a deployment of the CloudFront distribution, now both `www.osgav.run` and `https://www.osgav.run` redirect to the apex domain - wahey!



#### References

> **CloudFront configuration hints**<br />
> - https://nparry.com/2015/11/14/letsencrypt-cloudfront-s3.html<br />


> **cool Lambda idea**<br />
> - http://bezdelev.com/post/hugo-aws-lambda-static-website/<br />


> **AWS CLI**<br />
> - https://lustforge.com/2016/02/27/hosting-hugo-on-aws/<br />
> - https://lustforge.com/2016/02/28/deploy-hugo-files-to-s3/<br />

> **Wercker**<br />
> - http://atchai.com/blog/the-cms-is-dead-long-live-hugo-wercker-proseio-and-cloudfront<br />
> - https://gohugo.io/tutorials/automated-deployments<br />

> **Travis CI**<br />
> - http://www.gregreda.com/2015/03/26/static-site-deployments<br />
> - http://evanbrown.io/post/hugo-on-the-go/<br />
> - https://hagbarddenstore.se/posts/2016-02-24/continuously-deploy-hugo-sites/<br />
> - https://docs.travis-ci.com/user/deployment/s3<br />
> - https://docs.travis-ci.com/user/encryption-keys/<br />

> **Route53**<br/>
> - http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/MigratingDNS.html<br />

> **Amazon Certificate Manager**<br />
> - https://aws.amazon.com/blogs/aws/new-aws-certificate-manager-deploy-ssltls-based-apps-on-aws/<br />

> **more CloudFront hints (subdirectory default index.html problems)**<br />
> - http://blog.aws.andyfase.com/s3-backed-static-blog/index.html<br />
> - http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/DefaultRootObject.html<br />
> - https://gohugo.io/extras/urls/<br />






