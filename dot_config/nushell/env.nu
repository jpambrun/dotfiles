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

$env.Path = ($env.Path | prepend ($env.HOME | path join '.local' 'bin'))
$env.Path = ($env.Path | prepend ($env.HOME | path join '.bun' 'bin'))
$env.Path = ($env.Path | prepend '~/bin')

# Use Linux Node/npm in WSL instead of Windows Scoop npm from /mnt/c.
$env.FNM_DIR = ($env.HOME | path join '.local' 'share' 'fnm')
$env.Path = ($env.Path | prepend ($env.FNM_DIR | path join 'aliases' 'default' 'bin'))

$env.AWS_PROFILE = ($env.AWS_PROFILE? | default 'dev')

# Use pass(1) for cfl/jtk credentials instead of the encrypted file keyring.
$env.ATLASSIAN_CLI_KEYRING_BACKEND = 'pass'

# Let GPG/pass prompt correctly in interactive shells, then cache in gpg-agent.
let tty_result = (^tty | complete)
if $tty_result.exit_code == 0 {
    $env.GPG_TTY = ($tty_result.stdout | str trim)
    gpg-connect-agent updatestartuptty /bye | ignore
}

let secret_file = ($nu.default-config-dir | path join 'secret.toml')
if ($secret_file | path exists) {
    load-env (open $secret_file)
}
