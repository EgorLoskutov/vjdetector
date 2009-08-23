package kwon.dongwook.utils {
	
	public class MathUtil {
		
		public static function randomInRange(min:Number, max:Number):Number {
			return Math.floor(Math.random() * (max - min + 1)) + min;
		}
	}
}