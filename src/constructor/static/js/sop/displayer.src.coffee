
log = `function(){
			if (DEBUG){
				args =[];
				var E = new Error();
				if (E.stack != null){
					var f = E.stack.split('\n')[2].split('@')[0];
					var a = E.stack.split('\n')[2].split(':');

					var ln = parseInt(a[a.length-1])
					args.push('[' +f +':'+ln +']');
				}
				for (var i =0; i< arguments.length; i++){
					args.push(arguments[i]);
				}


				console.log.apply(console, args);
			}

		}`

scaleImage = (img, maxWidth, maxHeight, useMax = false) ->
	w = img.width
	h = img.height
	width = img.width
	height = img.height
	if useMax
		scale = Math.max(maxWidth / width, maxHeight / height)
	else
		scale = Math.min(maxWidth / width, maxHeight / height)
	width = parseInt(width * scale, 10)
	height = parseInt(height * scale, 10)
	img.width = width
	img.height = height
	img


if window.location.port is '8000'
		BASE_SITE = "test.be-test.com:8000"
else
		BASE_SITE = 'www.be-web.ru'

DEBUG = true;





clone=		`function clone(obj) {
			// Handle the 3 simple types, and null or undefined
			if (null == obj || "object" != typeof obj) return obj;

			// Handle Date
			if (obj instanceof Date) {
				 var copy = new Date();
				 copy.setTime(obj.getTime());
				 return copy;
			}

			// Handle Array
			if (obj instanceof Array) {
				 var copy = [];
				 for (var i = 0, len = obj.length; i < len; i++) {
					 copy[i] = clone(obj[i]);
				 }
				 return copy;
			}

			// Handle Object
			if (obj instanceof Object) {
				 var copy = {};
				 for (var attr in obj) {
					 if (obj.hasOwnProperty(attr)) copy[attr] = clone(obj[attr]);
				 }
				 return copy;
			}

			throw new Error("Unable to copy obj! Its type isn't supported.");
			}`


rgb2hsv=		`function rgb2hsv () {
				 var rr, gg, bb,
				r = arguments[0] / 255,
				g = arguments[1] / 255,
				b = arguments[2] / 255,
				h, s,
				v = Math.max(r, g, b),
				diff = v - Math.min(r, g, b),
				diffc = function(c){
					return (v - c) / 6 / diff + 1 / 2;
				};

				 if (diff == 0) {
				h = s = 0;
				 } else {
				s = diff / v;
				rr = diffc(r);
				gg = diffc(g);
				bb = diffc(b);

				if (r === v) {
					h = bb - gg;
				}else if (g === v) {
					h = (1 / 3) + rr - bb;
				}else if (b === v) {
					h = (2 / 3) + gg - rr;
				}
				if (h < 0) {
					h += 1;
				}else if (h > 1) {
					h -= 1;
				}
				 }
				 return {
				h: Math.round(h * 360),
				s: Math.round(s * 100),
				b: Math.round(v * 100)
				 };
		}
		`


hsvToRgb = 	(o, as_array = false, no_opacity = false ) ->

	# h = o.h, s=o.s, v = o.v
	# Make sure our arguments stay in-range
	h = Math.max(0, Math.min(360, o.h))
	s = Math.max(0, Math.min(100, o.s))
	v = Math.max(0, Math.min(100, o.b))
	v =	 if o.b? then o.b else o.v

	# We accept saturation and value arguments from 0 to 100 because that's
	# how Photoshop represents those values. Internally, however, the
	# saturation and value are calculated from a range of 0 to 1. We make
	# That conversion here.
	s /= 100
	v /= 100
	if s is 0

		# Achromatic (grey)
		r = g = b = v

	#return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
	else
		h /= 60 # sector 0 to 5
		i = Math.floor(h)
		f = h - i # factorial part of h
		p = v * (1 - s)
		q = v * (1 - s * f)
		t = v * (1 - s * (1 - f))
		switch i
			when 0
				r = v
				g = t
				b = p
			when 1
				r = q
				g = v
				b = p
			when 2
				r = p
				g = v
				b = t
			when 3
				r = p
				g = q
				b = v
			when 4
				r = t
				g = p
				b = v
			else # case 5:
				r = v
				g = p
				b = q
	if as_array
		[Math.round(r * 255), Math.round(g * 255), Math.round(b * 255), Math.round(o.a * 255)]
	else
		rr = Math.round(r * 255)
		gg = Math.round(g * 255)
		bb = Math.round(b * 255)
		unless typeof o.a is "undefined"
			a = o.a
		else
			a = 1
		if no_opacity or not isOpacitySupported()
			#console.log('noop')
			"rgb(" + rr + "," + gg + "," + bb + ")"
		else
			#console.log('op')
			
			"rgba(" + rr + "," + gg + "," + bb + "," + a + ")"
		

hsvToHex = (o) ->
	componentToHex = (c) ->
		hex = c.toString(16);
		if hex.length == 1
			"0" + hex
		else
			hex
	a = hsvToRgb(o, true)
	"#" + componentToHex(a[0]) + componentToHex(a[1]) + componentToHex(a[2])


window.base64_encode=`function  (data) {
  // http://kevin.vanzonneveld.net
  // +   original by: Tyler Akins (http://rumkin.com)
  // +   improved by: Bayron Guevara
  // +   improved by: Thunder.m
  // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
  // +   bugfixed by: Pellentesque Malesuada
  // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
  // +   improved by: Rafał Kukawski (http://kukawski.pl)
  // *     example 1: base64_encode('Kevin van Zonneveld');
  // *     returns 1: 'S2V2aW4gdmFuIFpvbm5ldmVsZA=='
  // mozilla has this native
  // - but breaks in 2.0.0.12!
  //if (typeof this.window['btoa'] === 'function') {
  //    return btoa(data);
  //}
  var b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
  var o1, o2, o3, h1, h2, h3, h4, bits, i = 0,
    ac = 0,
    enc = "",
    tmp_arr = [];

  if (!data) {
    return data;
  }

  do { // pack three octets into four hexets
    o1 = data.charCodeAt(i++);
    o2 = data.charCodeAt(i++);
    o3 = data.charCodeAt(i++);

    bits = o1 << 16 | o2 << 8 | o3;

    h1 = bits >> 18 & 0x3f;
    h2 = bits >> 12 & 0x3f;
    h3 = bits >> 6 & 0x3f;
    h4 = bits & 0x3f;

    // use hexets to index into b64, and append result to encoded string
    tmp_arr[ac++] = b64.charAt(h1) + b64.charAt(h2) + b64.charAt(h3) + b64.charAt(h4);
  } while (i < data.length);

  enc = tmp_arr.join('');

  var r = data.length % 3;

  return (r ? enc.slice(0, r - 3) : enc) + '==='.slice(r || 3);

}
`

window.hsvToRgb = hsvToRgb
window.hsvToHex = hsvToHex

default_site =
	_Apps : ['generic.'	+ BASE_SITE]
	layout:
		cols:12
		fixed: true
		grid:
			hor:10
			ver:5
		padding:
			left:10
			top:10
		width:960
		drawen_lines:30
		base_height:50
	colors:
		type:'mono'
		base:120
		brightness:100
		lights:50
		saturation:100
		shadows:50
	patterns: []
	blocks:[{x:0,y:0, width:3, height:3,widget:{name:'text.generic.'+BASE_SITE, data:test_block_content } , display_on:'all', dont_display_on : [] },
					{x:3,y:0, width:4, height:2,	 widget:{name:'text.generic.' + BASE_SITE, data:test_block_content } , display_on:'', dont_display_on : [] },
					{x:7,y:0, width:5, height:2,	 widget:{name:'image.generic.' + BASE_SITE, data:{} } , display_on:'about', dont_display_on : [] }]
	default_block_settings :false
	seo:
		title: 'Unknown site'

	pages :
			"":
				layout: "same"
				title: "Main"
				show_in_menu: true
				removable: true

			"about":
					layout:'same'
					title:"About"
					removable: true
					show_in_menu: true



default_app = """{name:'MyApplication',
title:"My application",
roles:['client','manager'],
default_role:'client',
data:{product:{view:['client','manager'],
 			add:['manager'],
		del:['manager'] } },
	Main: function(){
		 // put here some code
		 var obj = { title : 'new application',
		 admin_page: function(to){}, /* page shown in admin interface */
		 widgets: {widget_name:'',
					 title:'', // Title diaplaed on admin page in `widgets menu.
					 default_size: [3,1], // default size, when placed on grid
					 init:function(my_cont,	constructor_inst, pos, cp){
						//my_cont - is container div of widget - place to draw data
						// constructor_inst - global pointer to constracting javascript object
						// pos - index of a block in the blocks array
						// cp - control page div - designed to place specific content in settings div, if needed
					var o = {
		 				disobey:['padding_left_right', 'padding_top'], // settings field, that sholdn't be applied to this widget
						draw : function(){}, // function to draw widget on the page
						settings: function(){}, // function called, when edit functions activated
						save : function(){}, //save widget on the page
						cancel : function(){}, // cancel edits
						jq:{} // MUST be created - root element of this widget
						}
					return o


				 }
			 } // widgets, that culd be placed on pages
		 };
		 return obj
	},
	getter: function(){
		return this.Main()
	} }
							"""


