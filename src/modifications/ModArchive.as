package modifications 
{
	import flash.utils.getQualifiedClassName;
	/**
	 * A ppppuMod subclass that is used as an archive that contains various ppppuMods that actually contain data to be added 
	 * to the ppppu program
	 * @author 
	 */
	public class ModArchive extends Mod  implements IModdable
	{
		
		protected var modsList:Vector.<Mod> = new Vector.<Mod>();
		
		public function ModArchive() 
		{
			modType = MOD_ARCHIVE;
		}

		public function GetModsList():Vector.<Mod> { return modsList; }
		public function OutputModDetails():String
		{
			var output:String = "\tArchive contents: ";
			var mod:Mod;
			for (var i:int = 0, l:int = modsList.length; i < l; ++i)
			{
				mod = modsList[i];
				output += "\n\tMod Name: " +  getQualifiedClassName(mod) + ", Type: " + mod.GetStringOfModType() + (("OutputModDetails" in mod) ? ", " +  (mod["OutputModDetails"]()) : "");
			}
			return output;
		}

		public override function Dispose():void
		{
			super.Dispose();
			//Call the dispose function of all the mods in the list
			for (var i:int = 0; i < modsList.length; i++) 
			{
				modsList[i].Dispose();
				modsList[i] = null;
			}
			//Remove the reference to the modsList
			modsList = null;
		}
		
		/*FirstFrame should be defined by the subclass of the ModArchive. In the body for the function, the various mods that
		are to be added should be created and pushed (or added however you want) into the modsList vector and then 
		added to the mod archive's display list.*/
		//protected function FirstFrame(e:Event):void;
	}

}