package menu
{
	import com.bit101.components.PushButton;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import com.bit101.components.Style;
	
	/**
	 * ...
	 * @author
	 */
	public class IconPushButton extends PushButton
	{
		protected var _unselectedIcon:Sprite = null;
		protected var _selectedIcon:Sprite = null;
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
		
		public override function setSize(w:Number, h:Number):void
		{
			if (_selectedIcon && _unselectedIcon)
			{
				_selectedIcon.width = _unselectedIcon.width = w;
				_selectedIcon.height = _unselectedIcon.height = h;
			}
			super.setSize(w,h);
		}
	}

}