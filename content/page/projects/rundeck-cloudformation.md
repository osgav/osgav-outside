+++
author = "osgav"
date = "2016-09-25T11:37:09Z"
draft = false
image = "images/rundeck-logo2.png"
share = true
slug = "rundeck-cloudformation"
title = "Rundeck CloudFormation"

+++

[< back to projects](/page/projects.html)<br />
**`created: 25/09/2016`**

---

A basic CloudFormation template for spinning up an EC2 instance and installing Rundeck on it - [link](https://github.com/osgav/rundeck/blob/master/rundeck_basic_cloudformation.template) 

This CloudFormation template simply installs Rundeck as per the instructions from their website. No further configuration is applied. You will end up with a basic Rundeck installation which you can log into with default credentials.

Only a handful of changes were made to the AWS CloudFormation template for a [basic LAMP stack](https://s3-us-west-2.amazonaws.com/cloudformation-templates-us-west-2/LAMP_Single_Instance.template) - they are as follows:

```
> Update the CloudFormation::Init Install section to look like this: 
> (line numbers 100-106)

          "Install" : {
            "packages" : {
              "yum" : {
                "rundeck"         : [],
                "rundeck-config"  : []
              }
            },

```

```
> Update the CloudFormation::Init Configure section to run 1 command to update Rundeck configuration with hostname:
> (line numbers 142-149) 

          "Configure" : {
            "commands" : {
              "01_update_rundeck_hostname" : {
                "command" : "update=`curl -s http://instance-data/latest/meta-data/public-hostname`; sed -i s/localhost/$update/g rundeck-config.properties",
                "cwd" : "/etc/rundeck/"
              }
            }
          }

```

```
> Update the UserData section to add Rundeck repository before Install section is run:
> (line numbers 160-182)

        "UserData"       : { "Fn::Base64" : { "Fn::Join" : ["", [
             "#!/bin/bash -xe\n",
             "yum update -y aws-cfn-bootstrap\n",

             "# Install Rundeck repo and package signing key\n",
             "# before cfn-init installs and configures Rundeck\n",
             "rpm -Uvh http://repo.rundeck.org/latest.rpm\n",
             "curl -o ./rundeck.key http://rundeck.org/keys/BUILD-GPG-KEY-Rundeck.org.key\n",
             "rpm --import ./rundeck.key\n",

             "# Install the files and packages from the metadata\n",
             "/opt/aws/bin/cfn-init -v ",
             "         --stack ", { "Ref" : "AWS::StackName" },
             "         --resource WebServerInstance ",
             "         --configsets InstallAndRun ",
             "         --region ", { "Ref" : "AWS::Region" }, "\n",
            "# Signal the status from cfn-init\n",
             "/opt/aws/bin/cfn-signal -e $? ",
             "         --stack ", { "Ref" : "AWS::StackName" },
             "         --resource WebServerInstance ",
             "         --region ", { "Ref" : "AWS::Region" }, "\n"
        ]]}}
      },
```

```
> Update the Security Group to allow tcp/4440 for Rundeck:
> (line numbers 189-199)

    "WebServerSecurityGroup" : {
      "Type" : "AWS::EC2::SecurityGroup",
      "Properties" : {
        "GroupDescription" : "Enable HTTP access via port 4440",
        "SecurityGroupIngress" : [
          {"IpProtocol" : "tcp", "FromPort" : "4440", "ToPort" : "4440", "CidrIp" : "0.0.0.0/0"},
          {"IpProtocol" : "tcp", "FromPort" : "22", "ToPort" : "22", "CidrIp" : { "Ref" : "SSHLocation"}}
        ]
      }
    }
  },
```

```
> Update CloudFormation Outputs section to provide a link to Rundeck instance:
> (line numbers 201-207)

  "Outputs" : {
    "RundeckURL" : {
      "Description" : "URL for newly created Rundeck instance",
      "Value" : { "Fn::Join" : ["", ["http://", { "Fn::GetAtt" : [ "WebServerInstance", "PublicDnsName" ]}, ":4440"]] }
    }
  }
}
```





