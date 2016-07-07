package menu 
{
	import flash.display.DisplayObjectContainer;
	
	/**
	 * ...
	 * @author 
	 */
	public class AnimationList extends LockList 
	{
		
		public function AnimationList(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, items:Array=null) 
		{
			super(parent, xpos, ypos, items);
			
		}
		
		/*Gets the actual index of an item using the scroll bar value as an offset. The itemIndex given should be 0 to the maximum number
		 * of items displayed on the list at once.*/
		public function GetTrueAnimationIndex(itemIndex:int):int
		{
			var offset:int = _scrollbar.value;
			return offset + itemIndex;
		}
		
		public function ResetList(frameTargets:Vector.<int>):void
		{
			removeAll();
			for (var i:int = 0; i < frameTargets.length; ++i)
			{
				var text:String = String(i + 1);
				addItem({label:text, frameTarget:frameTargets[i]});
			}
			/*for (var i:int = 1; i <= frameTargets.length; ++i)
			{
				
			}*/
		}
		
		public override function set selectedIndex(value:int):void
		{
			if(value >= 0 && value < _items.length)
			{
				_selectedIndex = value;
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
//				_scrollbar.value = _selectedIndex;
			}
			else
			{
				_selectedIndex = -1;
			}
			invalidate();
			//dispatchEvent(new Event(Event.SELECT));
		}
	}

}