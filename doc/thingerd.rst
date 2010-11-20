========
thingerd
========

--------------------
thimbl finger daemon
--------------------


:Author: mcturra2000@yahoo.co.uk
:Date: 2010-11-20
:Copyright: Public Domain
:Version: 0.0
:Manual section: 8
:Manual group: thimbl

SYNOPSIS
========

thingerd.py

DESCRIPTION
===========

**thingerd** (actually **thingerd.py**, but hereafter referred to as
thingerd) is a replacement finger daemon, written in Python, that is
tailored specifically for Thimbl. It is designed to take the hassle
out of installing and configuring a finger daemon. It exposes very
little information about the operating environment, and may this be
considered beneficial from a security standpoint. It was also designed
to be used, eventually, from Windows. It therefore tries not to rely
too much on UNIX infrastructre.

**thingerd** was not written by an expert in protocol writing, SO YOU
SHOULD EXERCISE CAUTION IN ITS USE. I welcome feedback from security
experts as to how the program can be made more secure.



OPTIONS
=======

**thingerd** accepts no options. It binds to port 79, which is the
standard fingerd port.


INSTALLATION ON LINUX
=====================

This section describes one way to set up thingerd as a daemon. On UNIX
there is, of course, more than one way to do it, so this section is
merely a *suggestion*, not an absolute rule.

The recommended way is to launch thingerd as a regular user, and use
authbind to gain access to port 79, which is a privileged port. You
will need to install authbind. The method of installation will depend
on your Linux distribution. Some typical ways:
* Debian/Ubuntu: sudo apt-get install authbind

You now need to give a user (in this example, I assume the user name
is ossa) permission to execute on this port::
    touch /etc/authbind/byport/79
    chown ossa:ossa /etc/authbind/byport/79
    chmod 755 /etc/authbind/byport/79

As user ossa (or whatever), type **crontab -e**, and edit the crontab
file to include the line::
    @reboot authbind --deep /path/to/thingerd.py
This will ensure that the daemon will be started on each server reboot.

You will probably want to start the daemon immediately, too. If so,
then type::
    authbind --deep /path/to/thingerd.py

You should now be set up and ready to go.




INSTALLATION ON WINDOWS
=======================

This is currently untested. It should be possible to run thimbld.py
from a command line. Provided that the firewall unblocks port 79 for
its use, it should Just Work (TM). Setting up a service for it is a
TODO item.


SEE ALSO
========

* **thimbl** - main page for the description of thimbl
