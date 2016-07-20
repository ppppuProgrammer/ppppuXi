package menu
{
	import com.bit101.components.PushButton;
	import events.CharacterModeChangedEvent;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
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
		protected var mode:int = -1;
		protected var _normalIcon:Sprite = null;
		protected var _randomIcon:Sprite = null;
		protected var _singleIcon:Sprite = null;
		protected var currentIcon:Sprite = null;
		
		public function CharacterSelectModeButton(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, label:String = "", defaultHandler:Function = null)
		{
			super(parent, xpos, ypos, label, defaultHandler);
			toggle = true;
		}
		
		public function Initialize(initMode:String):void
		{
			if (mode == -1)
			{
				switch(initMode)
				{
					case "Normal":
						mode = NORMAL_MODE;
						break;
						
					case "Random":
						mode = RANDOM_MODE;
						break;
					
					case "Single":
						mode = SINGLE_MODE;
						break;
				}
				invalidate();
			}
		}
		
		public function ChangeButtonMode(modeString:String):void
		{
			switch(modeString)
			{
				case "Normal":
					mode = NORMAL_MODE;
					break;
					
				case "Random":
					mode = RANDOM_MODE;
					break;
				
				case "Single":
					mode = SINGLE_MODE;
					break;
			}
			invalidate();

		}
		
		override protected function onMouseGoUp(event:MouseEvent):void
		{
			if (_toggle && _over)
			{
				var modeString:String = null;
				if (mode != SINGLE_MODE)
				{
					mode = SINGLE_MODE;
					modeString = "Single";
					
				}
				else
				{
					mode = NORMAL_MODE;
					modeString = "Normal";
				}
				dispatchEvent(new CharacterModeChangedEvent(CharacterModeChangedEvent.CHARACTER_MODE_CHANGE, modeString));
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
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onRightMouseGoUp);
		}
		
		/**
		 * Internal mouseUp handler.
		 * @param event The MouseEvent passed by the system.
		 */
		protected function onRightMouseGoUp(event:MouseEvent):void
		{
			if (_toggle && _over)
			{
				var modeString:String = null;
				if (mode != RANDOM_MODE)
				{
					mode = RANDOM_MODE;
					modeString = "Random";
				}
				else
				{
					mode = NORMAL_MODE;
					modeString = "Normal";
				}
				dispatchEvent(new CharacterModeChangedEvent(CharacterModeChangedEvent.CHARACTER_MODE_CHANGE, modeString));
			}
			
			_down = _selected;
			drawFace();
			_face.filters = [getShadow(1, _selected)];
			stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, onRightMouseGoUp);
			//dispatchEvent(new Event.
		}
		
		override protected function drawFace():void
		{
			super.drawFace();
			if (currentIcon != null && currentIcon.parent != null)
			{
				currentIcon.parent.removeChild(currentIcon);
				currentIcon = null;
			}
			switch(mode)
			{
				case NORMAL_MODE:
					currentIcon = _face.addChild(_normalIcon) as Sprite;
					currentIcon.width = this.width-2; currentIcon.height = this.height-2;
					break;
					
				case RANDOM_MODE:
					currentIcon = _face.addChild(_randomIcon) as Sprite;
					currentIcon.width = this.width-2; currentIcon.height = this.height-2;
					break;
				
				case SINGLE_MODE:
					currentIcon = _face.addChild(_singleIcon) as Sprite;
					currentIcon.width = this.width-2; currentIcon.height = this.height-2;
					break;
			}
		}
		
		public function set normalIcon(value:Sprite):void 
		{
			if (_normalIcon != null)
			{
				if (_normalIcon.parent != null)
				{
					_normalIcon.parent.removeChild(_normalIcon);
				}
			}
			_normalIcon = value;
		}
		public function set randomIcon(value:Sprite):void 
		{
			if (_randomIcon != null)
			{
				if (_randomIcon.parent != null)
				{
					_randomIcon.parent.removeChild(_randomIcon);
				}
			}
			_randomIcon = value;
		}
		public function set singleIcon(value:Sprite):void 
		{
			if (_singleIcon != null)
			{
				if (_singleIcon.parent != null)
				{
					_singleIcon.parent.removeChild(_singleIcon);
				}
			}
			_singleIcon = value;
		}
	
		override protected function addChildren():void
		{
			super.addChildren();
			addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseGoDown);
		}
	}

}