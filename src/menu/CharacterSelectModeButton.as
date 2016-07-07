package menu
{
	import com.bit101.components.PushButton;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * Custom push button that is used to indicate what select mode is being used to select a character
	 * at every 4 second interval (done by the Character Manager).
	 * There are 3 modes, one for normal sequential changes, 1 for random changes, and the last for
	 * staying on the same character.
	 * If a non-norrmal mode is currently active and the mouse button to set that mode is activated,
	 * then the button will go back to normal mode. If the mouse button used to go to a different non-normal
	 * mode is pressed then the button will switch to the other, non-normal mode.
	 * @author
	 */
	public class CharacterSelectModeButton extends PushButton
	{
		private static const NORMAL_MODE:int = 0; //sequential character changing based on id.
		private static const RANDOM_MODE:int = 1; //randomly pick a character
		private static const SINGLE_MODE:int = 2; //Only allow a single character, the current selected one
		public var mode:int = 0;
		public var normalIcon:Sprite = null;
		public var randomIcon:Sprite = null;
		public var singleIcon:Sprite = null;
		public var currentIcon:Sprite = null;
		
		public function CharacterSelectModeButton(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, label:String = "", defaultHandler:Function = null)
		{
			super(parent, xpos, ypos, label, defaultHandler);
			//toggle = true;
		}
		
		override protected function onMouseGoUp(event:MouseEvent):void
		{
			if (_toggle && _over)
			{
				_selected = !_selected;
			}
			_down = _selected;
			drawFace();
			_face.filters = [getShadow(1, _selected)];
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
		}
		
		/**
		 * Internal mouseOut handler.
		 * @param event The MouseEvent passed by the system.
		 */
		protected function onRightMouseGoDown(event:MouseEvent):void
		{
			_down = true;
			drawFace();
			_face.filters = [getShadow(1, true)];
			stage.addEventListener(MouseEvent.MOUSE_UP, onMRightRouseGoUp);
		}
		
		/**
		 * Internal mouseUp handler.
		 * @param event The MouseEvent passed by the system.
		 */
		protected function onRightMouseGoUp(event:MouseEvent):void
		{
			if (_toggle && _over)
			{
				_selected = !_selected;
			}
			_down = _selected;
			drawFace();
			_face.filters = [getShadow(1, _selected)];
			stage.removeEventListener(MouseEvent.MOUSE_UP, onRightMouseGoUp);
		}
	
	}

}