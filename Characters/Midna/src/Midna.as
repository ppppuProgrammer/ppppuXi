package 
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author 
	 */
	public class Midna extends AnimatedCharacter 
	{
		
		public function Midna()
		{
			m_topLeftDiamondColor = CreateColorTransformFromHex(0x999999);
			m_centerDiamondColor = CreateColorTransformFromHex(0x666666);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x333333);
			m_outerDiamondColor = CreateColorTransformFromHex(0xCCCCCC);
			m_backlightColor = CreateColorTransformFromHex(0x49FBE1);
			//m_backlightColor = new ColorTransform(1.0, 1.0, 1.0, 1.0, -26, 19, 122);
			
			m_menuIcon = new MidnaIcon();
			
			m_name = "Midna";
			m_defaultMusicName = "Gerudo Valley";
		}
		
	}

}