package events 
{
	import flash.events.Event;
	
	/**
	 * Event to be dispatched when saving a shared object is desired.
	 * @author 
	 */
	public class SaveRequestEvent extends Event 
	{
		public static const SAVE_SHARED_OBJECT:String = "saveSharedObject";
		public function SaveRequestEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new SaveRequestEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("SaveRequestEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}