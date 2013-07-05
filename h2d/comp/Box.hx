package h2d.comp;

class Box extends Component {
	
	var surface : Sprite;
	var overlay : Sprite;
	
	public function new(?layout,?parent) {
		super("box", parent);
		surface = new Sprite();
		overlay = new Sprite();
		super.addChildAt(surface, 1);
		super.addChildAt(overlay, 2);
		if( layout == null ) layout = h2d.css.Defs.Layout.Inline;
		addClass(":"+layout.getName().toLowerCase());
	}
	
	override public function getSpritesCount() {
		return surface.getSpritesCount();
	}
	
	override public function addChild( s : Sprite ) {
		if( surface == null ) super.addChild(s);
		else surface.addChild(s);
	}
	
	override public function addChildAt( s : Sprite, pos : Int ) {
		if( surface == null ) super.addChildAt(s, pos);
		else surface.addChildAt(s, pos);
	}
	
	override public function removeChild( s : Sprite ) {
		surface.removeChild(s);
	}
	
	override public function getChildAt( n ) {
		return surface.getChildAt(n);
	}
	
	override function get_numChildren() {
		return surface.get_numChildren();
	}
	
	override public function iterator() {
		return surface.iterator();
	}
	
	override function resizeRec( ctx : Context ) {
		var extX = extLeft();
		var extY = extTop();
		var ctx2 = new Context(0, 0);
		ctx2.measure = ctx.measure;
		if( ctx.measure ) {
			width = ctx.maxWidth;
			height = ctx.maxHeight;
			contentWidth = width - (extX + extRight());
			contentHeight = height - (extY + extBottom());
			if( style.width != null ) contentWidth = style.width;
			if( style.height != null ) contentHeight = style.height;
		} else {
			ctx2.xPos = ctx.xPos;
			ctx2.yPos = ctx.yPos;
			if( ctx2.xPos == null ) ctx2.xPos = 0;
			if( ctx2.yPos == null ) ctx2.yPos = 0;
			resize(ctx2);
		}
		switch( style.layout ) {
		case Inline:
			var lineHeight = 0.;
			var xPos = 0., yPos = 0., maxPos = 0.;
			var prev = null;
			for( c in components ) {
				if( ctx.measure ) {
					ctx2.maxWidth = contentWidth;
					ctx2.maxHeight = contentHeight - (yPos + lineHeight + style.verticalSpacing);
					c.resizeRec(ctx2);
					var next = xPos + c.width;
					if( prev != null ) next += style.horizontalSpacing;
					if( xPos > 0 && next > contentWidth ) {
						yPos += lineHeight + style.verticalSpacing;
						xPos = c.width;
						lineHeight = c.height;
					} else {
						xPos = next;
						if( c.height > lineHeight ) lineHeight = c.height;
					}
					if( xPos > maxPos ) maxPos = xPos;
				} else {
					var next = xPos + c.width;
					if( xPos > 0 && next > contentWidth ) {
						yPos += lineHeight + style.verticalSpacing;
						xPos = 0;
						lineHeight = c.height;
					} else {
						if( c.height > lineHeight ) lineHeight = c.height;
					}
					ctx2.xPos = xPos;
					ctx2.yPos = yPos;
					c.resizeRec(ctx2);
					xPos += c.width + style.horizontalSpacing;
				}
				prev = c;
			}
			if( ctx.measure && style.dock == null ) {
				if( maxPos < contentWidth && style.width == null ) contentWidth = maxPos;
				if( yPos + lineHeight < contentHeight && style.height == null ) contentHeight = yPos + lineHeight;
			}
		case Horizontal:
			var lineHeight = 0.;
			var xPos = 0.;
			var prev = null;
			for( c in components ) {
				if( ctx.measure ) {
					if( prev != null ) xPos += style.horizontalSpacing;
					ctx2.maxWidth = contentWidth - xPos;
					if( ctx2.maxWidth < 0 ) ctx2.maxWidth = 0;
					ctx2.maxHeight = contentHeight;
					c.resizeRec(ctx2);
					xPos += c.width;
					if( c.height > lineHeight ) lineHeight = c.height;
				} else {
					ctx2.xPos = xPos;
					ctx2.yPos = 0;
					c.resizeRec(ctx2);
					xPos += c.width + style.horizontalSpacing;
				}
				prev = c;
			}
			if( ctx.measure && style.dock == null ) {
				if( xPos < contentWidth && style.width == null ) contentWidth = xPos;
				if( lineHeight < contentHeight && style.height == null ) contentHeight = lineHeight;
			}
		case Vertical:
			var colWidth = 0.;
			var yPos = 0.;
			var prev = null;
			for( c in components ) {
				if( ctx.measure ) {
					if( prev != null ) yPos += style.verticalSpacing;
					ctx2.maxWidth = contentWidth;
					ctx2.maxHeight = contentHeight - yPos;
					if( ctx2.maxHeight < 0 ) ctx2.maxHeight = 0;
					c.resizeRec(ctx2);
					yPos += c.height;
					if( c.width > colWidth ) colWidth = c.width;
				} else {
					ctx2.xPos = 0;
					ctx2.yPos = yPos;
					c.resizeRec(ctx2);
					yPos += c.height + style.verticalSpacing;
				}
				prev = c;
			}
			if( ctx.measure && style.dock == null ) {
				if( colWidth < contentWidth && style.width == null ) contentWidth = colWidth;
				if( yPos < contentHeight && style.height == null ) contentHeight = yPos;
			}
		case Absolute:
			ctx2.xPos = null;
			ctx2.yPos = null;
			if( ctx.measure ) {
				ctx2.maxWidth = contentWidth;
				ctx2.maxHeight = contentHeight;
			}
			for( c in components )
				c.resizeRec(ctx2);
		case Dock:
			ctx2.xPos = 0;
			ctx2.yPos = 0;
			var xPos = 0., yPos = 0., w = contentWidth, h = contentHeight;
			if( ctx.measure ) {
				for( c in components ) {
					ctx2.maxWidth = w;
					ctx2.maxHeight = h;
					c.resizeRec(ctx2);
					var d = c.style.dock;
					if( d == null ) d = Full;
					switch( d ) {
					case Left, Right:
						w -= c.width;
					case Top, Bottom:
						h -= c.height;
					case Full:
					}
					if( w < 0 ) w = 0;
					if( h < 0 ) h = 0;
				}
			} else {
				for( c in components ) {
					ctx2.maxWidth = w;
					ctx2.maxHeight = h;
					var d = c.style.dock;
					if( d == null ) d = Full;
					ctx2.xPos = xPos;
					ctx2.yPos = yPos;
					switch( d ) {
					case Left, Top:
					case Right:
						ctx2.xPos += w - c.width;
					case Bottom:
						ctx2.yPos += h - c.height;
					case Full:
						ctx2.xPos += Std.int((w - c.width) * 0.5);
						ctx2.yPos += Std.int((h - c.height) * 0.5);
					}
					c.resizeRec(ctx2);
					switch( d ) {
					case Left:
						w -= c.width;
						xPos += c.width;
					case Right:
						w -= c.width;
					case Top:
						h -= c.height;
						yPos += c.height;
					case Bottom:
						h -= c.height;
					case Full:
					}
					if( w < 0 ) w = 0;
					if( h < 0 ) h = 0;
				}
			}
		}
		if( ctx.measure ) {
			width = contentWidth + extX + extRight();
			height = contentHeight + extY + extBottom();
		} else {
			var overflow : h2d.css.Defs.Overflow = style.overflow != null ? style.overflow : Visible;
			var p = parentComponent;
			while( overflow == Inherit && p != null ) {
				overflow = p.style.overflow != null ? p.style.overflow : Visible;
				p = p.parentComponent;
			}
			if( overflow == Inherit )
				overflow = Visible;
			
			switch( overflow ) {
			case Visible:
				if( scrollbarH != null ) scrollbarH.visible = false;
				if( scrollbarV != null ) scrollbarV.visible = false;
				if( clipBounds != null ) clipBounds = null;
			case Hidden:
				if( scrollbarH != null ) scrollbarH.visible = false;
				if( scrollbarV != null ) scrollbarV.visible = false;
				doClip();
			case Auto, Scroll:
				measuredWidth = 0.;
				measuredHeight = 0.;
				for( c in components ) {
					if( c.width > measuredWidth ) measuredWidth = c.width;
					if( c.height > measuredHeight ) measuredHeight = c.height;
				}
				var doScrollH = overflow == Scroll || measuredWidth > contentWidth;
				var doScrollV = overflow == Scroll || measuredHeight > contentHeight;
				if( doScrollH || doScrollV ) {
					doClip();
					var spacer = 11;//(doScrollH && doScrollV) ? 11 : 0;
					if( doScrollH ) {
						if( scrollbarH == null ) {
							scrollbarH = createScrollbar( overlay, 0, contentHeight - 10, contentWidth - spacer, 10, 8 );
							scrollbarH.onChange = function(val) {
								surface.x = -(measuredWidth - contentWidth) * val;
							};
						}
						//scrollbarH.cursorRatio = contentWidth / measuredWidth;
						scrollbarH.visible = true;
					}
					if( doScrollV ) {
						if( scrollbarV == null ) {
							scrollbarV = createScrollbar( overlay, contentWidth - 10, 0, 10, contentHeight - spacer, 8 );
							scrollbarV.onChange = function(val) {
								surface.y = -(measuredHeight - contentHeight) * val;
							};
						}
						//scrollbarV.cursorRatio = contentHeight / measuredHeight;
						scrollbarV.visible = true;
					}
				} else {
					if( scrollbarH != null && scrollbarH.visible ) scrollbarH.visible = false;
					if( scrollbarV != null && scrollbarV.visible ) scrollbarV.visible = false;
					if( clipBounds != null ) clipBounds = null;
				}
			default:
			}
		}
	}
	
