package  {
	
	import flash.display.MovieClip;
    import flash.utils.getDefinitionByName;
	import fl.motion.Color;
	
	import IGameSlot;
	import ActionSlot;
	import AllyHpGage;
	
	public class AllySlot extends ActionSlot implements IGameSlot {
		
		public var coolDown:MovieClip;
		public var slotUse:MovieClip;
		public var slotIcon:Icon;
		public var hp:AllyHpGage;
		
		private var _lastIconPath:String;
		
		public function AllySlot() {
			coolDown.scaleX = 3;
			coolDown.scaleY = 3;
		}

		public function SetGage(cur:int, max:int):void
		{
			if (hp) hp.SetGage(cur, max);
		}

		public function updateIconPath(iconPath:String)
		{
			slotIcon.loadImage( iconPath );
		}

		public function updateActionkIconPath(iconPath:String)
		{
			if (iconPath) {
				if (iconPath != _lastIconPath) {
					var def:Class = getDefinitionByName("Icon") as Class;
					var spr:Icon = new def() as Icon;
					updateIconWithData(spr, iconPath);
					content = spr;
					content.x = 0;
					content.y = 0;
				}
				_lastIconPath = iconPath;
			}
			else {
				content = null;
				_lastIconPath = null;
			}
		}
		
        protected function updateIconWithData( icon:Icon, iconPath:String ):void {
            // NFM: This stuff is extremely temporary. Need to replace FakeIcon. Move tf_Count into MDragTarget.
            if (icon && iconPath) { 
                icon.loadImage( iconPath );
            }
        }
		
		public function clearCooldown():void {
			if (coolDown) 
				coolDown.gotoAndStop(1);
				
			if (slotUse) {
				slotUse.visible = false;
			}			
		}		
		
		////////////////////////////////////////////
		// IGameSlot implementation
		public function highlight():void 
		{ 
			//if (dropIndicator) 
			//	dropIndicator.gotoAndPlay("show"); 
		}
		
		public function unhighlight():void 
		{ 
			//if (dropIndicator) 
			//	dropIndicator.gotoAndPlay("hide"); 
		}
		
		public function updateCooldown(pct:Number):void 
		{
			if (coolDown) {
				var frame:uint = Math.floor((coolDown.totalFrames - 2) * pct) + 3;
				coolDown.gotoAndStop(frame);
			}
		}
		
		public function endCooldown():void 
		{
			if (coolDown) 
				coolDown.gotoAndStop(1);
				
			if (slotUse) {
				slotUse.visible = true;
				slotUse.gotoAndPlay("on");
			}
		}
	}
}
