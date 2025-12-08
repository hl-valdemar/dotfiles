# zvm installation
export ZVM_INSTALL="$HOME/.zvm/self"
export PATH="$ZVM_INSTALL:$PATH"
export PATH="$HOME/.zvm/bin:$PATH"

# zls installation
export ZLSVM_INSTALL="$HOME/.zlsvm/bin"
export PATH="$ZLSVM_INSTALL:$PATH"

# ols installation
export OLS_INSTALL="$HOME/.ols/bin"
export PATH="$OLS_INSTALL:$PATH"

# add standard user programs to PATH
export PATH="/usr/bin:/bin:$PATH"

# add homebrew programs to PATH
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# add bob to PATH
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

# add volta to PATH
export PATH="$HOME/.volta/bin:$PATH"

# pipx installation
export PATH="$HOME/.local/bin:$PATH"

# rust installation
export RUSTUP_HOME="$HOME/.local/share/rustup"
export CARGO_HOME="$HOME/.local/share/cargo"
export PATH="$HOME/.local/share/cargo/bin:$PATH"

# export vimrc location
export MYVIMRC="$HOME/.config/nvim/init.lua"

