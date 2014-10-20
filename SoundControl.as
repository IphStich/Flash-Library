package iphstich.library 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author IphStich
	 */
	public class SoundControl 
	{
		public static const CATEGORY_GLOBAL:Object = new Object();
		public static const CATEGORY_BGM:String = "BGM";
		public static const CATEGORY_SFX:String = "SFX";
		
		private static var globalVolume:Number = 1;
		
		private static var sounds:Dictionary = new Dictionary();
		
		private static var volumes:Dictionary = new Dictionary();
		
		private static var introChannelToClip = new Dictionary();
		
		private static var dummyClip:MovieClip = new MovieClip();
		
		private static var playing:Vector.<Playing>;
		
		// Have to use this, because you can't initialise 'playing' with the static class
		private static function checkInit () : void
		{
			if (playing == null)
			{
				volumes[CATEGORY_BGM] = 1;
				playing = new Vector.<Playing>();
			}
		}
		
		/**
		 * Use this function to add a pre-existing sound to the system, allowing you to easily play it later.
		 * @param	source		The Sound object that should be added
		 * @param	label		This is the label you will use later to play the sound, using <b>playSound()</b>
		 * @param	maxCount	The maximum number of instances of this sound that can play at once. If this value is exceeded at runtime, the olded sounds will be killed
		 * @param	category	The category this sound belongs to. Useful in adjusting volume levels in broad strokes using <b>adjustVolume()</b>
		 * @param	volumeMultiplier	This number is multiplied by the category volume to calculate the actual volume when this sound is played
		 */
		public static function addSound (source:Sound, label:*, maxCount:int=0, category:* = CATEGORY_SFX, volumeMultiplier:Number = 1) : void
		{
			checkInit();
			if (sounds[label] != undefined) trace("WARNING: A sound clip already exists with name \"" + label + "\"");
			
			var clip:SoundClip = new SoundClip();
			clip.source 	= source;
			clip.label 		= label;
			clip.count 		= maxCount;
			clip.category 	= category;
			clip.volume 	= volumeMultiplier;
			
			sounds[label] = clip;
			
			if (volumes[category] == undefined) volumes[category] = 1;
		}
		
		/**
		 * For loading a sound from an external source
		 * @param	source
		 */
		//public function loadSound (source:String) : void
		//{
			//var request:URLRequest = new URLRequest(source);
			//var loader:URLLoader = new URLLoader();
		//}
		
		/**
		 * Use this function to play a sound effect after its been added.
		 * @param	label		The label used when adding the sound.
		 */
		public static function playSound (label:*) : void
		{
			play( sounds[label] );
		}
		
		/**
		 * Use this function to add a pre-existing piece of <b>back ground music</b> to the system.
		 * Background music operates under slightly different parameters compared with standard sounds
		 * @param	source		The Sound object that should be added as BGM
		 * @param	label		This is the label you will use later to play the music, using <b>playBGM()</b>
		 * @param	loopTime	This is the time in the music that the system will loop back to
		 * @param	volumeMultiplier	This number is multiplied by the category volume to calculate the actual volume when this music is played
		 */
		public static function addBGM (source:Sound, label:*, loopTime:Number, volumeMultiplier:Number = 1) : void
		{
			checkInit();
			if (sounds[label] != undefined) trace("WARNING: A music clip already exists with name \"" + label + "\"");
			
			var clip:SoundClip = new SoundClip();
			clip.source 	= source;
			clip.label 		= label;
			clip.loopTime 	= loopTime;
			clip.category 	= CATEGORY_BGM;
			clip.volume 	= volumeMultiplier;
			
			sounds[label] = clip;
		}
		
		/**
		 * This function will play a piece of background music.
		 * @param	label		The label you assigned it when you added it
		 * @param	playIntro	Whether or not to play the intro for the music, and then loop it, or just start off by looping it
		 * @param	stopOld		If true, will stop whichever piece of BGM is currently playing before starting this piece
		 */
		public static function playBGM (label:*, playIntro:Boolean = true, stopOld:Boolean = true) : void
		{
			if (stopOld) stop();
			
			var clip:SoundClip = (sounds[label] as SoundClip);
			
			if (playIntro)
			{
				if (!dummyClip.hasEventListener(Event.ENTER_FRAME)) dummyClip.addEventListener(Event.ENTER_FRAME, introChecks);
				
				play (clip);
				introChannelToClip [ playing[playing.length-1].channel ] = clip;
			}
			else
			{
				loopBGM (clip);
			}
		}
		
		/**
		 * Use this to immediately end a piece of BGM or a SFX.
		 * @param	label	If <b>null</b> will stop whichever piece of BGM is currently playing. Use a label to check and cancel a specific piece of BGM.
		 */
		public static function stop (label:* = null) : void
		{
			var i:int;
			var p:Playing;
			for (i=playing.length-1; i>=0; --i)
			//p in playing)
			{
				p = playing[i];
				if ( p.clip.label == label || (label == null && p.clip.category == CATEGORY_BGM) )
				{
					p.channel.stop();
					playing.splice(i, 1);
				}
			}
		}
		
		/**
		 * Use this to set the volume level of all sounds of a category.
		 * Useful with option menus that adjust the volume of sounds based on type / category
		 * @param	category	The category the sound was entered under. Use <b>SoundControl.CATEGORY_BGM</b> for background music.
		 * @param	value		the volume level of the sound category. The standard practice is to have this value between 0 and 1. But values above 1 are acceptable.
		 */
		public static function adjustVolume (category:*, value:Number) : void
		{
			checkInit();
			if (category == CATEGORY_GLOBAL)
				globalVolume = value;
			else
				volumes[category] = value;
			
			var p:Playing;
			for each (p in playing)
			{
				if (category == CATEGORY_GLOBAL || p.clip.category == category)
				{
					p.channel.soundTransform = getST(p.clip);
				}
			}
		}
		
		private static function loopBGM (clip:SoundClip) : void
		{
			play(clip, int.MAX_VALUE);
		}
		
		private static var lastFrame:Number = 0;
		private static var count:Number = 0;
		private static var sum:Number = 0;
		private static function introChecks (e:*) : void
		{
			// Calculate framerate
			var thisFrame:Number = getTimer();
			if (count < 6) count ++;
			sum = ( (sum * (count - 1)) + (thisFrame - lastFrame)) / count;
			lastFrame = thisFrame;
			
			
			var i:*;
			var sc:SoundChannel;
			var clip:SoundClip;
			
			for (i in introChannelToClip)
			{
				sc = i as SoundChannel;
				if ( (introChannelToClip[sc] as SoundClip).source.length - sc.position * 1.002 < 2 * sum)
				{
					loopBGM(introChannelToClip[sc]);
					delete introChannelToClip[sc];
				}
			}
		}
		
		private static function play (clip:SoundClip, loops:int = 0) : void
		{
			var p:Playing = new Playing();
			
			p.clip = clip;
			
			// play the sound actual
			p.channel = clip.source.play(
				((loops == 0) ? 0 : clip.loopTime),
				loops,
				getST(clip)
			);
			
			// add the completion detect event
			if (loops == 0) p.channel.addEventListener(Event.SOUND_COMPLETE, soundComplete);
			
			// add to playing list for volume and count functions
			playing.push(p);
			
			// perform count check
			// if there is a limit
			if (clip.count > 0)
			{
				// iterate through the playing list
				// (ignoring the newly added instance)
				var count:int = clip.count-1;
				var i:int;
				for (i = playing.length-2; i>=0; --i)
				{
					p = playing[i];
					if (p.clip == clip)
					{
						if (count > 0) 
							count --;
						else
						{
							// kill and remove the instance
							p.channel.stop();
							playing.splice(i, 1);
						}
					}
				}
			}
		}
		
		// find and remove the finished sound from the playing list
		private static function soundComplete (e:Event)
		{
			var p:Playing;
			var i:int;
			var c:int = playing.length
			
			for (i=0; i<c; ++i)
			{
				p = playing[i];
				
				if (p.channel == e.target)
				{
					playing.splice(i, 1);
					return;
				}
			}
		}
		
		// get SoundTransform for the specified clip
		private static function getST (clip:SoundClip) : SoundTransform
		{
			var volume:Number = globalVolume * clip.volume * (volumes[clip.category] as Number);
			return new SoundTransform(volume);
		}
	}
}


import flash.media.Sound;
import flash.media.SoundChannel;

class SoundClip
{
	public var source:Sound;
	public var label:*;
	public var category:*;
	public var volume:Number;
	
	public var count:int;
	public var loopTime:Number = 0;
}

class Playing
{
	public var clip:SoundClip;
	public var channel:SoundChannel;
}