package menu 
{
	import com.bit101.components.List;
	import events.LockEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.bit101.components.ListItem;
	
	/**
	 * A list specialized to display a graphic for its item instead of a string. Only accepts items classes that are a GraphicListItem
	 * or a subclass of it.
	 * @author 
	 */
	public class IconList extends List 
	{
		protected var _rightClickedIndex:int = -1;
		
		public function IconList(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, items:Array=null) 
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
		
		/**
		 * Creates all the list items based on data.
		 */
		protected override function makeListItems():void
		{
			var item:IconListItem;
			while(_itemHolder.numChildren > 0)
			{
				item = IconListItem(_itemHolder.getChildAt(0));
				item.removeEventListener(MouseEvent.CLICK, onSelect);
				_itemHolder.removeChildAt(0);
			}

            var numItems:int = Math.ceil(_height / _listItemHeight);
			numItems = Math.min(numItems, _items.length);
            numItems = Math.max(numItems, 1);
			for(var i:int = 0; i < numItems; i++)
			{
				//Creates a new graphicListItem and feeds it the object parameter passed when addItem() was called.
				item = new _listItemClass(_itemHolder, 0, i * _listItemHeight/*, _items[i]*/);
				var icon:DisplayObject = item.data as DisplayObject || item.data["icon"] as DisplayObject;
				if (icon)
				{
					item.data.width = item.data.height = _listItemHeight;
				}
				item.setSize(width, _listItemHeight);
				item.defaultColor = _defaultColor;

				item.selectedColor = _selectedColor;
				item.rolloverColor = _rolloverColor;
				item.addEventListener(MouseEvent.CLICK, onSelect);
			}
		}
		
		/**
		 * Adds an item to the list.
		 * @param item The item to add. Can be a string or an object containing a string property named label.
		 */
		public override function addItem(item:Object):void
		{
			var icon:DisplayObject = item as DisplayObject || item["icon"] as DisplayObject;
			if (icon)
			{
				icon.width = icon.height = _listItemHeight;
			}
			_items.push(item);
			invalidate();
			makeListItems();
			fillItems();
		}
		
		/**
		 * Adds an item to the list at the specified index.
		 * @param item The item to add. Can be a string or an object containing a string property named label.
		 * @param index The index at which to add the item.
		 */
		public override function addItemAt(item:Object, index:int):void
		{
			var icon:DisplayObject = item as DisplayObject || item["icon"] as DisplayObject;
			if (icon is DisplayObject)
			{
				icon.width = icon.height = _listItemHeight;
			}
			index = Math.max(0, index);
			index = Math.min(_items.length, index);
			_items.splice(index, 0, item);
			invalidate();
			makeListItems();
			fillItems();
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
            }
        }
	}

}