``` bash
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
useradd -m -G wheel -s /bin/bash jpambrun
passwd jpambrun
exit
Arch.exe config --default-user jpambrun

sudo pacman -Sy archlinux-keyring 
sudo pacman -Syu
sudo pacman -S which git openssh eza helix wget


ssh-keygen # add key to github

mkdir bin
cd bin
curl https://i.ip.dev.health/twpayne/chezmoi | bash
./chezmoi init git@github.com:jpambrun/dotfiles
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

ssh-keygen -f ~/.ssh/vida -t ed25519