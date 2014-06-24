package iphstich.library
{
	import flash.geom.Point;
	
	/**
	 * A collection of useful math functions.
	 * @author IphStich - johnathon.warren@yahoo.com.au
	 */
	public class CustomMath
	{
		/**
		 * Takes a variety of inputs and will calculate the pythagorian distance between two points in either 2D or 3D.
		 * @param	... args
		 * @return
		 */
		public static function distance(... args):Number
		{
			return Math.sqrt(distanceSquared(args));
		}
		
		/**
		 * Similar to distance(), except that it doesn't sqrt the result. This makes it faster.
		 * If the result is being used for comparison, this is a better option.
		 * @param	... args
		 * @return
		 */
		public static function distanceSquared(... args):Number
		{
			if (args[0] is Array && args.length == 1) args=args[0];
			
			var dx:Number=0;
			var dy:Number=0;
			var dz:Number=0;
			
			if (args[0] is Point && (args.length == 2))// Point, Point
			{
				var asPoint:Point = (args[0] as Point).subtract(args[1] as Point);
			}
			else if (args[0] is Number && (args.length == 2 || args.length == 3)) // Number * 2
			{
				dx = args[0];
				dy = args[1];
				if (args.length == 3) dz = args[2];
			}
			else if (args[0] is Number && (args.length == 4 || args.length == 6)) // Number * 4
			{
				dx = args[0] - args[1];
				dy = args[2] - args[3];
				if (args.length == 6) dz = args[4] - args[5];
			}
			else
			{
				throw new Error("Unrecognized pattern detected. Unable to calculate distance for " + args);
			}
			return dx * dx + dy * dy + dz * dz;
		}
		
		/**
		 * Multipies x by y and returns the result without affecting either.
		 * Useful in vector math.
		 * @param	x
		 * @param	y
		 * @return
		 */
		public static function multiply(x:*, y:Number):*
		{
			if (x is Point)
			{
				var asPoint:Point = (x as Point).add(new Point(0,0));
				asPoint.x *= y;
				asPoint.y *= y;
				return asPoint;
			}
		}
		
		/**
		 * Takes the input, and interprets it, and then returns a value with magnitude 1, without modifying the original.
		 * This is useful in calculating direction, as many formulas use normalized values.
		 * @param	inp
		 * @return
		 */
		public static function normalize(inp:*):*
		{
			if (inp is Number) // Number
			{
				var asNum:Number = inp as Number;
				if (asNum == 0) return 0;
				if (asNum < 0) return -1;
				if (asNum > 0) return 1;
			}
			else if (inp is Point) // Point
			{
				var asPoint:Point = (inp as Point).add(new Point(0,0));
				asPoint.normalize(1);
				return asPoint;
			}
			else
			{
				throw Error("Enrecognised class.")
			}
			return null;
		}
		
		/**
		 * This function interprets the inputs, and will return the most-likely solution to the quadratic funciton.
		 * 0 = ax^2 + bx + c
		 * @param	a
		 * @param	b
		 * @param	c
		 * @return
		 */
		public static function solveQuadratic(a:Number, b:Number, c:Number):Number
		{
			var ret:Number = NaN;
			
			if (a == 0 || Math.abs(c) < 1)
			{
				ret = -c / b
			}
			else if (c < 0)
			{
				//trace("state B")
				ret = ( -b + Math.sqrt(b * b - 4 * a * c)) / (2 * a)
			}
			else if (c > 0)
			{
				//trace("state C")
				ret = ( -b - Math.sqrt(b * b - 4 * a * c)) / (2 * a)
			}
			//if (a!=0) {
				//trace("(a, b, c) = (" + a + ", " + b + ", " + c + ")")
				//trace(( -b + Math.sqrt(b * b - 4 * a * c)) / (2 * a))
				//trace(( -b - Math.sqrt(b * b - 4 * a * c)) / (2 * a))
			//}
			
			if (isNaN(ret)) throw new Error("Unable to solve quadratic (a, b, c) = (" + a + ", " + b + ", " + c + ").");
			return ret;
		}
		
		public static function randomBetween (a:Number, b:Number) : Number
		{
			b -= a;
			return Math.random() * b + a;
		}
	}

}