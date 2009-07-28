/** Copyright: Matthew Bush 2007 */
package util {
	
	import flash.events.*;
	import flash.system.System;
	import flash.text.*;
	import flash.utils.getTimer;
	
	import mx.core.UIComponent;
	
	public class FpsCounter extends UIComponent {
		
		private var fpsText:TextField;
		private var memUsedText:TextField;
		private var mfpsCount:int = 0;
		private var avgCount:int = 30;
		private var oldT:uint;
		
		public function FpsCounter() {
			var format:TextFormat = new TextFormat();
			format.size = 10;
			format.color = 0x999999;
			format.font = "arial";

			// create text field
			fpsText = new TextField();
			fpsText.text = "...";
			fpsText.y = 15;
			fpsText.defaultTextFormat = format;

			memUsedText = new TextField();
			memUsedText.text = "...";
			memUsedText.defaultTextFormat = format;
			
			// set initial lastTime
			oldT = getTimer();
			
			addChild(memUsedText);
			addChild(fpsText);
		}
		
		public function update():void {
			var newT:uint = getTimer();
			var f1:uint = newT-oldT;
			mfpsCount += f1;
			if (avgCount < 1){
				fpsText.text = String(Math.round(1000/(mfpsCount/30))+" fps average");
				avgCount = 30;
				mfpsCount = 0;
			}
			avgCount--;
			oldT = getTimer();
			
			memUsedText.text = Math.round(System.totalMemory/(1024)) + " KB used"
		}
	}
}

