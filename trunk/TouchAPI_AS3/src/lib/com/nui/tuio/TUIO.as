﻿﻿package com.nui.tuio {

import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.events.DataEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.geom.Point;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.XMLSocket;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import mx.validators.EmailValidator;
import flash.events.MouseEvent;
import flash.display.DisplayObject;
import mx.skins.halo.ApplicationBackground;

public class TUIO
{	
	private static var INSTANCE:TUIO;	

	private static var HOST:String;
	private static var PORT:Number;	

	private static var STAGE_WIDTH:int;
	private static var STAGE_HEIGHT:int;	
	
	// TODO: If this is set to false, TUIOCursors will NOT be removed!
    private static var DEBUG_MODE:Boolean = true; // NOTE: When you set values like this they will be in the PROTOTYPE chain and shared with all instances of this class.
	private static var RECORD_MODE:Boolean;
		
	private static var SOCKET:XMLSocket;
	private static var STAGE:Sprite;

	private static var TESTING_XML_URL:String; 
	private static var TESTING_XML:XML;
	private static var TESTING_XML_LOADER:URLLoader;	
	
	private static var RECORDED_XML:XML;
		
	private static var objectArray:Array;
	private static var DEBUG_TEXT:TextField;
	
	private static var EMULATE_FLEX_MOUSE:Boolean;

	/**********************************************************
	 * INIT
	***********************************************************/

	public static function init ( s:Sprite, host:String, port:Number, stageWidth:int, stageHeight:int, testingXML:String, recordMode:Boolean ):TUIO
	{     	
		if( INSTANCE == null ) 
		{
			INSTANCE = new TUIO( init );

			STAGE = s;
						
			STAGE_WIDTH = stageWidth;
			STAGE_HEIGHT = stageHeight;
						
			TESTING_XML_URL = testingXML;
			
			HOST = host;
			PORT = port;
			
			RECORD_MODE = recordMode;
			
			INSTANCE.start();
			
		}
		return INSTANCE;	
	}


	/**********************************************************
	 * GET_INSTANCE
	***********************************************************/
	public static function getInstance():TUIO
	{
		if (INSTANCE == null)
		{
			throw new Error("TUIO Instance not created, please use TUIO.init() before calling this function.");
		}
		
		return INSTANCE;
	}


	/**********************************************************
	 * START
	***********************************************************/
		
	private function start():void
	{
		EMULATE_FLEX_MOUSE = true;
		
		objectArray = new Array();
		
		if( DEBUG_MODE )
		{
			activateDebugMode();				
		}
	    if ( RECORD_MODE )
		{	
			activateRecordMode();
		}	
		if( TESTING_XML_URL != '' )
		{
			TESTING_XML_LOADER = new URLLoader();
			TESTING_XML_LOADER.addEventListener( 'complete', testingXmlOnLoaded );
			TESTING_XML_LOADER.load( new URLRequest( TESTING_XML_URL ) );				
		} else
		{
			SOCKET = new XMLSocket();
			
			SOCKET.addEventListener( Event.CLOSE, closeHandler );
			SOCKET.addEventListener( Event.CONNECT, connectHandler );
			SOCKET.addEventListener( DataEvent.DATA, dataHandler );
			SOCKET.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			SOCKET.addEventListener( ProgressEvent.PROGRESS, progressHandler );
			SOCKET.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
			
			SOCKET.connect( HOST, PORT );	
		}					
	}
	
	/**********************************************************
	 * ACTIVATE_DEBUG_MODE
	***********************************************************/
	
	private function activateDebugMode():void
	{
		var format:TextFormat = new TextFormat();
		DEBUG_TEXT = new TextField();
        format.font = 'Verdana';
     	format.color = 0xFFFFFF;
        format.size = 10;
        
		DEBUG_TEXT.defaultTextFormat = format;
		DEBUG_TEXT.autoSize = TextFieldAutoSize.LEFT;
		DEBUG_TEXT.background = true;	
		DEBUG_TEXT.backgroundColor = 0x000000;	
		DEBUG_TEXT.border = true;	
		DEBUG_TEXT.borderColor = 0x333333;	
	
		
		STAGE.addChild( DEBUG_TEXT );
	}

	/**********************************************************
	 * ACTIVATE_RECORD_MODE
	***********************************************************/
	
	private function activateRecordMode():void
	{
		RECORDED_XML = <OSCPackets></OSCPackets>;
			
		var record_btn:Sprite = new Sprite();
	
		record_btn.graphics.lineStyle( 2, 0x202020 );
		record_btn.graphics.beginFill( 0xF80101,0.5 );
		record_btn.graphics.drawRoundRect( 10, 10, 200, 200, 6 );				 
		record_btn.addEventListener( TUIOEvent.DOWN, stopRecording );
		
		STAGE.addChild( record_btn );
	}

	/**********************************************************
	 * TESTING_XML_ON_LOADED
	***********************************************************/
	
	private function testingXmlOnLoaded( e:Event ):void 
	{
		TESTING_XML = new XML( e.target.data );
		
		STAGE.addEventListener( Event.ENTER_FRAME, updateFrame );
	}

	/**********************************************************
	 * UPDATE_FRAME
	***********************************************************/
	
	private function updateFrame( e:Event ):void
	{
		if( TESTING_XML && TESTING_XML.OSCPACKET && TESTING_XML.OSCPACKET[ 0 ] )
		{			
			processXML( TESTING_XML.OSCPACKET[ 0 ] );
			delete TESTING_XML.OSCPACKET[ 0 ];
		}
	}		

	/**********************************************************
	 * GET_OBJECT_BY_ID
	***********************************************************/

	public function getObjectById( id:int ):TUIOObject
	{
		var listAmount:int = objectArray.length;
		
		for( var i:int = 0; i < listAmount; i++ )
		{
			if( objectArray[ i ].ID == id )
			{
				return objectArray[ i ];
			}
		}	
		return null;
	}


	/**********************************************************
	 * EMULATE_MOUSE_EVENT
	***********************************************************/
	private function emulateMouseEvent(target:InteractiveObject, type:String, x:Number, y:Number, relatedObject:InteractiveObject):void
	{
		trace(" @@@@@@@@@@ Emulating mouse event: " + type + " on " + target);
		
		if (target == null) 
			return;
			
		var p:Point = new Point(x, y);
		p = target.globalToLocal(p);
		p.x = 5;
		p.y = 5;
		
		// TODO: What should the x,y point be for a RollOut event?
		// Are we still in the new InteractiveObjects local space or the old one? (in the latter case giving it x,y outside its area)
		
		
		var me:MouseEvent; 
		if (relatedObject != null)
		{
			me = new MouseEvent(type, true , true, p.x, p.y, relatedObject);		
		} 
		else
		{
			me = new MouseEvent(type, true , true, p.x, p.y);
		}
		target.dispatchEvent(me);
	}	



	private function getObjectsUnderFinger(x:Number, y:Number):InteractiveObject
	{
		var stagePoint:Point = new Point( x,y );
		var tuioObjList:Array = STAGE.stage.getObjectsUnderPoint( stagePoint );
			
		var bottomObject:InteractiveObject;	
				
		if (EMULATE_FLEX_MOUSE && tuioObjList.length > 0)
		{
			// bottomObject is the highest InteractiveObject under the given finger x, y.
			// It's the one that gets the mouse input events.
	
			if ( tuioObjList[ tuioObjList.length-1 ] is TUIOCursor )
			{
				bottomObject = findTopObject( tuioObjList[ tuioObjList.length-2 ] );	
			}
			else
			{
				bottomObject = findTopObject( tuioObjList[ tuioObjList.length-1 ] );	
			}
					
			if (bottomObject != null)
				trace("Obj is: " + bottomObject);
						
		}
			
		return bottomObject;
	}


	/**********************************************************
	 * FIND_TOP_OBJECT
	 * Finds the first InteractiveObject for a given DisplayObject by .parent
	***********************************************************/
	private function findTopObject(obj:DisplayObject):InteractiveObject
	{
		
		trace("findTop got: " + obj);
		
		if (obj == null)
		{
			return null;
		}
		else if(obj is TUIOCursor)
		{
			return null;
		}
		else if (obj is InteractiveObject)
		{
			trace("Foo is InteractiveObject: " + obj);
			if (obj.parent.mouseChildren == false)
			{
				obj = findTopObject(obj.parent);
			}
			return InteractiveObject(obj);	
		}
		else if (obj.parent != null)
		{
			trace("Going for the parent");
			return findTopObject(obj.parent);
		}
		else
		{
			return null;
		}
		
	}
	
	private function findTopperObject(obj:InteractiveObject):InteractiveObject
	{
		if (obj == null)
		{
			return null;
		}
		else if (obj.parent.mouseChildren)
		{
			findTopperObject(obj.parent);
		}
		else
		{
			return obj.parent;
		}
		
		return obj;
	}


	/**********************************************************
	 * PROCESS_XML
	***********************************************************/

	private function processXML( xml:XML ):void
	{
		// XML-Node
		var node:XML;
		
		// fseq
		var fseq:String;
		
		// list of TUIO-Objects
		var tuioObjList:Array;
		
		// the object at the bottom of the display chain (which the finger is currently over)
		var bottomObject:InteractiveObject;
		
		// TUIO-Object
		var tuioObj:Object;
		
		// type can be set / alive
		var type:String;
		
		// store positions
		var localPoint:Point;
		var stagePoint:Point
		
		// sessionID
		var sID:int;
		
		// classID or unique id for every touchEvent
		var id:int;
		
		// new x,y coordinates
		var x:Number;
		var y:Number;
		
		// old x,y coordinates
		var X:Number;
		var Y:Number;
		
		// rotation vector
		var a:Number;
		var A:Number;
		
		// motion acceleration
		var m:Number;
		
		// rotation accel
		var r:Number;
		
		for each( node in xml.MESSAGE )
		{
			// detect fseq
			
			if( node.ARGUMENT[0] && node.ARGUMENT[0].@VALUE == 'fseq' )
			{
				// in the moment not in use
				fseq = node.ARGUMENT[ 1 ].@VALUE;					
			}
			
			// detect alive status
			
			if( node.ARGUMENT[ 0 ] && node.ARGUMENT[ 0 ].@VALUE == 'alive' )
			{
				for each ( var obj:TUIOObject in objectArray )
				{
					obj.isAlive = false;
					//TODO: Trigger MouseEvent.MOUSE_UP here?
				}
													
				for each( var aliveItem:XML in node.ARGUMENT.( @VALUE != 'alive' ) )
				{
					if( getObjectById( aliveItem.@VALUE ) )
					{
						getObjectById( aliveItem.@VALUE ).isAlive = true;
					}
				}   					
			}
			
			// detect new blobs / input
			
			if( node.ARGUMENT[ 0 ] )
			{
				
				// Static objects that gets put on the table, NOT fingers!
				if( node.@NAME == '/tuio/2Dobj' )
				{		
					
					type = node.ARGUMENT[0].@VALUE;				
					
					if( type == 'set' )
					{   
						var dobj:InteractiveObject = null;
						sID = node.ARGUMENT[ 1 ].@VALUE;
						id = node.ARGUMENT[ 2 ].@VALUE;
						x = Number( node.ARGUMENT[ 3 ].@VALUE ) * STAGE_WIDTH;
						y = Number( node.ARGUMENT[ 4 ].@VALUE ) * STAGE_HEIGHT;
						a = Number( node.ARGUMENT[ 5 ].@VALUE );
						X = Number( node.ARGUMENT[ 6 ].@VALUE );
						Y = Number( node.ARGUMENT[ 7 ].@VALUE );
						A = Number( node.ARGUMENT[ 8 ].@VALUE );
						m = node.ARGUMENT[ 9 ].@VALUE;
						r = node.ARGUMENT[ 10 ].@VALUE;
				
						tuioObj = getObjectById( id );
						if( tuioObj == null )
						{
							tuioObj = new TUIOObject('2Dobj', id, x, y, X, Y, objectArray.length, a );
							STAGE.addChild( tuioObj.spr );							
							objectArray.push( tuioObj );
						} else {
							tuioObj.spr.x = x;
							tuioObj.spr.y = y;								
							tuioObj.x = x;
							tuioObj.y = y;
							tuioObj.dX = X;
							tuioObj.dY = Y;							
							tuioObj.setObjOver( dobj );
						}
					}
				} else if( node.@NAME == '/tuio/2Dcur' )
				{ // 2Dcur is a finger that touches the table (cur = cursor)
			
					type = node.ARGUMENT[ 0 ].@VALUE;				
					//trace("type is: " + type);
					
					if( type == 'set' )
					{	
						//var dobj:InteractiveObject = null;
						id = node.ARGUMENT[ 1 ].@VALUE;
						x = Number( node.ARGUMENT[ 2 ].@VALUE ) * STAGE_WIDTH;
						y = Number( node.ARGUMENT[ 3 ].@VALUE ) * STAGE_HEIGHT;
						X = Number( node.ARGUMENT[ 4 ].@VALUE );
						Y = Number( node.ARGUMENT[ 5 ].@VALUE );
						m = node.ARGUMENT[ 6 ].@VALUE;
						//a = node.ARGUMENT[ 7 ].@VALUE;							

						tuioObj = getObjectById( id );
						// If we don't have an object on stage, we assume this is a new press
						if( tuioObj == null )
						{
							trace(" @@@@ CREATING NEW THINGIE!");
							
							tuioObj = new TUIOObject('2Dcur', id, x, y, X, Y, objectArray.length, 0 );
							//tuioObj.area = a;
							STAGE.addChild( tuioObj.spr );
							
							bottomObject = getObjectsUnderFinger(x, y);
							
							if (EMULATE_FLEX_MOUSE && bottomObject != null)
							{	emulateMouseEvent(bottomObject, MouseEvent.CLICK, x, y, null);
								//emulateMouseEvent(bottomObject, MouseEvent.MOUSE_DOWN, x, y, null);							
							}
														
							objectArray.push( tuioObj );
						} else {
							tuioObj.spr.x = x;
							tuioObj.spr.y = y;
							tuioObj.x = x;
							tuioObj.y = y;
							//tuioObj.area = a;								
							tuioObj.dX = X;
							tuioObj.dY = Y;
							
							// Triggers TUIOEvents
							tuioObj.setObjOver( dobj );
							
							bottomObject = getObjectsUnderFinger(x, y);
							
							// Roll out and roll over requires the relatedObject property to be set
							if (tuioObj.currentTarget != bottomObject)
							{
								// We have rolled out from last known component
								// New target might be null. In case of null and finger up, what should happen? Roll Out?
								if (EMULATE_FLEX_MOUSE && bottomObject != null)
								{
									emulateMouseEvent(tuioObj.currentTarget, MouseEvent.MOUSE_OUT, x, y, bottomObject);
									emulateMouseEvent(bottomObject, MouseEvent.MOUSE_OVER, x, y, null);
								}	
								
							}
							
							tuioObj.currentTarget = bottomObject;
							
							
							// TODO: Done! See above! //Erik Pettersson
							/*
									To get roll over and roll out to work we need to tell the *last* object that the finger has rolled out
									This is done by comparing the bottomObject I presume. 
									the 'relatedObject' property of MouseEvent should get the new bottomObject on roll out.
							*/
							
							if (EMULATE_FLEX_MOUSE && bottomObject != null)
								emulateMouseEvent(bottomObject, MouseEvent.MOUSE_MOVE, x, y, null);
						}	
					}	
				}
			}
		}		
		if(DEBUG_MODE)
		{
			DEBUG_TEXT.text = '';
			
			for ( var i:int=0; i<objectArray.length; i++ )
			{
				if( objectArray[i].isAlive == false )
				{
					// TODO: cast objects
					var disposeObj:TUIOObject = objectArray[i];	
					var target:InteractiveObject = getObjectsUnderFinger(disposeObj.x, disposeObj.y);
					if (EMULATE_FLEX_MOUSE && target != null)
					{
						emulateMouseEvent(target, MouseEvent.MOUSE_UP, disposeObj.x, disposeObj.y, null);
					}
					
					
					objectArray[i].disposeObject();
					STAGE  .removeChild(objectArray[i].spr);
					objectArray.splice(i, 1);
					i--;
	
				} else {
				//DEBUG DATA
			    if(DEBUG_MODE)
						DEBUG_TEXT.appendText('  ' + (i+1) + ' - ' + objectArray[i].ID + '  X: ' + int(objectArray[i].x) + '  Y: ' + int(objectArray[i].y) +  '   \n' );
						DEBUG_TEXT.y = STAGE_HEIGHT-300;
						DEBUG_TEXT.x = STAGE_WIDTH-250;				
				}
			}
		}
	}

	/**********************************************************
	 * STOP_RECORDING
	***********************************************************/
	
	private function stopRecording( e:TUIOEvent ):void
	{		
		RECORD_MODE = false;
		DEBUG_MODE = false;
		trace("Dump the XML");
		//System.setClipboard( RECORDED_XML.toString() );
	}

	/**********************************************************
	 * SOCKET_SERVER - CLODE_HANDLER
	***********************************************************/
	
	private function closeHandler( e:Event ):void 
	{
	}

	/**********************************************************
	 * SOCKET_SERVER - CONNECT_HANDLER
	***********************************************************/
	
	private function connectHandler( e:Event ):void 
	{
		trace( 'TUIO Socket Enabled:' + e );
	}

	/**********************************************************
	 * SOCKET_SERVER - DATA_HANDLER
	***********************************************************/
	
	private function dataHandler( e:DataEvent ):void 
	{
		if( RECORD_MODE )
		{
			RECORDED_XML.appendChild( XML( e.data ) );
		}			
		
		processXML( XML( e.data ) );
	}

	/**********************************************************
	 * SOCKET_SERVER - IO_ERROR_HANDLER
	***********************************************************/
	
	private function ioErrorHandler( e:IOErrorEvent ):void 
	{
		trace( 'ioErrorHandler:' + e );
	}
	
	/**********************************************************
	 * SOCKET_SERVER - PROGRESS_HANDLER
	***********************************************************/
	
	private function progressHandler( e:ProgressEvent ):void 
	{
	    //trace( 'progressHandler loaded:' + e.bytesLoaded + ' total: ' + e.bytesTotal );
	}

	/**********************************************************
	 * SOCKET_SERVER - SECURITY_ERROR_HANDLER
	***********************************************************/
	
	private function securityErrorHandler( e:SecurityErrorEvent ):void 
	{		
	}
	
	/**********************************************************
	 * TUIO
	***********************************************************/
	
	public function TUIO( caller:Function )
	{
		if( caller == TUIO.init )
		{
			
		}
		else
		{
			throw new Error( 'TUIO is a singleton, use TUIO.init' );
		}
	}
}
}