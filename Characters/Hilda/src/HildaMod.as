package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class HildaMod extends AnimatedCharacterMod
    {
        public function HildaMod()
        {
            this.characterPayload = new Hilda();
			initialAnimationContainer = new HildaAnimations();
			initialAnimationContainer.x = -104.75;
			initialAnimationContainer.y = 92;
        }
    }
}