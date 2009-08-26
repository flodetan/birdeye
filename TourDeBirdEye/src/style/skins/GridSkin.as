package style.skins {
	
	import flash.display.Graphics;
	
	import mx.skins.ProgrammaticSkin;

	public class GridSkin extends ProgrammaticSkin {
		
		public function GridSkin() {
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			var g:Graphics = this.graphics;
			g.clear();
			g.beginFill(0x000000, 0);
			g.drawRect(0, 0, unscaledWidth, unscaledHeight);
			g.endFill();
			g.lineStyle(1, 0xFFFFFF, 0.2);
			var squareSize:Number = 20;
			var numRows:Number = unscaledHeight / squareSize;
			var numCols:Number = unscaledWidth / squareSize;
			for(var row:Number = 0; row< numRows; row++) {
				g.moveTo(0, row * squareSize);
				g.lineTo(unscaledWidth, row * squareSize); 
			}
			for(var col:Number = 0; col< numCols; col++) {
				g.moveTo(col * squareSize, 0);
				g.lineTo(col * squareSize, unscaledHeight); 
			}
		}
		
	}
}