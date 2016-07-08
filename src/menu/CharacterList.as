package menu 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import com.bit101.components.ListItem;
	
	/**
	 * List subclass specialized for ppppuX's character select menu and the intentions of how it should interact with 
	 * keyboard and mouse input.
	 * @author 
	 */
	public class CharacterList extends LockList 
	{
		protected var _menuCursorIndex:int = -1;
		public function CharacterList(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, items:Array=null) 
		{
			super(parent, xpos, ypos, items);
			
		}
		
		protected override function fillItems():void
        {
            var offset:int = _scrollbar.value;
            var numItems:int = Math.ceil(_height / _listItemHeight);
			numItems = Math.min(numItems, _items.length);
            for(var i:int = 0; i < numItems; i++)
            {
                var item:ListItem = _itemHolder.getChildAt(i) as ListItem;
				if(offset + i < _items.length)
				{
	                item.data = _items[offset + i];
				}
				else
				{
					item.data = new Object();
					//item.data = "";
				}
				if(_alternateRows)
				{
					item.defaultColor = ((offset + i) % 2 == 0) ? _defaultColor : _alternateColor;
				}
				else
				{
					item.defaultColor = _defaultColor;
				}
                if(offset + i == _selectedIndex)
                {
                    item.selected = true;
                }
                else
                {
                    item.selected = false;
                }
				
				if(offset + i == _menuCursorIndex && item is CharacterListItem)
                {
                    (item as CharacterListItem).menuCursorOver = true;
                }
                else
                {
                    (item as CharacterListItem).menuCursorOver = false;
                }
            }
        }
		
		/**
		 * Sets / gets the index of the selected list item. Modified as keyboard input can change the selected index. However
		 * the character is not suppose to change when keyboard input is used for menu navigation, they need to press a different key
		 * to actually switch the character. To accomplish this, the selectedIndex setter does not dispatch a select event
		 */
		public override function set selectedIndex(value:int):void
		{
			if(value >= 0 && value < _items.length)
			{
				_selectedIndex = value;
				if (_menuCursorIndex == -1)	{ _menuCursorIndex = value; }
				
				var offset:int = _scrollbar.value;
				var numItems:int = Math.ceil(_height / _listItemHeight);
				numItems = Math.min(numItems, _items.length);
				
				if (offset + numItems >= value)
				{
//					_scrollbar.value = value - numItems +1;
				}
				else if (offset + numItems <= value)
				{
					_scrollbar.value = value;
				}
//				_scrollbar.value = _selectedIndex;
			}
			else
			{
				_selectedIndex = -1;
			}
			invalidate();
			//dispatchEvent(new Event(Event.SELECT));
		}
		
		public function set menuCursorIndex(value:int):void
		{
			_menuCursorIndex = value;
			var offset:int = _scrollbar.value;
			var numItems:int = Math.ceil(_height / _listItemHeight);
			numItems = Math.min(numItems, _items.length);
			
			if (offset + numItems >= value)
			{
				_scrollbar.value = value - numItems +1;
			}
			else if (offset + numItems <= value)
			{
				_scrollbar.value = value;
			}
			invalidate();
		}
		public function get menuCursorIndex():int
		{
			return _menuCursorIndex;
		}
		
	}

}