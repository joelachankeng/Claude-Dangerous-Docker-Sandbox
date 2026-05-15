# Claude Dangerous Docker Sandbox

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
- [Login Token](#login-token)
- [VcXsrv Setup](#vcxsrv-setup)
- [Scripts](#scripts)
- [Development](#development)
- [Disclaimer](#disclaimer)
- [License](#license)

## Problem

Claude Code has a `--dangerously-skip-permissions` flag. It lets Claude edit files and run commands without stopping to ask for approval.

That is great for letting Claude work uninterrupted — but running it that way on your real machine is risky. Claude can read, change, or delete anything on the computer, and run any command, with no prompt.

It is not only Claude itself. Any real project pulls in dozens of packages and command-line tools, and lately a lot of them have been getting compromised — malicious code slipped into popular packages, and new vulnerabilities surfacing all the time [(see disclaimer)](#disclaimer). The moment Claude installs or runs that code, it is running on your machine too.

I want that hands-off autonomy without giving Claude — or anything it downloads — the keys to my actual machine. Running Claude and the project inside an isolated container keeps all of it walled off, so an exploit cannot reach my files, my credentials, or the rest of my system [(see disclaimer)](#disclaimer).

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

Then set up your login token so Claude does not ask you to sign in every time — see [Login Token](#login-token) below.

That is it — see [Scripts](#scripts) below to run it.

## Login Token

Every time the container starts, Claude asks you to log in. To stop that for good, set up a long-lived login token once. (Its proper name is an OAuth token — "long-lived" just means it does not expire when the session ends.)

There is a trap in the middle of this, so follow the steps in order:

1. Run the token setup command:

   ```
   docker compose run --rm claude claude setup-token
   ```

2. The terminal prints a URL. Open it in a browser — click it, or copy and paste it.

3. Log in and approve. The browser then shows you a code. **This code is _not_ your long-lived token** — it is a short-lived browser code for the next step.

4. Go back to the terminal, paste in that browser code, and press Enter.

5. Claude exchanges the code and prints your real long-lived token. **It starts with `sk-ant-oat01-`.** If what you have does not start with `sk-ant-`, it is almost certainly the browser code from step 3 — not the token. Run the command again and watch for the `sk-ant-oat01-` line at the very end.

6. Copy `.env.example` to `.env`.

7. Open `.env` and set `CLAUDE_CODE_OAUTH_TOKEN` to the `sk-ant-oat01-` token from step 5.

8. Double-click one of the `start-claude-*.cmd` scripts ([see scripts](#scripts)) to start Claude in the container. Claude should not prompt you to log in.

9. If Claude still asks you to log in after step 8, the container is probably holding stale credentials from an earlier attempt — an old `.claude` folder and session files cached inside its volume. Run `rebuild-claude.cmd` to wipe the volume and rebuild clean, then repeat step 8.

## VcXsrv Setup

VcXsrv is the X server that lets the container draw the Playwright browser window on your Windows desktop. Without it, Claude still runs — you just will not see the browser.

Double-click `install-vcxsrv.cmd` to install it.

Or run the same command yourself with [winget](https://learn.microsoft.com/windows/package-manager/winget/):

```
winget install --id marha.VcXsrv -e --accept-package-agreements --accept-source-agreements
```

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

## Disclaimer

This is a personal project. It reduces risk — it does not eliminate it. Use it with a clear understanding of what the container does and does not protect.

**Supply-chain risk is real.** Packages from registries like npm and PyPI do get compromised, through maintainer account takeovers, typosquatting, and malicious updates. An npm `postinstall` script runs arbitrary code the moment a package is installed — before the project is ever run. The Problem section is not an exaggeration.

**A container reduces the blast radius — it does not "prevent" everything.** Phrases in this README like "walled off" and "an exploit cannot reach my system" describe the goal, not an absolute guarantee.

What the container protects:

- Malicious code cannot see or touch the rest of your machine — other folders, other projects, your Windows user profile, SSH keys, saved browser passwords. It only sees the container.
- On Windows, Docker Desktop runs the container inside a WSL2 virtual machine, so there is a VM boundary as well, not just a container boundary.
- The container is disposable. `rebuild-claude.cmd` destroys and recreates it.

What the container does not protect:

- **The mounted project folder is fully exposed.** The project directory is bind-mounted into the container with read and write access. Malicious code can read, change, encrypt, or steal anything in the project you mount. The container protects everything except the folder you point it at.
- **Outbound internet is open.** Malicious code can send data to a remote server. The container does not firewall outbound traffic, and Claude and Playwright both need internet to function.
- **Your Anthropic token is reachable.** `CLAUDE_CODE_OAUTH_TOKEN` lives in the container environment, and `.env` sits in the mounted project folder. Malicious code inside the container can read and exfiltrate it. To avoid this, remove the token from `.env` and log in interactively instead.
- **Container escape is possible.** It is rare, but a container is not as strong a security boundary as a full virtual machine.

The accurate mental model: anything that goes wrong is confined to the container and the single project folder mounted into it, and kept away from the rest of your system. That is a large and worthwhile reduction in risk — but the project folder and the injected token are inside the blast zone, and nothing here is a guarantee. Use it at your own risk.

## License

MIT

**Free Software, Hell Yeah!**
