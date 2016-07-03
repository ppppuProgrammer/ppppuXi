package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class IsabelleMod extends AnimatedCharacterMod
    {
        public function IsabelleMod()
        {
            this.characterPayload = new Isabelle();
			initialAnimationContainer = new IsabelleAnimations();
			initialAnimationContainer.x = -54.75;
			initialAnimationContainer.y = 92;
        }
    }
}