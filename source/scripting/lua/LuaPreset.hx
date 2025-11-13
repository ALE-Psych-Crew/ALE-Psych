package scripting.lua;

import scripting.lua.callbacks.*;

class LuaPreset
{
    public function new(lua:LuaScript)
    {
        new LuaSprite(lua);

        new LuaGlobal(lua);

        new LuaReflect(lua);

        new LuaCoolUtil(lua);

        new LuaBasic(lua);

        new LuaRemoved(lua);

        new LuaMouse(lua);

        new LuaTween(lua);

        new LuaTimer(lua);

        new LuaColor(lua);

        new LuaPaths(lua);

        new LuaCamera(lua);

        new LuaObject(lua);

        new LuaSound(lua);

        new LuaDiscord(lua);

        new LuaAnimate(lua);

        new LuaText(lua);

        new LuaShader(lua);

        new LuaKeyManager(lua);

        new LuaSave(lua);

        new LuaFileSystem(lua);

        new LuaStringTools(lua);

        new LuaVariables(lua);

        new LuaJson(lua);

        #if HSCRIPT_ALLOWED
        new LuaRuleScript(lua);
        #end

        new LuaWindowsAPI(lua);

        #if VIDEOS_ALLOWED
        new LuaVideoSprite(lua);
        #end
    }
}