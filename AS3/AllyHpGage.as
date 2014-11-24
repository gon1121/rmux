package  {
	
	import flash.display.MovieClip;
	
	
	public class AllyHpGage extends MovieClip {
		
		private const GAGE_SIZE:int = 60;
		private const GAGE_TOP:int = 0;
		
		public var gage_mask:MovieClip;		
		
		public function AllyHpGage() {
			// constructor code
		}

		public function SetGage(cur:int, max:int):void
		{
			var pos:int;
			pos = GAGE_SIZE * Number(cur)/Number(max) - GAGE_SIZE;
			gage_mask.x = pos;
 		}
	}
}
