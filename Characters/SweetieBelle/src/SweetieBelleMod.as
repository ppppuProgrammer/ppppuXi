package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class SweetieBelleMod extends AnimatedCharacterMod
    {
        public function SweetieBelleMod()
        {
            this.characterPayload = new SweetieBelle();
			initialAnimationContainer = new SweetieBelleAnimations();
			initialAnimationContainer.x = -54.05;
			initialAnimationContainer.y = 93;
        }
    }
}