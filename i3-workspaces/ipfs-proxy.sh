#!/usr/bin/env bash

function start {
  local args=$1

  urxvt -e fish -liC "$args" &
  go-psleep 100ms
}

function load_workspace {
  local workspace=$1
  local layout=$2

  i3-msg "workspace $workspace; append_layout $HOME/.dot/i3-workspaces/$layout"
}

function toggle_split {
  i3-msg "layout toggle split"
}

function down {
  i3-msg "focus down"
}

function left {
  i3-msg "focus left"
}

function up {
  i3-msg "focus up"
}

function right {
  i3-msg "focus right"
}

load_workspace 2 "ipfs-proxy.workspace"
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

