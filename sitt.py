'''sitt.py - Some Interesting Thimbl Tools
'''

import json
import optparse
import os
import re
import subprocess
import time

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

def print_messages(messages):
    for msg in messages:
        t = str(msg['time'])
        y, mo, d, h, mi, s = t[:4], t[4:6], t[6:8], t[8:10], t[10:12], t[12:14]
        print '{0}-{1}-{2} {3}:{4}:{5}'.format(y, mo, d, h, mi, s)
        print msg['text']
        print
def single_finger(user):
    '''Print the plan for a given user'''
    j = finger_user(user)
    #print j
    #print j
    #json.dumps(j, indent = 4)
    print_messages( j['messages'])


def add_message(text):
    plan_filename = os.path.expanduser('~/.plan')
    plan_text = file(plan_filename, 'r').read()
    plan = json.loads(plan_text)
    t = time.strftime('%Y%m%d%H%M%S')
    t = int(t)
    message = { 'time' : t , 'text' : text}
    if not plan.has_key('messages'): plan['messages'] = []
    plan['messages'].insert(0, message)
    plan_text = json.dumps(plan)
    file(plan_filename, 'w').write(plan_text)
    print "OK"

def main():
    parser = optparse.OptionParser()
    parser.add_option("-m", "--message", dest="message", help="add a message")
    parser.add_option("-a", "--address", dest="address", help="pretty-print the plan file for an address")
    (options, args) = parser.parse_args()
    #print options
    #print args
    if options.message:
        add_message(options.message)
    if options.address:
        single_finger(options.address)                    
    
if __name__ == "__main__":
    main()
