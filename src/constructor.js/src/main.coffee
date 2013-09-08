
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


hsvToRgb = 	(o, as_array = false ) ->

  # h = o.h, s=o.s, v = o.v
  # Make sure our arguments stay in-range
  h = Math.max(0, Math.min(360, o.h))
  s = Math.max(0, Math.min(100, o.s))
  v = Math.max(0, Math.min(100, o.b))
  v =   if o.b? then o.b else o.v

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




window.hsvToRgb = hsvToRgb
window.hsvToHex = hsvToHex

default_site =
  _Apps : ['generic.'  + BASE_SITE]
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
			     init:function(my_cont,  constructor_inst, pos, cp){
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


class Constructor
  constructor: ->
    @init = (do_constr=false, site_id) ->
      window.DB = init_db( window.csrf )

      @site_id = site_id
      @_site_type = "sites"
      @is_constructor = do_constr
      @page_cont = $('#id-top-cont')
      @default_app = default_app
      $(window).bind 'resize' , => @redraw()

      window.onhashchange= =>
        @_init_page()
        @redraw()
      if @is_constructor
        @init_cp_marker()
      @redraw()


window.Constructor = new Constructor();

$(document).bind "ready", (e) =>
    window.Constructor.init window.is_constructor, window.site_id

window.WidgetIniter = ->
	@default_size = [3, 1]
	@disobey = []
	@redraw = ->
	    @my_cont.find("*").remove()
	    @draw()

	@_data = ->

	    #console.log(">>>>",this.data);
	    (if @data then @data else @_def_data)

	@init = (my_cont, constructor_inst, pos, cp) ->
	    @set = constructor_inst.getBlockSettings(pos)
	    @data = constructor_inst.getWidgetData(pos)
	    @my_cont = my_cont
	    @pos = pos
	    @constructor_inst = constructor_inst
	    @C = constructor_inst
	    this

	@draw = ->
	    @apply_block_settings()
	    @_draw()

	@save = ->
	    @_save()  if @_save
	    @C.setWidgetData @pos, @data
	    @C.setBlockSettings @pos, @set

	@cancel = ->
	    @_cancel()  if @_cancel

	@settings = (cp) ->
		  @_init_block_cp cp
		  @_settings cp  if @_settings?
		  console.log("Wot")
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
	      value: self.set.line_height
	      slide: (event, ui) ->
	        self.set.line_height = ui.value / 10
	        self.apply_block_settings()
	    ).appendTo(li)
	    li = $("<li>").appendTo(ul)
	    $("<span>").text("Размер шрифта").appendTo li
	    $("<div>").width(250).slider(
	      min: 0
	      max: 300
	      value: self.set.font_size
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
    
	        #console.log('save')
	        self.C.setBlockSettings obj.pos, self.set

	      cancel: ->

	    o

	@apply_block_settings = ->
		C = @my_cont.parent()
		border_color = ->
		  if @set.border_color?

		    #console.log(this.set.border_color)
		    if typeof @set.border_color is "string"
		      C.css "border-color", @set.border_color
		    else
		      color = @C.get_color(@set.border_color)
		      c = hsvToRgb(color)
		      C.css "border-color", c

		opacity = ->
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
		      c = hsvToRgb(color)
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
		  C.css "color", hsvToRgb(@C.get_color(@set.text_color))  if @set.text_color

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


		# console.log(this.set);
		for k of appl
		  f = appl[k]

		  # console.log(k)
		  if @do_not_apply?
		    f.apply this  if @do_not_apply.indexOf(k) is -1
		  else
		    f.apply this
		# console.log (@)
		@_draw()  if @need_redraw

	
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
        this.data     = constructor_inst.getWidgetData(pos)
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
          self.C.Site.blocks[self.pos].height = Math.round(self.C.Site.blocks[self.pos].height  / self.C._block_height())
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
        var  border_radius = function(){
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
