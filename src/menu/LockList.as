package menu 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.bit101.components.ListItem;
	
	/**
	 * ...
	 * @author 
	 */
	public class LockList extends IconList 
	{
		protected var _lockedColor:uint = 0x000000;
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
		
		//locks/unlocks an item of a specified index. Returns the new unlocked value for the item.
		public function ToggleItemLock(index:int):void
		{
			if (index > -1 && index < _itemHolder.numChildren)
			{
				var item:LockListItem = (_itemHolder.getChildAt(index) as LockListItem);
				item.unlocked = !item.unlocked;
			}
		}
		
		public function SetItemLocks(locks:Vector.<Boolean>):void
		{
			var numItems:int = Math.ceil(_height / _listItemHeight);
			numItems = Math.min(numItems, _items.length);
            for(var i:int = 0; i < numItems; i++)
            {
                var item:LockListItem = _itemHolder.getChildAt(i) as LockListItem;
				item.unlocked = locks[i];
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
				if (item.data is DisplayObject)
				{
					item.data.width = item.data.height = _listItemHeight;
				}
				item.setSize(width, _listItemHeight);
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
		

		/**
		 * Called when a user selects an item in the list.
		 */
		protected override function onSelect(event:Event):void
		{
			if(! (event.target is ListItem)) return;
			
			var offset:int = _scrollbar.value;
			
			var originalSelectedIndex:int = selectedIndex;
			for(var i:int = 0; i < _itemHolder.numChildren; i++)
			{
				if (_itemHolder.getChildAt(i) == event.target) 
				{
					//Locked items can not be selected
					if (event.target is LockListItem && (event.target as LockListItem).unlocked == false)
					{
						//Restore the selected status for the original selected index. 
						ListItem(_itemHolder.getChildAt(selectedIndex)).selected =true;
						return;
					}
					_selectedIndex = i + offset;
				}
				ListItem(_itemHolder.getChildAt(i)).selected = false;
			}
			ListItem(event.target).selected = true;
			dispatchEvent(new Event(Event.SELECT));
		}
		
		protected override function onRightClick(event:Event):void
		{
			if (! (event.target is LockListItem)) return;
			LockListItem(event.target).unlocked = !LockListItem(event.target).unlocked;
			super.onRightClick(event);
			/*if (! (event.target is LockListItem)) return;
			var offset:int = _scrollbar.value;
			
			for(var i:int = 0; i < _itemHolder.numChildren; i++)
			{
				if (_itemHolder.getChildAt(i) == event.target)
				{
					rightClickedIndex = i + offset;
					break;
				}
			}
			LockListItem(event.target).unlocked = !LockListItem(event.target).unlocked;
			dispatchEvent(new Event(RightClickedEvent.RIGHT_CLICKED));*/
		}
	}

}