package org.un.cava.birdeye.geovis.utils
{	
	
	public class ArrayUtils
	{
		public function ArrayUtils()
		{
		}
		
			import mx.collections.ICollectionView;
			import mx.collections.IViewCursor;
		
   		public static function FindStepWithoutZero(List:ICollectionView, valueField:String, nbrStep:int):Array{
			var arrValues:Array=new Array();
			var arrRetValues:Array=new Array();
			var i:int=0;
			var cursor:IViewCursor = List.createCursor();
			
			while(!cursor.afterLast)
			{
				arrValues[i]=cursor.current[valueField];  
				i++;
				cursor.moveNext();  
			} 
			arrValues.sort(Array.NUMERIC);
			removeDup(arrValues);
			if(arrValues[0]==0){
				arrValues.splice(0,1);
			}
			var step:int=Math.floor(arrValues.length/(nbrStep+1));
			for (var k:int=0; k<nbrStep;k++){
				arrRetValues[k]=arrValues[(k+1)*step];
			}
			return arrRetValues;
		}
   		
   		
   		public static function removeDup(a:Array):void{
		    for(var y:int=0;y<a.length;y++){
				for(var z:int=(y+1);z<=a.length;z++){
					if(a[y]==a[z]){
		        		a.splice(z,1);
		                z--;
		            }
		        }
		    }
		}
		
		
		public static function FindMaxValue(List:ICollectionView, valueField:String):Array{
			var arrValues:Array=new Array();
			var i:int=0;
			var cursor:IViewCursor = List.createCursor();
				
			while(!cursor.afterLast)
			{
				arrValues[i]=cursor.current[valueField];  
				i++;
				cursor.moveNext();  
			} 
			
			arrValues.sort(Array.NUMERIC);
			var arrMinMax:Array=new Array();
			arrMinMax[0]=arrValues[0];
			arrMinMax[1]=arrValues[arrValues.length-1];
			
			return arrMinMax;
		}


	}
}