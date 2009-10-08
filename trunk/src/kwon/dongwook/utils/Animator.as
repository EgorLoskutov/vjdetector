package kwon.dongwook.utils {
	
	import fl.transitions.*;
	import fl.transitions.easing.*;
	
	import flash.display.MovieClip;
	
	public class Animator {
		
		public static function flip(fromClip:MovieClip, toClip:MovieClip, toFront:Boolean = false, callback:Function = null):void {
			var duration:Number = .4;
			var transitionScale:Number = 0.8;
			var angle:Number = toFront ? 90: -90; 
			toClip.scaleX = toClip.scaleY = transitionScale;
			toClip.rotationY = 90;
			var fromTweener:Tween = new Tween(fromClip, "rotationY", Regular.easeIn, 0, angle, duration, true);
			fromTweener.addEventListener(TweenEvent.MOTION_FINISH, function(event:TweenEvent):void {
				fromClip.visible = false;
				toClip.visible = true;
				var toTweener:Tween = new Tween(toClip, "rotationY", Regular.easeOut, -angle, 0, duration, true);
				if (callback != null) {
					toTweener.addEventListener(TweenEvent.MOTION_FINISH, function(event:TweenEvent):void {
						callback();
					}, false, 0, true);
				}
				toTweener.start();
				Animator.scale(toClip, Regular.easeOut, transitionScale, 1, duration);
			}, false, 0, true);
			fromTweener.start();
			Animator.scale(fromClip, Regular.easeIn, 1, transitionScale, duration);
		}
		
		private static function scale(clip:MovieClip, easing:Function, start:Number, end:Number, duration:Number):void {
			new Tween(clip, "scaleX", easing, start, end, duration, true).start();
			new Tween(clip, "scaleY", easing, start, end, duration, true).start();
		}
	}
}