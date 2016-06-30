package 
{
	import flash.events.Event;
	
	/**
	 * Event dispatched when an animation transition has happened.
	 * @author 
	 */
	public class AnimationTransitionEvent extends Event 
	{
		public static const ANIMATION_TRANSITIONED:String = "animationTransitioned";
		public function AnimationTransitionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new AnimationTransitionEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("AnimationTransitionEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}