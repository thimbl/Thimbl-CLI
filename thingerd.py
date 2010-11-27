#!/usr/bin/env python

#The MIT License
#
#Copyright (c) 2010 A.M. Kuchling
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

# fingerd.py
# By A.M. Kuchling (amk@amk.ca)
#
# This little program illustrates how easy it is to write network
# servers using the classes in the SocketServer module.
#
# The finger protocol is a very simple TCP-based protocol; the client
# sends a single line containing the name of the user whose
# information is being requested, followed by a newline.
# Information about the user should then be sent over the socket
# connection to the client.  In this implementation, the server simply
# tells you who you've fingered; you'd probably want it to retrieve
# information from the user's home directory or a database of some sort.
#

# ORIGINAL CODE
#   The original code can be downloaded from
#   http://www.amk.ca/files/simple/fingerd.txt
#   27-Nov-2010 - In an email correspondence, Andrew Kuchling stated that
#   this is source code is available under an MIT licence shown at:
#   http://www.opensource.org/licenses/mit-license.php
#   I have incorporated that code in with this source file so as to spell it
#   out. Many thanks to Andrew for posting his code and making it available
#   for free use.

import os
import platform
import SocketServer

class FingerHandler(SocketServer.StreamRequestHandler):
    def handle(self):
        # Read a line of text, limiting it to 512 bytes.
        # This will prevent someone trying to crash the server machine
        # by sending megabytes of data.
        username=self.rfile.readline(512)

        # Remove any leading and trailing whitespace, including the
        # trailing newline.
        import string
        username=string.strip(username)

        # Call the method to get the user's information, and return it
        # to the client.  The SocketServer classes make self.wfile
        # available to send data to the client.
        info = self.find_user_info(username)
        self.wfile.write(info)

    # The following method takes a string containing the username,
    # and returns another string containing whatever information is
    # desired.  You can subclass the FingerHandler class and override
    # this method with your own to produce customized output.

    def find_user_info(self, username):
        "Return a string containing the desired user information."
        #username = repr(username)
        text = "You fingered the user '{0}'\n".format(username)

        # work out user's home name
        #if platform.uname()[0] == "Windows":
        #    home_dir = os.path.expanduser('~')
        #    text += "Windows kludge applied - single user mode only.\n"
        #else:
        #    home_dir = os.path.expanduser('/home/{0}'.format(username))
        home_dir = os.path.expanduser('~{0}'.format(username) )
            
        plan_file = os.path.join(home_dir, ".plan")
        #print plan_file
        if os.path.isfile(plan_file):
            text += "Plan:\n" + file(plan_file).read()
        return text

# If this script is being run directly, it'll start acting as a finger
# daemon.  If someone's importing it in order to subclass
# FingerHandler, that shouldn't be done.  The following "if" statement
# is the usual Python idiom for running code only in a script.

if __name__=='__main__':
    # Create an instance of our server class
    server=SocketServer.TCPServer( ('', 79), FingerHandler)

    # Enter an infinite loop, waiting for requests and then servicing them.
    server.serve_forever()
