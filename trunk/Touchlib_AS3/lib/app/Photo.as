﻿package app{
	import flash.display.Shape;		
	import flash.display.Loader;		
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.geom.Point;			
    import flash.filters.BitmapFilter;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.DropShadowFilter; 
	
	class Photo extends RotatableScalable 
	{
		private var clickgrabber:Shape = new Shape();		
		private var photoLoader:Loader = null;		
		
		private var velX:Number = 0.0;
		private var velY:Number = 0.0;		
		
		private var velAng:Number = 0.0;
		
		private var friction:Number = 0.85;
		private var angFriction:Number = 0.92;
		
		
		public function Photo (url:String)
		{
//			trace(stage);
			this.x = 1600 * Math.random() - 800;
			this.y = 1600 * Math.random() - 800;			
			photoLoader = new Loader();
			photoLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, arrange );					

			
			clickgrabber.graphics.beginFill(0xffffff, 0.1);
			clickgrabber.graphics.drawRect(0, 0, 1,1);
			clickgrabber.graphics.endFill();			

			
			
			var request:URLRequest = new URLRequest( url );			
			
			// Unload any current child
			// Load new photo as specified by request object
			// NOTE: Repeated calls to load photo will add children to display 
			//		 object. All the photos will continue to be displayed 
			//		 overlapping one another. Allows for reuse of display 
			//		 object.
			photoLoader.unload();
			photoLoader.load( request );						
			
			addChild( photoLoader );	
			addChild( clickgrabber );
			
//            var filter:BitmapFilter = getShadowFilter();
//            var myFilters:Array = new Array();
//            myFilters.push(filter);
//            filters = myFilters;			
			
			this.addEventListener(Event.ENTER_FRAME, slide);
			
			
			// FIXME: I'd like to have some kind of status meter while it's downloading..
		}
		
		private function arrange( event:Event = null ):void 
		{
			photoLoader.x = -photoLoader.width/2;
			photoLoader.y = -photoLoader.height/2;			
			photoLoader.scaleX = 1.0;
			photoLoader.scaleY = 1.0;			
			
			clickgrabber.scaleX = photoLoader.width;
			clickgrabber.scaleY = photoLoader.height;			
			clickgrabber.x = -photoLoader.width/2;
			clickgrabber.y = -photoLoader.height/2;			
			
			this.scaleX = (Math.random()*0.4) + 0.3;
			this.scaleY = this.scaleX;
			this.rotation = Math.random()*180 - 90;
		}				
		



        private function getShadowFilter():BitmapFilter {
            var color:Number = 0x000000;
            var angle:Number = 45;
            var alpha:Number = 0.8;
            var blurX:Number = 8;
            var blurY:Number = 8;
            var distance:Number = 15;
            var strength:Number = 0.65;
            var inner:Boolean = false;
            var knockout:Boolean = false;
            var quality:Number = BitmapFilterQuality.HIGH;
            return new DropShadowFilter(distance,
                                        angle,
                                        color,
                                        alpha,
                                        blurX,
                                        blurY,
                                        strength,
                                        quality,
                                        inner,
                                        knockout);
        }		
		
		public override function released(dx:Number, dy:Number, dang:Number)
		{
			velX = dx;
			velY = dy;			
			
			velAng = dang;
		}
		
		private function slide(e:Event):void
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
				if(Math.abs(velAng) < 0.001)
					velAng = 0;					
				else {
					velAng *= angFriction;				
					this.rotation += velAng;					
				}
			}
		}
		
		
	}
}