test_block_content = "Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt, explicabo. Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos, qui ratione voluptatem sequi nesciunt, neque porro quisquam est, qui dolorem ipsum, quia dolor sit, amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt, ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit, qui in ea voluptate velit esse, quam nihil molestiae consequatur, vel illum, qui dolorem eum fugiat, quo voluptas nulla pariatur? At vero eos et accusamus et iusto odio dignissimos ducimus, qui blanditiis praesentium voluptatum deleniti atque corrupti, quos dolores et quas molestias excepturi sint, obcaecati cupiditate non provident, similique sunt in culpa, qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio, cumque nihil impedit, quo minus id, quod maxime placeat, facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet, ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.";
Site = false
port = window.location.port;
back_icons_urls=[
		'/static/images/back_constr/fg/icons_02.png',
		'/static/images/back_constr/fg/icons_06.png',
		'/static/images/back_constr/fg/icons_10.png',
		'/static/images/back_constr/fg/icons_12.png',
		'/static/images/back_constr/fg/icons_15.png',
		'/static/images/back_constr/fg/icons_16.png',
		'/static/images/back_constr/fg/icons_18.png',
		'/static/images/back_constr/fg/icons_20.png',
		'/static/images/back_constr/fg/icons_22.png',
		'/static/images/back_constr/fg/icons_28.png',
		'/static/images/back_constr/fg/icons_29.png',
		'/static/images/back_constr/fg/icons_31.png',
		'/static/images/back_constr/fg/icons_32.png',
		'/static/images/back_constr/fg/icons_33.png',
		'/static/images/back_constr/fg/icons_41.png',
		'/static/images/back_constr/fg/icons_45.png',
		'/static/images/back_constr/fg/icons_47.png',
		'/static/images/back_constr/fg/icons_52.png',
		'/static/images/back_constr/fg/icons_54.png',
		'/static/images/back_constr/fg/icons_58.png',
		'/static/images/back_constr/fg/icons_62.png',
		'/static/images/back_constr/fg/icons_65.png',
		'/static/images/back_constr/fg/icons_70.png',
		'/static/images/back_constr/fg/icons_73.png',
		'/static/images/back_constr/fg/icons_76.png',
		'/static/images/back_constr/fg/icons_81.png'

		];
is_safari = /Safari/.test( navigator.userAgent ) and not /Chrome/.test(navigator.userAgent)
is_webkit = /WebKit/.test( navigator.userAgent )
is_ie = /MSIE/.test( navigator.userAgent )
is_ie9 = /MSIE 9.0/.test( navigator.userAgent )

is_linux = /Linux/.test( navigator.userAgent )
window.isCanvasSupported = ->
	el = document.createElement 'canvas'
	el.getContext? and (el.getContext '2d')?
window.isOpacitySupported = ->
	$('body')[0].style.opacity?
window.initArray = `function(){
	if (!Array.prototype.indexOf)
	{
		Array.prototype.indexOf = function(elt /*, from*/)
		{
			var len = this.length >>> 0;

			var from = Number(arguments[1]) || 0;
			from = (from < 0)
					 ? Math.ceil(from)
					 : Math.floor(from);
			if (from < 0)
				from += len;

			for (; from < len; from++)
			{
				if (from in this &&
						this[from] === elt)
					return from;
			}
			return -1;
		};
	}
}`

class Constructor
	constructor: ->
		@init = (do_constr=false, site_id) ->
			window.DB = init_db( window.csrf )
			window.initArray()

			@site_id = site_id
			@_site_type = "sites"
			@is_constructor = do_constr
			@page_cont = $('#id-top-cont')
			@default_app = default_app
			$(window).bind 'resize' , => @redraw()
			
			window.PATTERNS = JSON.parse(window.PATTERNS_REPR) if window.PATTERNS_REPR?
			window.APP_EGGS = JSON.parse(window.APP_EGGS_REPR) if window.APP_EGGS_REPR?

			window.onhashchange= =>
				@_init_page()
				@redraw()
			if @is_constructor
				@init_cp_marker()
			@redraw()


window.Constructor = new Constructor();

$(document).bind "ready", (e) =>
	window.Constructor.init window.is_constructor, window.site_id
window.setFont = (jq, fontfamily) =>
		
	jq.css('font-family', fontfamily)
	
	
window.WidgetIniter = ->
	@default_size = [3, 1]
	@disobey = []
	@redraw = ->
		#console.log('redraw')
		@my_cont.find("*").remove()
		@draw()
	@__remove_blob = (id) ->
		DB.remove_blob id
		

	@_data = ->
		if @data 
			if typeof(@data) is 'object'
				jQuery.extend(true,{},@data) 
			else 
				@data
		else 
			@_def_data

	@init = (my_cont, constructor_inst, pos, cp) ->
		@set = constructor_inst.getBlockSettings(pos)
		@data = constructor_inst.getWidgetData(pos)
		@my_cont = my_cont
		@pos = pos
		@constructor_inst = constructor_inst
		@C = constructor_inst
		this

	@draw = ->
		#console.log('draw')
		@apply_block_settings(false)
		@_draw()
		

	@save = ->
		@_save()	if @_save
		@C.setWidgetData @pos, @data
		@C.setBlockSettings @pos, @set
	@remove = ->
		@_remove() if @_remove
		

	@cancel = ->
		@_cancel()	if @_cancel
		@redraw.apply(@,[])

	@settings = (cp) ->
		@_init_block_cp cp
		@_settings cp	if @_settings?
		cp.show()


	@_init_block_cp = (to) ->
		cb = undefined
		cl = undefined
		lhs = undefined
		li = undefined
		m = undefined
		o = undefined
		old_settings = undefined
		onCancel = undefined
		onColorChoice = undefined
		onPatternChoice = undefined
		onSave = undefined
		plr = undefined
		pt = undefined
		self = undefined
		settings = undefined
		ul = undefined
		vf = undefined
		w = undefined
		m = $("<div>").appendTo(to)
		self = this
		old_settings = $.extend(true, {}, @set)
		onPatternChoice = (pattern) ->
			self.set.background =
				type: "pattern"
				pattern: pattern

			self.apply_block_settings()

		onColorChoice = (color, pal_ix, hsba) ->
			if color is "clear"
				self.set.background = type: "none"
			else
				self.set.background =
					type: "color"
					color: pal_ix
			self.apply_block_settings()

		onCancel = ->
			@set = old_settings
			self.apply_block_settings()
			$(this).dialog "close"

		onSave = ->
			$(this).dialog "close"

		cl = $("<button>").button().text("Выбор фона").click(->
			self.C.drawBackgroundSelectorDialog onPatternChoice, onColorChoice, onCancel, onSave
		).appendTo(m)
		cl = $("<button>").button().text("выбрать цвет рамки").click(->
			cb = undefined
			cc = undefined
			cb = (col, ix) ->
				if col isnt "clear"
					self.set.border_color = ix
					self.apply_block_settings()

			cc = self.C.draw_color_chooser(cb)
			cc.appendTo(to).position
				of: this
				my: "left top"
				at: "left top"

		).appendTo(m)
		cl = $("<button>").button().text("выбрать цвет текста").click(->
			cb = undefined
			cc = undefined
			cb = (col, ix) ->
				if col isnt "clear"
					self.set.text_color = ix
					self.apply_block_settings()

			cc = self.C.draw_color_chooser(cb)
			cc.appendTo(to).position
				of: this
				my: "left top"
				at: "left top"

		).appendTo(m)
		vf = (a, d) ->
			if typeof a is "undefined"
				d
			else
				a

		ul = $("<ul>").appendTo(m).addClass("cp-ul")
		li = $("<li>").appendTo(ul)
		$("<span>").text("Прозрачность блока").appendTo li
		$("<div>").width(250).slider(
			min: 0
			max: 100
			value: vf(self.set.bg_opacity, 100) * 100
			slide: (event, ui) ->
				self.set.bg_opacity = ui.value / 100
				self.apply_block_settings()
		).appendTo li
		li = $("<li>").appendTo(ul)
		$("<span>").text("Радиус границы").appendTo li
		$("<div>").width(250).slider(
			min: 0
			max: 100
			value: vf(self.set.border_radius, 0)
			slide: (event, ui) ->
				self.set.border_radius = ui.value
				self.apply_block_settings()
		).appendTo li
		li = $("<li>").appendTo(ul)
		$("<span>").text("Ширина границы").appendTo li
		$("<div>").width(250).slider(
			min: 0
			max: 100
			value: vf(self.set.border_width, 0) * 10
			slide: (event, ui) ->
				self.set.border_width = ui.value / 10
				self.apply_block_settings()
		).appendTo li
		li = $("<li>").appendTo(ul)
		$("<span>").text("Межстрочный интервал").appendTo li
		lhs = $("<div>").width(250).slider(
			min: 0
			max: 300
			value: vf(self.set.line_height,1 ) * 10
			slide: (event, ui) ->
				self.set.line_height = ui.value / 10
				self.apply_block_settings()
		).appendTo(li)
		li = $("<li>").appendTo(ul)
		$("<span>").text("Размер шрифта").appendTo li
		$("<div>").width(250).slider(
			min: 0
			max: 300
			value: vf(self.set.font_size, 10)*10
			slide: (event, ui) ->
				self.set.font_size = ui.value / 10
				self.apply_block_settings()
		).appendTo li
		li = $("<li>").appendTo(ul)
		$("<span>").text("отступ сверху").appendTo li
		pt = ((if self.set.padding_top then self.set.padding_top * 10 else 0))
		$("<div>").width(250).slider(
			min: 0
			max: 300
			value: pt
			slide: (event, ui) ->
				self.set.padding_top = ui.value / 10
				self.apply_block_settings()
		).appendTo li
		li = $("<li>").appendTo(ul)
		$("<span>").text("Отступ слева-справа").appendTo li
		plr = ((if self.set.padding_left_right then self.set.padding_left_right * 10 else 0))
		$("<div>").width(250).slider(
			min: 0
			max: 300
			value: plr
			slide: (event, ui) ->
				self.set.padding_left_right = ui.value / 10
				self.apply_block_settings()
		).appendTo li
		$("<label for='available_all_pages'>").appendTo(m).append "Показывать на всех страницах"
		cb = $("<input type='checkbox' id='available_all_pages'>").appendTo(m).click(->
			if self.C.Site.blocks[self.pos].display_on is "all"
				self.C.Site.blocks[self.pos].display_on = self.current_page
			else
				self.C.Site.blocks[self.pos].display_on = "all"
		)
		cb.prop "checked", self.C.Site.blocks[self.pos].display_on is "all"
		$("<br>").appendTo m
		$("<label for='unsnap_to_grid'>").appendTo(m).append "Свободный блок"
		cb = $("<input type='checkbox' id='unsnap_to_grid'>").appendTo(m).click(->
			self.set.unsnap_to_grid = @checked
			bl = self.C.get_block(self.pos)
			if @checked
				self.C.move_block self.pos, self.C._calc_left(bl.x + 1) + self.set.border_width, self.C._calc_top(bl.y) + self.set.border_width, true
				self.C.Site.blocks[self.pos].width = self.C._calc_width(bl.width)
				self.C.Site.blocks[self.pos].height = self.C._calc_height(bl.height)
			else
				self.C.move_block self.pos, Math.round(self.C._uncalc_left(bl.x) + self.set.border_width), Math.round(self.C._uncalc_top(bl.y) + self.set.border_width), true
				self.C.Site.blocks[self.pos].width = Math.round(self.C.Site.blocks[self.pos].width / self.C._block_width())
				self.C.Site.blocks[self.pos].height = Math.round(self.C.Site.blocks[self.pos].height / self.C._block_height())
		)
		cb.prop "checked", self.set.unsnap_to_grid
		$("<br>").appendTo m
		cl = $("<button>").button().text("Применить для всех новых блоков").click(->
			self.C.Site.default_block_settings = self.set
			self.C.redraw()
			m.remove()
		).css("display", "block").css("padding", "5px").css("margin-bottom", "10px").appendTo(m)
		cl = $("<button>").button().text("Применить для всех имеющихся блоков").click(->
			self.C.Site.default_block_settings = self.set
			$.each self.C.Site.blocks, (i, bl) ->
				delete bl["settings"]

			self.C.redraw()
			to.remove()
		).appendTo(m).css("display", "block").css("padding", "5px").css("margin-bottom", "10px")
		o =
			save: ->
	
				self.C.setBlockSettings obj.pos, self.set

			cancel: ->

		o

	@apply_block_settings = (follow = true)->
		#console.log('apply_block_settings')
		C = @my_cont.parent()
		border_color = ->
			if @set.border_color?

				if typeof @set.border_color is "string"
					C.css "border-color", @set.border_color
				else
					color = @C.get_color(@set.border_color)
					c = hsvToRgb(color)
					C.css "border-color", c

		opacity = ->
			if isOpacitySupported()
				@my_cont.css "opacity", @set.bg_opacity

		border_radius = ->
			C.css "-moz-border-radius", @set.border_radius + "px"
			C.css "-webkit-border-radius", @set.border_radius + "px"
			C.css "border-radius", @set.border_radius + "px"

		border_width = ->
			bl = @C.get_block(@pos)
			unless @set.unsnap_to_grid
				xx = @C._calc_left(bl.x + 1) - @set.border_width
				yy = @C._calc_top(bl.y) - @set.border_width
			else
				xx = bl.x
				yy = bl.y
			C.css "border-width", @set.border_width + "px"
			C.css "left", xx
			C.css "top", yy
			C.css "border-style", "solid"

		line_height = ->
			C.css "line-height", @set.line_height + "px"

		font_size = ->
			C.css "font-size", @set.font_size + "px"

		padding_left_right = ->

			#C = w.children().eq(0);
			W = C.width()
			C.children().eq(0).css "margin-left", @set.padding_left_right + "px"
			C.children().eq(0).css "margin-right", @set.padding_left_right + "px"
			C.children().eq(0).width W - @set.padding_left_right * 2

		padding_top = ->
			C.children().eq(0).css "padding-top", @set.padding_top + "px"

		background = ->
			if @set.background.type is "color"
				if typeof @set.background.color is "string"
					C.css "background", @set.background.color
				else
					color = @C.get_color(@set.background.color)
					#console.log(color)
					c = hsvToRgb(color)
					#console.log(c)
					C.css "background", c
			else if @set.background.type is "none"
				C.css "background", ""
			else if @set.background.type is "pattern"
				patt = @set.background.pattern
				if patt.type is "image"
					C.css "background", "url(" + patt.image + " ) repeat"
				else if patt.type is "constructor"
					@C.renderPattern C, patt
				else
					@C._draw_css_background C, patt.image

		text_color = ->
			C.css "color", hsvToRgb(@C.get_color(@set.text_color))	if @set.text_color

		appl =
			border_color: border_color
			opacity: opacity
			border_radius: border_radius
			border_width: border_width
			padding_top: padding_top
			padding_left_right: padding_left_right
			background: background
			font_size: font_size
			line_height: line_height
			text_color: text_color


		for k of appl
			f = appl[k]

			if @do_not_apply?
				f.apply this	if @do_not_apply.indexOf(k) is -1
			else
				f.apply this
		#console.log( " Hello " )
		if (@need_redraw and follow)
			# console.log(">>>")
			@_draw() 

	
