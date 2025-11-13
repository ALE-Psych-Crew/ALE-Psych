# 0.1.0 (14/11/2025)

## Additions
- GitHub Actions workflows added (for Windows x64, Windows x32, and Android)
- Functions related to the **Windows API** were added
- Functions to clear memory when changing menus have been added
- Support for Extending Classes with Custom Classes
- Implement `ALERuntimeShader`
- Support for using some `abstracts` in HScript
- ALE Rewritten’s Discord RPC
- Support for Multiple Animated Images in a Single `FlxSprite`
- Implement Hot Reloading
- New Game Icon [(Credit to ManuArtz)](https://github.com/ManuArtXD)
- CoolMacro [(Credit to Kriptel)](https://github.com/Kriptel)
- Support for `PlayState` Functions in Lua
- CoolUtil Functions in Lua
- JSON Support in Lua
- Functions to Improve File Search
- Support for `String.fromCharCode` in HScript
- Implement `ale-ui`
- Android Support
- Implement Engine Wiki [(Credit to Malloy)](https://github.com/immalloy)

## Improvements
- Improved `install-haxelibs.bat`
- The **FPS counter** was rewritten so that it could store more information and be customizable
- An OpenAL arrangement was used to improve the audio
- The file load system has been rebuilt
- `Project.xml` was reorganized
- Organize Week Assets
- Switch from `FlxG.save` to `CoolUtil.save`
- Use `fpsLerp` instead of `lerp`
- New Song and Week Loading System
- `GameOverSubState` Rewrite
- Main Menu Rewrite
- Video Support and Improved Shader Support
- Lua Rewrite
- Psych Lua API Rewrite
- Rewrite of Lua Reflection Functions
- Update to `flixel 6.1.0`
- Improvements to `Paths`
- All menus and submenus were rewritten in HScript so they can be easily replaced

## Removals
- The Achievements support has been removed
- The annoying beep sound that plays when changing the game volume has been removed

## Modding
- Added `data.json`
- Added `options.json`
- Added `debug.json`

## Scripting
- The `Lua` system was rebuilt
- The `HScript` system was rebuilt
- `HScript`: Support for Custom Classes has been added
- `Lua`: Added support for importing modules with `require`
- `Lua & HScript`: Support for creating custom menus and submenus has been added
- PlayState Functions in Scripts

## Libraries
- `SScript` was replaced by `RuleScript`
- Replaced `hxcodec` with `hxvlc`
- Replace `linc_luajit` with `hxluajit` and `hxluajit-wrapper`
- MobilePorting's `lime` was used
- MobilePorting's `hxcpp` was used
- `sl-windows-api` was used
