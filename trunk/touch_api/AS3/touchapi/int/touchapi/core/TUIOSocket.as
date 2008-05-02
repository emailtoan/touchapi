﻿/**
 * This is TUIOLite!!!! 5k 
 * Version 1.3
*/

package touchapi.core
{			
	import flash.display.Stage;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.DataEvent;
	import flash.events.Event;	
	import flash.geom.Point;	
	import flash.net.XMLSocket;
	import flash.events.TouchEvent;			
	
	import flash.events.ConsoleEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	public class TUIOSocket
	{	
		internal static var state:Boolean = false;
		internal static var debug:Boolean = true;				
		private static var initialized:Boolean;	
		private static var n_stage:Stage;
		private static var n_socket:XMLSocket;										
		private static var n_ids:Array= new Array(); 		
		private static var n_objects:Array = new Array();		
			
		public static function init ($stage:DisplayObjectContainer, $debug:Boolean = true, $host:String = "localhost", $port:Number = 3000, $url:String = ''):void
		{
			if (initialized) { return; }			
			initialized = true;		
			debug = $debug;	
			
			n_stage = $stage.stage;
			n_stage.align = "TL";
			n_stage.scaleMode = "noScale";							       
			
			n_socket = new XMLSocket();	
			n_socket.addEventListener(DataEvent.DATA, dataHandler);			
			n_socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			n_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);		
			n_socket.addEventListener(Event.CONNECT, connectHandler);
			
			try
			{			
				n_socket.connect($host, $port);
			} 
			catch (e:Error) { }		
			
		}		
		public static function clear():void
		{
			n_ids = new Array(); 		
			n_objects= new Array();		
		}
		public static function getObjectById(id:Number):TUIOObject
		{
			if(id == 0)
			{
				return new TUIOObject("mouse", 0, n_stage.mouseX, n_stage.mouseY, 0, 0, 0, 0, 10, 10, null);
			}
			for(var i:int=0; i<n_objects.length; i++)
			{
				if(n_objects[i].ID == id)
				{
					return n_objects[i];
				}
			}
			return null;
		}
		public static function addObjectListener(id:Number, reciever:Object):void
		{
			var tmpObj:TUIOObject = getObjectById(id);			
			if(tmpObj)
			{
				tmpObj.addListener(reciever);				
			}
		}
		public static function removeObjectListener(id:Number, reciever:Object):void
		{
			var tmpObj:TUIOObject = getObjectById(id);			
			if(tmpObj)
			{
				tmpObj.removeListener(reciever);				
			}
		}		
		private static function processMessage(msg:XML):void
		{	var fseq:String;
			var node:XML;
			for each(node in msg.MESSAGE)
			{
				if(node.ARGUMENT[0])
				{
					if(node.ARGUMENT[0].@VALUE == "fseq")
					{
						fseq = node.ARGUMENT[1].@VALUE;		
					}
				
					if(node.ARGUMENT[0].@VALUE == "alive")
					{
					for each (var obj1:TUIOObject in n_objects)
					{
						obj1.alive = false;
					}
					
					var newIdArray:Array = new Array();					
					for each(var aliveItem:XML in node.ARGUMENT.(@VALUE != "alive"))
					{
						if(getObjectById(aliveItem.@VALUE))
							getObjectById(aliveItem.@VALUE).alive = true;

					}   
						n_ids = newIdArray;
					}
					
						var type:String;
						type = node.ARGUMENT[0].@VALUE;				
						if(type == "set")
						{
							var id:int;
							var x:Number,
								y:Number,
								X:Number,
								Y:Number,
								m:Number,
								wd:Number = 0, 
								ht:Number = 0;
				
								id = node.ARGUMENT[1].@VALUE;
								x = Number(node.ARGUMENT[2].@VALUE) * n_stage.stageWidth;
								y = Number(node.ARGUMENT[3].@VALUE) *  n_stage.stageHeight;
								X = Number(node.ARGUMENT[4].@VALUE);
								Y = Number(node.ARGUMENT[5].@VALUE);
								m = Number(node.ARGUMENT[6].@VALUE);
								if(node.ARGUMENT[7])
									wd = Number(node.ARGUMENT[7].@VALUE) * n_stage.stageWidth;															
								if(node.ARGUMENT[8])
									ht = Number(node.ARGUMENT[8].@VALUE) * n_stage.stageHeight;
							
							var stagePoint:Point = new Point(x,y);					
							var displayObjArray:Array = n_stage.getObjectsUnderPoint(stagePoint);
							var dobj:DisplayObject = null;
							
							if(displayObjArray.length > 0)								
							dobj = displayObjArray[displayObjArray.length-1];	
																				
							var tuioobj:TUIOObject = getObjectById(id);
							if(tuioobj == null)
							{
								n_stage.dispatchEvent(new ConsoleEvent(ConsoleEvent.WRITE, true, false, 'object ','-c touchapi.core.TUIOObject', ' (x:'+int(x)+', y:'+int(y)+')'));
								tuioobj = new TUIOObject("2Dcur", id, x, y, X, Y, -1, 0, wd, ht, dobj);
								n_stage.addChild(tuioobj.cursor);								
								n_objects.push(tuioobj);
								tuioobj.notifyCreated();
							} else {
								tuioobj.cursor.x = x;
								tuioobj.cursor.y = y;
								tuioobj.oldX = tuioobj.x;
								tuioobj.oldY = tuioobj.y;
								tuioobj.x = x;
								tuioobj.y = y;
								n_stage.setChildIndex(tuioobj.cursor,n_stage.numChildren-1);
								tuioobj.width = wd;
								tuioobj.height = ht;
								tuioobj.area = wd * ht;								
								tuioobj.dX = X;
								tuioobj.dY = Y;
								tuioobj.setObjOver(dobj);
																								
								if(!( int(Y*1000) == 0 && int(Y*1000) == 0) )
								{
									tuioobj.notifyMoved();
								}						
								}
								
								if(tuioobj.target && tuioobj.target.parent)
								{							
									var localPoint:Point = tuioobj.target.parent.globalToLocal(stagePoint);							
									tuioobj.target.dispatchEvent(new TouchEvent(TouchEvent.MOUSE_MOVE, true, false, x, y, localPoint.x, localPoint.y, tuioobj.oldX, tuioobj.oldY, tuioobj.target, false,false,false, true, m, "2Dcur", id, 0, 0));
								}
						}
				}
			}
			for (var i:int=0; i<n_objects.length; i++ )
			{	
				if (n_objects[i].alive == false)
				{
					n_objects[i].notifyRemoved();
					n_stage.removeChild(n_objects[i].cursor);
					n_objects.splice(i, 1);
					i--;

				} 
			else {
					if(debug)
					{	
						//n_objects[i].cursor.text.text = "";
						//n_objects[i].cursor.text.appendText("  " + (i + 1) +" - "+" X:" + int(n_objects[i].x) + "  Y:" + int(n_objects[i].y) +
						//"" + "  \n");	
						//n_stage.setChildIndex(n_objects, n_stage.numChildren - 1);
					}
					}
					}

		}
        private static function dataHandler(e:DataEvent):void 
        {           				
			try{
			processMessage(XML(e.data));}catch(e:Error){}
		
        }    
		private static function ioErrorHandler(event:IOErrorEvent):void 
        {
            //trace("ioErrorHandler: " + event);
        }
        private static function securityErrorHandler(event:SecurityErrorEvent):void 
        {
            //trace("securityErrorHandler: " + event);		
        } 	   
		private static function connectHandler(event:Event):void 
        {
			n_stage.dispatchEvent(new ConsoleEvent(ConsoleEvent.WRITE, true, false,'TUIO Socket Connected...'));
        } 			           
    }
}