package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class GardevoirMod extends AnimatedCharacterMod
    {
        public function GardevoirMod()
        {
            
			initialAnimationContainer = new GardevoirAnimations;
			initialAnimationContainer.x = -98.75;
			initialAnimationContainer.y = 174;
			
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xFFFFFF);
			m_centerDiamondColor = CreateColorTransformFromHex(0xCCCCCC);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x999999);
			m_outerDiamondColor = CreateColorTransformFromHex(0xFF0000);
			m_backlightColor = CreateColorTransformFromHex(0x999999);
			
			m_menuIcon = new GardevoirIcon;
			
			m_characterName = "Gardevoir";
			m_preferredMusicName = "Miror B";
        }
    }
}