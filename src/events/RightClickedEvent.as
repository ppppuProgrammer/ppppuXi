package events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class RightClickedEvent extends Event 
	{
		public static const RIGHT_CLICKED:String = "rightClicked";
		public function RightClickedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			
		}
		
		public override function clone():Event 
		{ 
			return new RightClickedEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("RightClickedEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}

}