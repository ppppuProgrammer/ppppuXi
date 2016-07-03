package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class MayMod extends AnimatedCharacterMod
    {
        public function MayMod()
        {
            this.characterPayload = new May();
			initialAnimationContainer = new MayAnimations();
			initialAnimationContainer.x = -99.15;
			initialAnimationContainer.y = 173.8;
        }
    }
}