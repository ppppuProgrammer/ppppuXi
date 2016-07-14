package menu
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	/**
	 * Specialized IconPushButton. The random animation button is not suppose to be unselected unless
	 * an item from the animation list is selected. This is due to the fact that randomly selecting
	 * an animation is the intended default behavior of the program.
	 * @author
	 */
	public class RandomAnimationButton extends IconPushButton
	{
		
		public function RandomAnimationButton(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, label:String = "", defaultHandler:Function = null)
		{
			super(parent, xpos, ypos, label, defaultHandler);
			unselectedIcon = new BlockIcon;
			selectedIcon = new HitBlockIcon;
		}
		
		//Mouse up will only allow selected to become true, never false;
		override protected function onMouseGoUp(event:MouseEvent):void
		{
			if (_toggle && _over && _selected == false)
			{
				_selected = !_selected;
			}
			_down = _selected;
			drawFace();
			_face.filters = [getShadow(1, _selected)];
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
			dispatchEvent(new Event(Event.SELECT));
		}
		
		override protected function addChildren():void
		{
			super.addChildren();
			var tf:TextFormat = _label.textField.getTextFormat();
			tf.font = "Super Mario 256";
			tf.size = 20;
			tf.color = 0xffffff;
			tf.align = "center";
			_label.textField.defaultTextFormat = tf;
			//addChildAt(unselectedIcon, 0);
		}
		
		
	
	}

}