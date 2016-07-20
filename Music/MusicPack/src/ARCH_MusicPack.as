package
{
	import modifications.ModArchive
	import flash.display.Sprite;
	import flash.events.Event;

	public class ARCH_MusicPack extends ModArchive
	{
		public function ARCH_MusicPack()
		{
			modsList.push(new M_MarioAdventures);
			modsList.push(new M_MissionFinal);
			modsList.push(new M_BurningTown_RR);
			modsList.push(new M_BurningTown_SatPC);
			modsList.push(new M_GerudoValley);
			modsList.push(new M_2AM);
			modsList.push(new M_Route1);
			modsList.push(new M_MirorB);
			modsList.push(new M_FE_Spa);
			modsList.push(new M_WFTrainingMenu);
			modsList.push(new M_GaurPlain);
			modsList.push(new M_TurnaboutSisters);
		}
	}
}