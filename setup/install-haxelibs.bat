@echo off
cd ..
@echo on
echo Installing dependencies

@if not exist ".haxelib\" mkdir .haxelib

echo Installing dependencies...

haxelib git hxcpp https://github.com/AlejoGDOfficial/MobilePorting-hxcpp

haxelib install tjson 1.4.0
haxelib install yaml 2.0.1

haxelib git lime https://github.com/AlejoGDOfficial/Lime

haxelib install openfl 9.4.1

haxelib git away3d https://github.com/ALE-Psych-Crew/away3d

haxelib install flixel 6.1.1 --skip-dependencies
haxelib install flixel-addons 3.3.2
haxelib install flixel-ui 2.6.4
haxelib install flixel-tools 1.5.1

haxelib install ale-ui 1.0.3

haxelib git flxanimate https://github.com/Dot-Stuff/flxanimate 7da385ca7fd8d8067aac03bc39798d37c5598e45

haxelib git flxsoundfilters https://github.com/TheZoroForce240/FlxSoundFilters a89bb537684111a6ff85737981f4b2d8ef4b4f68
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 1966f8fbbbc509ed90d4b520f3c49c084fc92fd6
haxelib git grig.audio https://github.com/FunkinCrew/grig.audio 8567c4dad34cfeaf2ff23fe12c3796f5db80685e

haxelib install funkin-modchart 1.2.4 --skip-dependencies

haxelib install hxvlc 2.2.5 --skip-dependencies

haxelib git hscript https://github.com/HaxeFoundation/hscript 92ffe9c519bbccf783df0b3400698c5b3cc645ef
haxelib git rulescript https://github.com/Kriptel/RuleScript 4f4c2b89a728b55154fde129474b454da921f65f --skip-dependencies

haxelib install hxluajit 1.0.5 --skip-dependencies
haxelib install hxluajit-wrapper 1.0.0 --skip-dependencies

haxelib git ale-ui https://github.com/ALE-Psych-Crew/ALE-UI
haxelib git flixel-away3d https://github.com/ALE-Psych-Crew/Flixel-Away-3D

haxelib install hxdiscord_rpc 1.3.0 --skip-dependencies

haxelib install sl-windows-api 1.2.0
haxelib install extension-haptics 1.0.4 --skip-dependencies

echo Finished!

pause