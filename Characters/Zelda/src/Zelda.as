package  
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author 
	 */
	public class Zelda extends AnimatedCharacter 
	{
		
		public function Zelda()
		{
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xFDFB86);
			m_centerDiamondColor = CreateColorTransformFromHex(0xFAF91A);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0xD1C30A);
			m_backgroundColor = CreateColorTransformFromHex(0xFFFFAA);
			m_backlightColor = CreateColorTransformFromHex(0xFFFFFF, 00);
			m_charAnimations = new ZeldaAnimations();
			m_charAnimations.x = -54.75;
			m_charAnimations.y = 94.5;
			m_menuButton = new ZeldaButton();
			m_menuButton.SetHitArea(new TriangleBtnHitArea);
			m_name = "Zelda";
			m_defaultMusicName = "Gerudo Valley";
		}
		
	}

}