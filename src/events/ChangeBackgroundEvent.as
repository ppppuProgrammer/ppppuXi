package events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class ChangeBackgroundEvent extends Event 
	{
		public static const CHANGE_BACKGROUND:String = "changeBackground";
		
		public var colorTransforms:Object;
		
		public function ChangeBackgroundEvent(type:String, colorTransformsObject:Object, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			colorTransforms = colorTransformsObject;
		} 
		
		public override function clone():Event 
		{ 
			return new ChangeBackgroundEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ChangeBackgroundGraphics", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}