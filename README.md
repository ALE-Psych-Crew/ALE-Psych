<h1 align="center">
  <img src="art/githubLogo.png" alt="ALE Psych Logo">
</h1>

<h3 align="center"><em><strong>"If Psych was so good, why wasn’t there a Psych 2?"</strong></em></h3>

<p align="center">
  <a href="https://github.com/ALE-Psych-Crew/ALE-Psych/stargazers"><img alt="Stars" src="https://img.shields.io/github/stars/ALE-Psych-Crew/ALE-Psych?style=flat-square"></a> <a href="https://github.com/ALE-Psych-Crew/ALE-Psych/network/members"><img alt="Forks" src="https://img.shields.io/github/forks/ALE-Psych-Crew/ALE-Psych?style=flat-square"></a> <a href="https://github.com/ALE-Psych-Crew/ALE-Psych/actions" <a href="https://github.com/ALE-Psych-Crew/ALE-Psych/issues"><img alt="Issues" src="https://img.shields.io/github/issues/ALE-Psych-Crew/ALE-Psych?style=flat-square"></a> <a href="https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/github/license/ALE-Psych-Crew/ALE-Psych?style=flat-square"></a>
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

### Latest Builds
[![Windows x64](https://img.shields.io/badge/Windows%20x64-LATEST-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://nightly.link/ALE-Psych-Crew/ALE-Psych/workflows/main.yaml/main/Windows%20Build.zip)
[![Windows x32](https://img.shields.io/badge/Windows%20x32-LATEST-00A4EF?style=for-the-badge&logo=windows&logoColor=white)](https://nightly.link/ALE-Psych-Crew/ALE-Psych/workflows/main.yaml/main/Windows%20Build%20(32%20Bits).zip)
[![Android](https://img.shields.io/badge/Android-LATEST-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://nightly.link/ALE-Psych-Crew/ALE-Psych/workflows/main.yaml/main/Android%20Build.zip)
[![Linux](https://img.shields.io/badge/Linux-LATEST-FCC624?style=for-the-badge&logo=linux&logoColor=black)](https://nightly.link/ALE-Psych-Crew/ALE-Psych/workflows/main.yaml/main/Linux%20Build.zip)

### Build Notes

- **Tagged releases are not yet available.**  
- For a more stable experience, consider waiting for official releases.  
- For testing and development, use the builds provided above via GitHub Actions.  

### Additional Resources

- [Getting Started Guide](https://github.com/ALE-Psych-Crew/ALE-Psych/wiki) – Installation and setup instructions  
- [Lua API Documentation](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md) – In-depth scripting reference

### Quick Tip for Players

To open the Mods menu in-game, press **Ctrl + Shift + M**.

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

- Documentation is incomplete.  
- Certain HScript/Lua functions are missing.
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
- **THE VOID** — Co-Founder
- **Kriptel** — RuleScript integration
- **Malloy** — GitHub Maintainer | Managed Repositories and Wiki
- **ManuArtz** — Artist
- And [all contributors](https://github.com/ALE-Psych-Crew/ALE-Psych/graphs/contributors)  

---

## License
ALE Psych is released under the **Apache License 2.0**.  
See [LICENSE](LICENSE) for details.  
