package menu 
{
	import com.bit101.components.Component;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author 
	 */
	public class AnimationListItem extends LockListItem 
	{
		/*The frame of the character's animation collection movie clip to go to. The displayed index does not necessarily
		 * match the target frame*/
		//private var _frameNumber:int;
		//private var _targetFrame:int;
		
		private const selectedBlockIcon:Sprite = new HitBlockIcon();
		private const blockIcon:Sprite = new BlockIcon();
		
		public function AnimationListItem(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, data:Object=null) 
		{
			super(parent, xpos, ypos, data);
			/*selectedBlockIcon.width = blockIcon.width = this.width;
			selectedBlockIcon.height = blockIcon.height = this.height;*/
		}
		
		/**
		 * Creates and adds the child display objects of this component.
		 */
		protected override function addChildren() : void
		{
			super.addChildren();
			var tf:TextFormat = _label.textField.getTextFormat();
			tf.font = "Super Mario 256";
			tf.size = 14;
			tf.color = 0xffffff;
			tf.align = "center";
			_label.textField.defaultTextFormat = tf;
			//_label.textField.setTextFormat(tf);
			//_label.
		}
		
		/*override public function setSize(w:Number, h:Number):void
		{
			super.setSize(w, h);
			selectedBlockIcon.width = blockIcon.width = w;
			selectedBlockIcon.height = blockIcon.height = h;
		}*/
		
		public override function set selected(value:Boolean):void
		{
			_selected = value;

			if (_selected)
			{
				data.icon = selectedBlockIcon;				
			}
			else
			{
				data.icon = blockIcon;
			}
			
			invalidate();
		}
		
		public function ForceChildrenRedrawThisFrame():void
		{
			for (var i:int = 0; i < this.numChildren; i++) 
			{
				var child:Component = this.getChildAt(i) as Component;
				if (child != null)
				{
					child.draw();
				}
			}
		}
		
		/*public function set targetFrame(value:int):void
		{
			_targetFrame = targetFrame;
		}
		public function get targetFrame():int
		{
			return _targetFrame;
		}*/
		/*public override function draw():void
		{
			super.draw();
			if (_data == null) { return; }
			
			var icon:DisplayObject = _data.icon as DisplayObject;
			if (iconCurrentlyUsed != null && icon != iconCurrentlyUsed && iconCurrentlyUsed.parent != null)
			{
				iconCurrentlyUsed.parent.removeChild(iconCurrentlyUsed);
			}
			if (_selected)
			{
				this.addChildAt(selectedBlockIcon, 0);
				iconCurrentlyUsed = selectedBlockIcon;
			}
			else
			{
				this.addChildAt(blockIcon, 0);
				iconCurrentlyUsed = blockIcon;
			}
		}*/
	}

}