WI = 	`function WidgetIniter(){
		this.default_size = [3,1];
		this.disobey = [];
		this.redraw = function(){
				this.my_cont.find('*').remove()
				this.draw();
		};
		this._data = function(){
				//console.log(">>>>",this.data);
				return this.data?this.data:this._def_data}

		this.init = function(my_cont, constructor_inst, pos, cp){
				this.set = constructor_inst.getBlockSettings(pos)
				this.data		 = constructor_inst.getWidgetData(pos)
				this.my_cont = my_cont;
				this.pos = pos;
				this.constructor_inst = constructor_inst;
				this.C = constructor_inst;
				return this;
		}
		this.draw = function(){
				// console.log('fdfdf')
				this.apply_block_settings()
				this._draw()


		}
		this.save = function(){
				if (this._save)this._save();

				this.C.setWidgetData(this.pos, this.data)
				this.C.setBlockSettings(this.pos, this.set);
		};
		this.cancel = function(){if (this._cancel)this._cancel();};
	
		this.settings = function( cp ){ 
		this._init_block_cp( cp );
				if (this._settings != null ) {this._settings(cp);}
		cp.show();
		};
	
		this._init_block_cp = function(to) {
			var cb, cl, lhs, li, m, o, old_settings, onCancel, onColorChoice, onPatternChoice, onSave, plr, pt, self, settings, ul, vf, w;
			m = $("<div>").appendTo(to);
			self = this;
			old_settings = $.extend(true, {}, this.set);

			onPatternChoice = function(pattern) {
				self.set.background = {
					type: "pattern",
					pattern: pattern
				};
				return self.apply_block_settings();
			};

			onColorChoice = function(color, pal_ix, hsba) {
				if (color === "clear") {
					self.set.background = {
						type: "none"
					};
				} else {
					self.set.background = {
						type: "color",
						color: pal_ix
					};
				}
				return self.apply_block_settings();
			};
			onCancel = function() {
				this.set = old_settings;
				self.apply_block_settings();
				return $(this).dialog("close");
			};
			onSave = function() {
				return $(this).dialog("close");
			};

				cl = $("<button>").button().text("Выбор фона").click(function() {
					return self.C.drawBackgroundSelectorDialog(onPatternChoice, onColorChoice, onCancel, onSave);
				}).appendTo(m);

				cl = $("<button>").button().text("выбрать цвет рамки").click(function() {
					var cb, cc;
					cb = function(col, ix) {
						if (col !== "clear") {
							self.set.border_color = ix;
							return self.apply_block_settings();
						}
					};
					cc = self.C.draw_color_chooser(cb);
					return cc.appendTo(to).position({
						of: this,
						my: "left top",
						at: "left top"
					});
				}).appendTo(m);
				cl = $("<button>").button().text("выбрать цвет текста").click(function() {
					var cb, cc;
					cb = function(col, ix) {
						if (col !== "clear") {
							self.set.text_color = ix;
							return self.apply_block_settings();
						}
					};
					cc = self.C.draw_color_chooser(cb);
					return cc.appendTo(to).position({
						of: this,
						my: "left top",
						at: "left top"
					});
				}).appendTo(m);


			vf = function(a, d) {
				if (typeof a === "undefined") {
					return d;
				} else {
					return a;
				}
			};


			ul = $("<ul>").appendTo(m).addClass("cp-ul");

				li = $("<li>").appendTo(ul);
				$("<span>").text("Прозрачность блока").appendTo(li);
				$("<div>").width(250).slider({
					min: 0,
					max: 100,
					value: vf(self.set.bg_opacity, 100) * 100,
					slide: function(event, ui) {
						self.set.bg_opacity = ui.value / 100;
						return self.apply_block_settings();
					}
				}).appendTo(li);

				li = $("<li>").appendTo(ul);
				$("<span>").text("Радиус границы").appendTo(li);
				$("<div>").width(250).slider({
					min: 0,
					max: 100,
					value: vf(self.set.border_radius, 0),
					slide: function(event, ui) {
						self.set.border_radius = ui.value;
						return self.apply_block_settings();
					}
				}).appendTo(li);
				li = $("<li>").appendTo(ul);
				$("<span>").text("Ширина границы").appendTo(li);
				$("<div>").width(250).slider({
					min: 0,
					max: 100,
					value: vf(self.set.border_width, 0) * 10,
					slide: function(event, ui) {
						self.set.border_width = ui.value / 10;
						return self.apply_block_settings();
					}
				}).appendTo(li);
				li = $("<li>").appendTo(ul);
				$("<span>").text("Межстрочный интервал").appendTo(li);
				lhs = $("<div>").width(250).slider({
					min: 0,
					max: 300,
					value: self.set.line_height,
					slide: function(event, ui) {
						self.set.line_height = ui.value / 10;
						return self.apply_block_settings();
					}
				}).appendTo(li);
				li = $("<li>").appendTo(ul);
				$("<span>").text("Размер шрифта").appendTo(li);
				$("<div>").width(250).slider({
					min: 0,
					max: 300,
					value: self.set.font_size,
					slide: function(event, ui) {
						self.set.font_size = ui.value / 10;
						return self.apply_block_settings();
					}
				}).appendTo(li);
				li = $("<li>").appendTo(ul);
				$("<span>").text("отступ сверху").appendTo(li);
				pt = (self.set.padding_top ? self.set.padding_top * 10 : 0);
				$("<div>").width(250).slider({
					min: 0,
					max: 300,
					value: pt,
					slide: function(event, ui) {
						self.set.padding_top = ui.value / 10;
						return self.apply_block_settings();
					}
				}).appendTo(li);
				li = $("<li>").appendTo(ul);
				$("<span>").text("Отступ слева-справа").appendTo(li);
				plr = (self.set.padding_left_right ? self.set.padding_left_right * 10 : 0);
				$("<div>").width(250).slider({
					min: 0,
					max: 300,
					value: plr,
					slide: function(event, ui) {
						self.set.padding_left_right = ui.value / 10;
						return self.apply_block_settings();
					}
				}).appendTo(li);

			$("<label for='available_all_pages'>").appendTo(m).append("Показывать на всех страницах");
			cb = $("<input type='checkbox' id='available_all_pages'>").appendTo(m).click(function() {
				if (self.C.Site.blocks[self.pos].display_on === "all") {
					return self.C.Site.blocks[self.pos].display_on = self.current_page;
				} else {
					return self.C.Site.blocks[self.pos].display_on = "all";
				}
			});

			cb.prop("checked", self.C.Site.blocks[self.pos].display_on === "all");
			$("<br>").appendTo(m);
			$("<label for='unsnap_to_grid'>").appendTo(m).append("Свободный блок");
			cb = $("<input type='checkbox' id='unsnap_to_grid'>").appendTo(m).click(function() {
				self.set.unsnap_to_grid = this.checked;
				var bl = self.C.get_block(self.pos);
				if (this.checked) {
						self.C.move_block(self.pos, self.C._calc_left(bl.x + 1) + self.set.border_width, self.C._calc_top(bl.y ) + self.set.border_width, true);

						self.C.Site.blocks[self.pos].width = self.C._calc_width(bl.width);
						self.C.Site.blocks[self.pos].height = self.C._calc_height(bl.height);
				} else {
					self.C.move_block(self.pos, Math.round(self.C._uncalc_left(bl.x) + self.set.border_width), Math.round(self.C._uncalc_top(bl.y) + self.set.border_width), true);
					self.C.Site.blocks[self.pos].width = Math.round(self.C.Site.blocks[self.pos].width / self.C._block_width())
					self.C.Site.blocks[self.pos].height = Math.round(self.C.Site.blocks[self.pos].height	/ self.C._block_height())
				}
			});
			cb.prop("checked", self.set.unsnap_to_grid);
			$("<br>").appendTo(m);
			cl = $("<button>").button().text("Применить для всех новых блоков").click(function() {
				self.C.Site.default_block_settings = self.set;
				self.C.redraw();
				return m.remove();
			}).css("display", "block").css("padding", "5px").css("margin-bottom", "10px").appendTo(m);
			cl = $("<button>").button().text("Применить для всех имеющихся блоков").click(function() {
				self.C.Site.default_block_settings = self.set;
				$.each(self.C.Site.blocks, function(i, bl) {
					return delete bl["settings"];
				});
				self.C.redraw();
				return to.remove();
			}).appendTo(m).css("display", "block").css("padding", "5px").css("margin-bottom", "10px");
			o = {
				save: function() {
					//console.log('save')
					return self.C.setBlockSettings(obj.pos, self.set);
				},
				cancel: function() {}
			};
			return o;
		};

		this.apply_block_settings = function(){
				var C = this.my_cont.parent();
				var border_color = function(){
						if (this.set.border_color != null) {
								//console.log(this.set.border_color)
								if (typeof this.set.border_color === 'string'){
										C.css('border-color', this.set.border_color);
								}else{

										var color = this.C.get_color(this.set.border_color);
										c = hsvToRgb(color);
										C.css("border-color", c );
								}
						}
				}
				var opacity = function(){
						this.my_cont.css("opacity", this.set.bg_opacity);
				}
				var	border_radius = function(){
						C.css("-moz-border-radius", this.set.border_radius + "px");
						C.css("-webkit-border-radius", this.set.border_radius + "px");
						C.css("border-radius", this.set.border_radius + "px");
				}

				var border_width = function(){
									 bl = this.C.get_block(this.pos);
									if (!this.set.unsnap_to_grid) {
										xx = this.C._calc_left(bl.x + 1) - this.set.border_width;
										yy = this.C._calc_top(bl.y) - this.set.border_width;
									} else {
										xx = bl.x;
										yy = bl.y;
									}
									C.css("border-width", this.set.border_width + "px");
									C.css("left", xx);
									C.css("top", yy);
									C.css("border-style", "solid");
				}
				var line_height = function(){
						C.css("line-height", this.set.line_height + "px");

				}
				var font_size = function(){
						 C.css("font-size", this.set.font_size + "px");

				}
				var padding_left_right = function(){
						//C = w.children().eq(0);
						var W = C.width();
						C.children().eq(0).css("margin-left", this.set.padding_left_right + "px");
						C.children().eq(0).css("margin-right", this.set.padding_left_right + "px");
						C.children().eq(0).width(W - this.set.padding_left_right * 2);

				}
				var padding_top = function(){
						C.children().eq(0).css("padding-top", this.set.padding_top + "px");
				}
				var background = function(){
						if (this.set.background.type === "color") {

								if (typeof this.set.background.color === "string") {
									C.css("background", this.set.background.color);
								} else {
									color = this.C.get_color(this.set.background.color);
									c = hsvToRgb(color);
									C.css("background", c);
								}

						} else if (this.set.background.type === "none") {
								C.css("background", "");
						} else if (this.set.background.type === "pattern") {
							patt = this.set.background.pattern;
							if (patt.type === "image") {
								C.css("background", "url(" + patt.image + " ) repeat");
							} else if (patt.type === 'constructor') {
								this.C.renderPattern(C, patt);
							} else {
								this.C._draw_css_background(C, patt.image);
							}
						}
				}


				var text_color = function(){
						if (this.set.text_color ){
								C.css('color', hsvToRgb(this.C.get_color( this.set.text_color ) ) )
						}
				}
				var appl = {border_color:border_color,
								opacity:opacity,
								border_radius:border_radius,
								border_width: border_width,
								padding_top: padding_top,
								padding_left_right: padding_left_right,
								background:background,
								font_size:font_size,
								line_height:line_height,
								text_color:text_color

						}
				// console.log(this.set);
				for (k in appl){
						f = appl[k]
						// console.log(k)
						if (this.do_not_apply != null){
								if (this.do_not_apply.indexOf(k) === -1)
									 f.apply(this)

						}else {f.apply(this)}
				}
				if (this.need_redraw){
						this._draw();
				}




		}
		// return this;
}

`
# END of Main.coffee