	// needs localToGlobal
	function doClip() {
		if( clipBounds == null || clipBounds.xMin != x || clipBounds.yMin != y || 
			clipBounds.xMax != contentWidth || clipBounds.yMax != contentHeight )
			// perhaps a h2d.col.Bounds.fromEasy(x,y,w,h) / constructor args option?
			clipBounds = h2d.col.Bounds.fromPoints(
				new h2d.col.Point(x, y), 
				new h2d.col.Point(contentWidth, contentHeight)
			);
	}
	
	// how can we easily update width / height etc. a .refresh() after does not work..
	function createScrollbar( parent : Sprite, x : Float, y : Float, w : Float, h : Float, cursorSide : Float ) {
		
		var scrollbar = new h2d.comp.Slider(parent);
		
		scrollbar.width = w;
		scrollbar.height = h;
		var s = new h2d.css.Style();
		s.width = w;
		s.height = h;
		s.layout = Absolute;
		scrollbar.setStyle(s);
		
		scrollbar.x = x;
		scrollbar.y = y;
		
		s = new h2d.css.Style();
		s.marginTop = s.marginRight = s.marginBottom = s.marginLeft = 0;
		s.paddingTop = s.paddingRight = s.paddingBottom = s.paddingLeft = 0;
		s.width = s.height = cursorSide;
		s.layout = Absolute;
		scrollbar.cursor.setStyle(s);
		scrollbar.fullRange = false;
		
		scrollbar.cursor.width = cursorSide;
		scrollbar.cursor.height = cursorSide;
		
		return scrollbar;
	}
	
	var measuredWidth : Float;
	var measuredHeight : Float;
	var scrollbarH : h2d.comp.Slider;
	var scrollbarV : h2d.comp.Slider;
}