package core.objects;

import openfl.display.DisplayObject;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.utils.Assets;

/**
 * A wrapper for `Sprite` that adds a set of tools to simplify its use (inspired by `FlxGroup`)
 */
class GameObject extends Sprite
{
    /**
     * Members added using the class utilities
     */
    public var members:Array<DisplayObject> = [];

    /**
     * This creates the object to be added to another `Sprite`
     */
    public function new()
    {
        super();

        FlxG.signals.preUpdate.add(_updateHandler);
    }
    
    /**
     * Simply create a bitmap based on an image that can be added directly
     * 
     * @param img Image path
     * @return Resulting `Bitmap`
     */
    public function createBitmap(img:Dynamic):Bitmap
    {
        final bitmap = new Bitmap(Assets.getBitmapData('images/' + img + '.png'));
        bitmap.smoothing = ClientPrefs.data.antialiasing;

        return bitmap;
    }

    /**
     * This simply adds an object to this
     * 
     * @param obj Object to add
     * @return Item Added
     */
    public function add(obj:DisplayObject):DisplayObject
    {
        addChild(obj);

        members.push(obj);

        return obj;
    }

    /**
     * This simply inserts an object at a specific position
     * 
     * @param index Position of the object
     * @param obj Object to insert
     * @return Item Added
     */
    public function insert(index:Int, obj:DisplayObject):DisplayObject
    {
        addChildAt(obj, index);

        members.insert(index, obj);

        return obj;
    }

    /**
     * This simply removes an object from this
     * 
     * @param obj Object to remove
     * @param splice Specifies whether or not to reposition the members after removing the object
     * @return Object Removed
     */
    public function remove(obj:DisplayObject, ?splice:Bool = false):DisplayObject
    {
        removeChild(obj);

        final index = members.indexOf(obj);

        if (splice)
            members.splice(index, 1);
        else
            members[index] = null;

        return obj;
    }

    /**
     * Remove all members belonging to this
     */
    public function clear()
    {
        for (member in members)
            remove(member);

        members.resize(0);
    }

    @:dox(hide)
    private function _updateHandler()
        update(FlxG.elapsed);

    /**
     * This function is called every time Flixel is updated
     * 
     * @param elapsed 
     */
    public function update(elapsed:Float) {}

    /**
     * This removes and deletes the members of this
     */
    public function destroy()
    {
        FlxG.signals.preUpdate.remove(_updateHandler);

        for (member in members)
        {
            remove(member);

            if (member is GameObject)
                cast(member, GameObject).destroy();
        }

        members.resize(0);

        graphics.clear();

        parent?.removeChild(this);
    }
}