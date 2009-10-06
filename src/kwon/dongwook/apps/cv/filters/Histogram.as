package kwon.dongwook.apps.cv.filters {

	import flash.display.BitmapData;
	
	public class Histogram {
	
		public static function equalize(bitmapData:BitmapData, apply:Boolean = true):Vector.<uint> {
			var histogram:Vector.<Number> = bitmapData.histogram(bitmapData.rect)[2];
			var equalizedHistogram:Vector.<uint> = new Vector.<uint>(256, true);
			var size:uint = bitmapData.width * bitmapData.height;
			var accumulated:Number = 0;
			for (var i:int = 0; i < 256; i++) {
				var current:Number = (histogram[i] / size) + accumulated;
				equalizedHistogram[i] = Math.round(current * 255);
				accumulated = current;
			}
			var pixels:Vector.<uint> = bitmapData.getVector(bitmapData.rect);
			var length:uint = pixels.length;
			var equalizedPixels:Vector.<uint> = new Vector.<uint>(length, true);
			for (i = 0; i < length; i++) {
				var index:uint = uint(pixels[i] & 0x000000FF);
				var color:uint = uint(equalizedHistogram[index]);
				equalizedPixels[i] = 0xFF000000 + (color << 16) + (color << 8) + color;
			}
			if (apply)
				bitmapData.setVector(bitmapData.rect, equalizedPixels);
			return equalizedPixels;
		}
	}
}