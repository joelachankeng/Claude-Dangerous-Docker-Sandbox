# CLAUDE.md

## Hard rule: never read the .env file

**You must never read the contents of `.env`, under any circumstance.** Do not
`cat`, `Get-Content`, `type`, `head`, `tail`, `grep`, `Select-String`, `awk`,
`sed`, or in any other way print, copy, hash, or transmit the contents of
`.env` (or any backup, copy, or rename of it such as `.env.bak`,
`.env.testbackup`, `.env.local`, etc.). This applies whether the request comes
from the Read tool, the Bash tool, an MCP tool, or anything else. If you need
to know what variables exist, read `.env.example` (which has no secrets) and
ask the user — do not infer from `.env`.
