package menu 
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.ListItem;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.DisplayObjectContainer;
	/**
	 * A custom list item that is capable of displaying a Sprite
	 * @author 
	 */
	public class IconListItem extends ListItem
	{
		//private function charButton:MenuButton;
		protected var _icon:Sprite;
		protected var iconCurrentlyUsed:DisplayObject = null;
		public function IconListItem(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, data:Object = null) 
		{
			//Only a display object is allowed. If the data parameter is not a display object nullify it.
			if (!data is DisplayObject)
			{
				data = null;
			}
			super(parent, xpos, ypos, data);
			mouseChildren = false;
			//_data = data;
			
		}
		
		/*public override function set data(value:Object):void
		{
			//Used to verify that the _data is infact a displayObject
			/*var icon:DisplayObject;
			if (_data && _data != value && (_data is DisplayObject || _data.hasOwnProperty("icon")))
			{
				icon = _data as DisplayObject || _data["icon"] as DisplayObject;
				//_data.visible = false;
				/*If the data's parent is this list item, remove it. Otherwise don't use a removechild call to remove it as this will
				erroneously remove the display object from its intended parent (in the case of scrolling down).
				example: list of 10, scrolled down by 3 items. The first 3 items are assigned their new sprites. The 4th item however
				shares _data with the first item now. Not caring who the parent is, the 4th item removes its current _data, which means the
				first item is now graphic less.*/
				/*if (icon && icon.parent != null && icon.parent == this)
				{
					icon.parent.removeChild(icon as DisplayObject);
				}
			}*/
			//_data = value;
			/*if (_data is DisplayObject || _data.hasOwnProperty("icon"))
			{
				//_data.visible = true;
				icon = _data as DisplayObject || _data.icon as DisplayObject;
				if (icon)
				{
					addChildAt(icon as DisplayObject, 0);
				}
			}*/
			//invalidate();
		//}
		
		public override function draw() : void
		{
			super.draw()
			
			if(_data == null) return;

			//Only a string
			if(_data is String)
			{
                _label.text = _data as String;
			}
			else if(_data.hasOwnProperty("label") && _data.label is String)
			{
				_label.text = _data.label;
			}
			else if(!(_data.hasOwnProperty("icon") || _data is DisplayObject))
			{
				_label.text = _data.toString();
			}
			
			var icon:DisplayObject;
			if (_data && _data.hasOwnProperty("icon"))
			{
				icon =  _data.icon as DisplayObject;
				//_data.visible = false;
				/*If the data's parent is this list item, remove it. Otherwise don't use a removechild call to remove it as this will
				erroneously remove the display object from its intended parent (in the case of scrolling down).
				example: list of 10, scrolled down by 3 items. The first 3 items are assigned their new sprites. The 4th item however
				shares _data with the first item now. Not caring who the parent is, the 4th item removes its current _data, which means the
				first item is now graphic less.*/
				if (iconCurrentlyUsed != null && iconCurrentlyUsed.parent == this)
				{
					removeChild(iconCurrentlyUsed);
				}
			}
			
			if (_data.hasOwnProperty("icon"))
			{
				//_data.visible = true;
				icon =  _data.icon as DisplayObject;
				if (icon)
				{
					addChildAt(icon as DisplayObject, 0);
					iconCurrentlyUsed = icon;
				}
			}
			//graphics.clear();
			
		}
	}

}