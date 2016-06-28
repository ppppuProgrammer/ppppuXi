package
{
	import flash.display.Sprite;
	import AppCore;
	import flash.events.Event;
	/**
	 * Main entryway into the program. Creates an instance of AppCore, adds it 
	 * @author ppppuProgrammer
	 */
	 
	[Frame(factoryClass = "Preloader")]
	public class Main extends Sprite
	{
		//Array that holds all the mods loaded at startup by the preloader.
		private var loadedModsContent:Array = null;
		
		public function Main() 
		{
			mouseEnabled = false;
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			var ppppuApp:AppCore = new AppCore();
			addChild(ppppuApp);
			ppppuApp.Initialize(loadedModsContent);
		}
		
		public function SetModsContent(mods:Array):void
		{
			loadedModsContent = mods;
		}
	}
}