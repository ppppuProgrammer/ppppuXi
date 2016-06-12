package  
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	/**
	 * ...
	 * @author 
	 */
	public class Hilda extends AnimatedCharacter 
	{
		
		public function Hilda() 
		{
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xFFFFFF);
			m_centerDiamondColor = CreateColorTransformFromHex(0xCCCCCC);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x999999);
			m_backgroundColor = CreateColorTransformFromHex(0xFF0000);
			m_backlightColor = CreateColorTransformFromHex(0x999999);
			m_charAnimations = new HildaAnimations();
			m_charAnimations.x = -104.75;
			m_charAnimations.y = 92;
			m_menuButton = new HildaButton();
			m_menuButton.SetHitArea(new SquareBtnHitArea(75,75));
			m_name = "Hilda";
			m_defaultMusicName = "Miror B";
		}
		
	}

}