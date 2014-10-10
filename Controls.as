package iphstich.library
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	import flash.ui.Keyboard;
	
	/**
	 * A simple to use, versitle, and easy scheme for managing keyboard controls.
	 * @author IphStich - johnathon.warren@yahoo.com.au
	 */
	public class Controls
	{
		public static const KEY_UP:uint = 1;
		public static const KEY_RELEASED:uint = 2;
		public static const KEY_DOWN:uint = 4;
		public static const KEY_PRESSED:uint = 8;
		
		private static var bindings:Dictionary;
		private static var keys:Dictionary;
		//private static var stage:DisplayObject;
		private static var initialized:Boolean = false;
		
		/**
		 * Run this function before using any of the other Controls functions.
		 * <b>WARNING:</b> The events will be attached to the object passed through this function. Keys are in the "pressed" state until the passed DisplayObjects's EXIT_FRAME event.
		 * @param	stage This object will receive the three event listeners required. It is HIGHLY recommended that you use the Stage.
		 */
		public static function init(stage:DisplayObject):void
		{
			if (initialized) return;
			initialized = true;
			
			//Controls.stage = stage;
			if (!(stage is Stage)) trace("WARNING: It is HIGHLY recommended that you use the base Stage object for Controls.");
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			stage.addEventListener(Event.EXIT_FRAME, enterFrameHandler, false, int.MIN_VALUE);
			
			bindings = new Dictionary();
			keys = new Dictionary();
		}
		
		private static function keyDown(e:KeyboardEvent):void
		{
			if (!(keys[e.keyCode] & KEY_DOWN)) { // fixes a bug in flash where it will sometimes think the button is pressed again
				keys[e.keyCode] = KEY_DOWN | KEY_PRESSED;
			}
		}
		
		private static function keyUp(e:KeyboardEvent):void
		{
			keys[e.keyCode] = KEY_UP | KEY_RELEASED;
		}
		
		private static function enterFrameHandler(e:Event):void
		{
			if (manualMode) return;
			
			equalize();
		}
		
		private static var manualMode:Boolean = false;
		public static function manualReset ():void 
		{
			manualMode = true;
			
			equalize();
		}
		
		public static function automaticReset ():void
		{
			manualMode = false;
		}
		
		private static function equalize () : void
		{
			const EQUALIZE:uint = KEY_UP | KEY_DOWN;
			for (var i:* in keys)
			{
				keys[i] &= EQUALIZE;
			}
		}
		
		/**
		 * Required so that Controls recognizes button presses. This is the very base idea behind this class.
		 * Every <b>odd</b>:* value should be a label of some sorts, usually a String. Every <b>even</b>:uint value should be a Keyboard key.
		 * Any label can have multiple keys. Any key can have multiple labels.
		 * @param	args Every <b>odd</b> value should be a label of some sorts, usually a String. Every <b>even</b> value should be a Keyboard key.
		 */
		public static function addKeys(... args):void
		{
			var i:uint;
			if (args[0] is Array) args = args[0];
			
			for (i=0; i<args.length; i+=2)
			{
				var label:* = args[i];
				var key:uint = args[i+1];
				
				if (bindings[label] == undefined) bindings[label] = new Vector.<uint>();
				var bind:Vector.<uint> = bindings[label];
				if (bind.indexOf(key) == -1) bind.push(key);
			}
		}
		
		/**
		 * This can be used to remove label-key specific key bindings.
		 * Every <b>odd</b>:* value should be a label of some sorts, usually a String. Every <b>even</b>:uint value should be a Keyboard key.
		 * @param	args Every <b>odd</b>:* value should be a label of some sorts, usually a String. Every <b>even</b>:uint value should be a Keyboard key.
		 */
		public static function removeKeys (... args) : void
		{
			var i:uint, index:uint;
			if (args[0] is Array) args = args[0];
			
			for (i=0; i<args.length; i+=2)
			{
				var label:* = args[i];
				var key:uint = args[i+1];
				
				var bind:Vector.<uint> = bindings[label];
				bind.splice(bind.indexOf(key), 1);
			}
		}
		
		/**
		 * Returns the key-bindings vector for the label.
		 * @param	label
		 * @return
		 */
		public static function getKeys (label:*) : Vector.<uint>
		{
			return bindings[label];
		}
		
		/**
		 * This function returns the button state of a key binding. Only works if a key has been bound using editKeys().
		 * <b>Returns</b> a bit mask combination of KEY_UP, KEY_RELEASED, KEY_DOWN, KEY_PRESSED.
		 * For smaller code: pressed() down() up() released() can also be used.
		 * @param	action The key binding to "search" for. Usually a string, but can be anything. See editKeys().
		 * @return A bit mask combination of KEY_UP, KEY_RELEASED, KEY_DOWN, KEY_PRESSED
		 */
		public static function button(action:*):uint
		{
			var i:uint;
			if (!initialized) throw new Error("Controls has not been initialized.  Run the init() method first.")
			
			var ret:uint = 0;
			for each (i in bindings[action])
			{
				ret |= keys[i];
			}
			return ret;
		}
		
		public static function key (keycode:uint) : uint
		{
			return keys[keycode];
		}
		
		public static function pressed(action:*):Boolean
		{
			return ((button(action) & KEY_PRESSED) != 0);
		}
		public static function down(action:*):Boolean
		{
			return ((button(action) & KEY_DOWN) != 0);
		}
		public static function up(action:*):Boolean
		{
			return ((button(action) & KEY_UP) != 0);
		}
		public static function released(action:*):Boolean
		{
			return ((button(action) & KEY_RELEASED) != 0);
		}
	}
}