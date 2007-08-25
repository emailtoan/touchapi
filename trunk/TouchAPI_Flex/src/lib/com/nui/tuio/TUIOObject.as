﻿package com.nui.tuio {
	
/**
 * LastChanged:
 * 
 * $Author$
 * $Revision$
 * $LastChangedDate$
 * $URL$
 * 
 */ 

import flash.display.Sprite;
import flash.display.DisplayObject;	
import flash.display.MovieClip;	
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.filters.DropShadowFilter;

	public class TUIOObject 
	{
		public var x:Number;
		public var y:Number;		
		public var dX:Number;
		public var dY:Number;						
		public var area:Number;		
		public var TUIOClass:String;		// cur or Obj.. 
		public var sID:int;
		public var ID:int;
		public var angle:Number;		
		public var pressure:Number;		
		private var isNew:Boolean;
		public var isAlive:Boolean;		
		public var obj;
		public var spr:Sprite;		
		private var color:int;
		private var DEBUG_TEXT:TextField;

		public function TUIOObject (cls:String, id:int, px:Number, py:Number, dx:Number, dy:Number, sid:int = -1, ang:Number = 0, o = null)
		{
			TUIOClass = cls;
			ID = id;
			x = px;
			y = py;
			dX = dx;
			dY = dy;
			sID = sid;
			angle = ang;
			isAlive = true;		

			spr = new MovieClip();
			spr.graphics.beginFill(0xFFFFFF , 0.5);					
			spr.graphics.drawCircle(0,0,10);
			spr.graphics.endFill();
			spr.graphics.lineStyle(1, 0x000000, 1);	
			//spr.graphics.drawCircle(0,0,10);		
			//spr.graphics.drawCircle(0,0,11);		
			//spr.graphics.lineStyle(1, 0xFFFFFF, 1);			
			//spr.graphics.drawCircle(0,0,12);		
			//spr.blendMode="invert";		
			var dropshadow:DropShadowFilter=new DropShadowFilter(0,90, 0xFFFFFF, 0.5, 20, 20);
			spr.filters=new Array(dropshadow);
			spr.x = x;
			spr.y = y;  			
			
			var format:TextFormat = new TextFormat();
			DEBUG_TEXT = new TextField();
        	format.font = "Verdana";
     		format.color = 0xFFFFFF;
        	format.size = 10;
			DEBUG_TEXT.defaultTextFormat = format;
			DEBUG_TEXT.autoSize = TextFieldAutoSize.LEFT;
			DEBUG_TEXT.background = false;	
			DEBUG_TEXT.backgroundColor = 0xFFFFFF;	
			DEBUG_TEXT.border = true;	
			DEBUG_TEXT.text = '';
			DEBUG_TEXT.appendText( ' ' + ID);
			//DEBUG_TEXT.appendText( 'var' + ID +"var"+ sID + " (x:" + int(x) + ", y:" + int(y) + ")");
			
			DEBUG_TEXT.x = -10;
			DEBUG_TEXT.y = 10;  
			spr.addChild(DEBUG_TEXT);
			//DEBUG_TEXT.text = '';



		

			try {
 	 			obj = o;
			} catch (e:Error)
			{
				obj = null;
			}
			trace("------------------------------------------------------");			
			trace("Start " + ID + ", " + sID + " (" + int(px) + "," + int(py) + ")");
			
			if(obj)
			{
				try
				{	
				spr.graphics.beginFill( 0xFFFFFF , 1);					
				spr.graphics.drawCircle(0,0,7);
				spr.graphics.endFill();
				var localPoint:Point = obj.parent.globalToLocal(new Point(x, y));				
					trace("Down : " + localPoint.x + "," + localPoint.y);
					obj.dispatchEvent(new TUIOEvent(TUIOEvent.ROLL_OVER, true, false, x, y, localPoint.x, localPoint.y, obj, false,false,false, true, 0, TUIOClass, ID, sID, angle));													
					obj.dispatchEvent(new TUIOEvent(TUIOEvent.DOWN, true, false, x, y, localPoint.x, localPoint.y, obj, false,false,false, true, 0, TUIOClass, ID, sID, angle));									
				} catch (e:Error)
				{
						trace("Failed : " + e);
//					trace(obj.name);
					obj = null;
				}
			}
			
			isNew = true;
		}
		
		public function setObjOver(o:DisplayObject):void
		{
			try {
				
				if(obj == null)
				{
					obj = o;				
					if(obj) 
					{
						var localPoint:Point = obj.parent.globalToLocal(new Point(x, y));				
						obj.dispatchEvent(new TUIOEvent(TUIOEvent.ROLL_OVER, true, false, x, y, localPoint.x, localPoint.y, obj, false,false,false, true, 0, TUIOClass, ID, sID, angle));					
					}
				} else if(obj != o) 
				{
					
					var localPoint:Point = obj.parent.globalToLocal(new Point(x, y));								
					obj.dispatchEvent(new TUIOEvent(TUIOEvent.ROLL_OUT, true, false, x, y, localPoint.x, localPoint.y, obj, false,false,false, true, 0, TUIOClass, ID, sID, angle));
					if(o)
					{
						localPoint = obj.parent.globalToLocal(new Point(x, y));
						o.dispatchEvent(new TUIOEvent(TUIOEvent.ROLL_OVER, true, false, x, y, localPoint.x, localPoint.y, obj, false,false,false, true, 0, TUIOClass, ID, sID, angle));
					}
					obj = o;								
				}
			} catch (e:Error)
			{
//				trace("ERROR " + e);
			}
		}
		
		public function disposeObject():void
		{
			trace("End: " + ID);		
			if(obj && obj.parent)
			{				
				var localPoint:Point = obj.parent.globalToLocal(new Point(x, y));				
				obj.dispatchEvent(new TUIOEvent(TUIOEvent.ROLL_OUT, true, false, x, y, localPoint.x, localPoint.y, obj, false,false,false, true, 0, TUIOClass, ID, sID, angle));				
				obj.dispatchEvent(new TUIOEvent(TUIOEvent.UP, true, false, x, y, localPoint.x, localPoint.y, obj, false,false,false, true, 0, TUIOClass, ID, sID, angle));									
			}			
			obj = null;
		}
	}
}