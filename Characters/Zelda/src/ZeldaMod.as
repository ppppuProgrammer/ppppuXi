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
        }
    }
}