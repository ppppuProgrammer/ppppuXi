package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class ShantaeMod extends AnimatedCharacterMod
    {
        public function ShantaeMod()
        {
            this.characterPayload = new Shantae();
			initialAnimationContainer = new ShantaeAnimations();
			initialAnimationContainer.x = -54.55;
			initialAnimationContainer.y = 92.75;
        }
    }
}