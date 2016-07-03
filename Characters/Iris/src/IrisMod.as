package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class IrisMod extends AnimatedCharacterMod
    {
        public function IrisMod()
        {
            this.characterPayload = new Iris();
			initialAnimationContainer = new IrisAnimations();
			initialAnimationContainer.x = -226.8;
			initialAnimationContainer.y = 213.6;
        }
    }
}