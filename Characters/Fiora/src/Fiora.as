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
			m_charAnimations.x = -99.15;
			m_charAnimations.y = 173.8;
			m_menuButton = new FioraButton();
			m_menuButton.SetHitArea(new SquareBtnHitArea(75,75));
			m_name = "Fiora";
			m_musicClassName = "HildaBGM";
			m_musicTitle = "Miror B. Battle - Pokemon XD";
			m_musicStartPoint = ConvertSamplesToMilliseconds(576);
			m_musicLoopStartPoint = ConvertSamplesToMilliseconds(871773) + m_musicStartPoint;
			m_musicLoopEndPoint= (ConvertSamplesToMilliseconds(2989939) + m_musicStartPoint);
		}
		
	}

}