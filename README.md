[![Build
Status](https://travis-ci.org/awesomefoundation/awesomebits.svg)](https://travis-ci.org/awesomefoundation/awesomebits)

AwesomeBits
===========

Countries
---------

Constant COUNTRY_PRIORITY used to define an array of priority countries. This
used in the Chapter Form to create quick access to popular countries; also used
in CountrySorter model for sorting the chapters.

Constant can be found in initializers file. /config/initializers/countries.rb


Localization
------------

Much of the AwesomeBits interface has been localized. Localization files are 
in the config/locales/ directory with a separate file for each language.


Images
------

Images are resized dynamically via the [Magickly gem](http://magickly.afeld.me). 
In order to display images properly, you must have a Magickly installation running
and you must set the MAGICKLY_HOST environment variable to point to that host. 

e.g. If you are running Magickly localy on port 8888, run AwesomeBits using the command: 

  MAGICKLY_HOST=http://localhost:8888 thin start


License
-------

AwesomeBits is Copyright 2012-2013, Institute on Higher Awesome Studies

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
