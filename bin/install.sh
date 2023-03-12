curl https://i.ip.dev.health/dandavison/delta | bash
curl https://i.ip.dev.health/watchexec/watchexec | bash
curl https://i.ip.dev.health/multiprocessio/dsq | bash
curl https://i.ip.dev.health/antonmedv/fx | bash
curl https://i.ip.dev.health/TomWright/dasel | bash
curl https://i.ip.dev.health/devspace-sh/devspace | bash
curl https://i.ip.dev.health/sharkdp/bat | bash
curl https://i.ip.dev.health/carvel-dev/ytt | bash
curl https://i.ip.dev.health/denoland/deno | bash
curl https://i.ip.dev.health/sachaos/viddy | bash
curl https://i.ip.dev.health/cantino/mcfly | bash
curl https://i.ip.dev.health/junegunn/fzf | bash
curl https://i.ip.dev.health/ogham/exa | bash
curl https://i.ip.dev.health/sharkdp/fd | bash
curl https://i.ip.dev.health/BurntSushi/ripgrep?as=rg | bash
curl https://i.ip.dev.health/derailed/k9s | bash
curl https://i.ip.dev.health/grafana/k6 | bash
curl https://i.ip.dev.health/casey/just | bash
curl https://i.ip.dev.health/twpayne/chezmoi | bash
curl https://i.ip.dev.health/mutagen-io/mutagen-compose | bash
curl https://i.ip.dev.health/zellij-org/zellij | bash


curl -L https://github.com/helix-editor/helix/releases/download/22.12/helix-22.12-x86_64-linux.tar.xz | tar xJf - --strip-components=1 -C /tmp
mv /tmp/hx .
mv /tmp/runtime .


curl -L https://github.com/mutagen-io/mutagen/releases/download/v0.17.0/mutagen_linux_amd64_v0.17.0.tar.gz | tar xzf - -C /tmp
mv /tmp/mutagen* .
