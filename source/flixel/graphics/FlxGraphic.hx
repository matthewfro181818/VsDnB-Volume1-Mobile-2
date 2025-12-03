package flixel.graphics;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxFrameCollectionType;
import flixel.graphics.frames.FlxImageFrame;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.display.BitmapData;
import flixel.system.FlxAssets.FlxShader;
import haxe.ds.EnumValueMap;

/**
 * `BitmapData` wrapper which is used for rendering.
 * It stores info about all frames, generated for specific `BitmapData` object.
 */
class FlxGraphic implements IFlxDestroyable
{
	public static var defaultPersist:Bool = false;

	/** MAP WAS MISSING IN YOUR VERSION — REQUIRED **/
	var frameCollections:EnumValueMap<FlxFrameCollectionType, Array<Dynamic>> =
		new EnumValueMap();

	public static function fromAssetKey(Source:String, Unique:Bool = false, ?Key:String, Cache:Bool = true):FlxGraphic
	{
		var bitmap:BitmapData = null;

		if (!Cache)
		{
			bitmap = FlxG.assets.getBitmapData(Source);
			if (bitmap == null) return null;
			return createGraphic(bitmap, Key, Unique, Cache);
		}

		var key:String = FlxG.bitmap.generateKey(Source, Key, Unique);
		var graphic:FlxGraphic = FlxG.bitmap.get(key);
		if (graphic != null) return graphic;

		bitmap = FlxG.assets.getBitmapData(Source);
		if (bitmap == null) return null;

		graphic = createGraphic(bitmap, key, Unique);
		graphic.assetsKey = Source;
		return graphic;
	}

	public static function fromClass(Source:Class<BitmapData>, Unique:Bool = false, ?Key:String, Cache:Bool = true):FlxGraphic
	{
		var bitmap:BitmapData = null;

		if (!Cache)
		{
			bitmap = FlxAssets.getBitmapFromClass(Source);
			return createGraphic(bitmap, Key, Unique, Cache);
		}

		var key:String = FlxG.bitmap.getKeyForClass(Source);
		key = FlxG.bitmap.generateKey(key, Key, Unique);

		var graphic:FlxGraphic = FlxG.bitmap.get(key);
		if (graphic != null) return graphic;

		bitmap = FlxAssets.getBitmapFromClass(Source);
		graphic = createGraphic(bitmap, key, Unique);
		graphic.assetsClass = Source;
		return graphic;
	}

	public static function fromBitmapData(Source:BitmapData, Unique:Bool = false, ?Key:String, Cache:Bool = true):FlxGraphic
	{
		if (!Cache)
			return createGraphic(Source, Key, Unique, Cache);

		var key:String = FlxG.bitmap.findKeyForBitmap(Source);
		var assetKey:String = null;
		var assetClass:Class<BitmapData> = null;

		var graphic:FlxGraphic = null;
		if (key != null)
		{
			graphic = FlxG.bitmap.get(key);
			assetKey = graphic.assetsKey;
			assetClass = graphic.assetsClass;
		}

		key = FlxG.bitmap.generateKey(key, Key, Unique);
		graphic = FlxG.bitmap.get(key);
		if (graphic != null) return graphic;

		graphic = createGraphic(Source, key, Unique);
		graphic.assetsKey = assetKey;
		graphic.assetsClass = assetClass;
		return graphic;
	}

	public static function fromFrame(Source:FlxFrame, Unique:Bool = false, ?Key:String, Cache:Bool = true):FlxGraphic
	{
		var key:String = Source.name;
		if (key == null) key = Source.frame.toString();
		key = Source.parent.key + ":" + key;

		key = FlxG.bitmap.generateKey(key, Key, Unique);
		var graphic:FlxGraphic = FlxG.bitmap.get(key);
		if (graphic != null) return graphic;

		var bitmap:BitmapData = Source.paint();
		graphic = createGraphic(bitmap, key, Unique, Cache);

		var image:FlxImageFrame = FlxImageFrame.fromGraphic(graphic);
		image.getByIndex(0).name = Source.name;
		return graphic;
	}

	public static inline function fromFrames(Source:FlxFramesCollection, Unique:Bool = false, ?Key:String):FlxGraphic
	{
		return fromGraphic(Source.parent, Unique, Key);
	}

	public static function fromGraphic(Source:FlxGraphic, Unique:Bool = false, ?Key:String):FlxGraphic
	{
		if (!Unique)
			return Source;

		var key:String = FlxG.bitmap.generateKey(Source.key, Key, Unique);
		var graphic:FlxGraphic = createGraphic(Source.bitmap, key, Unique);

		graphic.unique = Unique;
		graphic.assetsClass = Source.assetsClass;
		graphic.assetsKey = Source.assetsKey;

		return FlxG.bitmap.addGraphic(graphic);
	}

