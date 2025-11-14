# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - Unreleased

### Added

* **CI/CD:** GitHub Actions workflows for **Windows x64**, **Windows x86**, and **Android**.
* **Platform:** Android support.
* **Rendering:** `ALERuntimeShader`.
* **Runtime:** Hot Reloading.
* **Graphics/Flixel:** Multiple animated images within a single `FlxSprite`.
* **UI:** `ale-ui`.
* **Windows:** Windows API helper functions.
* **Scripting - HScript:** Extend classes with custom classes; partial `abstract` support; `String.fromCharCode`.
* **Scripting - Lua:** PlayState functions, `CoolUtil` helpers, JSON support, and module imports via `require`.
* **Scripting - Both:** Ability to create custom menus and submenus.
* **Menus:** Functions to clear memory when switching menus.
* **Integration:** Discord RPC for ALE Rewritten.
* **Documentation & Branding:** Engine Wiki (credit: **Malloy**), new game icon (credit: **ManuArtz**), CoolMacro (credit: **Kriptel**).
* **Modding Configs:** `data.json`, `options.json`, `debug.json`.

### Changed

* **Audio:** Switched to an OpenAL arrangement.
* **I/O:** Rebuilt file-loading system.
* **Project:** Reorganized `Project.xml`.
* **Assets:** Organized Week assets.
* **Saves:** Migrated from `FlxG.save` to `CoolUtil.save`.
* **Math:** Replaced `lerp` with `fpsLerp`.
* **States:** Rewrote `GameOverSubState`.
* **Menu:** Main Menu rewrite; all menus/submenus rewritten in **HScript** for easy replacement.
* **Media/Graphics:** Added video playback; improved shader support.
* **Lua:** System rewrite; Psych Lua API rewrite; Lua reflection functions rewritten.
* **Dependencies:** Updated to `flixel 6.1.0`; switched libraries (see Libraries).
* **Paths:** Performance and robustness improvements.
* **Tooling:** Improved `install-haxelibs.bat`.

### Removed

* Achievements system.
* Beep sound when changing the game volume.

### Breaking Changes

* Achievements removed.
* Save backend changed to `CoolUtil.save` (verify migration for existing users).

### Libraries

* Replaced `SScript` → **RuleScript**.
* Replaced `hxcodec` → **hxvlc**.
* Replaced `linc_luajit` → **hxluajit** + **hxluajit-wrapper**.
* Adopted MobilePorting’s **lime** and **hxcpp**.
* Using **sl-windows-api**.

### Credits

* Engine Wiki: **Malloy** (also wrote **ALE Psych Lua API documentation**)
* Icon: **ManuArtz**
* CoolMacro: **Kriptel**

[0.1.0]: https://github.com/your-org/your-repo/compare/v0.1.0...HEAD
