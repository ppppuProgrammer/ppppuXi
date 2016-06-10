package  
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	public class MenuButton extends MovieClip
	{
		
		public static const TYPE_CHARACTER:int = 0;
		public static const TYPE_ANIMATION:int = 1;
		public static const TYPE_MISC:int = 2;
		private var m_menuIndex:int = -1;
		private var m_menuCommand:String = null;
		private var m_type:int = -1;
		
		public function MenuButton()
		{
			try
			{
				gotoAndStop("_up");
			}
			catch(error:ArgumentError)
			{
				gotoAndStop(1);
			}
		}
		public function SetButtonFunction(type:int, command:String, indexNum:int=-1):void
		{
			m_type = type;
			if(command != null)
			{
				m_menuCommand = command;
			}
			else
			{
				//No menu command, so this menu button is invalid. return before button mode is set.
				return;
			}
			if(indexNum >= 0)
			{
				m_menuIndex = indexNum;
			}
			
			buttonMode = true;
		}
		
		public function SetHitArea(hitZone:Sprite):void
		{
			if(hitArea != null)
			{
				removeChildren();
			}
			hitZone.mouseEnabled = false;
			hitZone.visible = false;
			hitArea = hitZone;
			addChild(hitArea);
		}
		
		public function GetMenuIndex():int
		{
			return m_menuIndex;
		}
		
		public function GetMenuCommand():String
		{
			return m_menuCommand;
		}
		
		public function GetType():int
		{
			return m_type;
		}
	}
}