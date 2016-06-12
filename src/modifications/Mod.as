package modifications 
{
	import flash.display.Sprite;
	import flash.events.Event;
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
		/*The mod will add in a character that has no fixed animations and instead relies on a template animation where character graphics
		 * are swapped around (used for NX versions).  Prefix is "TCHAR"*/
		public static const MOD_TEMPLATECHARACTER:int = 2;
		//The mod will add in music.  Prefix is "M"
		public static const MOD_MUSIC:int = 3;
		//The mod will add in new graphics, such as background, character parts, clothing, and more.  Prefix is "ASSET"
		public static const MOD_ASSETS:int = 4;
		//The mod will add in an animation template. Prefix is "ANIM"
		public static const MOD_ANIMATION:int = 5;
		
		
		protected var modType:int = MOD_UNDEFINED;
		//Upon creation, a ppppuMod will listen for an added to stage event and when added to the stage will invoke the first frame function.
		//That function is where the content will be generated for use then added into the main program.
		public function Mod() 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, FirstFrame);
		}
		
		//Function to be implemented by any sub classes. This is where the subclass will do any work necessary to get the data ready to
		//be read by the ppppu program
		protected function FirstFrame(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, FirstFrame);
		}
		
		public function GetModType():int { return modType;}
		
	}

}