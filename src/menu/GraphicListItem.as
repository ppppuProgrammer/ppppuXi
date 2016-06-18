package menu 
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.ListItem;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.DisplayObjectContainer;
	/**
	 * A custom list item that displays a Sprite instead of text like the standard list item.
	 * @author 
	 */
	public class GraphicListItem extends ListItem
	{
		//private function charButton:MenuButton;
		public function GraphicListItem(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, data:Object = null) 
		{
			//Only a display object is allowed. If the data parameter is not a display object nullify it.
			if (!data is DisplayObject)
			{
				data = null;
			}
			super(parent, xpos, ypos, data);
			//_data = data;
			
		}
		
		public override function set data(value:Object):void
		{
			if (_data != value && _data is DisplayObject)
			{
				//_data.visible = false;
				/*If the data's parent is this list item, remove it. Otherwise don't use a removechild call to remove it as this will
				erroneously remove the display object from its intended parent (in the case of scrolling down).
				example: list of 10, scrolled down by 3 items. The first 3 items are assigned their new sprites. The 4th item however
				shares _data with the first item now. Not caring who the parent is, the 4th item removes its current _data, which means the
				first item is now graphic less.*/
				if (_data.parent != null && _data.parent == this)
				{
					_data.parent.removeChild(_data as DisplayObject);
				}
			}
			_data = value;
			if (_data is DisplayObject)
			{
				//_data.visible = true;
				
				addChild(_data as DisplayObject);
			}
			invalidate();
		}
		
		/*public override function draw() : void
		{
			super.draw()
			
			//graphics.clear();
			
		}*/
		
		protected override function addChildren():void
		{
			super.addChildren();
			_label.visible = false;
		}
	}

}