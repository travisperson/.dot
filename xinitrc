#! /bin/bash

xrdb -merge $HOME/.Xdefaults
[[ -f $HOME/.fehbg ]] && . $HOME/.fehbg

vmware-user

session=${1:-i3}

case $session in
  i3|i3wm ) exec i3;;
  *) exec $1;;
esac
