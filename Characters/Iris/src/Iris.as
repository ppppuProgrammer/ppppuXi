package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author 
	 */
	public class Iris extends AnimatedCharacter 
	{
		
		public function Iris() 
		{
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xBC508D);
			m_centerDiamondColor = CreateColorTransformFromHex(0xB43C76);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0xA03167);
			m_backgroundColor = CreateColorTransformFromHex(0x8F2C5B);
			m_backlightColor = new ColorTransform(0,0,0,0);
			m_charAnimations = new IrisAnimations();
			m_charAnimations.x = -226.8;
			m_charAnimations.y = 213.6;
			m_menuButton = new IrisButton();
			m_menuButton.SetHitArea(new CircleBtnHitArea);
			m_name = "Iris"; 
			m_musicClassName = "CMC BGM";
			m_musicTitle = "CMC theme";
			m_musicStartPoint = ConvertSamplesToMilliseconds(576);
			m_musicLoopStartPoint = ConvertSamplesToMilliseconds(739524 + 576);
			m_musicLoopEndPoint = ConvertSamplesToMilliseconds(3917226+576);
		}
		
	}
	
}