	public static function fromRectangle(Width:Int, Height:Int, Color:FlxColor, Unique:Bool = false, ?Key:String):FlxGraphic
	{
		var systemKey:String = Width + "x" + Height + ":" + Color;
		var key:String = FlxG.bitmap.generateKey(systemKey, Key, Unique);

		var graphic:FlxGraphic = FlxG.bitmap.get(key);
		if (graphic != null) return graphic;

		var bitmap = new BitmapData(Width, Height, true, Color);
		return createGraphic(bitmap, key);
	}

	static inline function getBitmap(Bitmap:BitmapData, Unique:Bool = false):BitmapData
	{
		return Unique ? Bitmap.clone() : Bitmap;
	}

	static function createGraphic(Bitmap:BitmapData, Key:String, Unique:Bool = false, Cache:Bool = true):FlxGraphic
	{
		Bitmap = getBitmap(Bitmap, Unique);

		var graphic = new FlxGraphic(Key, Bitmap);
		graphic.unique = Unique;

		if (Cache)
			FlxG.bitmap.addGraphic(graphic);

		return graphic;
	}

	public var key(default, null):String;
	public var bitmap(default, set):BitmapData;
	public var width(default, null):Int = 0;
	public var height(default, null):Int = 0;
	public var assetsKey(default, null):String;
	public var assetsClass(default, null):Class<BitmapData>;

	public var persist:Bool = false;
	public var destroyOnNoUse(default, set):Bool = true;
	public var shader(default, null):FlxShader;
	public var useCount(default, null):Int = 0;
	public var unique:Bool = false;

	var imageFrameInternal:FlxImageFrame;

	public function new(key:String, bitmap:BitmapData, ?persist:Bool)
	{
		this.key = key;
		this.persist = (persist != null) ? persist : defaultPersist;
		this.bitmap = bitmap;
		shader = new FlxShader();
	}

	public function refresh():Void
	{
		var newBitmap:BitmapData = getBitmapFromSystem();
		if (newBitmap != null)
			bitmap = newBitmap;
	}

	public function destroy():Void
	{
		bitmap = FlxDestroyUtil.dispose(bitmap);
		imageFrameInternal = FlxDestroyUtil.destroy(imageFrameInternal);
		shader = null;
		assetsClass = null;
	}

	public function addFrameCollection(collection:FlxFramesCollection):Void
	{
		if (collection.type != null)
		{
			final collections = getFramesCollections(collection.type);
			if (!collections.contains(collection))
				collections.push(collection);
		}
	}

	public inline function getFramesCollections(type:FlxFrameCollectionType):Array<Dynamic>
	{
		var collections = frameCollections.get(type);
		if (collections == null)
		{
			collections = [];
			frameCollections.set(type, collections);
		}
		return collections;
	}

	inline function get_isLoaded()
		return bitmap != null && !bitmap.rect.isEmpty();

	inline function get_isDestroyed()
		return shader == null;

	inline function get_canBeRefreshed():Bool
		return assetsClass != null || assetsKey != null;

	inline function get_canBeDumped():Bool
		return get_canBeRefreshed();

	public function incrementUseCount()
		useCount++;

	public function decrementUseCount()
	{
		useCount--;
		checkUseCount();
	}

	function checkUseCount()
	{
		if (useCount <= 0 && destroyOnNoUse && !persist)
			FlxG.bitmap.remove(this);
	}

	function set_destroyOnNoUse(v:Bool):Bool
	{
		destroyOnNoUse = v;
		checkUseCount();
		return v;
	}

	function get_imageFrame():FlxImageFrame
	{
		if (imageFrameInternal == null)
			imageFrameInternal = FlxImageFrame.fromRectangle(this);
		return imageFrameInternal;
	}

	function get_atlasFrames():FlxAtlasFrames
	{
		return FlxAtlasFrames.findFrame(this, null);
	}

	function set_bitmap(value:BitmapData):BitmapData
	{
		if (value != null)
		{
			bitmap = value;
			width = bitmap.width;
			height = bitmap.height;
		}
		return value;
	}

	function getBitmapFromSystem():BitmapData
	{
		var newBitmap:BitmapData = null;

		if (assetsClass != null)
			newBitmap = FlxAssets.getBitmapFromClass(assetsClass);
		else if (assetsKey != null)
			newBitmap = FlxG.assets.getBitmapData(assetsKey);

		if (newBitmap != null)
			return getBitmap(newBitmap, unique);

		return null;
	}
}
