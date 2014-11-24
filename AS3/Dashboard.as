package  {
	
	import flash.display.MovieClip;
	
	public class Dashboard extends MovieClip {
		
		public var mana:MovieClip, rage:MovieClip, hp:MovieClip;
		
		public function Dashboard() {
			// constructor code
		}
		
		public function SetMana(cur:int, max:int):void {
			mana.SetGage(cur, max);
		}
		
		public function SetRage(cur:int, max:int):void {
			rage.SetGage(cur, max);
		}
		
		public function SetHp(cur:int, max:int):void {
			hp.SetGage(cur, max);
		}
	}
	
}
