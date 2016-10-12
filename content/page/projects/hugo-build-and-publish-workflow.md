+++
author = "osgav"
date = "2016-06-11T20:10:08Z"
draft = false
image = "images/hugo-logo2.png"
share = true
slug = "hugo-build-and-publish-workflow"
title = "Hugo Build and Publish Workflow"

+++

[< back to projects](/page/projects.html)<br />
**`created: 11/06/2016`**<br />
**`updated: 12/06/2016`**

---

### building

To make building and previewing changes locally easier, I wrote a couple of short scripts. For context, I run the `hugo` commands inside a vagrant virtual machine (linux) and access the site using a web browser on the host machine (windows).

In the source for my hugo site, I have a `hugo` folder for these scripts. This makes running them similar to invoking the `hugo` command itself:

```
$ ls -1 osgav
archetypes
config.toml
content
data
hugo
layouts
public
static
themes

$ tree osgav/hugo/
osgav/hugo/
├── build-public
├── serve
└── serve-withdrafts

$ ./hugo/serve
$ ./hugo/build-public
```

As mentioned in [Hugo Markdown Cheatsheet](/page/hugo-markdown-cheatsheet.html), if you run `hugo server` with the parameter `--buildDrafts` then any posts or pages where `draft = true` will also be published to the blog on the local hugo server.

The `--buildDrafts` parameter is the only difference between the `serve` and `serve-withdrafts` scripts.

Both the `serve` and `build-public` scripts ignore drafts, so I can use `serve` first to preview what will be generated after I run `build-public`.

Until I take a look at live reloading, this let's me do the following to make changes and preview them - my ***build workflow:***

```
$ vi content/page/hugo-build-and-publish-workflow.md
<make edits>
$ ./hugo/serve-withdrafts
...
Press Ctrl+C to stop
<preview changes>
<ctrl+c to stop hugo server>

repeat
```
With live reload I shouldn't need to stop the server to make changes - simply saving changes <s>and refreshing the page in the browser</s> will be enough.

I use a mixture of `vi` and [Sublime](https://www.sublimetext.com/) - <s>I suspect I may use Sublime more once I configure live reload...</s> *Wrong! LiveReload is already enabled by default, but `hugo server` only seems to be able to detect changes to files made from inside my virtual machine - using Sublime on the host isn't detected, so the page is not reloaded...*

##### what's in the scripts?

**`./hugo/serve`**<br />
The `serve` scripts also use the `hugo server` parameters `--port` `--bind` & `--baseURL` which let me correctly serve the site from my vagrant virtual machine and make it accessible to the host (`1313` is actually the default port, `192.168.56.2` is required or else its only accessible inside the virtual machine - this is the virtual machine's IP on a Host-only Network that the host is also connected to. `http://192.168.56.2:1313/` overrides the value specified in `config.toml` that contains the site's public domain).

```
#!/bin/bash
hugo server --theme=casper \
--port=1313 \
--bind=192.168.56.2 \
--baseURL="http://192.168.56.2:1313/"
```

**`./hugo/serve-withdrafts`**<br />
The only difference is `--buildDrafts \`

```
...
hugo server --theme=casper \
--buildDrafts \
--port=1313 \
...
```

**`./hugo/build-public`**<br />
The `build-public` script also adds a `CNAME` file to the root of the output directory `public`. This file contains `osgav.run` which enables GitHub Pages to serve from a custom domain once its being served from the correct place in GitHub.

```
#!/bin/bash
hugo --theme=casper

# add CNAME file to public
touch public/CNAME
echo "osgav.run" > public/CNAME
```

---

### publishing

<s>I haven't scripted the publishing steps yet - need to rename some things for better structuring - *like cleanly deploying another hugo site in another repo's `gh-pages` branch or simply not messing up this site...*</s>

So my ***build workflow*** has advanced a little since the beginning of this tale and some renaming has taken place as I hinted at above. With LiveReload now working (just a hitch with how I was editing my files) and another couple of scripts (one that swallows up `build-public`) the ***build and publish workflow*** looks something like this:

- Creating new content or editing drafts -->

```
$ cd osgav-source
$ ./hugo/01-serve-withdrafts
```
```
<open another terminal>
$ vagrant ssh
$ cd /vagrant/workbench/osgav-source
$ hugo -t casper new post/next-new-post.md
$ vi content/post/next-new-post.md
<update content and save>
```
With the `vi` terminal on one side of the screen and a web browser on the other, I can see the changes immediately after `:w` in `vi`. Really awesome!

And to publish that new content live, we follow the same workflow as below... if I run `02-serve` I will no longer see my [cheatsheet](/page/projects/hugo-markdown-cheatsheet.html), but if I notice the latest post isn't there I can use the `hugo undraft` command and it'll appear immediately.


- Simple update to live page like updating an image or a typo -->

```
<edit image accordingly and save it>
```
```
<if image filename has changed, update posts/pages referencing filename>
<update posts/pages with typo>
```
```
$ ./hugo/02-serve # to preview locally if necessary (unlikey for typo)
$ ./hugo/03-publish-stage
$ ./hugo/04-publish-prod "update typo in recent post"
```
##### what's in the scripts now?

```
$ tree hugo
hugo
├── 01-serve-withdrafts
├── 02-serve
├── 03-publish-stage
└── 04-publish-prod
```

**`./hugo/03-publish-stage`**<br />
So where did the `build-public` script go? It's purpose, described above, is in fact the first step towards publishing. You can test all of the site completely locally with `hugo server` without having to build the `public` directory. As such it made sense to include its commands in a more complete script: `03-publish-stage`

```
#!/bin/bash

# delete old 'public' build
rm -rf public/

echo -e "\n--------------------------------------------------\n"
echo -e "building hugo site --> public\n"

hugo --theme=casper

echo -e "\n--------------------------------------------------\n"
echo "adding CNAME for osgav.run"
touch public/CNAME
echo "osgav.run" > public/CNAME

echo -e "copying hugo site public --> osgav-root-public\n"
rm -rf ../osgav-root-public/*
cp -r public/* ../osgav-root-public/

echo -e "\n--------------------------------------------------\n"
echo -e "$ git status osgav-root-public\n"

cd ../osgav-root-public
git status

echo -e "\n--------------------------------------------------\n"
```

**`./hugo/04-publish-prod "commit message!"`**<br />
The `04-publish-prod` script is the only one that takes an argument - the commit message to be used for the `git commit` command. It also shows you the same `git status` output as `03-publish-stage` so you have another chance to sanity check what you're pushing before you publish.

```
#!/bin/bash

function pause(){
        read -sp "$*"
}

echo -e "\n---------------------------------------------\n"
echo "$ git status osgav-root-public"
echo -e "\n---------------------------------------------\n"

cd ../osgav-root-public
git status

echo -e "\n---------------------------------------------\n"
echo "Hit [Enter] to continue with:"
echo "$ git add --all"
echo "$ git commit -am \"$1\""
echo "$ git push origin master"
echo ""
pause "Are you sure?"
echo -e "\n\n---------------------------------------------\n"

git add --all
git commit -am "$1"
git push origin master

echo -e "\n---------------------------------------------\n"
echo "updated published! https://osgav.run"
echo -e "\n---------------------------------------------\n"
```

As you can see I've also numbered the scripts so it is obvious which order they should be getting used in. I still have some steps to add here - don't want `osgav-source` to get out of sync. Currently I've been catching it up manually meaning more than 1 commit to the site could be reverted if I checkout the previous version of the source. Not so great! 


---

[< back to projects](/page/projects.html)


