package modifications 
{
	import flash.utils.getQualifiedClassName;
	import flash.events.Event;
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
			var modClassName:String;
			for (var i:int = 0, l:int = modsList.length; i < l; ++i)
			{
				mod = modsList[i];
				modClassName = getQualifiedClassName(mod);
				/*The multiple classes in 1 .as file trick causes the class name to be $0::(class). So check if double colons are in the mod's class name and if they're found, remove them and the characters preceding them.*/
				if (modClassName.lastIndexOf("::") > -1)
				{
					modClassName = modClassName.substr(modClassName.lastIndexOf(":") + 1);
				}
				output += "\n\tMod Name: " +  modClassName + ", Type: " + mod.GetStringOfModType() + (("OutputModDetails" in mod) ? ", " +  (mod["OutputModDetails"]()) : "");
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
		override protected function FirstFrame(e:Event):void
		{
			for (var i:int = 0; i < modsList.length; i++) 
			{
				this.addChild(modsList[i]);
				//this.removeChild(modsList[i]);
			}
			this.removeChildren();
			super.FirstFrame(e);
		}
		
	}

}