window.Constructor.redraw = (force_reload = false)-> # Done
				@clear();
				@draw(null,null,null,force_reload);
window.Constructor.clear = ->
	# console.log('clear')
	@page_cont.find( "*").remove()
	$("#controls>.widget-control").remove()

window.Constructor.draw= (custom_cont = @page_cont, custom_head=$('head'), custom_hash, force_reload=false) -> #Done
			#log("CH", custom_hash)
			if custom_hash
				custom_hash = custom_hash.slice(1).split('?')
			if @_init_page custom_hash, custom_head, force_reload
				@init_grid(custom_cont, custom_head)

window.Constructor._init_page = (hash_ = window.location.hash.slice(1).split('?'), head = $('head'), force_reload=false ) -> #Done
	@page_vars= {} if not @page_vars?
	page_name = hash_[0].replace('!','')
	params = if hash_[1]?
			hash_[1]
		else ""
	@current_page = page_name
	pdata = @getPageData(page_name, force_reload)
	if pdata? # We've got page Draw!
		if	pdata.params
			for p, val of pdata.params
				do (p, val) =>
					#log(@, p, val)
					@page_vars[p] = val

		t = head.find('title')
		if t.length is 0
			t = $('<title>').appendTo head
		@head_tag = head
		@_set_description	pdata.description
		@_set_keywords pdata.keywords
		if not @Site.seo.title?
			title = "Undefined"
		else title = @Site.seo.title
		if not pdata.title?
			ptitle = "Unknown page"
		else ptitle = pdata.title
		#console.log(t.text())
		doc_title = ptitle + '|' + title
		if is_ie
			document.title = doc_title
		else
			t.text (doc_title)

		head.append(@Site.seo.metas.yandex) if @Site.seo.metas? and @Site.seo.metas.yandex?
		head.append(@Site.seo.metas.google) if @Site.seo.metas? and @Site.seo.metas.google?
		if params
			a = params.split('&')
			for p in a
				do (p) =>
					#log(p)
					_p = p.split('=')
					name = _p[0]
					val =	_p[1]
					if name and val
						@page_vars[name] = val
		@layout = @Site.layout
		@base_height = @layout.base_height
		@inited_blocks = []
		#log 'ok', page_name, pdata, params
		true
	else
		#log ('no ok')
		false




window.Constructor.getPageData = ( page_name, do_reload = false ) -> # DOne
	@load_site(do_reload);
	@Site.pages[page_name]


window.Constructor.load_site = (do_reload = false ) -> #done


	if window.SITE_OBJECT_REPR?
		@Site = JSON.parse(window.SITE_OBJECT_REPR)
		window.SITE_OBJECT_REPR = undefined
		
		
	if not @Site? or do_reload
		#console.log('reload')
		S = DB.get_objects("generic." + BASE_SITE, this._site_type, {} )
		if S.total_amount isnt 0
			@Site = S.objects[0];
			if not @Site.layout.grid?
				@Site.layout.grid = this.Site.layout.padding
				@Site.layout.padding = {top:50, left:10}
		else
			@Site = default_site
	else
		#console.log('no load')


	if not @Site.Applications?
		apps_ = {}
		for app_name in @Site._Apps
			do (app_name) =>
				app = @getApp(app_name)
				if app
					apps_[app_name] = app
		
		@Site['Applications'] = apps_;

		delete @Site.version
		@page_order_index = {};
		@page_amount = 0
		for i,page in @Site.pages
			@page_order_index[page.order] = i
			@page_amount +=1




