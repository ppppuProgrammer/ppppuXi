package modifications 
{
	import flash.events.Event;
	import modifications.Mod;
	/**
	 * Character mod intended for use in interactive versions of ppppu. A movie clip containing all the animations that will be shown
	 * is expected. In order to add more animations for the character, the flash document for the character must be modified.
	 * @author 
	 */
	public class AnimatedCharacterMod extends Mod
	{
		
		
		//The character instance that will be extracted from the mod and added into the character manager.
		protected var characterPayload:AnimatedCharacter;
		
		public function AnimatedCharacterMod() 
		{
			modType = Mod.MOD_ANIMATEDCHARACTER;
		}
		
		public function GetCharacter():AnimatedCharacter
		{
			return characterPayload;
		}
		
		override protected function FirstFrame(e:Event):void
		{
			super.FirstFrame(e);
			if (characterPayload != null)
			{
				characterPayload.InitializeAfterLoad();
			}
		}
	}

}