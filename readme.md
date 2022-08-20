What?
-----
Simple repository that uses Terraform to instantiate a Pavlov Shack server running on an AWS EC2 server.  Based on the information here: http://wiki.pavlov-vr.com/index.php?title=Dedicated_server

Why?
----
It was getting hard to find an Asia Pacific server? Yeah, by default this will create an EC2 instance in `ap-southeast-2`.  You can always change this if you want.

How?
----

You need to have both `docker` and `make` installed.  Thats it.  Terraform is run from a container to make it easy. 😄

Firstly, what are the important files:

1. `.secrets.env` - This file is used to store secrets.  A template will be generated on first run, so you can then just fill in the details.
2. `environment.tfvars` - This file can be used to modify various aspects of the server.  See the file `variables.tf` to see what can be modified.  This file will be generated for you on first run.
3. `userdata.tmpl` - This is the file that controls how Pavlov is installed, and the general server configuration.  Things like map rotations and passcode for the server are all controlled from here.  Modify at will.


Ok, so how do you make this thing work?

1. You need to have an AWS account.  You will then need to provide authentication details (either via a .aws directory or via populating both `AWS_SECRET_ACCESS_KEY` and `AWS_ACCESS_KEY_ID` in the `.secrets.env` file)
2. Run `make init`.  This will get Terraform ready.
3. Run `make plan`.  This will figure out what needs to be done.  Note that I place the server in its own VPC, with minimal infrastructure.  This is in an attempt to avoid polluting any existing infrastructure.
4. Run `make apply`.  This will create all the infrastructure and start the server.  This can take a few minutes as the binary is about a 3Gb download.  Once it has started, you should see your server name appear in the Pavlov Shack server list.  If you do not, you can jump on to the AWS Console and use an SSM connection to connect directly to the server console, or alternatively run `make output` to get the private key details to ssh directly to the server.
5. When you are done, run `make destroy` to destroy all the infrastructure.  If you leave this running it WILL COST YOU MONEY!

Caveats?
--------

Sure.  Heaps.

1. Secure?  Probably not, but low surface area.  By default it will create a VPC, subnet, internet gateway, route table, security group, a few IAM policies and an EC2 instance.  The security group only allows what is necessary for Pavlov and SSH.  But who knows....
2. Consistently updated?  No.  This was a quick spin up for my own uses.  I expect to spin it up and shut it down when I want to play, so no capabilities are implemented for it to update itself.
3. Bugs?  Probably. 🤷 If you find one, let me know.