======
thimbl
======

---------------------------------------
command-line Thimbl microblogging tools
---------------------------------------

:Author: mcturra2000@yahoo.co.uk
:Date: 2010-11-16
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


SEE ALSO
========

* ``man 7 plan`` - an example .plan file
