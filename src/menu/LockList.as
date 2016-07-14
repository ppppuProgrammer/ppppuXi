package menu 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.bit101.components.ListItem;
	import events.LockEvent;
	
	/**
	 * ...
	 * @author 
	 */
	public class LockList extends IconList 
	{
		protected var _lockedColor:uint = 0x000000;
		protected var _rightClickedIndex:int = -1;
		/*Whether to disable the scroll to selection that occurs when the list needs to be redrawn.
		 * It remains disabled until the next draw call.*/
		protected var disableNextScrollToSelection:Boolean = false;
		
		public function LockList(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, items:Array=null) 
		{
			super(parent, xpos, ypos, items);
		}
		
		/**
		 * Initilizes the component.
		 */
		protected override function init() : void
		{
			super.init();
			
			setSize(100, 100);
			addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
            addEventListener(Event.RESIZE, onResize);
            makeListItems();
            fillItems();
		}
		
		public function get rightClickedIndex():int
		{
			return _rightClickedIndex;
		}
		
		/**
		 * Sets / gets the index of the right clicked list item.
		 */
		public function set rightClickedIndex(value:int):void
		{
			if(value >= 0 && value < _items.length)
			{
				_rightClickedIndex = value;
//				_scrollbar.value = _selectedIndex;
			}
			else
			{
				_rightClickedIndex = -1;
			}
			invalidate();
			//dispatchEvent(new Event(MouseEvent.RIGHT_CLICK));
		}
		
		//locks/unlocks an item of a specified index. Returns the new locked value for the item.
		public function ToggleItemLock(index:int):void
		{
			if (index > -1 && index < _itemHolder.numChildren)
			{
				var item:LockListItem = (_itemHolder.getChildAt(index) as LockListItem);
				item.locked = !item.locked;
			}
		}
		
		public function SetItemLock(lockIndex:int, value:Boolean):void
		{
			var numItems:int = Math.ceil(_height / _listItemHeight);
			numItems = Math.min(numItems, _items.length);
			if (lockIndex < numItems)
			{
				var item:LockListItem = _itemHolder.getChildAt(lockIndex) as LockListItem;
				item.locked = value;
			}
		}
		
		public function SetItemLocks(locks:Vector.<Boolean>):void
		{
			var numItems:int = Math.ceil(_height / _listItemHeight);
			numItems = Math.min(numItems, _items.length);
            for(var i:int = 0; i < numItems; i++)
            {
                var item:LockListItem = _itemHolder.getChildAt(i) as LockListItem;
				item.locked = locks[i];
			}
		}
		
		/**
		 * Creates all the list items based on data.
		 */
		protected override function makeListItems():void
		{
			var item:ListItem;
			while(_itemHolder.numChildren > 0)
			{
				item = ListItem(_itemHolder.getChildAt(0));
				item.removeEventListener(MouseEvent.CLICK, onSelect);
				item.removeEventListener(MouseEvent.RIGHT_CLICK, onRightClick);
				_itemHolder.removeChildAt(0);
			}

            var numItems:int = Math.ceil(_height / _listItemHeight);
			numItems = Math.min(numItems, _items.length);
            numItems = Math.max(numItems, 1);
			for(var i:int = 0; i < numItems; i++)
			{
				//Creates a new graphicListItem and feeds it the object parameter passed when addItem() was called.
				item = new _listItemClass(_itemHolder, 0, i * _listItemHeight/*, _items[i]*/);
				/*var icon:DisplayObject =  item.data["icon"] as DisplayObject;
				if (icon)
				{
					item.data.width = item.data.height = _listItemHeight;
				}*/
				item.setSize(width-10, _listItemHeight);
				item.defaultColor = _defaultColor;

				item.selectedColor = _selectedColor;
				item.rolloverColor = _rolloverColor;
				if (item is LockListItem)
				{
					(item as LockListItem).lockedColor = _lockedColor;
				}
				item.addEventListener(MouseEvent.CLICK, onSelect);
				item.addEventListener(MouseEvent.RIGHT_CLICK, onRightClick);
			}
		}
		
		public override function addItem(item:Object):void
		{
			if (!("locked" in item))
			{
				item.locked = false;
			}
			super.addItem(item);
		}
		public override function addItemAt(item:Object, index:int):void
		{
			if (!("locked" in item))
			{
				item.locked = false;
			}
			super.addItemAt(item, index);
		}
		
		public override function draw():void
		{
			super.draw();
			if (disableNextScrollToSelection == true)
			{
				disableNextScrollToSelection = false;
			}
		}
		
		public function ChangeSelectedIndexWithoutMovingScrollBar(value:int):void
		{
			if(value >= 0 && value < _items.length)
			{
				_selectedIndex = value;
			}
			else
			{
				_selectedIndex = -1;
			}
			invalidate();
		}
		
		public function DisableNextScrollToSelection():void
		{
			disableNextScrollToSelection = true;
		}
		
		protected override function scrollToSelection():void
		{
			if (disableNextScrollToSelection == false)
			{
				var numItems:int = Math.ceil(_height / _listItemHeight);
				if(_selectedIndex != -1)
				{
					if(_scrollbar.value > _selectedIndex)
					{
	//                    _scrollbar.value = _selectedIndex;
					}
					else if(_scrollbar.value + numItems < _selectedIndex)
					{
						_scrollbar.value = _selectedIndex - numItems + 1;
					}
				}
				else
				{
					_scrollbar.value = 0;
				}
			}
            fillItems();
		}
		
		/*protected override function fillItems():void
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
					item.data = "";
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
				if (item is LockListItem)
				{
					if(offset + i == _selectedIndex)
					{
						(item as LockListItem). = true;
					}
					else
					{
						(item as LockListItem).selected = false;
					}
				}
            }
        }

		/**
		 * Called when a user selects an item in the list.
		 */
		protected override function onSelect(event:Event):void
		{
			if(! (event.target is ListItem)) return;
			
			//Locked items can not be selected
			if (event.target is LockListItem && (event.target as LockListItem).locked == true)	{return;}
			
			var offset:int = _scrollbar.value;

			for(var i:int = 0; i < _itemHolder.numChildren; i++)
			{
				if (_itemHolder.getChildAt(i) == event.target)	{ _selectedIndex = i + offset; }
				ListItem(_itemHolder.getChildAt(i)).selected = false;
			}
			ListItem(event.target).selected = true;
			dispatchEvent(new Event(Event.SELECT));
		}
		
		protected function onRightClick(event:Event):void
		{
			if (! (event.target is LockListItem)) return;
			LockListItem(event.target).locked = !LockListItem(event.target).locked;
			
			var offset:int = _scrollbar.value;
			
			for(var i:int = 0; i < _itemHolder.numChildren; i++)
			{
				if (_itemHolder.getChildAt(i) == event.target)
				{
					rightClickedIndex = i + offset; 
					break;
				}
			}
			dispatchEvent(new Event(LockEvent.LOCK));
		}
		
		/*public function ForceRedraw():void
		{
			//selectedIndex = value;
			invalidate();
			dispatchEvent(new Event(Event.SELECT));
		}*/
	}

}