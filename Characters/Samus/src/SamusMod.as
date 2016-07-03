package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class SamusMod extends AnimatedCharacterMod
    {
        public function SamusMod()
        {
            this.characterPayload = new Samus();
			initialAnimationContainer = new SamusAnimations();
			initialAnimationContainer.x = -54.75;
			initialAnimationContainer.y = 92;
        }
    }
}