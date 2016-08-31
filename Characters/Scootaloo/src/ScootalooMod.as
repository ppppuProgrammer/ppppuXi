package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class ScootalooMod extends AnimatedCharacterMod
    {
        public function ScootalooMod()
        {
            
			initialAnimationContainer = new ScootalooAnimations;
			initialAnimationContainer.x = -54.05;
			initialAnimationContainer.y = 93;
			
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xEF67A5);
			m_centerDiamondColor = CreateColorTransformFromHex(0xD7298F);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x99258E);
			m_outerDiamondColor = CreateColorTransformFromHex(0xF6B7D2);
			m_backlightColor = CreateColorTransformFromHex(0x49FBE1);
			
			m_menuIcon = new ScootalooIcon;
			
			m_characterName = "Scootaloo"; 
			m_preferredMusicName = "CMC Go Crusading";
        }
    }
}