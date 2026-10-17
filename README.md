# dotfiles

My personal config, managed with [chezmoi](https://chezmoi.io).

## Setup on a new machine

```sh
chezmoi init --apply niranjan279
```

## Usage

```sh
chezmoi edit --apply ~/.config/foot/foot.ini   # edit a managed file
chezmoi add ~/.config/<app>/<file>             # start tracking a new one
chezmoi update                                 # pull latest + apply
chezmoi diff                                   # see what would change
```
