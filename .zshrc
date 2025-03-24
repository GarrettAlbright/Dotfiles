HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=10000
# Make sure history is shared between terminals
setopt SHARE_HISTORY

# Do color output on ls & tab completion lists
# https://superuser.com/questions/290500/zsh-completion-colors-and-os-x
export CLICOLOR=1
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Make history search work more like it did on tcsh
# (Search with current buffer; put cursor at end of line)
# https://coderwall.com/p/jpj_6q/zsh-better-history-searching-with-arrow-keys
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Key binding for searching through history
# "^[[A" and "^[[B" are Mac; "^[OA" and "^[OB" are leeenucks
# https://stackoverflow.com/a/62118006/11023
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search

# Make ls -l show human sizes by default
alias ls="ls -h"

# Make `history` show all history entries, not just the last 15
# (so `history|ag foo` works as expected again)
# https://stackoverflow.com/questions/26846738/zsh-history-is-too-short
alias history="history 1"

# Alias for ag-ing only inside certain files
alias agp="ag -G '\.php$'"
alias agj="ag -G '\.js$'"
alias agc="ag -G '\.css$'"

# Make XZ use all cores and compress its best
export XZ_OPT="--best -T 0"

# Case insensitive completion
# https://scriptingosx.com/2019/07/moving-to-zsh-part-5-completions/
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# Command option completion
autoload -Uz compinit && compinit

# Calculator
# https://stackoverflow.com/a/15915233
calculator () {
  echo "$*" | tr -d \"-\', | bc -l
}

alias C='noglob calculator'

find_motd () {
  # Show the Ubuntu MOTD if found
  if [ -f /run/motd.dynamic ] ; then
    cat /run/motd.dynamic
  # Show the BSD MOTD if found
  elif [ -f /etc/motd ] ; then
    cat /etc/motd
  fi
}

# Generate password. Pass a length (10 by default)
pw() {
  local char=${1:-10}
  local chardouble=$((char * 2))
  head -c $chardouble /dev/urandom | base64 | tr "+/" "-_" | cut -c "-$char"
}

# Do some Mac-specific stuff if we're on my Mac
if [ `uname` = "Darwin" ] ; then

  # Set prompt - Yellow machine name, inverse red error if applicable, blue path, prompt
  PROMPT='%F{y}%m%f%(0?.. %K{r}%F{b}%?%f%k) %F{c}%~%f%# '

  # Path for MacPorts-installed stuff,
  # plus stuff installed with Composer and Python
  export PATH="/opt/local/bin:/opt/local/sbin:/Users/albright/Library/Python/3.10/bin:/Users/albright/.composer/vendor/bin:$PATH"

  # Invoke Streamlink with the URL in the clipboard
  sl() {
    # Use an explicit quality setting if it was passed; otherwise default
    # to 480p
    # https://zsh.sourceforge.io/Doc/Release/Expansion.html#Parameter-Expansion
    pbpaste | xargs -I '@' streamlink '@' ${1-480p}
  }

  # Same for yt-dlp
  dl() {
    # YouTube format 18 is best for putting on my phone IMO
    pbpaste | xargs -I '@' yt-dlp -f ${1-18} --paths "~/Videos" "@"
  }

  # Get available formats for the clipboard video for yt-dlp
  dlf() {
    pbpaste | xargs -I '@' yt-dlp -F "@"
  }

  # Nethack
  export NETHACKOPTIONS="color,name:Contrabandit,fullscreen"

else

  # Same prompt except machine name is inversed
  PROMPT='%F{b}%K{y}%m%k%f%(0?.. %K{r}%F{b}%?%f%k) %F{c}%~%f%# '

  # On OpenBSD, "vi" won't automatically alias to "vim"
  if (( $+commands[vim] )) ; then
    alias vi="vim"
  fi

  # Start tmux automatically
  # https://stackoverflow.com/questions/27613209/how-to-automatically-start-tmux-on-ssh-session
  if [ -z "$TMUX" ] && [ -n "$SSH_CONNECTION" ] ; then
    tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
  fi

  if [ `uname` = "NetBSD" ] ; then
    export PATH="/sbin:/usr/sbin:/usr/X11R7/bin:/usr/pkg/bin:/usr/pkg/sbin:/usr/pkg/games:/usr/local/sbin:$PATH"
  fi
fi

# Load zsh-syntax-highlighting wherever it might be hiding
if [ -e /usr/local/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ] ; then
  source /usr/local/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
elif [ -e ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] ; then
  source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -e /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] ; then
  source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -e /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] ; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -e /usr/pkg/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] ; then
  source /usr/pkg/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