window.Constructor.getAppJson = (name) ->
	if window.APP_EGGS? and name of window.APP_EGGS
		window.APP_EGGS[name]
	else
		xhr = $.ajax({url: window.get_application_url + name + "/",async: false, cache:true})
		#log(xhr.status)
		if xhr.status is 200
			JSON.parse(xhr.responseText)
		else
			ix = @Site._Apps.indexOf(name)
			@Site._Apps.splice ix, 1
			false
		



window.Constructor.getApp = (name) ->
	app_egg = @getAppJson name
	if app_egg
		app_egg.Main = new Function(app_egg.Main.attr, app_egg.Main.body)
		app_egg.getter = new Function(app_egg.getter.attr, app_egg.getter.body)
		App = app_egg.getter(this, name)
		App.roles = app_egg.roles
		App.default_role = app_egg.default_role
		App.app_name = app_egg.app_name
		App.title = app_egg.title
		App.is_own = app_egg.is_own
		App
	else false





window.Constructor.set_app_cache = (n,v)->
	if @_app_cache?
		@_app_cache[n]=v
	else
		@_app_cache = {}
		@_app_cache[n] = v


window.Constructor.get_app_cache = (n)->
	if @_app_cache? and @_app_cache[n]?
			@_app_cache[n]
	else{}





window.Constructor.get_block = (ix) -> @Site.blocks[ix]


getBlockSettings = `function (pos){
				if (this.Site.default_block_settings){
					set = clone(this.Site.default_block_settings)
				}else{
					set = {border_width:0,
							 background:{type:'none'}}
				}

				if ( this.Site.blocks[pos].settings ){
					for (k in this.Site.blocks[pos].settings){
						set[k] = this.Site.blocks[pos].settings[k]
					}
					// set = self.Site.blocks[pos].settings
				}
					return set

			}`
window.Constructor.getBlockSettings = (pos) ->
	
	if @Site.default_block_settings
		set = clone(@Site.default_block_settings)
	else
		set =
			border_width: 0
			background:
				type: "none"
	if @Site.blocks[pos].settings
		for k of @Site.blocks[pos].settings
			set[k] = @Site.blocks[pos].settings[k]
	
	# set = self.Site.blocks[pos].settings
	set




rect = `function (x,y,w,h){
			return {left:x, top:y, width:w, height:h}	 ;
			}`
window.Constructor.rect = rect





getWidgetData = `function (pos, def){
				var self = this;
				return (function(i){
					 var d = self.Site.blocks[pos].widget.data;
					if (d){
						return d
					}
					return def;

				})(pos)


			}`
window.Constructor.getWidgetData = getWidgetData






_add_title = `function (title) {
				var t = this.head_tag.find('title');
				var text = t.text()
				t.text(title +'|' + text);
			}`
window.Constructor._add_title = _add_title




_set_keywords = `function (kw){
				var H	= this.head_tag;
				var d = H.find('meta[name=keywords]');
				if(d.length){
				}else{
					d = $('<meta>').appendTo(H).attr('name','keywords');
				}
				if(kw){
					if(typeof kw == 'string'){
						d.attr('content', kw )
					}else{
						d.attr('content', kw.join(', ') )
					}
				}else{
					d.attr('content', '' )
				}
			}`
window.Constructor._set_keywords = _set_keywords





_set_description = `function (description){
				var H	= this.head_tag;
				var d = H.find('meta[name=description]');

				if(d.length){
				}else{
					d = $('<meta>')
					// console.log(d)
					d.appendTo(H).attr('name','description');
				}
				d.attr('content', description)


			}`
window.Constructor._set_description = _set_description




_set_page_var = `function (name, val){
				this.page_vars[name] = val
			}`
window.Constructor._set_page_var = _set_page_var




_get_page_var = `function (name){
				return this.page_vars[name];
			}`
window.Constructor._get_page_var = _get_page_var







window.Constructor.get_color = (c) ->
	@_make_pallette()
	if c.v is 'C'
		if	c.ix of @Site.colors.custom_pallette
			@Site.colors.custom_pallette[c.ix]
		else
			@Site.colors.custom_pallette[ 0 ]
	else
		v = @Site.colors.pallette[c.v]
		if v
			v[c.ix]
		else
			v = @Site.colors.pallette[c.v - 1]
			if v
				v[c.ix]
			else
				v = @Site.colors.pallette[c.v - 2]
				if v
					v[c.ix]
				else
					@Site.colors.pallette[c.v - 3][c.ix]



window.Constructor.getTextColors = ->
	colors = if not @Site.textColors? then {} else @Site.textColors
	defaults =
		text_color : "rgb(0,0,0)"
		link_color : "#0000ff"
		visited_color : "#800080"
		active_color : "#ff0000"
		hover_color	: "#0000ff"
	lc = {}
	#log('W', @Site.textColors, colors)
	for k in ["text_color", "link_color", "visited_color", "active_color", 'hover_color']

		if colors[k]? and colors[k].index?
			lc[k] = hsvToRgb(@get_color(colors[k].index))
		else
			lc[k] = defaults[k]
	#log("FINAL", lc)
	lc

window.Constructor.init_grid = (to, head) ->

	# log(to,head);
	block_width = @_block_width()
	base_height = @layout.base_height
	self = this
	if @layout.fixed
		e = "px"
	else
		e = "%"
	$("body").css "margin", 0
	total_height = @Site.layout.drawen_lines * (@Site.layout.base_height + 2 * (@Site.layout.grid.ver))
	window_width = window.innerWidth
	width = @Site.layout.width
	w_left = window_width - width
	left = w_left / 2
	@layout_cont = $("<div>").css("position", "absolute").css("width", @layout.width + e).css("top", @Site.layout.padding.top).css("left", left).css("height", total_height).appendTo(to)
	c_off = @layout_cont.offset()
	to.css "top", "0px"

	@_main_offset = c_off
	@redraw_background()
	@_busy_regions = []
	@_moved_block_ = []

	bw = self._block_width(1)
	bh = self._block_height(1)
	bhp = self.Site.layout.grid.hor
	bvp = self.Site.layout.grid.ver
	gw = bw + (bhp * 2)
	gh = bh + (bvp * 2)
	gp = self.Site.layout.padding.left + self.Site.layout.grid.hor

	gmp = (gp - (bhp * 2))

	if not is_safari
		grad_function = 'linear-gradient'

		$("<div>").addClass("empty-block").appendTo(@layout_cont)
		.css("position", "absolute")
		.css("background-color", "transparent")
		.css("background-image", grad_function+"(90deg, rgba(0,0,0,.5) 1px, transparent 1px)," +
											 grad_function+"(90deg, rgba(255,255,255,.5) 2px, transparent 1px)," +
											 grad_function+"(90deg, rgba(255,255,255,.5) 2px, transparent 1px)," +
											 grad_function+"(90deg, rgba(0,0,0,.5) 1px, transparent 1px)," +
											 grad_function+"(0deg, rgba(0,0,0,.5) 1px, transparent 1px)," +
											 grad_function+"(0deg, rgba(255,255,255,.5) 2px, transparent 1px)," +
											 grad_function+"(0deg, rgba(255,255,255,.5) 2px, transparent 1px)," +
											 grad_function+"(0deg, rgba(0,0,0,.5) 1px, transparent 1px)")
		.css("background-size", gw + "px 1px,	" + gw + "px 1px,	" + gw + "px 1px,	" + gw + "px 1px, 1px " + gh + "px, 1px " + gh + "px, 1px " + gh + "px, 1px " + gh + "px	")
		.css("background-position", gp + "px 0px, " + (gp + 1) + "px 0px, " + gmp + "px 0px, " + (gmp + 1) + "px 0px, 0px 0px,0px 1px, 0px -" + (bvp * 2) + "px,0px -" + ((bvp * 2) - 1) + "px")
		.css("left", 0)
		.css("top", 0).css("width", @Site.layout.width)
		.css("height", total_height)	if @is_constructor

	@inited_blocks = [] # Предназначение - последующий анбинд события клик после даблклика - включения панели управления
	@settings_over_block = false;

	hm = []
	$.each @Site.blocks, (ix, block) =>
		if block.display_on is "all"
			return	unless block.dont_display_on.indexOf(self.current_page) is -1
		else return	unless block.display_on is self.current_page
		set = self.getBlockSettings(ix)

		bw = (if set then set.border_width else 0)
		x = block.x # Number(koords.split(':')[0]);
		y = block.y # Number(koords.split(':')[1]);
		unless set.unsnap_to_grid

			xx = self._calc_left(x + 1) - bw
			yy = self._calc_top(y) - bw
		else
			xx = x
			yy = y
		w = block.width
		h = block.height
		unless set.unsnap_to_grid
			W = self._calc_width(w)
			H = self._calc_height(h)
		else
			W = w
			H = h
		gp =
			jq: $("<div>").appendTo(self.layout_cont).css("position", "absolute").css("left", xx).css("top", yy).width(W).css("height", H)
			.css("overflow", "hidden")
			pos: ix
		bl = self.init_block block, gp
		if bl
			offs = bl.offset()
			h = bl.height()
			hm.push(offs.top + h)
			@inited_blocks.push bl;
	@layout_cont.height(Math.max.apply(Math,hm))





window.Constructor.reapply_block_settings = (obj, widget)->
	sett = @getBlockSettings(obj.pos)
	@apply_block_settings(obj, sett, widget)

