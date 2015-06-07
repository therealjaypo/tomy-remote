package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	
	/**
	 * Simple class to control the basic functions of a Tomy Omnibot. Has been 
	 * tested and verified to work using a cassette adapter and the Ominbot 
	 * set to "Program" mode.
	 *
	 * Requires Flash Player 10+ and has been tested on the desktop and a Sony 
	 * Xperia X10 running Gingerbread.
	 * 
	 * This code is released without any warranty whatsoever and if anything 
	 * breaks while you're playing with it, you get to keep the pieces.
	 */
	public class Tomy extends Sprite
	{
		// -------------------------------------------------------------------
		// This section handles our frequency generation and defines constants
		// reprenseting frequencies that make our robot do things.
		//
		// If yours doesn't work, you should probably tweak these.
		// -------------------------------------------------------------------
		
		/** Frequency to move Omnibot forward */
		public static const MOVE_FORWARD:int = 3275;
		
		/** Frequency to move Omnibot backward */
		public static const MOVE_BACKWARD:int = 4070;
		
		/** Frequency to turn Omnibot left */
		public static const MOVE_LEFT:int = 4500;
		
		/** Frequency to turn Omnibot right */
		public static const MOVE_RIGHT:int = 4200;
		
		/** The flash.media.Sound object for our frequency generator */
		private var _gen:Sound;
		
		/** Direction we're currently moving */
		public static var _freq:int = 0;
		
		/**
		 * Invoked whenever our Sound object needs sample data.
		 * Basically we generate the frequency for the appropriate direction.
		 * This generator assumes we're playing at 44khz.
		 *
		 * @param ev The SampleDataEvent our Sound object is going to play.
		 */
		public function sigGenerator(ev:SampleDataEvent):void {
			var n:Number;
			
			for( var i:int=0;i<4092;i++ ) {
				n = Math.sin((i+ev.position)*_freq*2.0*Math.PI/44100);
				ev.data.writeFloat(n);
				ev.data.writeFloat(n);
			}
		}
		
		// -------------------------------------------------------------------
		// Various graphical elements we're going to add to our stage to do 
		// our thing.
		// -------------------------------------------------------------------
		
		[Embed(source="../assets/arrow-up.png")]
		private static const ICON_FORWARD:Class;
		
		[Embed(source="../assets/arrow-down.png")]
		private static const ICON_BACKWARD:Class;
		
		[Embed(source="../assets/arrow-left.png")]
		private static const ICON_LEFT:Class;
		
		[Embed(source="../assets/arrow-right.png")]
		private static const ICON_RIGHT:Class;
		
		// Tracks for our crosshairs.
		private var _horiz:Sprite;
		private var _vert:Sprite;
		
		/**
		 * We don't do anything until we're actually added to the stage.
		 */
		public function Tomy()
		{
			this.addEventListener(Event.ADDED_TO_STAGE,onStage);
		}
		
		/**
		 * Instantiate the specified Bitmap and add it as a child 
		 * to a specifically named Sprite we return.
		 * 
		 * @param clz The class of the Bitmap to show
		 * @param nm The name of the Sprite we're creating
		 * 
		 * @return A Sprite ready to go
		 */
		private function mkButton(bmp:Class, nm:String):Sprite {
			var ret:Sprite = new Sprite();
			ret.mouseChildren = false;
			ret.name = nm;
			ret.addChild(new bmp());
			
			return ret;
		}
		
		/**
		 * When we're added to the stage, create our various graphical 
		 * elements and add a MOUSE_UP listener to change the frequency.
		 * 
		 * @param ev The flash.events.Event.ADDED_TO_STAGE being fired
		 */
		private function onStage(ev:Event):void {
			if( ev.target == this ) {
				// Clean up & prepare stage
				this.removeEventListener(Event.ADDED_TO_STAGE,onStage);
				this.stage.align = StageAlign.TOP_LEFT;
				this.stage.scaleMode = StageScaleMode.NO_SCALE;
				
				// White background
				with( this.graphics ) {
					beginFill(0xffffff,1);
					drawRect(0,0,this.stage.stageWidth,this.stage.stageHeight);
					endFill();
				}
				
				// Create generator object
				_gen = new Sound();
				_gen.addEventListener(SampleDataEvent.SAMPLE_DATA,sigGenerator);
				_gen.play();

				// Vertical part of crosshairs
				var s:Sprite = new Sprite();
				with( s.graphics ) {
					beginFill(0x333333,1);
					drawRoundRect(0,0,20,160,10,10);
					endFill();
				}
				
				// Centered on stage
				s.x = (int)(this.stage.stageWidth / 2 - s.width / 2);
				s.y = (int)(this.stage.stageHeight / 2 - s.height / 2 );
				this.addChild(s);
				_vert = s;
				
				// Horizontal part of crosshairs
				s = new Sprite();
				with( s.graphics ) {
					beginFill(0x333333,1);
					drawRoundRect(0,0,160,20,10,10);
					endFill();
				}
				
				// Centered on stage
				s.x = (int)(this.stage.stageWidth / 2 - s.width / 2);
				s.y = (int)(this.stage.stageHeight / 2 - s.height / 2 );
				this.addChild(s);
				_horiz = s;
				
				// Forward button
				s = mkButton(ICON_FORWARD,"MOVE_FORWARD");
				s.y = _vert.y - s.height - 10;
				s.x = (int)(this.stage.stageWidth / 2 - s.width / 2);
				this.addChild(s);
				
				// Backward button
				s = mkButton(ICON_BACKWARD,"MOVE_BACKWARD");
				s.y = _vert.y + _vert.height + 10;
				s.x = (int)(this.stage.stageWidth / 2 - s.width / 2);
				this.addChild(s);
				
				// Left Button
				s = mkButton(ICON_LEFT,"MOVE_LEFT");
				s.y = (int)(this.stage.stageHeight / 2 - s.height / 2);
				s.x = _horiz.x - s.width - 7;
				this.addChild(s);
				
				// Right button
				s = mkButton(ICON_RIGHT,"MOVE_RIGHT");
				s.y = (int)(this.stage.stageHeight / 2 - s.height / 2);
				s.x = _horiz.x + _horiz.width + 7;
				this.addChild(s);

				// Listen for MOUSE_UP events
				this.stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			}
		}
		
		/**
		 * Handle a mouse up event and update the frequency generator 
		 * accordingly.
		 * If the target's name starts with MOVE_ it's assumed to match 
		 * one of our directional constants, otherwise we stop the 
		 * robot moving.
		 *
		 * @param ev The flash.events.MouseEvent being fired
		 */
		private function onMouseUp(ev:MouseEvent):void {
			if( ev.target.name && ev.target.name.indexOf("MOVE_") === 0 )
				_freq = Tomy[ev.target.name];
			else
				_freq = 0;
		}
	}
}