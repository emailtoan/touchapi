﻿// Added: Listener functions which should greatly simplify dealing with TUIO events.. 

// FIXME: need velocity

package com.touchlib {
import flash.display.Sprite;
import flash.display.DisplayObject;	
import flash.display.InteractiveObject;	
import flash.display.MovieClip;	
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.Timer;
import flash.events.MouseEvent;
import flash.events.Event;
	
	public class TUIOObject 
	{
		public var x:Number;
		public var y:Number;
		
		public var oldX:Number;
		public var oldY:Number;
		
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
		
		public var aListeners:Array;
		public var color:int;
		
		public function TUIOObject (cls:String, id:int, px:Number, py:Number, dx:Number, dy:Number, sid:int = -1, ang:Number = 0, o:Object = null)
		{
			aListeners = new Array();
			TUIOClass = cls;
			ID = id;
			x = px;
			y = py;
			oldX = px;
			oldY = py;
			dX = dx;
			dY = dy;
			sID = sid;
			angle = ang;
			isAlive = true;				
			var c = int(Math.random() * 4);
			
			if(c == 0)
				color = 0xff0000;
			else if(c == 1)
				color = 0x00ffff;
			else if(c == 2)
				color = 0x00ff00;				
			else if(c == 3)
				color = 0x0000ff;		
				
			spr = new TUIOCursor(ID.toString());			
			spr.x = x;
			spr.y = y;  			
			
			try {
 	 			obj = o;
			} catch (e:Event)
			{
				obj = null;
			}
			
			//trace("Start : " + ID + ", " + sID + " (" + int(px) + "," + int(py) + ")");
			//trace("Start : " + ID);
			
			isNew = true;
		}
		
		public function notifyCreated():void
		{
			if(obj)
			{
				try
				{
					var localPoint:Point = obj.parent.globalToLocal(new Point(x, y));				
					//trace("Down : " + localPoint.x + "," + localPoint.y);
					obj.dispatchEvent(new TUIOEvent(TUIOEvent.TUIO_OVER, true, false, x, y, localPoint.x, localPoint.y, obj, false,false,false, true, 0, TUIOClass, ID, sID, angle));													
					obj.dispatchEvent(new TUIOEvent(TUIOEvent.TUIO_DOWN, true, false, x, y, localPoint.x, localPoint.y, obj, false,false,false, true, 0, TUIOClass, ID, sID, angle));									
				} catch (e:Event)
				{
						trace("Failed : " + e);
//					trace(obj.name);
					obj = null;
				}
			}			
		}
		
		public function setObjOver(o:DisplayObject):void
		{
			if(o == null)
				return;
				
			try {
				var localPoint:Point;
				
				if(obj == null)
				{
					obj = o;				
					if(obj) 
					{
						localPoint = obj.parent.globalToLocal(new Point(x, y));				
						obj.dispatchEvent(new TUIOEvent(TUIOEvent.TUIO_OVER, true, false, x, y, localPoint.x, localPoint.y, obj, false,false,false, true, 0, TUIOClass, ID, sID, angle));					
					}
				} else if(obj != o) 
				{
					
					localPoint = obj.parent.globalToLocal(new Point(x, y));								
					obj.dispatchEvent(new TUIOEvent(TUIOEvent.TUIO_OUT, true, false, x, y, localPoint.x, localPoint.y, obj, false,false,false, true, 0, TUIOClass, ID, sID, angle));
					if(o)
					{
						localPoint = obj.parent.globalToLocal(new Point(x, y));
						o.dispatchEvent(new TUIOEvent(TUIOEvent.TUIO_OVER, true, false, x, y, localPoint.x, localPoint.y, obj, false,false,false, true, 0, TUIOClass, ID, sID, angle));
					}
					obj = o;								
				}
			} catch (e:Event)
			{
//				trace("ERROR " + e);
			}
		}
		
		public function addListener(reciever:Object):void
		{
			aListeners.push(reciever);
		}
		public function removeListener(reciever:Object):void
		{
			for(var i:int = 0; i<aListeners.length; i++)
			{
				if(aListeners[i] == reciever)
					aListeners.splice(i, 1);
			}
		}		
		
		public function removeObject():void
		{
			//trace("End : " + ID);			
			var localPoint:Point;
			
			if(obj && obj.parent)
			{				
				localPoint = obj.parent.globalToLocal(new Point(x, y));				
				obj.dispatchEvent(new TUIOEvent(TUIOEvent.TUIO_OUT, true, false, x, y, localPoint.x, localPoint.y, obj, false,false,false, true, 0, TUIOClass, ID, sID, angle));				
				obj.dispatchEvent(new TUIOEvent(TUIOEvent.TUIO_UP, true, false, x, y, localPoint.x, localPoint.y, obj, false,false,false, true, 0, TUIOClass, ID, sID, angle));									
			}			
			obj = null;
			
			for(var i:int=0; i<aListeners.length; i++)
			{
				localPoint = aListeners[i].parent.globalToLocal(new Point(x, y));				
				aListeners[i].dispatchEvent(new TUIOEvent(TUIOEvent.TUIO_UP, true, false, x, y, localPoint.x, localPoint.y, aListeners[i], false,false,false, true, 0, TUIOClass, ID, sID, angle));								
			}
		}
		
		public function notifyMoved():void
		{
			var localPoint:Point;
			for(var i:int=0; i<aListeners.length; i++)
			{
				//trace("Notify moved");
				localPoint = aListeners[i].parent.globalToLocal(new Point(x, y));				
				aListeners[i].dispatchEvent(new TUIOEvent(TUIOEvent.TUIO_MOVE, true, false, x, y, localPoint.x, localPoint.y, aListeners[i], false,false,false, true, 0, TUIOClass, ID, sID, angle));								
			}			
		}
	}
}