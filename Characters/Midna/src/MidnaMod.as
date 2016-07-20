package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class MidnaMod extends AnimatedCharacterMod
    {
        public function MidnaMod()
        {
            
			initialAnimationContainer = new MidnaAnimations;
			initialAnimationContainer.x = -54.05;
			initialAnimationContainer.y = 93;
			
			m_topLeftDiamondColor = CreateColorTransformFromHex(0x999999);
			m_centerDiamondColor = CreateColorTransformFromHex(0x666666);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x333333);
			m_outerDiamondColor = CreateColorTransformFromHex(0xCCCCCC);
			m_backlightColor = CreateColorTransformFromHex(0x49FBE1);
			//m_backlightColor = 1.0, 1.0, 1.0, 1.0, -26, 19, 122;
			
			m_menuIcon = new MidnaIcon;
			
			m_characterName = "Midna";
			m_preferredMusicName = "Gerudo Valley";
        }
    }
}