window.Constructor.apply_block_settings = (obj, settings, widget) ->
	if not widget.has_own_settings

		w = obj.jq #.children(":first")
		bl = @get_block(obj.pos)
		if widget.disobey.indexOf("border_color") is -1
			if typeof settings.border_color is "string"
				w.css "border-color", settings.border_color
			else
				if typeof settings.border_color is "undefined"
					settings.border_color =
						v: 0
						ix: 0
				color = @get_color(settings.border_color)
				c = hsvToRgb(color)
				w.css "border-color", c
		w.css "opacity", settings.bg_opacity	if widget.disobey.indexOf("bg_opacity") is -1
		if "border_radius" not	in widget.disobey
			w.css "-moz-border-radius" , settings.border_radius + "px"
			w.css "-webkit-border-radius" , settings.border_radius + "px"
			w.css "border-radius" , settings.border_radius + "px"


		if widget.disobey.indexOf("border_width") is -1
			unless settings.unsnap_to_grid
				xx = @_calc_left(bl.x + 1) - settings.border_width
				yy = @_calc_top(bl.y) - settings.border_width
			else
				xx = bl.x
				yy = bl.y
			w.css "border-width", settings.border_width + "px"
			w.css "left", xx
			w.css "top", yy
			w.css "border-style", "solid"
		w.css "line-height", settings.line_height + "px"	if widget.disobey.indexOf("line_height") is -1
		w.css "font-size", settings.font_size + "px"	if widget.disobey.indexOf("font_size") is -1
		if widget.disobey.indexOf("padding_left_right") is -1
			C = w.children().eq(0)
			W = w.width()
			C.css "margin-left", settings.padding_left_right + "px"
			C.css "margin-right", settings.padding_left_right + "px"
			C.width W - settings.padding_left_right * 2
		C.css "padding-top", settings.padding_top + "px"	if widget.disobey.indexOf("padding_top") is -1
		if settings.background.type is "color"
			if widget.disobey.indexOf("background_color") is -1
				if typeof settings.background.color is "string"
					w.css "background", settings.background.color
				else
					color = @get_color(settings.background.color)
					c = hsvToRgb(color)
					w.css "background", c
		else if settings.background.type is "none"
			w.css "background", ""
		else if settings.background.type is "pattern"
			patt = settings.background.pattern
			if patt.type is "image"

				w.css "background", "url(" + patt.image + " ) repeat"
			else if patt.type is 'constructor'
				@renderPattern w, patt

			else
				@_draw_css_background w, patt.image
		if widget.depends_on_settings?
			widget.draw(settings)






window.Constructor.init_block = (bl, to) ->

	init_resizer = ->
	newWidget = (c, t, p, cp) ->
		A = t.Site.Applications[app_name]
		if A? and A.widgets[widget_name]?

			W = A.widgets[widget_name];
			wi = (->new W())();
			wi.init c, t, p, cp
			#console.log(c,t,p,cp)
			return wi
		else
			false
	r = bl.top
	l = bl.left
	w = bl.width
	h = bl.height
	self = this
	W = @_calc_width(w)
	H = @_calc_height(h)
	widget_str = bl.widget.name.split(".")
	widget_name = widget_str[0]
	widget_str.splice 0, 1
	app_name = widget_str.join(".")
	wdata = bl.widget.data
	w = $("<div>").css('overflow','hidden').css("width", to.jq.width()).css("height", to.jq.height()).appendTo(to.jq).addClass("draggable-module")
	draga = undefined
	Widget = newWidget(w, this, to.pos)
	unless Widget
		return false
	#log( widget_name, app_name)
	#console.log('BEFORE widget draw');
	Widget.draw()
	# console.log("Widget test", bl.x, bl.y, bl.width, bl.height, app_name, widget_name, Widget.data);
	# settings = self.getBlockSettings(to.pos)
	#console.log("B", w.width() )
	# self.apply_block_settings to, settings, Widget
	if Widget.set.unsnap_to_grid
		W = bl.width
		H = bl.height

	# console.log("WH", W,H)

	make_draggable = (to)=>
		#console.log(to.jq)
		to.jq.draggable
			scroll: false
			zIndex: 100
			cancel: ".resize-marker"
			start: (event, ui) ->
				regs = []
				w = bl.x
				while w < bl.x + bl.width
					h = bl.y
					while h < bl.y + bl.height
						regs.push w + ":" + h
						h++
					w++
				for i of self.inited_blocks
					self.inited_blocks[i].unbind "mouseenter"
				to.jq.unbind "mouseleave" # , 'mouseenter')
				self._moved_block_ = regs

			drag: (event, ui) ->

				# // // console.log(ui)
				# var C = ui.helper;
				#console.log(settings)
				unless Widget.set.unsnap_to_grid
					ll = self._stepping_left(ui.position.left)
					tt = self._stepping_top(ui.position.top)
					draga =
						left: ll.block
						top: tt.block

					ui.position =
						top: tt.val
						left: ll.val
				else
					draga =
						left: ui.position.left
						top: ui.position.top

			stop: ->
				self._moved_block = false
				self.move_block to.pos, draga.left, draga.top
				self.redraw()

	if @is_constructor
		make_draggable(to);


	#console.log("A", w.width() )

	if @is_constructor
		to.jq.dblclick =>
			control_panel = $("<div>").addClass('widget-control') .appendTo($("#controls"))
			#wco = self.init_block_cp(to, control_panel, Widget)
			#saving_data = (evt) =>
			#	Widget.save()	if Widget.save
			#	wco.save()
			#
			#
			#	@settings_over_block = false
			#	control_panel.remove()
			#	@redraw.apply self, []

			#if	 @settings_over_block isnt false

			#	@settings_over_block.saving()
			#else
			#	@settings_over_block = {to:to, Widget:Widget, saving: saving_data }

			for bl in @inited_blocks
				bl.unbind "click dblclick"
				bl.draggable('destroy')
			#log("after loop",	to.jq.attr('class'))

			$("#controls>.widget-control").hide()
			control_panel.css("position", "absolute").position(
				of: w
				my: "left top"
				at: "right top"
				collision: "none none"
			).css("border", "2px solid black").css("background-color", "white").draggable(scroll: false).css "padding", "10"


			Widget.settings control_panel	if Widget.settings

			#$("<div>").css("background-color", "orange").appendTo(to.jq).css("position", "absolute").position(
			#	of: to.jq
			#	my: "left top"
			#	at: "right top"
			#	collision: "none"
			#).addClass("ui-icon ui-icon-gripsmall-diagonal-se").width(20).height 20
			$("<div>").css("background-color", "green").appendTo(to.jq.parent()).css("position", "absolute").position(
				of: to.jq
				my: "left top"
				at: "left-20 top"
				collision: "none none"
			).addClass("ui-icon ui-icon-gripsmall-diagonal-se").width(20).height(20).click =>
				Widget.save() if Widget.save #saving_data()
				@_save_site();
				control_panel.remove();
				#console.log('draw');
				self.redraw();

			$("<div>").css("background-color", "red").appendTo(to.jq.parent()).css("position", "absolute").position(
				of: to.jq
				my: "left top"
				at: "left-20 top+30"
				collision: "none none"
			).addClass("ui-icon ui-icon-gripsmall-diagonal-se").width(20).height(20).click ->
				control_panel.remove();
				Widget.cancel();
				#console.log('cancel');
				self.redraw();
				
				


		mouseWidth = W
		mouseHeight = H
		start_x = undefined
		start_y = undefined

		# .css('cursor', 'se-resize')

		#.position({of:to.jq, my:"right top", at:"right-20 top"})
		delete_marker = $("<div>").appendTo($("#controls")).css("position", "absolute").addClass("delete-marker widget-control").css("background-color", "blue").css("border-radius", "5px").css("border", "1px solid black").addClass("ui-icon ui-icon-closethick").width("20px").height("20px").hide().click(->
			Widget.remove();
			self.delete_block to.pos
			self.redraw.apply self, []
		)

		resize_marker = $("<div>").appendTo($("#controls")).css("position", "absolute").addClass("ui-icon ui-icon-grip-diagonal-se").width("32px").height("32px").hide().addClass("resize-marker widget-control").css("background-color", "blue").css("cursor", "se-resize").css("border-radius", "5px").css("border", "1px solid black").mouseenter(->
		).mouseup((evt) ->
			self.resize_frame = false
		).mousedown((evt) ->
			start_x = evt.clientX
			start_y = evt.clientY
			self.resize_frame = $("<div>").css("position", "absolute").css("border", "1px solid black").appendTo(to.jq.parent()).width(W).height(H).position(
				of: to.jq
				my: "left top"
				at: "left top"
			)
			mouseWidth = bl.width
			mouseHeight = bl.height
			to.jq.parent().unbind "mouseup"
			to.jq.parent().unbind "mousemove"
			to.jq.parent().mouseup ->
				if self.resize_frame
					self.resize_frame.remove()
					self.resize_frame = false
					self.Site.blocks[to.pos].width = mouseWidth
					self.Site.blocks[to.pos].height = mouseHeight
					self.redraw.apply self, []
			to.jq.parent().mousemove((evt) ->
				fr = self.resize_frame
				if fr
					if fr.size()
						nh = evt.clientY - start_y + H
						nw = evt.clientX - start_x + W
						unless Widget.set.unsnap_to_grid
							width_step = self._stepping_width(nw)
							height_step = self._stepping_height(nh)
							fr.width width_step.val
							fr.height height_step.val
							mouseWidth = width_step.block
							mouseHeight = height_step.block
						else
							fr.width nw
							fr.height nh
							mouseWidth = nw
							mouseHeight = nh
				evt.preventDefault()
			).css "cursor", "se-resize"
			$(this).hide()
		)
		po = to.jq.position()
		wi = to.jq.width()
		he = to.jq.height()
		mw = resize_marker.width()
		mh = resize_marker.height()
		o = @_main_offset

		resize_marker.css "top", po.top + o.top + he - mh
		resize_marker.css "left", po.left + o.left + wi - mw
		delete_marker.css "top", po.top
		delete_marker.css "left", po.left + o.left + wi - mw
		clc = (e) =>

			$("#controls>.widget-control").hide()
			delete_marker.show().zIndex 1000
			resize_marker.show().zIndex 1000
		(->to.jq.on('click', clc))()
	to.jq


window.Constructor.registerEvent = (e, f)->
	if @events?
		if @events[e]
			@events[e].push(f)
		else:
			@events[e] = [f]
	else
		@events = {}
		@events[e] = [f]

window.Constructor.fireEvent = (e)->
	if @events? and @events[e]
		for f in @events[e]
			do f


