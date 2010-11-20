======
thimbl
======

---------------------------------------
command-line Thimbl microblogging tools
---------------------------------------

:Author: mcturra2000@yahoo.co.uk
:Date: 2010-11-17
:Copyright: public domain
:Version: 0.0
:Manual section: 1
:Manual group: thimbl

SYNOPSIS
========

thimbl COMMAND [ARGS]

DESCRIPTION
===========

Thimbl is a set of client-side tools for a distributed open source
microblogging platform. Thimbl implements a set of file conventions
layered on top of the finger protocol in order to create a
microblogging platform.

The COMMAND is a name of a Thimbl command (see below).

OPTIONS
=======

There are currently no options for thimbl.

THIMBL COMMANDS
===============

  thimbl-fetch(1)
    Fetch and store posts of the users being followed.

  thimbl-follow(1)
    Follow a user.

  thimbl-post(1)
    Post a message.

  thimbl-print(1)
    Print all the messages stored in the cache.

  thimbl-setup(1)
    Initial setup of a user account.


QUICKSTART
==========

* Set up your profile::
    thimbl setup mcarter@markcarter.me.uk "Just a guy" \
       "Mark Carter" "www.markcarter.me.uk" "N/A" "info@markcarter.me.uk"

* Create a post::
    thimbl post "First post"

* Follow someone::
    thimbl follow "dk" "dk@telekommunisten.net"

* Fetch messages of people you are following::
    thimbl fetch

* Print messages (including your own)::
    thimbl print


PEOPLE TO FINGER
================

You can finger anyone you like, provided they have an account on a
machine where fingerd is running. You may want to follow the people
listed below, because they are/were involved in the development of
Thimbl - so they are the most likely to be blogging actively::

   dk@telekommunisten.net
   dk@thimbl.net
   ossa@nummo.strangled.net
   ww@river.styx.org
   ww.foaf@river.styx.org


RESOURCES
=========

This section provides information available on the web that is related
to Thimbl.

* Mailing list::
   http://telekommunisten.net/telecomintern

* Twitter account: thimbl


TIPS
====

* To print the rst files as man pages::
   rst2man.py <thimbl.rst | groff -man -Tascii | less

* To pretty-print json strings::
   echo '{"foo": "lorem", "bar": "ipsum"}' | python -mjson.tool

SEE ALSO
========

* **man 5 plan** - plan file format
* **man 8 thingerd** - a simple finger server tailored for thimbl
