# Claude Dangerous Docker
## _A sandboxed Docker container for running Claude Code in dangerous mode, with Playwright browser automation._


[![Made with Docker](https://img.shields.io/badge/Made%20with-Docker-2496ED?logo=docker&logoColor=white)](#)
[![Windows only](https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows&logoColor=white)](#)
[![Claude](https://img.shields.io/badge/Claude-D97757?logo=claude&logoColor=fff)](#)
[![Command Prompt](https://img.shields.io/badge/Command%20Prompt-4D4D4D?logo=windowsterminal&logoColor=fff)](#)


This project runs Claude Code inside Docker. **It is for Windows only** — it relies on `.cmd` scripts and a Windows X server.

## Table of Contents

- [Problem](#problem)
- [Solution](#solution)
- [Tech](#tech)
- [Installation](#installation)
- [VcXsrv Setup](#vcxsrv-setup)
- [Scripts](#scripts)
- [Development](#development)
- [License](#license)

## Problem

Claude Code has a `--dangerously-skip-permissions` flag. It lets Claude edit files and run commands without stopping to ask for approval.

That is great for letting Claude work uninterrupted — but running it that way on your real machine is risky. Claude can read, change, or delete anything on the computer, and run any command, with no prompt.

I want that hands-off autonomy without giving it the keys to my actual machine.

## Solution

- Runs Claude Code with `--dangerously-skip-permissions` inside an isolated Docker container — it can do whatever it wants, but only to the container and the single project folder you mount into it.
- Bundles Playwright MCP with a real Chrome browser, forwarded to the Windows desktop through an X server so you can watch the automation happen.
- Persists your login with a long-lived token, so Claude never asks you to sign in again.
- Includes double-click `.cmd` scripts to install VcXsrv, start the container, and rebuild it from scratch.
- Clone the folder to get a fresh sandbox for any new project — and run as many of them at once as you want.

## Tech


- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Node.js 22](https://hub.docker.com/_/node) — container base image
- [Claude Code](https://docs.claude.com/en/docs/claude-code/overview)
- [@playwright/mcp](https://www.npmjs.com/package/@playwright/mcp)
- [VcXsrv](https://sourceforge.net/projects/vcxsrv/) — X server for the headed browser window

## Installation

Claude Dangerous Docker requires [Docker Desktop](https://www.docker.com/products/docker-desktop/) to run, plus [VcXsrv](https://sourceforge.net/projects/vcxsrv/) for the Playwright browser (see VcXsrv Setup below).

Build the image:

```
docker compose build
```

Generate a login token and follow the browser link it prints:

```
docker compose run --rm claude claude setup-token
```

Copy `.env.example` to `.env` and paste the token into `CLAUDE_CODE_OAUTH_TOKEN`.

That is it — see Scripts below to run it.

## VcXsrv Setup

VcXsrv is the X server that lets the container draw the Playwright browser window on your Windows desktop. Without it, Claude still runs — you just will not see the browser.

Install it from the command line with [winget](https://learn.microsoft.com/windows/package-manager/winget/):

```
winget install --id marha.VcXsrv -e --accept-package-agreements --accept-source-agreements
```

Or double-click `install-vcxsrv.cmd`, which runs that command for you.

Then configure it:

- Launch **XLaunch** from the Start menu.
- **Display settings:** choose _Multiple windows_, leave the display number at `0`, click Next.
- **Client startup:** choose _Start no client_, click Next.
- **Extra settings:** check _Disable access control_ — this is required, or the container cannot connect. Click Next.
- Click _Save configuration_ to keep an `.xlaunch` file you can double-click next time, then Finish.
- When Windows Firewall asks, allow VcXsrv on Private networks.

VcXsrv must be running before you start Claude. The start scripts warn you if it is not.

## Scripts

The project ships with four Windows batch files. Double-click any of them.

- **`install-vcxsrv.cmd`** — Installs VcXsrv through winget. You only need this once, during setup.
- **`start-claude-dangerously.cmd`** — Launches Claude with `--dangerously-skip-permissions`, so it never stops to ask before editing files or running commands. Starts Docker Desktop and builds the image first if needed.
- **`start-claude-normal.cmd`** — Launches Claude in normal mode, where it asks for approval before editing files or running commands. Same Docker and image checks as the dangerous script.
- **`rebuild-claude.cmd`** — Deletes this project's container, volumes, and image, then rebuilds the image from scratch with `--no-cache`. It asks for confirmation first. Use it for a clean slate when something breaks.

To start Claude without a script, run it from the project folder: `docker compose run --rm claude` for dangerous mode, or `docker compose run --rm claude claude` for normal mode.

## Development

Want to contribute? Great!

Fork it, edit the `Dockerfile`, and send a PR — or just send me a message.

## License

MIT

**Free Software, Hell Yeah!**
