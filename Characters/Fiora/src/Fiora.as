package 
{
	import flash.geom.ColorTransform;
	/**
	 * ...
	 * @author 
	 */
	public class Fiora extends AnimatedCharacter 
	{
		
		public function Fiora() 
		{
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xBDCEEC);
			m_centerDiamondColor = CreateColorTransformFromHex(0x98B4DC);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x7C99C3);
			m_backgroundColor = CreateColorTransformFromHex(0x494E62);
			m_backlightColor = new ColorTransform(0, 0, 0, 0);
			m_charAnimations = new FioraAnimations();
			m_charAnimations.x = -226.8;
			m_charAnimations.y = 213.6;
			m_menuButton = new FioraButton();
			m_menuButton.SetHitArea(new SquareBtnHitArea(75,75));
			m_name = "Fiora";
			m_defaultMusicName = "Gaur Plain";
		}
		
	}

}