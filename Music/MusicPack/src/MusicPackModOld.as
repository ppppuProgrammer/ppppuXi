package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import modifications.ModArchive;
	
	/**
	 * Archive mod containing multiple music for all the characters.
	 * @author 
	 */
	public class MusicPackMod extends ModArchive
	{
		
		public function MusicPackMod() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
		}
		
	}
	
}