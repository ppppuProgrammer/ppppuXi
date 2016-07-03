package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class MidnaMod extends AnimatedCharacterMod
    {
        public function MidnaMod()
        {
            this.characterPayload = new Midna();
			initialAnimationContainer = new MidnaAnimations();
			initialAnimationContainer.x = -54.05;
			initialAnimationContainer.y = 93;
        }
    }
}