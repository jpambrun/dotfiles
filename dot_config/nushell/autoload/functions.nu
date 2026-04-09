# AWS profile selector function
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

def --env awmode [mode?: string] {
  let current = if "AWS_ACCESS_LEVEL" in $env and (($env.AWS_ACCESS_LEVEL | str trim) != "") {
    $env.AWS_ACCESS_LEVEL | str trim
  } else {
    "ro"
  }

  if ($mode | is-empty) {
    echo $current
    return
  }

  if $mode == "toggle" {
    let next = if $current == "ro" { "admin" } else { "ro" }
    $env.AWS_ACCESS_LEVEL = $next
    echo $"AWS access level set to: ($next)"
    return
  }

  if $mode == "ro" or $mode == "admin" {
    $env.AWS_ACCESS_LEVEL = $mode
    echo $"AWS access level set to: ($mode)"
    return
  }

  print stderr "Usage: awmode [ro|admin|toggle]"
  return 1
}
