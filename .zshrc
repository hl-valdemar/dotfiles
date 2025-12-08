# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color|*ghostty) color_prompt=yes;;
esac

# set vim mode
bindkey -v

# set aliases
alias vi=nvim
alias vim=nvim
alias l=eza
alias ls="eza -l"
alias la="eza -la"
alias lt="eza --tree --sort=type"
alias lg="lazygit"

# style prompt
NEWLINE=$'\n'
export PS1="${NEWLINE}λ "

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# init plugins (before completion)
eval "$(atuin init zsh)"
eval "$(zoxide init zsh)"

# init completion (after plugins)
fpath+=~/.zfunc
autoload -Uz compinit && compinit

fzf-file-widget() {
  local selected_file=$(fd --type f --hidden --exclude .git --exclude node_modules | fzf --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}')
  if [[ -n "$selected_file" ]]; then
    LBUFFER="${LBUFFER}${selected_file}"
  fi
  zle reset-prompt
}

zle -N fzf-file-widget
bindkey '^F' fzf-file-widget
