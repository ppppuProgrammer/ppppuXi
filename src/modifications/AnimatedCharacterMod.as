package modifications 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	/**
	 * Character mod intended for use in interactive versions of ppppu. A movie clip containing all the animations that will be shown
	 * is expected. In order to add more animations for the character, the flash document for the character must be modified.
	 * @author 
	 */
	public class AnimatedCharacterMod extends Mod
	{
		
		
		//The character instance that will be extracted from the mod and added into the character manager.
		protected var characterPayload:AnimatedCharacter;
		//A movie clip containing 1 or more frames, each frame being a movie clip that holds an animation sequence.
		public var initialAnimationContainer:MovieClip = null;
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
			if (characterPayload != null && initialAnimationContainer != null)
			{
				if (initialAnimationContainer.totalFrames > 1)	{ characterPayload.AddAnimationsFromMovieClip(initialAnimationContainer); }
				characterPayload.SetBackgroundColorsToDefault();
				//characterPayload.InitializeAfterLoad();
			}
		}
		
		public override function Dispose():void
		{
			if (initialAnimationContainer != null)
			{
				initialAnimationContainer.stopAllMovieClips();
				initialAnimationContainer.removeChildren();
				if (initialAnimationContainer.parent != null)
				{
					initialAnimationContainer.parent.removeChild(initialAnimationContainer);
				}
				initialAnimationContainer = null;
			}
			
			//Remove the ref to the character payload
			if (characterPayload != null)	{characterPayload = null;}
		}
	}

}