# Ethan's Config

## Installation
1. Install [Zsh](https://www.zsh.org/), [Git](https://git-scm.com/) and [JJ](https://www.jj-vcs.dev/).

2. Fetch the config:
```shell
mkdir -p ~/.config
cd ~/.config
jj git init
jj git remote add origin https://github.com/etlhsu/.config.git
jj git fetch
```

3. Set up Zsh, then restart your terminal:
```shell
echo "source ~/.config/zsh/.zshenv" >> ~/.zshenv
```

4. Run the init script:
```shell
init
```
