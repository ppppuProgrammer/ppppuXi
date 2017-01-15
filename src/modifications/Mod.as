package modifications 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * Base class to be used for any class that will load in new content into ppppu.
	 * @author 
	 */
	public class Mod extends Sprite
	{
		/*Constants*/
		//The mod type is undefined. If this value is returned then a sub class did not properly set its type. 
		public static const MOD_UNDEFINED:int = -1;
		//This mod is actually an archive and contains multiple mods of possibly various types. Prefix is "ARCH"
		public static const MOD_ARCHIVE:int = 0;
		//The mod will add in a character with a fixed set of animations (used for interactive versions).  Prefix is "ACHAR"
		public static const MOD_ANIMATEDCHARACTER:int = 1;
		//The mod will add animations for a specified animated character.  Prefix is "ANIM"
		public static const MOD_ANIMATION:int = 2;
		//The mod will add in music.  Prefix is "M"
		public static const MOD_MUSIC:int = 3;
		//The mod will add in new graphics, such as background, character parts, clothing, and more.  Prefix is "ASSET"
		public static const MOD_ASSETS:int = 4;
		/*The mod will add in a character that has no fixed animations and instead relies on a template animation where character graphics
		 * are swapped around (used for NX versions).  Prefix is "TCHAR"*/
		public static const MOD_TEMPLATECHARACTER:int = 5;
		//The mod will add in an animation template. Prefix is "TANIM"
		public static const MOD_TEMPLATEANIMATION:int = 6;
		//Used when the mod is loaded standalone to tell the user what type of mod was loaded.
		private static const modTypeStringDictionary:Vector.<String> = Vector.<String>(["Archive", "AnimatedCharacter", "Animation", "Music", "Assets", "TemplateCharacter", "TemplateAnimation" ]);
		protected var modType:int = MOD_UNDEFINED;
		
		//For holding any extra mod-inspecific information.
		public var modData:Object;
		/*Currently recognized properties read from modData:
		 * variable name - expected data type - description
		 * modMajorVersion - uint - Defines the major version of the mod (version x.0)
		 * modMinorVersion - uint - Defines the minor version of the mod (version 1.x)*/
		
		 //Keeps track of what url the mod was loaded from. Must check if the getter/setter for this variable exists before using it as pre-v0.3.3 builds do not have this.
		protected var _urlLoadedFrom:String = "";
		public function set UrlLoadedFrom(url:String):void
		{
			if (_urlLoadedFrom.length == 0) { _urlLoadedFrom = url;}
		}
		public function get UrlLoadedFrom():String
		{
			return _urlLoadedFrom;
		}
		//Upon creation, a ppppuMod will listen for an added to stage event and when added to the stage will invoke the first frame function.
		//That function is where the content will be generated for use then added into the main program.
		public function Mod() 
		{
			InitiateModData();
			this.addEventListener(Event.ADDED_TO_STAGE, FirstFrame, false, 0, true);
		}
		//Mod archive has a problem calling this on its modlist contents when the function is protected, so it's public until a true fix is found.
		//public function OutputModDetails():String { return ""; }
		//Function to be implemented by any sub classes. This is where the subclass will do any work necessary to get the data ready to
		//be read by the ppppu program
		protected function FirstFrame(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, FirstFrame);
			//If the mod's parent is the stage then someone attempted to directly load the mod swf through a flash player.
			//Put up a message telling the user not to do this.
			if (this.parent == stage)
			{
				var startupError:TextField = new TextField();
				startupError.multiline = true;
				startupError.wordWrap = true;
				var textFormat:TextFormat = new TextFormat(null, 16, 0);
				startupError.defaultTextFormat = textFormat;
				startupError.text = "This swf is a mod for ppppuXi and is not meant to be loaded standalone.\n" +
				"Have this mod loaded by the main ppppuXi swf to access its contents.";
				startupError.appendText("\n\nMod Information:\n");
				//Some older mods don't have the variables needed to output this. Need to do variable checking so we don't potentially use a variable that doesn't exist.
				startupError.appendText("Mod Type: " + GetStringOfModType() + "\n");
				startupError.appendText("Version: " + this.GetModVersion() + "\n");
				("OutputModDetails" in this) ? startupError.appendText("Content Information : \n" + this["OutputModDetails"]()) : null;
				startupError.width = 480;
				startupError.height = 720;
				this.addChild(startupError);
			}
		}
		public function GetModType():int { return modType; }
		public function GetModVersion():String
		{
			var versionText:String = modData.modMajorVersion + "." + modData.modMinorVersion;
			if (versionText == "0.0") { versionText = "Not Available";}
			return versionText;
		}
		//Abstract function meant to be overwritten for the needs of any Mod subclasses
		public function Dispose():void { modData = null; _urlLoadedFrom = null; }
		public function GetStringOfModType():String
		{
			if (modType >= 0 && modType < modTypeStringDictionary.length)
			{
				return modTypeStringDictionary[modType];
			}
			return "Undefined";
		}
		[inline]
		private function InitiateModData():void
		{
			modData = new Object();
			modData.modMajorVersion = 0;
			modData.modMinorVersion = 0;
		}
	}

}