import os
import sys
import locale
from functools import cmp_to_key

""" The smart cd for zsh or bash

SMARTCD=$(dirname $0)
cd() {
    argvs=$(python3 $SMARTCD/smartcd.py "$@")
    eval "builtin cd $argvs && ls --color=tty"
}

"""

locale.setlocale(locale.LC_ALL, 'en_US.UTF-8')

def gen_cd_path(p):
    dir_name = os.path.dirname(p)
    if dir_name == '':
        dir_name = '.'
    base_name = os.path.basename(p)

    if p.startswith('-') or p.startswith('+'):
        return p

    if os.path.isdir(p):
        return p
    elif os.path.isfile(p):
        return dir_name
    else:
        dirs = [
                 d for d in os.listdir(dir_name)
                 if os.path.isdir(os.path.join(dir_name, d))
                 # ignore hidden directories
                 #if not d.startswith('.')
               ]

        for d in sorted(dirs, key=cmp_to_key(locale.strcoll)):
            if d.lower().startswith(base_name.lower()):
                return '{}/{}'.format(dir_name, d)

        for d in sorted(dirs, key=cmp_to_key(locale.strcoll)):
            if base_name.lower() in d.lower():
                return '{}/{}'.format(dir_name, d)

        return dir_name

argc = len(sys.argv)
if argc == 1:
    exit(0)
elif argc == 2:
    print(gen_cd_path(sys.argv[1]))
elif argc == 3:
    if (sys.argv[1].startswith('-')):
        print('{} {}'.format(sys.argv[1], gen_cd_path(sys.argv[2])))
    else:
        print('{} {}'.format(sys.argv[1], sys.argv[2]))
else:
    print('{} {} {}'.format(sys.argv[1], sys.argv[2], sys.argv[3]))