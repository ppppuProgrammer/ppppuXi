package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class ZeldaMod extends AnimatedCharacterMod
    {
        public function ZeldaMod()
        {
            
			initialAnimationContainer = new ZeldaAnimations;
			initialAnimationContainer.x = -54.75;
			initialAnimationContainer.y = 94.5;
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xFDFB86);
			m_centerDiamondColor = CreateColorTransformFromHex(0xFAF91A);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0xD1C30A);
			m_outerDiamondColor = CreateColorTransformFromHex(0xFFFFAA);
			m_backlightColor = CreateColorTransformFromHex(0xFFFFFF, 00);
			
			m_menuIcon = new ZeldaIcon;
			
			m_characterName = "Zelda";
			m_preferredMusicName = "Gerudo Valley";
        }
    }
}