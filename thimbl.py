'''thimbl.py - Command-line python tools '''

import cStringIO
#import datetime
import json
import optparse
import os
import re
import subprocess
import sys
import time

#################################################################

class Data:
    def __init__(self):
        self.data = load_cache()
        self.me = myplan(self.data)
 
    def post(self, text):
        'Create a message. Remember to publish() it'
        timefmt = time.strftime('%Y%m%d%H%M%S')
        message = { 'time' : timefmt, 'text' : text }
        self.me['messages'].append(message)
    
    
    def post_file(self, filename):
        'Create a post from the text in a file'
        text = file(filename, 'r').read()
        self.post(text)

    def following(self):
        'Who am I following?'
        followees = self.me['following']
        followees.sort(key = lambda x: x['nick'])
        for f in followees:
            print '{0:5} {1}'.format(f['nick'], f['address'])

    def unfollow(self, address):
        'Remove an address from someone being followed'
        def func(f): return not (f['address'] == address)
        new_followees = filter(func, self.me['following'])
        self.me['following'] = new_followees
        
    def __del__(self):
        #print "Data exit"
        save_cache(self.data)
        publish(self.data)
        
#################################################################

def writeln(text):
    print text
    
def create(address, bio, name, website, mobile, email):
    'Create data given user information'

    properties =  {'website' : website, 'mobile' : mobile, 'email' : email }
    plan = { 'address' : address, 'name' : name, 'messages' : [],
             'replies' : {},'following' : [], 'properties' : properties}
    data = { 'me' : address, 'plans' : { address : plan }}
    return data



def myplan(data):
    return data['plans'][data['me']]





    

def follow(data, nick, address):
    myplan(data)['following'].append( { 'nick' : nick, 'address' : address } )


def finger_user(user_name):
    '''Try to finger a user, and convert the returned plan into a dictionary
    E.g. j = finger_user("dk@telekommunisten.org")
    print j['bio']    
    '''
    args = ['finger', user_name]
    p = subprocess.Popen(args, stdout=subprocess.PIPE)
    output = p.communicate()[0]
    m = re.search('^.*?Plan:\s*(.*)', output, re.M + re.S)
    raw = m.group(1)
    j = json.loads(raw)
    return j

def fetch(data, wout = writeln):
    '''Retrieve all the plans of the people I am following'''
    for following in myplan(data)['following']:
        address = following['address']
        if address == data['me']:
            wout("Stop fingering yourself!")
            continue

        wout('Fingering ' + address)
        try:
            plan = finger_user(address)
            wout("OK")
        except AttributeError:
            wout('Failed. Skipping')
            continue
        #print "DEBUG:", plan
        data['plans'][address] = plan
    wout('Finished')
    
    


def prmess(data, wout = writeln):
    'Print messages in reverse chronological order'
    
    # accumulate messages
    messages = []
    for address in data['plans'].keys():
        plan = data['plans'][address]
        if not plan.has_key('messages'): continue
        for msg in plan['messages']:
            msg['address'] = address
            messages.append(msg)
            
    messages.sort(key = lambda x: x['time'])
    
    # print messages
    for msg in messages:
        # format time
        t = str(msg['time'])
        y, mo, d, h, mi, s = t[:4], t[4:6], t[6:8], t[8:10], t[10:12], t[12:14]
        ftime = '{0}-{1}-{2} {3}:{4}:{5}'.format(y, mo, d, h, mi, s)

        text = '{0}  {1}\n{2}\n\n'.format(ftime, msg['address'], msg['text'])
        wout(text)


def save(data, filename):
    'Save data to a file as a json file'
    j = json.dumps(data)
    file(filename, 'w').write(j)

def publish(data):
    save(myplan(data), os.path.expanduser('~/.plan'))
         
def load(filename):
    'Load data from a json file'
    s = file(filename, 'r').read()
    return json.loads(s)

def cache_filename():
    'Return the name of the cache file that stores all of the data'
    thimbldir = os.path.expanduser('~/.config/thimbl')
    try: os.makedirs(thimbldir)
    except OSError: pass # don't worry if directory already exists
    thimblfile = os.path.join(thimbldir, 'data1.jsn')
    return thimblfile
    
def load_cache():
    'Load the data file'
    thimblfile = cache_filename()
    if os.path.isfile(thimblfile):
        data = load(thimblfile)
    else:
        data = None
    return data

def save_cache(data):
    cache_file = cache_filename()
    save(data, cache_file)
    


def main():

    #parser.add_option("-f", "--file", dest="filename",
    #help="write report to FILE", metavar="FILE")
    #parser.add_option("-q", "--quiet",
    #action="store_false", dest="verbose", default=True,
    #help="don't print status messages to stdout")
    #parser.add_option


    d = Data()
    #data = load_cache()
    cmd = sys.argv[1]
    if cmd =='fetch':
        fetch(d.data)
    elif cmd == 'follow':
        follow(d.data, sys.argv[2], sys.argv[3])
    elif cmd == 'following':
        d.following()
    elif cmd == 'post':
        d.post(sys.argv[2])
    elif cmd == 'print':
        prmess(d.data)
    elif cmd == 'setup':
        d.data = apply(create, sys.argv[2:])
    elif cmd == 'stdin':
        text = sys.stdin.read()
        d.post(text)
    elif cmd == 'unfollow':
        d.unfollow(sys.argv[2])
    else:
        print "Unrecognised command: ", cmd


    #save_cache(data)
    #publish(data)


if __name__ == "__main__":
    main()
