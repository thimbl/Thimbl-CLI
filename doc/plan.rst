====
plan
====

----------------
thimbl plan file
----------------


:Author: mcturra2000@yahoo.co.uk
:Date: 2010-11-16
:Copyright: Public Domain
:Version: 0.0
:Manual section: 7
:Manual group: thimbl

SYNOPSIS
========

N/A

DESCRIPTION
===========

Conventially, a user may put anything or nothing in their ~/.plan
file. In order for thimbl to work, it requires that the plan file has
a certain format: basically a json-formatted file. As at 16-Nov-2010,
the exact specifications changes frequently, as Thimbl is still in
an early development stage.

Although it is possible for you to edit the ~/.plan file yourself,
this is not recommended. You should use appropriate commands on
**thimbl** .


FILE FORMAT
===========

When a remote user is fingered using a command such as::

    finger dk@telekommunisten.net

the response usually includes some header information such as::

    [telekommunisten.org]
    Login: dk                               Name: Dmytri Kleiner
    Directory: /home/dk                     Shell: /bin/bash
    Office: +491632866163
    Last login Fri Nov  5 12:42 (EDT) on pts/1 from 89.246.67.229
    Mail last read Sun Nov  1 15:07 2009 (EST)
    Plan:

followed by the contents of the user's plan file. If the user does not have aplan file, then finger wont print "Plan:".  

Here is an example plan file that is comprehensible by thimbl::

   {
       "bio": "Venture Communist", 
       "following": [
           {
               "address": "mike@mikepearce.net", 
               "nick": "mike"
           }, 
           {
               "address": "rw@telekommunisten.org", 
               "nick": "rico"
           }, 
           {
               "address": "ashull@telekommunisten.org", 
               "nick": "ashull"
           }
       ], 
       "messages": [
           {
               "text": "Hey @mark, this is the first update sent with Thimbl-CLI", 
               "time": 20101105124412
           }, 
           {
               "text": "mike needs to stop sending messages from the future!", 
               "time": 20100707125120
           }, 
           {
               "text": "#thimbl is rolling!", 
               "time": 20100707122140
           }, 
           {
               "text": "I love thimbl! #thimbl", 
               "time": 20100622170914
           }
       ], 
       "name": "Dmytri Kleiner", 
       "properties": {
           "email": "dk@telekommunisten.net", 
           "mobile": "+491632866163", 
           "website": "http://www.telekommunisten.net"
       }, 
       "replies": {
           "ashull@telekommunisten.org": [
               {
                   "text": "@ashull, the feed is awesome, works great!", 
                   "time": 20100707122315
               }, 
               {
                   "text": "@ashull, here is a reply", 
                   "time": 20100705163145
               }
           ], 
           "mike@mikepearce.net": [
               {
                   "text": "@mike, the baboon would win. No contest", 
                   "time": 20100707122100
               }, 
               {
                   "text": "@mike, do you like this json format?", 
                   "time": 20100622170025
               }
           ], 
           "rw@telekommunisten.org": [
               {
                   "text": "@rico, I'll call you later", 
                   "time": 20100622162340
               }
           ]
       }
   }


SEE ALSO
========

* **thimbl** - main page for the description of thimbl
