package ui {
	
	import mx.containers.VBox;
	import mx.controls.Button;
	import flash.events.MouseEvent;
	
	/**
	 * This is an extended VBox that allows to hide
	 * and show anything it contains
	 * */
	public class Grip extends VBox {
		
		/**
		 * Tooltip for Grip component */
		[Bindable]
		public var gripTip:String; 

		/**
		 * Icon to be displayed if any */
		[Bindable]
		public var gripIcon:Class;
		
		private var _cntrlPanelButton:Button;
		
		public function Grip() {
			super();
			
			/* add the control panel button */
			_cntrlPanelButton = new Button();
			_cntrlPanelButton.id = "cntrlPanelButton";
			_cntrlPanelButton.toolTip = gripTip;
			_cntrlPanelButton.toggle = true;
			_cntrlPanelButton.setStyle("fillAlphas", [0.6, 0.4]);
    		_cntrlPanelButton.setStyle("fillColors", [0x666666, 0xCCCCCC]);
    		_cntrlPanelButton.setStyle("themeColor", 0xCCCCCC);
			_cntrlPanelButton.percentWidth = 100;
			_cntrlPanelButton.percentHeight = 100;
			_cntrlPanelButton.addEventListener(MouseEvent.CLICK,navPanel);
			//cntrlPanelButton.setStyle("upIcon",<GRIP IMAGE>);
			//cntrlPanelButton.setStyle("downIcon",<VISUALISATION IMAGE>);
			
			this.addChild(_cntrlPanelButton);
		}
		
		/**
		 * This sets the current State of the parent document
		 * to hideCntrlPanel or showCntrlPanel
		 * */
		public function navPanel(event:Event):void {
			if (_cntrlPanelButton.selected==true) {
				parentDocument.currentState="hideCntrlPanel";
			} else {
				parentDocument.currentState="showCntrlPanel";
			}
		}
	}
}
   
  