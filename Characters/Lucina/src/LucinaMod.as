package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;
	import flash.geom.ColorTransform;

    public class LucinaMod extends AnimatedCharacterMod
    {
        public function LucinaMod()
        {
            
			initialAnimationContainer = new LucinaAnimations;
			initialAnimationContainer.x = -54.05;
			initialAnimationContainer.y = 93;
			
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xC4CCE1);
			m_centerDiamondColor = CreateColorTransformFromHex(0xA3B1D1);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x869AC4);
			m_outerDiamondColor = CreateColorTransformFromHex(0x496298);
			m_backlightColor = new ColorTransform(0, 0, 1);
			
			m_menuIcon = new LucinaIcon;
			
			m_characterName = "Lucina";
			m_preferredMusicName = "FE Spa";
        }
    }
}