# env.nu
#
# Installed by:
# version = "0.102.0"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.

$env.Path = ($env.Path | append '~/.npm-global/bin')
$env.Path = ($env.Path | prepend '~/bin')
$env.Path = ($env.Path | prepend '~/.local/bin/')
$env.Path = ($env.Path | prepend '~/.local/share/aquaproj-aqua/bin')
$env.AQUA_GLOBAL_CONFIG = ($env.HOME | path join '.config/aquaproj-aqua/aqua.yaml')
