package events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class LockEvent extends Event 
	{
		public static const LOCK:String = "lock";
		public function LockEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			
		}
		
		public override function clone():Event 
		{ 
			return new LockEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("LockEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}

}