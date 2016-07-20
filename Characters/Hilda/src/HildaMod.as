package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class HildaMod extends AnimatedCharacterMod
    {
        public function HildaMod()
        {
            
			initialAnimationContainer = new HildaAnimations;
			initialAnimationContainer.x = -104.75;
			initialAnimationContainer.y = 92;
			
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xFFFFFF);
			m_centerDiamondColor = CreateColorTransformFromHex(0xCCCCCC);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x999999);
			m_outerDiamondColor = CreateColorTransformFromHex(0xFF0000);
			m_backlightColor = CreateColorTransformFromHex(0x999999);
			
			m_menuIcon = new HildaIcon;
			
			m_characterName = "Hilda";
			m_preferredMusicName = "Miror B";
        }
    }
}