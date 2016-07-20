package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;
	import flash.geom.ColorTransform;

    public class SamusMod extends AnimatedCharacterMod
    {
        public function SamusMod()
        {
            
			initialAnimationContainer = new SamusAnimations;
			initialAnimationContainer.x = -54.75;
			initialAnimationContainer.y = 92;
			
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xFF7464);
			m_centerDiamondColor = CreateColorTransformFromHex(0xCD2C2E);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x982C2E);
			m_outerDiamondColor = CreateColorTransformFromHex(0xFF2C2E);
			m_backlightColor = new ColorTransform(.53,.53,.53,.73,120,120);
			
			m_menuIcon = new SamusIcon;
			
			m_characterName = "Samus";
			m_preferredMusicName = "Mission Final";
        }
    }
}