#!/bin/sh
set -eu

# Enforce personal macOS defaults when chezmoi is applied.
# Lower keyboard repeat values mean faster repeat.

if [ "$(uname -s)" != "Darwin" ]; then
  exit 0
fi

changed=0

write_default() {
  domain=$1
  key=$2
  type=$3
  value=$4
  expected=$5

  current=$(defaults read "$domain" "$key" 2>/dev/null || true)
  if [ "$current" != "$expected" ]; then
    defaults write "$domain" "$key" "$type" "$value"
    changed=1
  fi
}

read_plist_value() {
  domain=$1
  path=$2

  defaults export "$domain" - 2>/dev/null | plutil -extract "$path" raw -o - - 2>/dev/null || true
}

write_color_default() {
  domain=$1
  key=$2
  red=$3
  green=$4
  blue=$5
  alpha=$6

  current_red=$(read_plist_value "$domain" "$key.red")
  current_green=$(read_plist_value "$domain" "$key.green")
  current_blue=$(read_plist_value "$domain" "$key.blue")
  current_alpha=$(read_plist_value "$domain" "$key.alpha")

  if [ "$current_red" != "$red" ] || [ "$current_green" != "$green" ] || [ "$current_blue" != "$blue" ] || [ "$current_alpha" != "$alpha" ]; then
    defaults write "$domain" "$key" -dict red "$red" green "$green" blue "$blue" alpha "$alpha"
    changed=1
  fi
}

write_symbolic_hotkey() {
  id=$1
  keycode=$2
  modifiers=$3

  current_enabled=$(read_plist_value com.apple.symbolichotkeys "AppleSymbolicHotKeys.$id.enabled")
  current_param0=$(read_plist_value com.apple.symbolichotkeys "AppleSymbolicHotKeys.$id.value.parameters.0")
  current_param1=$(read_plist_value com.apple.symbolichotkeys "AppleSymbolicHotKeys.$id.value.parameters.1")
  current_param2=$(read_plist_value com.apple.symbolichotkeys "AppleSymbolicHotKeys.$id.value.parameters.2")

  if [ "$current_enabled" != "true" ] || [ "$current_param0" != "65535" ] || [ "$current_param1" != "$keycode" ] || [ "$current_param2" != "$modifiers" ]; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$id" "{ enabled = 1; value = { parameters = (65535, $keycode, $modifiers); type = standard; }; }"
    changed=1
  fi
}

# Disable press-and-hold accents so held keys repeat normally.
write_default NSGlobalDomain ApplePressAndHoldEnabled -bool false 0

# Fastest practical keyboard repeat settings: smaller numbers repeat sooner/faster.
write_default NSGlobalDomain InitialKeyRepeat -int 10 10
write_default NSGlobalDomain KeyRepeat -int 1 1

# Pointer size and color.
write_default com.apple.universalaccess cursorIsCustomized -bool true 1
write_default com.apple.universalaccess mouseDriverCursorSize -float 1.77235746383667 1.77235746383667
write_color_default com.apple.universalaccess cursorFill 1.000000 0.298953 0.000000 1.000000
write_color_default com.apple.universalaccess cursorOutline 1.000000 1.000000 1.000000 1.000000

# Global UI preferences.
write_default NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true 1
write_default NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool false 0

# Dock preferences.
write_default com.apple.dock autohide -bool true 1
write_default com.apple.dock tilesize -int 25 25
write_default com.apple.dock wvous-br-corner -int 14 14
write_default com.apple.dock workspaces-swoosh-animation-off -bool true 1

# Screenshot preferences.
write_default com.apple.screencapture target -string clipboard clipboard

# Finder preferences.
write_default com.apple.finder ShowExternalHardDrivesOnDesktop -bool true 1
write_default com.apple.finder ShowRemovableMediaOnDesktop -bool true 1
write_default com.apple.finder ShowHardDrivesOnDesktop -bool false 0
write_default com.apple.finder FXPreferredGroupBy -string "Date Modified" "Date Modified"
write_default com.apple.finder FXArrangeGroupViewBy -string Name Name

# Window manager / desktop preferences.
write_symbolic_hotkey 118 18 262144 # Control+1: Switch to Desktop 1
write_symbolic_hotkey 119 19 262144 # Control+2: Switch to Desktop 2
write_symbolic_hotkey 120 20 262144 # Control+3: Switch to Desktop 3
write_default com.apple.WindowManager EnableTiledWindowMargins -bool false 0
write_default com.apple.WindowManager GloballyEnabled -bool false 0
write_default com.apple.WindowManager HideDesktop -bool true 1
write_default com.apple.WindowManager StageManagerHideWidgets -bool true 1
write_default com.apple.WindowManager StandardHideDesktopIcons -bool true 1
write_default com.apple.WindowManager StandardHideWidgets -bool true 1

if [ "$changed" -eq 1 ]; then
  echo "Updated macOS defaults. Restart apps, log out/in, or reboot for all changes to fully apply."
fi
