package iphstich.library
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	/**
	 * FPSCounter is a very simple MovieClip that can be easily transferred between projects.
	 * It simply creates a text box and updates it with the average FPS every frame.
	 * @author IphStich - johnathon.warren@yahoo.com.au
	 */
	public class FPSCounter extends MovieClip
	{
		private var lastFrame:uint;
		private var thisFrame:uint;
		private var average:Number = 0;
		private var goes:uint = 0;
		private var display:TextField;
		
		public function FPSCounter(stage:DisplayObject)
		{
			super();
			
			display = new TextField;
			addChild(display);
			
			stage.addEventListener(Event.ENTER_FRAME, efh, false, int.MIN_VALUE);
		}
		
		private function efh(e:Event):void
		{
			thisFrame = getTimer();
			average = ((average * goes) + (thisFrame - lastFrame)) / (goes + 1);
			lastFrame = thisFrame;
			
			if (goes < 10) ++goes;
			
			display.text = "FPS: " + int(1000 / average);
		}
	}
}