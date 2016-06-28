package  
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author 
	 */
	public class Samus extends AnimatedCharacter 
	{
		
		public function Samus()
		{
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xFF7464);
			m_centerDiamondColor = CreateColorTransformFromHex(0xCD2C2E);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x982C2E);
			m_backgroundColor = CreateColorTransformFromHex(0xFF2C2E);
			m_backlightColor = new ColorTransform(.53,.53,.53,.73,120,120);
			m_charAnimations = new SamusAnimations();
			m_charAnimations.x = -54.75;
			m_charAnimations.y = 92;
			m_menuIcon = new SamusIcon();
			
			m_name = "Samus";
			m_defaultMusicName = "Mission Final";
		}
		
	}

}