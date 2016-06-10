package  {
	
	import flash.display.Sprite;
	
	
	public class SquareBtnHitArea extends Sprite{
		
		
		public function SquareBtnHitArea(setWidth:Number = 0.0, setHeight:Number = 0.0, xPos:Number = 0.0, yPos:Number=0.0) 
		{
			// constructor code
			//this.width = setWidth;
			//this.height = setHeight;
			//var hitArea:Sprite = new Sprite();
			
			/*hitArea.graphics.beginFill(0x000000);
			hitArea.graphics.lineStyle();
			hitArea.graphics.drawRect(xPos, yPos, setWidth, setHeight);
			hitArea.graphics.endFill();*/
			//addChild(hitArea);
			//this.x=xPos;
			//this.y=yPos;
			
			this.graphics.beginFill(0x000000);
			this.graphics.lineStyle();
			this.graphics.drawRect(xPos, yPos, setWidth, setHeight);
			this.graphics.endFill();
		}
	}
	
}
