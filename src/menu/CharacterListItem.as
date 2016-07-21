package menu 
{
	import flash.display.DisplayObjectContainer;
	
	/**
	 * ...
	 * @author 
	 */
	public class CharacterListItem extends LockListItem 
	{
		protected var _menuCursorOver:Boolean;
		protected var _menuCursorColor:uint = 0x0000FF;
		public function CharacterListItem(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, data:Object=null) 
		{
			super(parent, xpos, ypos, data);
			
		}
		
		public function set menuCursorOver(value:Boolean):void
		{
			_menuCursorOver = value;
			invalidate();
		}
		public function get menuCursorOver():Boolean
		{
			return _menuCursorOver;
		}
		
		public override function draw():void
		{
			super.draw();
			
			graphics.clear();
			
			if(_selected)
			{
				graphics.beginFill(_selectedColor);
			}
			else if(_mouseOver)
			{
				graphics.beginFill(_rolloverColor);
			}
			else if (_menuCursorOver)
			{
				graphics.beginFill(_menuCursorColor);
			}
			else
			{
				graphics.beginFill(_defaultColor);
			}
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
		}
		
		/**
		 * Sets/gets the menu cursor's background color for list items.
		 */
		public function set menuCursorColor(value:uint):void
		{
			_menuCursorColor = value;
			invalidate();
		}
		public function get menuCursorColor():uint
		{
			return _menuCursorColor;
		}
	}

}