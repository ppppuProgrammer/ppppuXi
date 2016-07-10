package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class ToadetteMod extends AnimatedCharacterMod
    {
        public function ToadetteMod()
        {
            this.characterPayload = new Toadette();
            this.initialAnimationContainer = new ToadetteAnimations();
        }
    }
}