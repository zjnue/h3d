package h2d.comp;

class Slider extends Component {
	
	public var cursor : Button;
	var input : h2d.Interactive;
	var vertical : Bool;
	public var fullRange(default, set) : Bool;
	public var cursorRatio(default, set) : Float;
	public var value(default, set) : Float;
	
	@:access(h2d.comp.Button)
	public function new(?parent) {
		super("slider", parent);
		input = new h2d.Interactive(0, 0, this);
		input.onPush = function(e) {
			gotoValue(pixelToVal(e));
			input.startDrag(function(e) {
				if( e.kind == EMove )
					gotoValue(pixelToVal(e));
			});
		};
		input.onRelease = function(_) {
			input.stopDrag();
		}
		cursor = new Button("", this);
		cursor.input.blockEvents = false;
		cursor.onMouseDown = function() {
			
		};
		value = 0.;
		fullRange = true;
	}
	
	function pixelToVal( e : h2d.Event ) {
		return vertical ? Std.int(e.relY - (style.borderSize + cursor.height * 0.5) ) / (input.height - (style.borderSize * 2 + cursor.height)) :
						Std.int(e.relX - (style.borderSize + cursor.width * 0.5) ) / (input.width - (style.borderSize * 2 + cursor.width));
	}
	
	function gotoValue( v : Float ) {
		if( v < 0 ) v = 0;
		if( v > 1 ) v = 1;
		if( v == value )
			return;
		var dv = Math.abs(value - v);
		if( style.maxIncrement != null && dv > style.maxIncrement ) {
			if( v > value )
				value += style.maxIncrement;
			else
				value -= style.maxIncrement;
		} else if( style.increment != null )
			value = Math.round(v / style.increment) * style.increment;
		else
			value = v;
		onChange(value);
	}
	
	function set_value(v:Float) {
		if( v < 0 ) v = 0;
		if( v > 1 ) v = 1;
		value = v;
		needRebuild = true;
		return v;
	}
	
	function set_fullRange(v:Bool) {
		fullRange = v;
		needRebuild = true;
		return v;
	}
	
	function set_cursorRatio(v:Float) {
		if( vertical )
			cursor.height = input.height * v;
		else
			cursor.width = input.width * v;
		cursorRatio = v;
		needRebuild = true;
		return v;
	}

	override function resize( ctx : Context ) {
		super.resize(ctx);
		if( !ctx.measure ) {
			vertical = height > width;
			if( vertical ) {
				input.height = height - (style.marginTop + style.marginBottom) + cursor.height;
				input.width = cursor.width - (cursor.style.marginLeft + cursor.style.marginRight);
				input.y = cursor.style.marginTop - style.borderSize - cursor.height * 0.5;
				input.x = cursor.style.marginLeft;
				cursor.style.offsetY = fullRange ? contentHeight * value - cursor.height * 0.5 : (contentHeight - cursor.height) * value;
			} else {
				input.width = width - (style.marginLeft + style.marginRight) + cursor.width;
				input.height = cursor.height - (cursor.style.marginTop + cursor.style.marginBottom);
				input.x = cursor.style.marginLeft - style.borderSize - cursor.width * 0.5;
				input.y = cursor.style.marginTop;
				cursor.style.offsetX = fullRange ? contentWidth * value - cursor.width * 0.5 : (contentWidth - cursor.width) * value;
			}
		}
	}

	public dynamic function onChange( value : Float ) {
	}

}