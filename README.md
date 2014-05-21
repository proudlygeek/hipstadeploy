HipstaDeploy
=========

A bash script for *generating* and *deploying* **static websites** on **[Amazon Cloudfront][1]**.

![Imgur](http://i.imgur.com/vSmiPIj.gif?1)

Why this stuff?
-----------

Deploying a static website (*blogs* are probably the best suited) on a **CDN** will give you **tremendous amounts of speed** from **all around the world** compared to a *dynamic* host for a relatively *cheap* price.

You can use **HipstaDeploy** with any kind of local blog installation like [Ghost][3], [Wordpress][4] or [Jekyll][5].

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

This will *download* the bash script into */usr/local/bin*, so check if is in your env **PATH** var.

You can check your installation by typing:

```bash
hipdep -h
```

If you prefer the *Good Old Ways* you can just clone this repository and run:

```bash
./deploy.sh
```

Usage
----

On the first run you'll have to create file named    's3_website.yml' with this command:

```bash
s3_website cfg create
```

Edit this file with your AWS Credentials:

```yaml
s3_id: YOUR_AWS_S3_ACCESS_KEY_ID
s3_secret: YOUR_AWS_S3_SECRET_ACCESS_KEY
s3_bucket: your.blog.bucket.com
```

Now just fire up HipstaDeploy with:

```bash
hipdep
```

HipstaDeploy will ask you if you want to deploy your static folder to Amazon CloudFront, say **Y** to rock on!

Your static files will be generated from URL **http//localhost:2368** (yes, that's a [Ghost][3] blog) and will be saved in a folder named **_site**. 

You can override this behavior by using the **-u** and **-o** flags:

```bash
hipdep -u http://blog.local:8080 -o static_file
```

License
-----
MIT

[1]:http://aws.amazon.com/cloudfront/
[2]:https://github.com/laurilehmijoki/s3_website
[3]:https://ghost.org/
[4]:https://www.wordpress.org
[5]:http://jekyllrb.com/