window.Constructor.renderPattern = (to, pattern)->
	# log(pattern)
	redraw_ctx = (image_obj) =>
		dr_im = (x, y, bx, by_) ->
			ctx.save()
			ctx.translate x, y
			ctx.scale Z, Z
			rad = A * (3.14 / 180)
			ctx.rotate rad
			ctx.globalAlpha = opacity / 100
			ctx.drawImage image_obj, -(iw / 2), -(ih / 2), iw, ih
			ctx.restore()
		Cjq.css("margin-left", (300 - base) / 2).css "margin-top", (300 - base) / 2
		C.width = base
		C.height = base
		iw = image_obj.width * Z
		ih = image_obj.height * Z
		if BG
			if "ix" of BG
				c = @get_color(BG)
			else
				c = BG
			c.a = GA
			ctx.fillStyle = hsvToRgb(c) # "rgba( 255,255, 255, 255)";
		ctx.rect 0, 0, C.width, C.height
		ctx.fill()
		ctx.save()
		ctx.clip()
		dr_im base / 2, base / 2
		dr_im 0, 0
		dr_im 0, base
		dr_im base, 0
		dr_im base, base
		ctx.closePath()
		ctx.restore()
		img = C.toDataURL()
		to.css "background", "url(" + img + ") repeat"


	exc_color = (img_) =>
		S.width = img_.width
		S.height = img_.height
		sctx.drawImage img_, 0, 0
		buffData = sctx.getImageData(0, 0, img_.width, img_.height)
		if "ix" of FG
			c = @get_color(FG)
		else
			c = FG
		FGA = hsvToRgb(c, true)
		x = 0
		while x < buffData.width
			y = 0
			while y < buffData.height
				ix = (x + (y * buffData.width)) * 4
				buffData.data[ix] = FGA[0] #red
				buffData.data[ix + 1] = FGA[1] #green
				buffData.data[ix + 2] = FGA[2] #blue
				y++
			x++
		sctx.putImageData buffData, 0, 0
		du = S.toDataURL()
		_I = new Image()
		_I.onload = -> redraw_ctx(_I)
		_I.src = du
		
	if pattern.base_image?
		img_src = pattern.base_image
		FG = pattern.FG
		BG = pattern.BG
		A = pattern.A
		Z = pattern.Z
		GA=pattern.GA
		base = pattern.base
		opacity = pattern.opacity
		Cjq = $('<canvas>') #.appendTo(flright)
		C	 = Cjq[0]
		S = $('<canvas>')[0] #.appendTo(flright)[0]
		ctx = C.getContext('2d')
		sctx = S.getContext('2d')
		image_obj = $(new Image())
		
		image_obj.one('load', (e)=>
			exc_color(e.delegateTarget)
		)
		image_obj.prop('src', img_src)

	else
		 to.css "background", "url(" + pattern.image + ") repeat"






caching = `function (){
				var _current_page = this.current_page;
				var hashes = {};
				var self = this;
				var active_renderers = {}
				var is_saved =false

				var body_style = $('body').prop('style')



				var perform_caching = function(){
					if (is_saved){return} // просто выходим - сохранили
					var is_done = true;

					for( i in active_renderers ){
						is_d = !active_renderers[i]
						is_done = is_done && is_d;
					}
					// log(is_done, active_renderers)
					if( is_done ){ // все процессы отработали
						DB.save_cache(hashes)
						is_saved = true
					}else{
						setTimeout(perform_caching, 1000);
					}

				}

				var render_page = function(hash){
				  // hash = hash.replace("#", "")

					if(hash in hashes){ return }

					active_renderers[hash] = true;
					var custom_cont = $('<div>');
					var custom_head = $('<div>');
					var content, head_content;
					try{
						self.is_constructor = false;
						self.draw(custom_cont, custom_head, hash)
						self.is_constructor = true;

						setTimeout(function(){
              var content = custom_cont.html();
              var head_content = custom_head.html();
              var link_list = [];
              var as = custom_cont.find('a');
              $.each(as, function(ix, a){
                 var h = "#" + $(a).prop('href').split('#')[1]
                 if(h != null){
                  render_page(h);
                 }
              })
              custom_cont.remove();
              var h = $('<html>')
              var b = $('<body>')
              .prop('style', body_style.cssText)
              .html(content).appendTo(h)
              hashes[hash] = {'cont':b.html(), head:head_content}
              active_renderers[hash] = false;
            }, 5000)
					}finally{
						self.is_constructor = true
						// throw
					}





				}

				render_page("#!");
				perform_caching();



			}`
window.Constructor.caching = caching






_make_pallette = `function (){

				var h =	 this.Site.colors.base,
					lights = this.Site.colors.lights,
					shadows = this.Site.colors.shadows,

					brightness = this.Site.colors.brightness,
					saturation = this.Site.colors.saturation,
					i = this.Site.colors.type;
				this.Site.colors.pallette = [];


				var s,a,A;
				// // // // console.log(i,h,s,a,A, this.Site.colors)
				switch(i) {

					case 'mono':
						s = a = A = false;
						break;
					case 'complement':
						s = (h + 180) % 360
						a = A = false
						break;
						//return hsvToRgb(a,100,100)
					case 'triada':
						var s = (h + 120) % 360,
							a = (h + (360 -120)) % 360,
							A = false;
						break;
					case 'split-trio':
						var s = (h + 150) % 360,
							a = (h + (360 -150)) % 360,
							A = false;
						break; // return hsvToRgb(a,100,100)
					case 'analogous':
						var s = (h + 30) % 360,
							a = (h + (360 - 30)) % 360,
							A = false;
						break; // return hsvToRgb(a,100,100)

					case 'accent':
						var s = (h + 30) % 360,
							a = (h + (360 - 30)) % 360,
							A = (h + 180) % 360;
						break; // return hsvToRgb(a,100,100)

				}
				sat_koef = [0.89, 0.5, 0.5, 0.01];
				br_koef	 = [0.05, 0.05, 0.45 ,0.3];

				colors = [h,a,s,A];
        console.log("Hues", colors)
				var greys = new Array();
				am = 5
				for(c =0; c <= am; c++){
					_c = {h:0,s:0, b: c * (100/am),a:1 }
					greys.push(_c)
				}
				this.Site.colors.pallette[0]= greys

				for( col in colors){
					var color = colors[col];
					var vars = [{h:color,s:saturation,b:brightness}];

					if (color){
						for (i in sat_koef){
							ds = saturation * sat_koef[i]
							db = brightness * br_koef[i]

							if (i < 2){ // lights
								dsat = ds * lights /100
								dbri = db* lights /100

							}else{// shadows
								dsat = ds * shadows /100
								dbri = db* shadows /100

							}
								sat = saturation - dsat;
								bri = brightness - dbri;

							vars[Number(i)+1] = {h:color,s:sat, b:bri, a:1}
						}
						this.Site.colors.pallette.push( vars)

					}else{
						this.Site.colors.pallette.push(false) ;
					}
				}
			}`
window.Constructor._make_pallette =->
  h = @Site.colors.base
  lights = @Site.colors.lights
  shadows = @Site.colors.shadows
  brightness = @Site.colors.brightness
  saturation = @Site.colors.saturation
  i = @Site.colors.type
  @Site.colors.pallette = []
  s = undefined
  a = undefined
  A = undefined

  # // // // console.log(i,h,s,a,A, this.Site.colors)
  switch i
    when "mono"
      s = a = A = false
    when "complement"
      s = (h + 180) % 360
      a = A = false

    #return hsvToRgb(a,100,100)
    when "triada"
      s = (h + 120) % 360
      a = (h + (360 - 120)) % 360
      A = false
    when "split-trio"
      s = (h + 150) % 360
      a = (h + (360 - 150)) % 360
      A = false
    # return hsvToRgb(a,100,100)
    when "analogous"
      s = (h + 30) % 360
      a = (h + (360 - 30)) % 360
      A = false
    # return hsvToRgb(a,100,100)
    when "accent"
      s = (h + 30) % 360
      a = (h + (360 - 30)) % 360
      A = (h + 180) % 360
  # return hsvToRgb(a,100,100)
  sat_koef = [0.89, 0.5, 0.5, 0.01]
  br_koef = [0.05, 0.05, 0.45, 0.3]
  colors = [h, s, a, A]
  # console.log("COLORS", colors)
  greys = new Array()
  am = 5
  c = 0
  while c <= am
    _c =
      h: 0
      s: 0
      b: c * (100 / am)
      a: 1

    greys.push _c
    c++
  @Site.colors.pallette[0] = greys
  #log("LOGGIN COLOR", colors)

  for col of colors
    color = colors[col]
    vars = [
      h: color
      s: saturation
      b: brightness
    ]

    if color
      for i of sat_koef
        ds = saturation * sat_koef[i]
        db = brightness * br_koef[i]
        if i < 2 # lights
          dsat = ds * lights / 100
          dbri = db * lights / 100
        else # shadows
          dsat = ds * shadows / 100
          dbri = db * shadows / 100
        sat = saturation - dsat
        bri = brightness - dbri
        vars[Number(i) + 1] =
          h: color
          s: sat
          b: bri
          a: 1
      @Site.colors.pallette.push vars
    else
      @Site.colors.pallette.push false

window.Constructor._draw_css_background =(to, css_pattern) ->

  # var preview = to
  sizes = []
  poss = []
  grads = []
  $.each css_pattern.gradients, (ix, grad) =>
    stops = []

    # need two color stops at least
    return  if grad.stops.length < 2
    $.each grad.stops, (ix, st) =>
      # log(st)
      rgba = hsvToRgb(st.col) unless st.col_ix?
      if st.col_ix?
        hsva = @get_color(st.col_ix)
        hsva.a = st.a
        rgba = hsvToRgb(hsva)
      s = rgba + " " + st.size.v + st.size.m
      stops.push s

    if grad.type is "linear"
      is_safari = /Safari/.test( navigator.userAgent ) and not /Chrome/.test(navigator.userAgent)
      is_mobile = /Mobile/.test(navigator.userAgent)
      if is_safari or is_mobile
        deg = (360 - (grad.deg - 90)) % 360
        gr = "-webkit-linear-gradient(" + deg + "deg, " + stops.join(", ") + ")"
      else
        gr = "linear-gradient(" + grad.deg + "deg, " + stops.join(", ") + ")"
    else
      position = grad.rad_w.v + grad.rad_w.m + " " + grad.rad_h.v + grad.rad_h.m
      size = "circle at " + grad.rad_l.v + grad.rad_l.m + " " + grad.rad_t.v + grad.rad_t.m
      gr = "radial-gradient(" + size + ", " + stops.join(", ") + ") \t" + position
    grads.push gr
    poss.push grad.pos[0].v + grad.pos[0].m + " " + grad.pos[1].v + grad.pos[1].m
    sizes.push grad.size[0].v + grad.size[0].m + " " + grad.size[1].v + grad.size[1].m

  to.css

    "background": grads.join(",")
    "background-size": sizes.join(", ")
    "background-position": poss.join(", ")



