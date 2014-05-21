HipstaDeploy
=========

A bash script for deploying *static sites* on **[Amazon Cloudfront][1]**.

![Imgur](http://i.imgur.com/vSmiPIj.gif?1)


Requisites
-------

Right now **HipstaDeploy** expects you to have installed [s3_website][2]:

```ruby
gem install s3_website
```

Installation
---------

Just run this command if you wanna do a *quick* **Hipstallation**:

```bash
curl -s https://gist.githubusercontent.com/proudlygeek/9551019ff48053ae5bf3/raw/install.sh | sh
```

This will *download* the bash into */usr/local/bin*, so check if is in your env **PATH** var.

Usage
----

You need to enter

[1]:aws.amazon.com/cloudfront/
[2]:https://github.com/laurilehmijoki/s3_website
