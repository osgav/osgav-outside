+++
author = "osgav"
comments = true
date = "2016-09-25T11:37:09Z"
draft = false
image = "images/rundeck-logo2.png"
menu = ""
share = true
slug = "rundeck-on-aws-part-i"
tags = ["rundeck", "AWS"]
title = "Rundeck on AWS Part I: CloudFormation"

+++

#### Then...

A few months ago I started playing around with [Rundeck](http://rundeck.org/) - a platform for *runbook automation, job scheduling, incident response, post-build deployment automation, environment provisioning, data processing jobs* and anything you like really it seems, according to its website.

This all sounded very interesting so I set about trying out the [vagrant image](http://rundeck.org/downloads.html) locally at first, then quickly decided I'd like to get an instance running in AWS with the [EC2 plugin](http://rundeck.org/plugins/2013/01/01/aws-ec2-nodes.html) so I could control a few nodes with it and really test it out.

So how can I get an instance running in AWS? I'd heard lots about [CloudFormation](https://aws.amazon.com/cloudformation/) at this point but hadn't delved into it before - now seemed like a good opportunity. After a few hours of reading up and fiddling around I had a working CloudFormation template that would create a Security Group and place an EC2 instance in it with the Rundeck application installed and running.

Taking the [example CloudFormation](https://aws.amazon.com/cloudformation/aws-cloudformation-templates/) for a [basic LAMP stack](https://s3-us-west-2.amazonaws.com/cloudformation-templates-us-west-2/LAMP_Single_Instance.template), I was able to make a few simple changes to have it install Rundeck instead and return the URL to access Rundeck in its Output.

I've described the changes I made to the example CloudFormation on [my project page.](/page/projects/rundeck-cloudformation.html)

You can find the Rundeck CloudFormation [in my github](https://github.com/osgav/rundeck/blob/master/rundeck_basic_cloudformation.template) if you would like to try it out.

This was great, I could now create and destroy a Rundeck stack at will for testing.

The next thing I tested was changing the Rundeck database from a local file-based one to a local MySQL database and then to an RDS instance in AWS. Then I started thinking about including RDS instance creation in the CloudFormation... unfortunately I didn't get around to putting RDS into the template, but I'm not too phased by this as I think I'm going to stick to a local MySQL database as it should be sufficient for my light usage - and I do have a [slightly messy cloudformation](https://github.com/osgav/rundeck/blob/master/rundeck_mysql_database_cloudformation.template) for configuring a MySQL database (PHP could be removed for example).

#### Now-ish

Some time later I had the urge to work on Rundeck again... *(actually back in July when I drafted this post oops!)*

So I came back to my Rundeck project. Still plenty of fun to be had here. After looking at things with fresh eyes I started investigating using Ansible with Rundeck - *I think the less CloudFormation I write the better really...*

I noticed Rundeck has an Ansible plugin and thought I'd see what Ansible had to offer in the way of plugins (or Modules it turned out) that do interesting things. I get the basics of Ansible but again hadn't delved into it before, beyond some basic tutorials, so exploring the documentation for Modules was thoroughly inspiring.

The Rundeck Ansible plugin combined with Ansible Modules looked like a very interesting path, so I have been wandering down it for a little while now...

At the moment I'm still using my Rundeck CloudFormation - with a test instance I've tried out the Ansible plugin for Rundeck, configuring a Dynamic Inventory for Ansible which is then read by Rundeck as it's "Resource Model" or Node Inventory (this seems better than the EC2 plugin) and running ad-hoc commands on selected nodes from the Rundeck UI.

However, I'm thinking about replacing the Rundeck CloudFormation with an Ansible playbook so Ansible will be doing everything! Both creating "core" resources in AWS like Rundeck with a playbook and then creating further resources from Rundeck UI again via Ansible playbooks.

More blogs on Rundeck (and Ansible) to come...
 
#### Also!

Lately I stumbled across this interesting paper (via the Rundeck website) on using Rundeck in a security environment - very interesting read, particularly section 3: [SANS Institute: Rundeck for Secure Script Executions](http://rundeck.org/news/2016/08/17/rundeck-sans-whitepaper.html)
