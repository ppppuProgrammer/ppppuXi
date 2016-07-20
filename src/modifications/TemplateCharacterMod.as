package modifications 
{
	/**
	 * Character mod intended for NX/customizable versions of ppppu. No movie clip that holds all the animations is expected as this 
	 * type of character mod modifies a template animation (which are loaded in by an Animation mod) to give the desired appearance.
	 * @author 
	 */
	public class TemplateCharacterMod extends Mod
	{
		public function TemplateCharacterMod() 
		{
			modType = Mod.MOD_TEMPLATECHARACTER;
		}
		public function Dispose():void
		{
			
		}
	}

}