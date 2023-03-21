curl https://i.ip.dev.health/twpayne/chezmoi! | bash
chezmoi init git@github.com:jpambrun/dotfiles

```
sudo pacman -S helix
```

``` lua
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
```

```
sudo pacman -S podman
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $(whoami)
echo "wsl.exe -u root -e mount --make-rshared /" | sudo tee  /etc/profile.d/02-shared-root.sh
sudo chmod +x  /etc/profile.d/02-shared-root.sh
podman system migrate
```