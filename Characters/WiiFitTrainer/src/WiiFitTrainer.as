package  
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author 
	 */
	public class WiiFitTrainer extends AnimatedCharacter 
	{
		
		public function WiiFitTrainer()
		{
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xA0D551);
			m_centerDiamondColor = CreateColorTransformFromHex(0x6FBD1C);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x30B001);
			m_backgroundColor = CreateColorTransformFromHex(0xD1EF8B);
			m_charAnimations = new WFTAnimations();
			m_charAnimations.x = -54.75;
			m_charAnimations.y = 92;
			m_menuIcon = new WFTIcon();
			
			m_name = "WiiFitTrainer";
			m_defaultMusicName = "WF Training Menu";
		}
		
	}

}