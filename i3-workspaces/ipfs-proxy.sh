#!/usr/bin/env bash
cd "$(dirname ${BASH_SOURCE[0]})" || exit 1
source .shared

if [ -f $HOME/.ipfs/repo.lock ]; then
  i3-msg "[title=ipfs-daemon-watch] focus"
  exit 1
fi

load_workspace $(current_workspace) $(workspace_name $BASH_SOURCE)

toggle_split

start "ipfs-proxy proxy"
down
start "ipfs-daemon-watch"
down
start "sleep 6; ipfs-proxy id; clear"
right
start "ipfs-proxy proxy-out"
up
start "ipfs-proxy proxy-in"
