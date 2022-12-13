[![Build
Status](https://travis-ci.org/awesomefoundation/awesomebits.svg)](https://travis-ci.org/awesomefoundation/awesomebits)

AwesomeBits
===========

Configuration
-------------

### Docker

To start developing this project quickly, feel free to use the [docker compose](https://docs.docker.com/compose/) workflow. This will install a local Postgres database in a Docker container, and the Rails app in another container.

#### Installing the Docker runtime

##### Linux: Install the Native Docker Engine

If you're developing on a Linux system, follow [these instructions](https://docs.docker.com/installation/) to install Docker natively on your system. You will also need to install [Docker Compose](https://docs.docker.com/compose/install/).

##### Mac or Windows: Install Docker Desktop

If you're developing from a Mac or Windows machine, you will need to install [Docker Desktop](https://docs.docker.com/desktop/).

#### Starting the app with Docker Compose

Once you have the Docker engine installed, you should be able to launch the app with the following command:

```bash
docker compose up
```

If successful, your terminal should look something like this:

![Docker Compose Up Success](doc/awesomebits-docker-compose-up.gif)

#### Changes to the Dockerfile

If there are any changes made to the `Dockerfile` (for example, if the Ruby version changes), you will have rebuild the Docker container that runs the app. You will only have to do this once:

```bash
docker compose up --build
```

#### Executing arbitary commands with Docker Compose

You can also run arbitrary commands within the Docker container. For example, to run `rails console`, do the following:

```bash
docker compose run web rails console
```

![Running Rails Console with Docker Compose](doc/awesomebits-docker-compose-rails-console.gif)

### Environment Variables

In order to set environment variables (for example, to enable S3 in your development environment),
create a file called `.env` in the main project directory. This file will look like this:

```shell
AWS_ACCESS_KEY_ID=XXX
AWS_SECRET_ACCESS_KEY=YYY
AWS_BUCKET=your-bucket-name
```

Subdomains
----------

The site supports chapter subdomain redirects. When a wildcard DNS record is set up to point at the app, all traffic to subdomains other than `www` and the subdomain that is contained in the `SUBDOMAIN` environment variable will be redirected to the chapter page with that subdomain set as the chapter slug.

For example, `nyc.awesomefoundation.org` redirects to `www.awesomefoundation.org/en/chapters/nyc`

In order to prevent that redirect for other installations (such as staging environments), or for testing with a service like [ngrok](https://ngrok.io), set the `SUBDOMAIN` environment variable to the site's subdomain.

```shell
SUBDOMAIN=staging
```

Alternately, you can set the `CANONICAL_HOST` environment variable which will force all non-chapter subdomain redirects to be redirected to the canonical hostname. This is necessary to ensure that the main site is not served up by stray hostnames due to wildcard DNS. i.e. www.m.awesomefoundation.org should redirect to the canonical www.awesomefoundation.org host for SEO and overall confusion reasons.

```shell
CANONICAL_HOST=www.awesomefoundation.org
```


Secret Token
------------

When deploying to production, the SECRET_KEY_BASE environment variable must be set. This token only needs to be generated once and then stored in the environment variable, but it must be kept secret. This does not need to be set in development or test environments.

For a Heroku deployment, something like the following could be used:

```shell
$ heroku config:set SECRET_KEY_BASE=`rake secret`
```


Countries
---------

Constant COUNTRY_PRIORITY used to define an array of priority countries. This used in the Chapter Form to create quick access to popular countries; also used
in CountrySorter model for sorting the chapters.

Constant can be found in initializers file config/initializers/countries.rb


Localization
------------

Much of the AwesomeBits interface has been localized. Localization files are stored in two places, depending on the type of content being localized:

* Discrete srings and localizations are stored in config/locales/ directory with a separate file for each language
* Partials with localized content are stored in the app/views/locales/ directory with the locale in the names of the file (i.e. _about_us.en.md)


Images
------

Images are resized dynamically with [imgproxy](https://imgproxy.net). The `docker compose` configuration includes a local install of imgproxy which is configured to work with your development environment. For other installations or if you're not running in docker, you'll have to run your own and you must set the IMGPROXY_HOST environment variable to point to that host.

```shell
IMGPROXY_HOST=http://localhost:8080
```

Spam Protection
---------------

We implement very basic spam projection on applications. Set the environment variable SPAM_REGEXP to be a `|` separated list of blocked strings which will be rejected at the time of project creation.


Blocklist
---------

Very basic blocklisting is implemented using [Rack::Attack](https://github.com/kickstarter/rack-attack). To block an IP, simply add the IP address to the BLOCKLIST_IPS environment variable. Multiple IPs should be comma separated:

```shell
BLOCKLIST_IPS=10.0.0.1,10.0.0.2
```

Password Protection
-------------------

There are instances where you want to put a password on the entire site (for example, a staging server which is on the public internet but should not be accessible to the general public). Set the `SITE_PASSWORD` environment variable to a password you want people to have to use to access the site. The user should then enter the `SITE_PASSWORD` text for both the username and password when prompted.

```shell
SITE_PASSWORD=topsecret
```

HTTPS
-----

The site can be forced to redirect users to https pages by setting the `FORCE_HTTPS` environment variable. By doing this, all traffic to the `www` subdomain will be forced to https.

NOTE: We do not currently enforce HSTS in case there is a problem and we need to turn off https. This might change in the future.

```shell
FORCE_HTTPS=true
```

License
-------

AwesomeBits is Copyright 2012-2022, Institute on Higher Awesome Studies

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
