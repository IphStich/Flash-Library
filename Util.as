package iphstich.library 
{
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author IphStich
	 */
	public class Util 
	{
		/**
		 * Returns the memory location reference to the target object.
		 * Special thanks goes to Diney Bomfim of Stack Overflow - http://stackoverflow.com/a/2926901/1049532
		 * @param	target
		 * @return
		 */
		public static function getMemoryLocation (target:*) : String
		{
			try { ByteArray(target); } catch (e:Error)
			{
				return String(e).replace(/.*([@|\$].*?) to .*$/gi, '$1');
			}
			return "";
		}
	}
}