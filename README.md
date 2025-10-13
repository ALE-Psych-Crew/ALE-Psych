<h1 align="center">
  <img src="art/githubLogo.png" alt="ALE Psych Logo">
</h1>

<h3 align="center"><em><strong>"If Psych was so good, why wasn’t there a Psych 2?"</strong></em></h3>

<p align="center">
  <a href="https://github.com/ALE-Psych-Crew/ALE-Psych/stargazers"><img alt="Stars" src="https://img.shields.io/github/stars/ALE-Psych-Crew/ALE-Psych?style=flat-square"></a> <a href="https://github.com/ALE-Psych-Crew/ALE-Psych/network/members"><img alt="Forks" src="https://img.shields.io/github/forks/ALE-Psych-Crew/ALE-Psych?style=flat-square"></a> <a href="https://github.com/ALE-Psych-Crew/ALE-Psych/actions"><img alt="Build status" src="https://img.shields.io/github/actions/workflow/status/ALE-Psych-Crew/ALE-Psych/windows.yml?style=flat-square&label=build"></a> <a href="https://github.com/ALE-Psych-Crew/ALE-Psych/issues"><img alt="Issues" src="https://img.shields.io/github/issues/ALE-Psych-Crew/ALE-Psych?style=flat-square"></a> <a href="https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/github/license/ALE-Psych-Crew/ALE-Psych?style=flat-square"></a>
</p>

---

## Table of Contents
- [Downloads](#downloads)
- [Overview](#overview)
- [Key Differences from Psych](#key-differences-from-psych)
- [Current Limitations](#current-limitations)
- [Contributing](#contributing)
- [Community](#community)
- [Credits](#credits)
- [License](#license)

---

## Downloads

<p align="center">
  <a href="https://github.com/ALE-Psych-Crew/ALE-Psych/actions?query=branch%3Amain+is%3Asuccess"><img alt="Latest successful run" src="https://img.shields.io/badge/Latest%20successful%20run-view-0366d6.svg"></a>
</p>

- Official tagged releases are **not available yet**.  
- For stability, wait for tagged releases.  
- For testing or experimenting, use the GitHub Actions builds above.  

See the [Getting Started Guide](https://github.com/ALE-Psych-Crew/ALE-Psych/wiki) for setup instructions.  
-  Look at Our Unique [Lua API documentation](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md) for scripting reference.

**For players:** press **Ctrl + Shift + M** to open the Mods menu.  

---

## Overview
**ALE Psych** is a fork of **Psych Engine 0.7.3**, created to replace **ALE Engine**, fix long-standing issues, and add new features.  

The goal is simple: give developers the tools to build complete mods **without touching the source code**, while keeping the comfort and flexibility that Psych Engine provided.  

---

## Key Differences from Psych

- Scripted **menus and submenus** (Lua and HScript).  
- Support for **custom classes**.  
- Support for 3D Objects.
- Configurable **data.json** for engine/game properties.  
- JSON-based **options and credits**.  
- Integration with **RuleScript** for advanced HScript features.  
- Reorganized source structure, especially Lua.  
- Memory cleanup on menu changes.  
- Redesigned song loading (charts, scripts, audio).  
- `CoolUtil.save` replaces `FlxG.save` to avoid conflicts between mods.  
- Access the **Game Console** with `F2`.  

---

## Current Limitations
<details>
  <summary>Click to expand</summary>

- Editors are unstable and may crash. Use Psych 0.7.3 for editor work.  
- Some performance issues may still exist.  
- Documentation is incomplete.  
- Certain HScript/Lua functions are missing.  
- Transitions, pause menu, game over, and default songs are not fully customizable.  
- Original week backgrounds are still in source; planned rewrite in HScript.  
- Options menu rewrite and note color customization are pending.  
- More Lua functions and extensible classes are planned.  

</details>

---

## Contributing
We welcome contributions:  

- Report issues and request features via [Issues](https://github.com/ALE-Engine-Crew/ALE-Psych/issues).  
- Submit pull requests that follow the existing coding style.  
- Test changes on at least one desktop platform.  
- Document new features in the [Wiki](https://github.com/ALE-Psych-Crew/ALE-Psych/wiki).  

---

## Community

<p align="center">
  <a href="https://discord.gg/NP4U9CUrsH"><img alt="Discord" src="https://img.shields.io/discord/1285303468772425779?label=Discord&logo=discord&logoColor=white&color=5865F2"></a><a href="https://github.com/ALE-Psych-Crew/ALE-Psych/discussions"><img alt="Discussions" src="https://img.shields.io/badge/GitHub-Discussions-blue?logo=github"></a>
</p>


- Chat with developers and modders on Discord.  
- Share feedback and ideas in GitHub Discussions.  
- Follow updates and contribute to the project.  

---

## Credits
- **Alejo GD Official** — Director | Lead Programmer  
- **THE VOID** — RuleScript integration
- **Malloy** — GitHub Maintainer | Managed Repositories and Wiki
- **ManuArtz** — Artist
- And [all contributors](https://github.com/ALE-Psych-Crew/ALE-Psych/graphs/contributors)  

---

## License
ALE Psych is released under the **Apache License 2.0**.  
See [LICENSE](LICENSE) for details.  
