package menu
{
	import com.bit101.components.PushButton;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import com.bit101.components.Style;
	
	/**
	 * ...
	 * @author
	 */
	public class IconPushButton extends PushButton
	{
		public var _unselectedIcon:Sprite = null;
		public var _selectedIcon:Sprite = null;
		protected var currentIcon:Sprite = null;
		
		public function IconPushButton(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, label:String = "", defaultHandler:Function = null)
		{
			super(parent, xpos, ypos, label, defaultHandler);
			toggle = true;
			this.mouseChildren = false;
		
		}
		
		override protected function drawFace():void
		{
			//super.drawFace();
			if (currentIcon != null && currentIcon.parent == this)
			{
				currentIcon.parent.removeChild(currentIcon);
				currentIcon = null;
			}
			if (_selected)
			{
				if (_selectedIcon != null)
				{
					currentIcon = _face.addChild(_selectedIcon) as Sprite;
				}
			}
			else
			{
				if (_unselectedIcon != null)
				{
					currentIcon = _face.addChild(_unselectedIcon) as Sprite;
				}
			}
		
		/*if(_down)
		   {
		   _face.graphics.beginFill(Style.BUTTON_DOWN);
		   }
		   else
		   {
		
		   }*/
			   //_face.graphics.drawRect(0, 0, _width - 2, _height - 2);
			   //_face.graphics.endFill();
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
		
		public function set unselectedIcon(value:Sprite):void
		{
			if (_unselectedIcon != null)
			{
				if (_unselectedIcon.parent != null)
				{
					_unselectedIcon.parent.removeChild(_unselectedIcon);
				}
			}
			_unselectedIcon = value;
			_unselectedIcon.width = this.width;
			_unselectedIcon.height = this.height;
		}
		
		public function set selectedIcon(value:Sprite):void
		{
			if (_selectedIcon != null)
			{
				if (_selectedIcon.parent != null)
				{
					_selectedIcon.parent.removeChild(_selectedIcon);
				}
			}
			_selectedIcon = value;
			_selectedIcon.width = this.width;
			_selectedIcon.height = this.height;
		}
		//public function get selectedIcon():Sprite { return ; }
		//public function get unselectedIcon():Sprite { return ; }
	}

}