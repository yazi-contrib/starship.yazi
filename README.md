# stats.yazi

> A status line for Yazi with the path, owner and modification time, and optionally your starship prompt.

[![CI](https://github.com/yazi-contrib/stats.yazi/actions/workflows/ci.yml/badge.svg)](https://github.com/yazi-contrib/stats.yazi/actions/workflows/ci.yml) [![Release](https://img.shields.io/github/v/release/yazi-contrib/stats.yazi)](https://github.com/yazi-contrib/stats.yazi/releases) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Dependencies

- [Yazi](https://yazi-rs.github.io) (the latest release)
- [starship](https://starship.rs) - only with `starship = true`

## Installation

```sh
ya pkg add yazi-contrib/stats
```

Or by hand, into the folder of your configuration of Yazi:

```sh
git clone https://github.com/yazi-contrib/stats.yazi ~/.config/yazi/plugins/stats.yazi
```

## Usage

In `init.lua`:

```lua
require("stats"):setup()
```

The status line shows the path of the hovered file on the left, and on the right the owner and the group, and
the modification time.

## Configuration

```lua
require("stats"):setup {
  starship = true,                                   -- the prompt of starship for the folder, off by default
  starship_config = "~/.config/starship/yazi.toml",  -- a STARSHIP_CONFIG of its own, optional
  owner = true,                                      -- the owner and the group
  mtime = true,                                      -- the modification time
}
```

| Option            | Default | Meaning                                                                  |
|-------------------|---------|--------------------------------------------------------------------------|
| `starship`        | `false` | Run `starship prompt` for the folder and show its output at the right    |
| `starship_config` | none    | The `STARSHIP_CONFIG` for that run, so that Yazi has a prompt of its own |
| `owner`           | `true`  | Show the owner and the group                                             |
| `mtime`           | `true`  | Show the modification time                                               |

The prompt is made again when the folder changes, not on every hover. A starship that is missing, or fails,
shows nothing.

## How it works, and what can break

The plugin changes `Status.name` and adds the segments to the right of `Status`. If a new release of Yazi
changes the status line, the plugin has to follow, so it is tested against the latest Yazi in CI.

## Development

```sh
nix develop
bats tests/
```

The tests start Yazi in a detached tmux session with a configuration of its own that loads the plugin from
this folder, and fail on an error of Lua, a deprecated API, or a start that does not hold.

## The yazi-contrib ecosystem

Plugins of Yazi, one repository for each: `viewer.yazi`, `layout.yazi`, `stats.yazi`.

## License

MIT
