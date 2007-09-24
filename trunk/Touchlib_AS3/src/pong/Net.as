﻿package pong
{
	import flash.display.MovieClip;
	
	/**
	 * The net in the middle of the ping pong table
	 */
	public class Net extends MovieClip
	{
		/**
		 * Set up the net with a given height and stroke length
		 * @param height Height of the net
		 * @param strokeLength Length of the dashed strokes
		 * @param gapLength Length of the gaps
		 */
		function setup(height:Number, strokeLength:Number, gapLength:Number)
		{
			var strokeAndGapLength:Number = strokeLength + gapLength;
			var numStrokes:Number = height / strokeAndGapLength;
			
			// Draw all the strokes
			var curY:Number = 0;
			this.graphics.lineStyle(2, 0x000000, 1.0);
			for (var i:Number = 0; i < numStrokes; ++i)
			{
				this.graphics.lineTo(0, curY + strokeLength);
				curY += strokeAndGapLength;
				this.graphics.moveTo(0, curY);
			}
		}
	}
}