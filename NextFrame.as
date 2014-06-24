package iphstich.library
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * Allows for an easy system to run a function at the beiggining of the next ENTER_FRAME dispatch.
 	 * @author IphStich - johnathon.warren@yahoo.com.au
	 */
	public class NextFrame
	{
		//private static var dummy:MovieClip;
		private static var initialized:Boolean = false;
		private static var functions:Vector.<Function>;
		private static var delays:Vector.<uint>;
		
		public static function perform (fn:Function, delay:uint = 0):void
		{
			if (!initialized) throw new Error("NextFrame has not been initliazed.  The init() functions needs to be run first.")
			
			functions.push(fn)
			delays.push(delay);
		}
		
		public static function init(stage:DisplayObject):void
		{
			if (initialized) return;
			
			functions 	= new Vector.<Function>();
			delays 		= new Vector.<uint>();
			
			stage.addEventListener(Event.ENTER_FRAME, everyFrame, false, int.MAX_VALUE);
			
			initialized = true;
		}
		
		private static function everyFrame(e:Event):void
		{
			var i:int = functions.length-1;
			if (i > -1)
			{
				while (i >= 0)
				{
					if (delays[i] == 0) {
						functions[i]();
						functions.splice(i, 1);
						delays.splice(i, 1);
					} else {
						--delays[i];
					}
					--i;
				}
			}
		}
	}
}