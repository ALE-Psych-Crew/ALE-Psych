<h1 align="center">
  <img src="art/githubLogo.png" alt="ALE Psych Logo">
</h1>

<h3 align="center"><em><strong>"If Psych was so good, why wasn’t there a Psych 2?"</strong></em></h3>

<p align="center">
    <img alt="Stars" src="https://img.shields.io/github/stars/ALE-Psych-Crew/ALE-Psych?style=flat-square" style=";padding-right:10px;">
    <img alt="Forks" src="https://img.shields.io/github/forks/ALE-Psych-Crew/ALE-Psych?style=flat-square" style=";padding-right:10px;">
    <img alt="Issues" src="https://img.shields.io/github/issues/ALE-Psych-Crew/ALE-Psych?style=flat-square" style=";padding-right:10px;">
    <img alt="License" src="https://img.shields.io/github/license/ALE-Psych-Crew/ALE-Psych?style=flat-square">
</p>

---

## Downloads

### Latest Builds

[![Windows](https://img.shields.io/badge/Windows-LATEST-0078D6?style=for-the-badge)](https://nightly.link/ALE-Psych-Crew/ALE-Psych/workflows/builds.yaml/main/Windows%20Build.zip)
[![Windows x32](https://img.shields.io/badge/Windows%20x32-LATEST-00A4EF?style=for-the-badge)](https://nightly.link/ALE-Psych-Crew/ALE-Psych/workflows/builds.yaml/main/Windows%20x32%20Build.zip)
[![Android](https://img.shields.io/badge/Android-LATEST-3DDC84?style=for-the-badge)](https://nightly.link/ALE-Psych-Crew/ALE-Psych/workflows/builds.yaml/main/Android%20Build.zip)
[![iOS](https://img.shields.io/badge/iOS-LATEST-9B9B9B?style=for-the-badge)](https://nightly.link/ALE-Psych-Crew/ALE-Psych/workflows/builds.yaml/main/iOS%20Build.zip)
[![Linux](https://img.shields.io/badge/Linux-LATEST-FCC624?style=for-the-badge)](https://nightly.link/ALE-Psych-Crew/ALE-Psych/workflows/builds.yaml/main/Linux%20Build.zip)
[![MacOS](https://img.shields.io/badge/MacOS-LATEST-9B9B9B?style=for-the-badge)](https://nightly.link/ALE-Psych-Crew/ALE-Psych/workflows/builds.yaml/main/MacOS%20Build.zip)
[![MacOS x64](https://img.shields.io/badge/MacOS%20x64-LATEST-7A7A7A?style=for-the-badge)](https://nightly.link/ALE-Psych-Crew/ALE-Psych/workflows/builds.yaml/main/MacOS%20x64%20Build.zip)

---

## Table of Contents
- [Downloads](#downloads)
- [Overview](#overview)
- [Key Differences from Psych](#key-differences-from-psych)
- [Current Limitations](#current-limitations)
- [Contributing](#contributing)
- [Community](#community)
- [Community Scripts and Tools](#community-scripts-and-tools)
- [Credits](#credits)
- [License](#license)

### Build Notes

- **Tagged releases are not yet available.**  
- For a more stable experience, consider waiting for official releases.  
- For testing and development, use the nightly builds provided above.

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
- Support for **3D objects**.  
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
- Certain HScript/Lua functions are missing.  
</details>

---

## Contributing

We welcome contributions:

- Report issues and request features via [Issues](https://github.com/ALE-Psych-Crew/ALE-Psych/issues).  
- Submit pull requests following the existing coding style.  
- Test changes on at least one desktop platform.  
- Document new features in the [Wiki](https://github.com/ALE-Psych-Crew/ALE-Psych/wiki).  

---

## Community

<p align="center" style="margin:0;padding:0;">
  <a href="https://discord.gg/NP4U9CUrsH" style="display:inline-block;margin:0;padding:0;">
    <img alt="Discord"
      src="https://img.shields.io/discord/1285303468772425779?label=Discord&logo=discord&logoColor=white&color=5865F2&style=for-the-badge">
  </a><a href="https://github.com/ALE-Psych-Crew/ALE-Psych/discussions" style="display:inline-block;margin:0;padding:0;">
    <img alt="Discussions"
      src="https://img.shields.io/badge/GitHub_Discussions-000?logo=github&style=for-the-badge">
  </a>
</p>

- Chat with developers and modders on Discord.  
- Share feedback and ideas in GitHub Discussions.  
- Follow updates and contribute to the project.  

---

## Community Scripts and Tools

<p align="left" style="margin:0;padding:0;">
  <a href="https://github.com/topics/ale-psych" style="display:inline-block;margin:0;padding:0;">
    <img alt="Community Scripts"
      src="https://img.shields.io/badge/GitHub_Topic-ale--psych-30363D?style=for-the-badge&logo=github&logoColor=white">
  </a><a href="https://discord.com/channels/1285303468772425779/1385460090672386079" style="display:inline-block;margin:0;padding:0;">
    <img alt="Discord Scripts Channel"
      src="https://img.shields.io/badge/Discord_Scripts_Channel-5865F2?style=for-the-badge&logo=discord&logoColor=white">
  </a>
</p>

The **`ale-psych` GitHub topic** groups community-created scripts, tools, addons, utilities, and extensions for ALE Psych.  
Repositories tagged with `ale-psych` automatically appear in this collection.

The **Discord Scripts Channel** is dedicated to sharing scripts, tools, and development resources contributed by the community.

---

## Credits

- **Alejo GD Official** — Director | Lead Programmer  
- **THE VOID** — Co-Founder  
- **Kriptel** — RuleScript Integration  
- **Malloy** — GitHub Maintainer | Managed Repositories and Wiki  
- **ManuArtz** — Artist  
- And [all contributors](https://github.com/ALE-Psych-Crew/ALE-Psych/graphs/contributors)

---

## License

ALE Psych is released under the **Apache License 2.0**.  
See [LICENSE](LICENSE) for details.
