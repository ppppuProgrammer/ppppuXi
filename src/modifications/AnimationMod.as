package modifications 
{
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author 
	 */
	public class AnimationMod extends Mod  implements IModdable
	{
		//The movie clip for an single animation or for multiple animations, each in a frame of the container.
		protected var animationContainer:MovieClip=null;
		//The character group this mod is intended for.
		protected var targetCharacterName:String = null;
		
		//protected var 
		public function AnimationMod() 
		{
			modType = Mod.MOD_ANIMATION;
		}
		public function GetAnimationContainer():MovieClip
		{
			return animationContainer;
		}
		
		public function GetTargetCharacterName():String
		{
			return targetCharacterName;
		}
		
		public function OutputModDetails():String
		{
			var output:String = "Target character group: " + (targetCharacterName != null && targetCharacterName.length > 0 ? targetCharacterName : "None targetted");
			return output;
		}
		
		override public function Dispose():void 
		{
			super.Dispose();
			if (animationContainer != null)
			{
				animationContainer.stopAllMovieClips();
				animationContainer.removeChildren();
				if (animationContainer.parent != null)
				{
					animationContainer.parent.removeChild(animationContainer);
				}
				animationContainer = null;
			}
			targetCharacterName = null;
		}
		
	}

}