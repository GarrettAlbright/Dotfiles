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
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

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

# Switch into new directory after creation
mkcd () {
  mkdir -p "$1" && cd "$1"
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

# Do some Mac-specific stuff if we're on my Mac
if [ `uname` = "Darwin" ] ; then

  # Set prompt - Yellow machine name, inverse red error if applicable, blue path, prompt
  PROMPT='%F{y}%m%f%(0?.. %K{r}%F{b}%?%f%k) %F{c}%~%f%# '

  # Path for MacPorts-installed stuff,
  # plus stuff installed with Composer and Python
  export PATH="/opt/local/bin:/opt/local/sbin:/Users/albright/Library/Python/3.9/bin:/Users/albright/.composer/vendor/bin:$PATH"

  # Quickly bring dev stuff up or down
  alias webup="sudo port load nginx; sudo port load mariadb-10.1-server; sudo port load php72-fpm"
  alias webdn="sudo port unload nginx; sudo port unload mariadb-10.1-server; sudo port unload php72-fpm"

  # swiftenv stuff
  # export SWIFTENV_ROOT="$HOME/.swiftenv"
  # export PATH="$SWIFTENV_ROOT/bin:$PATH"
  # Below might still need to be ported to zsh
  # eval "`swiftenv init - | sed -e 's/export PATH=/setenv PATH /'`"

  # Alias to quickly regenerate Xcode project files
  alias spg='swift package generate-xcodeproj --output=`pwd | rev | cut -d "/" -f 1 | rev | tr -d " "`.xcodeproj'

  # Convert WAVs (legally obtained, thank you) to AAC/M4As
  # When needed, re-implement this as a ZSH function
  wav2m4a () {
    find . -name \*.wav -print | sed 's/.wav$//' | sed "s/'/\\\'/" | xargs -I @ -P 4 zsh -c "/opt/local/bin/ffmpeg -i \"@.wav\" -loglevel warning -b:a 256k \"@.m4a\" && echo \"Finished converting @.wav\" && rm \"@.wav\""
  }

  # Convert FLACs to AAC/M4As
  flac2m4a() {
    find . -name \*.flac -print | sed 's/.flac$//' | sed "s/'/\\\'/" | xargs -I @ -P 4 zsh -c "/opt/local/bin/ffmpeg -i \"@.flac\" -loglevel warning -b:a 256k -vn \"@.m4a\" && echo \"Finished converting @.flac\" && rm \"@.flac\""
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
fi

# Load zsh-syntax-highlighting wherever it might be hiding
if [ -e ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] ; then
  source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -e /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] ; then
  source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -e /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] ; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
