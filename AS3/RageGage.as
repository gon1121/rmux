package  {
	
	import flash.display.MovieClip;
	
	
	public class RageGage extends MovieClip {
		
		private const GAGE_SIZE:int = 110;
		private const GAGE_TOP:int = 15;
		
		public var gage_mask:MovieClip;		
		
		public function RageGage() {
			// constructor code
		}

		public function SetGage(cur:int, max:int):void
		{
			var pos:int;
			pos = GAGE_SIZE - GAGE_SIZE * Number(cur)/Number(max);
			gage_mask.y = pos;
		}
	}
	
}
