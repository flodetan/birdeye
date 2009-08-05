package birdeye.util
{
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.GradientGlowFilter;
	
	public class EffectsUtil
	{
		import birdeye.vis.data.DataItemLayout;
		
		public function EffectsUtil()
		{
		}

		public static function setGlowEffect(target:DataItemLayout):void
		{
			var gradientGlow:GradientGlowFilter = new GradientGlowFilter();
			gradientGlow.distance = 0;
			gradientGlow.angle = 45;
			gradientGlow.colors = [0x000000, DataItemLayout(target).fill];
			gradientGlow.alphas = [0, 1];
			gradientGlow.ratios = [0, 255];
			gradientGlow.blurX = 8;
			gradientGlow.blurY = 8;
			gradientGlow.strength = 2;
			gradientGlow.quality = BitmapFilterQuality.HIGH;
			gradientGlow.type = BitmapFilterType.OUTER;
			DataItemLayout(target).filters=[gradientGlow];
		}
		
		public static function removeEffects(target:DataItemLayout):void
		{
			DataItemLayout(target).filters=[];
		}
	}
}