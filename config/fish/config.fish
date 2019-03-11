source $HOME/.asdf/asdf.fish

alias vim nvim

#
# Go
#

set -x GOPATH $HOME

#
# Rust
#

set -x PATH $HOME/.cargo/bin $PATH

#
# Setup path
#

set -x PATH $HOME/.local/bin $PATH
set -x PATH $HOME/bin $PATH
