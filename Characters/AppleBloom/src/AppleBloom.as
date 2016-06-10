package  
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author 
	 */
	public class AppleBloom extends AnimatedCharacter 
	{
		
		public function AppleBloom()
		{
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xEF67A5);
			m_centerDiamondColor = CreateColorTransformFromHex(0xD7298F);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x99258E);
			m_backgroundColor = CreateColorTransformFromHex(0xF6B7D2);
			m_backlightColor = CreateColorTransformFromHex(0x49FBE1);
			m_charAnimations = new AppleBloomAnimations();
			m_charAnimations.x = -54.05;
			m_charAnimations.y = 93;
			m_menuButton = new AppleBloomButton();
			m_menuButton.SetHitArea(new CircleBtnHitArea);
			m_name = "Apple Bloom"; 
			m_musicClassName = "CMC BGM";
			m_musicTitle = "CMC theme";
			m_musicStartPoint = ConvertSamplesToMilliseconds(576);
			m_musicLoopStartPoint = ConvertSamplesToMilliseconds(739524 + 576);
			m_musicLoopEndPoint = ConvertSamplesToMilliseconds(3917226+576);
		}
		
	}

}