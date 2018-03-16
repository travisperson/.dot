#
# Go
#

set -x GOROOT $HOME/.apps/go
set -x GOPATH $HOME

#
# Setup path
#

set -x PATH $HOME/.local/bin $PATH
set -x PATH $GOROOT/bin $PATH
set -x PATH $HOME/bin $PATH
