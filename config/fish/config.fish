#
# Go
#

set -x GOROOT $HOME/.apps/go
set -x GOPATH $HOME

#
# Rust
#

set -x CARGO_HOME $HOME/.apps/cargo
set -x RUSTUP_HOME $HOME/.apps/multirust
set -x RUST_SRC_PATH (/home/travis/.apps/cargo/bin/rustc --print sysroot)/lib/rustlib/src/rust/src

#
# VSCode
#

set -x VSCODE_HOME $HOME/.apps/vs-code

#
# Ruby
#

set -x CHRUBY_ROOT /usr
source /usr/local/share/chruby/chruby.fish

#
# Setup path
#

set -x PATH $HOME/.local/bin $PATH
set -x PATH $GOROOT/bin $PATH
set -x PATH $CARGO_HOME/bin $PATH
set -x PATH $HOME/bin $PATH
set -x PATH $VSCODE_HOME/bin $PATH
set -x PATH $HOME/.apps/yarn/bin $PATH

#
# Node version management
#

set -x N_PREFIX $HOME/.local
