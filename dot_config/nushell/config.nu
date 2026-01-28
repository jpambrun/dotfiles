# config.nu
#
# Installed by:
# version = "0.102.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.

$env.config.history.file_format = "sqlite"
$env.config.history.isolation = true
$env.config.buffer_editor = "hx"
$env.config.show_banner = false

def --env aw [] {
  # Check if gum is available
  if (which gum | is-empty) {
    echo "gum is required for this function. Please install it first (e.g., via your package manager)."
    return
  }

  # Parse profiles from ~/.aws/config
  let config_path = ($env.HOME | path join '.aws/config')
  if not ($config_path | path exists) {
    echo $"AWS config file not found at ($config_path)"
    return
  }
  let profiles = (open $config_path 
    | lines 
    | where {|line| $line =~ '^\[profile ' or $line =~ '^\[default\]'} 
    | each {|line| $line | str replace -r '^\[profile (.+)\]$|\[(.+)\]$' '${1}${2}'})

  if ($profiles | is-empty) {
    echo "No AWS profiles found in config"
    return
  }

  # Use gum for interactive selection
  let selected = (gum choose --no-show-help --header "Select AWS Profile:" ...$profiles | str trim)

  # Set the profile in the environment
  $env.AWS_PROFILE = $selected
  echo $"AWS profile set to: ($selected)"
}
