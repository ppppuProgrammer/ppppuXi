package menu 
{
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.bit101.components.Label;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author 
	 */
	public class AnimationMenu extends Panel
	{
		public const AnimationButtonSize:Number = 30;
		
		//Text
		private var modeLabel:Label;
		
		//Animation List
		private var animationList:AnimationList;
		
		//Buttons
		private var randomAnimButton:PushButton;
		
		private var buttonYPos:Number = 10;
		public function AnimationMenu(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number =  0)
		{
			name = "Animation Menu";
			super(parent, xpos, ypos);
			setSize(40, 440);
			
			//list
			animationList = new AnimationList(this,0,40);
			animationList.listItemClass = AnimationListItem;
			animationList.setSize(40,400)
			//modeLabel = new Label(this, 5, 0, "Keyboard Mode:\nChange");
			
			/*anim1Button = new PushButton(this, 5, GetYPosForButton(), "1");
			anim1Button.setSize(AnimationButtonSize, AnimationButtonSize);
			anim1Button.label
			anim2Button = new PushButton(this, 5, GetYPosForButton(), "2");
			anim2Button.setSize(AnimationButtonSize, AnimationButtonSize);*/
		}
		
		public function SetAnimationList(frameTargets:Vector.<int>):void
		{
			animationList.ResetList(frameTargets);
		}
		
		private function GetYPosForButton():Number
		{
			var _retYPos:Number = buttonYPos;
			buttonYPos += AnimationButtonSize + 2;
			return _retYPos;
		}
		
		public function ChangeModeLabelToChange():void
		{
			modeLabel.text = "Keyboard Mode:\nChange";
		}
		
		public function ChangeModeLabelToLock():void
		{
			modeLabel.text = "Keyboard Mode:\nLock";
		}
	}

}