window.Constructor.redraw_background = ->

  #log( "BGs", @Site.backgrounds )
	if @Site.backgrounds?
		$.each @Site.backgrounds, (name, imgo) =>
			if name is "body"
				C = $("body")
			else C = @layout_cont  if name is "content"
			if imgo.type is "pattern"
				#console.log window.PATTERNS? , imgo.pattern of window.PATTERNS
				if window.PATTERNS? and imgo.pattern of window.PATTERNS
					patt = window.PATTERNS[imgo.pattern]
				else
					patt = DB.get_objects('generic.' + BASE_SITE , 'pattern', {'_id': {'$oid':imgo.pattern }}).objects[0]
				if typeof patt is "undefined"
					C.css "background-image", ""
					return
				if patt.type is "image"
					pat = patt.image
					C.css "background", "url(\"" + pat + "\") repeat"

				else if patt.type is "constructor"
					if not isCanvasSupported()
						C.css "background", "url(\"" + patt.image + "\") repeat"
					else
						@renderPattern C, patt
				else
					pat = patt.image
					@_draw_css_background C, pat
			else if imgo.type is "color"
				c = @get_color(imgo.color)
				
				C.css "background", hsvToRgb(c)
			else C.css "background", ""  if imgo.type is "none"


window.Constructor.draw_color_chooser = (onSelectColor) ->
  color_chooser = $("<div>").css("position", "absolute").css("background-color", "white").css("border", "1px solid black")
  .css("padding", "10px")
  .width(500).zIndex(10000).draggable(scroll: false)
  self = this
  @_make_pallette()
  $.each @Site.colors.pallette, (l, vars) ->
    b = undefined
    if l is 0

      # Сначала серые - 6 градаций черный - (4 серых) - белый
      $.each vars, (i, col_) ->
        col_.a = 1  if typeof col_.a is "undefined"
        col = hsvToRgb(col_)
        self.__b = $("<div>").css("float", "left").width(100).height(100).appendTo(color_chooser)  if i is 0
        $("<button>").css("padding", "0").css("border", "0").css("display", "block").css("background-color", col).css("float", "left").width(100).height(100 / 6).appendTo(self.__b).click (evt) ->
          color_chooser.remove()
          onSelectColor col,
            v: l
            ix: i
          , col_

          evt.preventDefault()
          evt.stopPropagation()


    else
      $.each vars, (i, col_) ->
        col_.a = 1  if typeof col_.a is "undefined"
        col = hsvToRgb(col_)
        if i is 0
          self.__b = $("<div>").css("float", "left").width(100).height(100).appendTo(color_chooser)
          self.__main = $("<button>").css("padding", "0").css("border", "0").css("display", "block").css("background-color", col).css("float", "left").width(100).height(50).click((evt) ->
            color_chooser.remove()
            onSelectColor col,
              v: l
              ix: i
            , col_

            evt.preventDefault()
            evt.stopPropagation()
          )
        else
          self.__main.appendTo self.__b  if i is 3
          $("<button>").css("padding", "0").css("border", "0").css("display", "block").css("background-color", col).css("float", "left").width(50).height(25).appendTo(self.__b).click (evt) -> # console.log(col);
            onSelectColor col,
              v: l
              ix: i
            , col_
            evt.preventDefault()
            evt.stopPropagation()

            color_chooser.remove()

  $('<div>').css('clear','both').css('display','block').appendTo color_chooser
  customs = $("<div>").css("float", "left").width(200).height(200).appendTo(color_chooser)
  $("<div>").text("Custom colors").width(200).height(25).appendTo customs
  if @Site.colors.custom_pallette?
    $.each @Site.colors.custom_pallette, (l, vars) ->
      vars.a = 1  if typeof vars.a is "undefined"
      col = hsvToRgb(vars)
      tr = $("<div>").css("background", "url(/static/images/bar-opacity.png) repeat").width(25).height(25).css("float", "left").appendTo(customs)
      $("<button>").css("padding", "0").css("border", "0").css("display", "block").css("background-color", col).width(25).height(25).appendTo(tr).click (evt) -> # console.log(col);
        onSelectColor col,
          v: "C"
          ix: l
        , vars
        evt.preventDefault()
        evt.stopPropagation()

        color_chooser.remove()


  $("<div>").css("clear", "both").appendTo color_chooser
  butts = $("<div>").appendTo(color_chooser).css("border-top", "1px solid black").css("margin-top", "20px")
  $("<input>").attr("value", "Закрыть").button().appendTo(butts).click ->
    color_chooser.remove()

  $("<input>").button().text("Другой цвет").appendTo(butts).attr("value", "Выбрать другой цвет").button().colorpicker
    inline: false
    alpha: true
    colorFormat: "RGBA"
    ok: (evt, color) ->
      hsv = color.hsv
      hsv.s = hsv.s * 100
      hsv.b = hsv.v * 100
      hsv.h = hsv.h * 360
      hsv.a = color.a
      delete hsv.v

      #console.log hsv
      #console.log("BEFORE", self.Site.colors.custom_pallette)
      if self.Site.colors.custom_pallette?
        self.Site.colors.custom_pallette.push hsv
      else
        self.Site.colors.custom_pallette = [hsv]
      #console.log("AFTER", self.Site.colors.custom_pallette)
      ix = self.Site.colors.custom_pallette.length - 1
      color_chooser.remove()
      #console.log( "Index", ix )
      onSelectColor color.formatted,
        v: "C"
        ix: ix
      , hsv

  color_chooser

_stepping_left = `function (left){
				// // // console.log(
				var sm = 10000000,
					ls = {};
				for(var i =0; i< this.layout.cols; i++){
					var ll	 = this._calc_left(i+1);
					var d	 = Math.abs(left - ll);
					if (d < sm){
						sm = d;
					}
					ls[d] = {val:ll, block:i }
				}
				//// // console.log("LEFT", left, ls[sm] );
				return ls[sm];
			}`
window.Constructor._stepping_left = _stepping_left




_stepping_top = `function (w){
				var ws = {},
					sm= 1000000;
				for (var i =0; i < this.Site.layout.drawen_lines; i++){

					var ww = this._calc_top(i)
					var d = Math.abs(w-ww)
					if (d< sm){
						sm = d;
					}
					ws[d] = {val:ww,block:i}
				}
				return ws[sm]
			}`
window.Constructor._stepping_top = _stepping_top




_stepping_height = `function (w){
				var ws = {},
					sm= 1000000;
				for (var i =0; i < this.Site.layout.drawen_lines; i++){

					var ww = this._calc_height(i+1)
					var d = Math.abs(w-ww)
					if (d< sm){
						sm = d;
					}
					ws[d] = {val:ww,block:i+1}
				}
				return ws[sm]


			}`
window.Constructor._stepping_height = _stepping_height




_stepping_width = `function (w){
				var ws = {},
					sm= 1000000;
				for (var i =0; i< this.layout.cols; i++){

					var ww = this._calc_width(i+1)
					var d = Math.abs(w-ww)
					if (d< sm){
						sm = d;
					}
					ws[d] =	 {val:ww,block:i+1}
				}
				return ws[sm]


			}`
window.Constructor._stepping_width = _stepping_width




_block_width = `function (){
				var base_width =  ((this.layout.width - ( 2 * this.layout.padding.left) ) / this.layout.cols)
				var block_width = (base_width - ( 2 * this.layout.grid.hor ) )

				return block_width

			}`
window.Constructor._block_width = _block_width




_block_left = `function (){

			}`
window.Constructor._block_left = _block_left




_block_height = `function (){
				block_height = this.layout.base_height;
				return block_height;

			}`
window.Constructor._block_height = _block_height




_uncalc_top = `function (T) {
				return  T  / this._block_height();

			}`
window.Constructor._uncalc_top = _uncalc_top




_uncalc_left = `function (L){
				return L / this._block_width();
			}`
window.Constructor._uncalc_left = _uncalc_left




_calc_top = `function (t){
				var h = (this._calc_height(t))
				if (h == 0){ var P =0} else {var P = 2}
				return (h + P*this.layout.grid.ver) ;// + this._main_offset.top;
			}`
window.Constructor._calc_top = _calc_top




_calc_left = `function (l){
				var w = (this._calc_width (l-1) )
				if (l > 1){var P =2 }else{var P=0}
				return (this.layout.padding.left + this.layout.grid.hor  + w + P*this.layout.grid.hor) // + this._main_offset.left;

				// console.log('LL', l)
				//var w = this._calc_width( l-1 ) // Ширина блока учитывается при значениях больше 1 (0,1)
				//return (this.layout.padding.left + w +(this.layout.grid.hor * (l-1)*2))
			}`
window.Constructor._calc_left = _calc_left




_calc_height = `function (h){
				if (this._c_bh){
					cbh = this._c_bh
				}
				else{
					this._c_bh = this._block_height()
					cbh = this._c_bh
				}
				return (cbh * h) + (this.layout.grid.ver *2 * (h-1));


			}`
window.Constructor._calc_height = _calc_height




_calc_width = `function (w){
				if (w <= 0) return 0;
				this._c_bw = this._block_width()
				cbw = this._c_bw
				return (cbw * w) + (this.layout.grid.hor *2 * (w-1) )


			}`
window.Constructor._calc_width = _calc_width

