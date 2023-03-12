curl https://i.ip.dev.health/twpayne/chezmoi! | bash
chezmoi init git@github.com:jpambrun/dotfiles


sudo pacman -S helix



return {
  wsl_domains = {
    {
      name = 'Arch',
      distribution = 'Arch',
      default_cwd = "~"
    },
  },
  default_domain = 'Arch',
  color_scheme = 'Ayu Mirage',
 
}