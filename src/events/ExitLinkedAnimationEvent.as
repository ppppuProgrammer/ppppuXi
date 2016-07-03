package events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class ExitLinkedAnimationEvent extends Event 
	{
		public static const EXIT_LINKED_ANIMATION:String = "exitLinkedAnimation";
		
		public function ExitLinkedAnimationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new ExitLinkedAnimationEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ExitLinkedAnimationEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}