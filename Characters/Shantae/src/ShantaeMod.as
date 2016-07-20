package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class ShantaeMod extends AnimatedCharacterMod
    {
        public function ShantaeMod()
        {
            
			initialAnimationContainer = new ShantaeAnimations;
			initialAnimationContainer.x = -54.55;
			initialAnimationContainer.y = 92.75;
			
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xFE9707);
			m_centerDiamondColor = CreateColorTransformFromHex(0xF84704);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0xEE2703);
			m_outerDiamondColor = CreateColorTransformFromHex(0xF3B80B);
			
			m_menuIcon = new ShantaeIcon;
			
			m_characterName = "Shantae";
			m_preferredMusicName = "Burning Town PC";
        }
    }
}