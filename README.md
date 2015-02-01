[![Build
Status](https://travis-ci.org/awesomefoundation/awesomebits.svg)](https://travis-ci.org/awesomefoundation/awesomebits)

AwesomeBits
===========

Configuration
-------------

### Environment Variables

In order to set environment variables (for example, to enable S3 in your development environment),
create a file called `.env` in the main project directory. This file will look like this:

```shell
AWS_ACCESS_KEY_ID=XXX
AWS_SECRET_ACCESS_KEY=YYY
AWS_BUCKET=your-bucket-name
```

Countries
---------

Constant COUNTRY_PRIORITY used to define an array of priority countries. This
used in the Chapter Form to create quick access to popular countries; also used
in CountrySorter model for sorting the chapters.

Constant can be found in initializers file. /config/initializers/countries.rb


Localization
------------

Much of the AwesomeBits interface has been localized. Localization files are 
stored in two places, depending on the type of content being localized:

* Discrete srings and localizations are stored in config/locales/ directory
  with a separate file for each language
* Partials with localized content are stored in the app/views/locales/
  directory with the locale in the names of the file (i.e. _about_us.en.md)


Images
------

Images are resized dynamically via the [Magickly gem](http://magickly.afeld.me). 
In order to display images properly, you must have a Magickly installation running
and you must set the MAGICKLY_HOST environment variable to point to that host. 

e.g. If you are running Magickly localy on port 8888, add the following line to your `.env` file:

```shell
MAGICKLY_HOST=http://localhost:8888
```


License
-------

AwesomeBits is Copyright 2012-2014, Institute on Higher Awesome Studies

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
