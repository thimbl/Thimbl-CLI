'''sitt.py - Some Interesting Thimbl Tools '''

import cStringIO
#import datetime
import json
import optparse
import os
import re
import subprocess
import sys
import time

def create(address, bio, name, website, mobile, email):
    'Create data given user information'

    properties =  {'website' : website, 'mobile' : mobile, 'email' : email }
    plan = { 'address' : address, 'name' : name, 'messages' : [],
             'replies' : {},'following' : [], 'properties' : properties}
    data = { 'me' : address, 'plans' : { address : plan }}
    return data



def myplan(data):
    return data['plans'][data['me']]


def post(data, text):
    'Create a message. Remember to publish() it'
    timefmt = time(time.strftime('%Y%m%d%H%M%S'))
    message = { 'time' : timefmt, 'text' : text }
    myplan(data)['messages'].append(message)


    

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

def fetch(data):
    '''Retrieve all the plans of the people I am following'''
    for following in myplan(data)['following']:
        address = following['address']
        if address == data['me']:
            print "Stop fingering yourself!"
            continue

        print 'Fingering ', address
        try:
            plan = finger_user(address)
        except AttributeError:
            print 'Failed on address. Skipping'
            continue
        data['plans'][address] = plan
    print 'Finished'
    
    


def prmess(data):
    'print messages'
    for address in data['plans'].keys():
        plan = data['plans'][address]
        print address, plan
        if not plan.has_key('messages'): continue
        for msg in plan['messages']:
            print address
            t = str(msg['time'])
            y, mo, d, h, mi, s = t[:4], t[4:6], t[6:8], t[8:10], t[10:12], t[12:14]
            print '{0}-{1}-{2} {3}:{4}:{5}'.format(y, mo, d, h, mi, s)
            print msg['text']
            print


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
