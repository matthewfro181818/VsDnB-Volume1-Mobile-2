package data.language;

import haxe.Exception;
import data.language.Language;
import flixel.FlxG;
import flixel.util.FlxColor;
import play.save.Preferences;
import util.FileUtil;
import Paths;

/**
 * Maps key → translated string
 */
typedef LanguageList = Map<String, String>;

/**
 * Core language manager
 */
class LanguageManager
{
	/** All parsed UI text. */
	public static var currentLocaleList:LanguageList;

	/** All parsed dialogue text. */
	public static var currentDialogueList:LanguageList;

	/** All parsed subtitle text. */
	public static var currentSubtitlesList:LanguageList;

	/** All parsed credits text. */
	public static var currentCreditsList:LanguageList;

	/**
	 * Loads all language files based on Preferences.language
	 */
	public static function init():Void
	{
		var lang = Preferences.language;

		currentLocaleList     = parseLocaleFile('locale/$lang/textList.txt');
		currentDialogueList   = parseLocaleFile('locale/$lang/dialogue.txt');
		currentSubtitlesList  = parseLocaleFile('locale/$lang/subtitles.txt');
		currentCreditsList    = parseLocaleFile('locale/$lang/credits.txt');

		FlxG.console.registerClass(LanguageManager);
	}

	/**
	 * Loads all available languages listed in the language config file.
	 */
	public static function getLanguages():Array<Language>
	{
		var list:Array<Language> = [];
		var lines = FileUtil.splitText(Paths.languageFile());

		for (line in lines)
		{
			var split = line.split(':');
			if (split.length >= 3)
			{
				var lang:Language = {
					name: split[0],
					id: split[1],
					color: FlxColor.fromString(split[2])
				};
				list.push(lang);
			}
		}
		return list;
	}

	/**
	 * Retrieve a specific language object by its ID.
	 */
	public static function languageFromId(id:String):Language
	{
		for (lang in getLanguages())
		{
			if (lang.id == id)
				return lang;
		}
		return null;
	}

	/**
	 * Returns the translated string for a given key.
	 */
	public static function getTextString(id:String, ?list:LanguageList):String
	{
		var listToUse = list != null ? list : currentLocaleList;

		if (listToUse.exists(id))
		{
			var text = listToUse.get(id);

			text = text.replace(":linebreak:", "\n");
			text = text.replace(":addquote:", "\"");

			return text;
		}

		return id; // fallback
	}

	/**
	 * Loads any *.txt locale file into a LanguageList
	 */
	static function parseLocaleFile(path:String):LanguageList
	{
		var list:LanguageList = new Map();

		var lines = FileUtil.splitText(Paths.file(path, TEXT, 'preload'));

		for (line in lines)
		{
			try
			{
				var parts = line.trim().split("==");
				if (parts.length < 2) continue;

				var key   = parts[0];
				var value = parts[1];

				list.set(key, value);
			}
			catch (e:Exception)
			{
				var msg = buildErrorMessage(path, e);
				FlxG.stage.window.alert(msg, "Language Parsing Error");
				FlxG.stage.window.close();
			}
		}

		return list;
	}

	/**
	 * Build a message when locale parsing fails
	 */
	static function buildErrorMessage(file:String, e:Exception):String
	{
		var message = 'An error occurred while parsing language "${Preferences.language}". ($file)\n\n';
		message += e.stack.toString();
		return message;
	}
}
