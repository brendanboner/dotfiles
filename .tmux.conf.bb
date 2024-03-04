# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

# Other examples:
# set -g @plugin 'github_username/plugin_name'
# set -g @plugin 'github_username/plugin_name#branch'
# set -g @plugin 'git@github.com:user/plugin'
# set -g @plugin 'git@bitbucket.com:user/plugin'
set -g @plugin "arcticicestudio/nord-tmux"
# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'

set -g default-shell $SHELL

set -g status-bg black
set -g status-fg white
set -g default-terminal "screen-256color"
set -g focus-events on

# window numbering starts at 1
set -g base-index 1
set-window-option -g pane-base-index 1

set-window-option -g aggressive-resize

set -g mouse on

# Toggle mouse on
bind-key M \
  set-option -g mouse on \;\
  display-message 'Mouse: ON'

# Toggle mouse off
bind-key m \
  set-option -g mouse off \;\
  display-message 'Mouse: OFF'

# macOS only
set -g mouse on
bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'select-pane -t=; copy-mode -e; send-keys -M'"
bind -n WheelDownPane select-pane -t= \; send-keys -M
bind -n C-WheelUpPane select-pane -t= \; copy-mode -e \; send-keys -M
bind -T copy-mode-vi    C-WheelUpPane   send-keys -X halfpage-up
bind -T copy-mode-vi    C-WheelDownPane send-keys -X halfpage-down
bind -T copy-mode-emacs C-WheelUpPane   send-keys -X halfpage-up
bind -T copy-mode-emacs C-WheelDownPane send-keys -X halfpage-down

# To copy, left click and drag to highlight text in yellow, 
# once you release left click yellow text will disappear and will automatically be available in clibboard
# # Use vim keybindings in copy mode
setw -g mode-keys vi
# Update default binding of `Enter` to also use copy-pipe
unbind -T copy-mode-vi Enter
bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "pbcopy"
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

# split
bind | split-window -h
bind \\ split-window -v

# resize panes like vim
bind -r < resize-pane -L 10
bind -r > resize-pane -R 10
bind -r - resize-pane -D 10
bind -r + resize-pane -U 10

bind y set-window-option synchronize-panes

bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

if-shell '[ -n "$(command -v reattach-to-user-namespace)" ]' \
    'set -g default-command "reattach-to-user-namespace ${SHELL}"'

if-shell '[ -n "$(command -v reattach-to-user-namespace)" ] && [ "$TERM_PROGRAM" = "Apple_Terminal" ]' \
    'bind-key -Tcopy-mode-vi y send -X copy-pipe "reattach-to-user-namespace pbcopy"; \
     bind-key -Tcopy-mode-vi Enter send -X copy-pipe "reattach-to-user-namespace pbcopy"; \
     bind-key -Tcopy-mode-vi MouseDragEnd1Pane send -X copy-pipe "reattach-to-user-namespace pbcopy"'
