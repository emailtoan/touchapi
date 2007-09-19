﻿package app {
	import flash.display.Shape;		
	import flash.events.Event;
	import flash.geom.Point;		
	
	public class PhotoCanvas extends RotatableScalable
	{

		
		private var clickgrabber:Shape = new Shape();				
		private var sizeX:int = 6000;
		private var sizeY:int = 6000;
		
		private var velX:Number = 0.0;
		private var velY:Number = 0.0;		
		
		private var velAng:Number = 0.0;
		
		private var friction:Number = 0.85;
		private var angFriction:Number = 0.92;
		
		
		
		function PhotoCanvas()
		{
			bringToFront = false;			
			noScale = false;
			noRotate = false;
			
			clickgrabber.graphics.beginFill(0xffffff, 0.0);
			clickgrabber.graphics.drawRect(-sizeX/2,-sizeY/2,sizeX,sizeY);
			clickgrabber.graphics.endFill();						
			
			this.addChild( clickgrabber );		
			this.addEventListener(Event.ENTER_FRAME, slide);			
		}
		
		public override function released(dx:Number, dy:Number, dang:Number)
		{
			velX = dx;
			velY = dy;			
			
			velAng = dang;
		}
		
		private function slide(e:Event)
		{
			if(this.state == "none")
			{		
				if(Math.abs(velX) < 0.001)
					velX = 0;
				else {
					x += velX;
					velX *= friction;										
				}
				if(Math.abs(velY) < 0.001)
					velY = 0;					
				else {
					y += velY;
					velY *= friction;						
				}
			}
		}		
		
		public function addPhoto(sz:String)
		{
			var photo:Photo = new Photo( sz );
			this.addChild(photo);
		}
		
		
	}
}