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
			else if(_mouseOver || _menuCursorOver)
			{
				graphics.beginFill(_rolloverColor);
			}
			else
			{
				graphics.beginFill(_defaultColor);
			}
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
		}
		
	}

}