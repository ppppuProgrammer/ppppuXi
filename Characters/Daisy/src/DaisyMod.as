package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class DaisyMod extends AnimatedCharacterMod
    {
        public function DaisyMod()
        {
            this.characterPayload = new Daisy();
			initialAnimationContainer = new DaisyAnimations();
			initialAnimationContainer.x = -99.4;
			initialAnimationContainer.y = 173.8;
        }
    }
}