package events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class CharacterModeChangedEvent extends Event 
	{
		public static const CHARACTER_MODE_CHANGE:String = "characterModeChange";
		public var mode:String = null;
		public function CharacterModeChangedEvent(type:String, modeString:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			mode = modeString;
			
		} 
		
		public override function clone():Event 
		{ 
			return new CharacterModeChangedEvent(type, mode, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("CharacterModeChangedEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}