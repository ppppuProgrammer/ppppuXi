package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class ZeldaMod extends AnimatedCharacterMod
    {
        public function ZeldaMod()
        {
            this.characterPayload = new Zelda();
			initialAnimationContainer = new ZeldaAnimations();
			initialAnimationContainer.x = -54.75;
			initialAnimationContainer.y = 94.5;
        }
    }
}