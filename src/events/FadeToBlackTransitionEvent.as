package events 
{
	import flash.events.Event;
	
	/**
	 * Event dispatched when the fade to black transition is to start.
	 * @author 
	 */
	public class FadeToBlackTransitionEvent extends Event 
	{
		public static const FADETOBLACK_TRANSITION:String = "faceToBlackTransition";
		public function FadeToBlackTransitionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new FadeToBlackTransitionEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("FadeToBlackTransitionEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}