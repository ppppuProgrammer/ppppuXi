package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class PeachMod extends AnimatedCharacterMod
    {
        public function PeachMod()
        {
            this.characterPayload = new Peach();
        }
    }
}