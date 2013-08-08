
log = `function(){
			if (DEBUG){
				var E = new Error();
				var f = E.stack.split('\n')[1].split('@')[0];
				var a = E.stack.split('\n')[1].split(':');

				var ln = parseInt(a[a.length-1])
				args = ['[' +f +':'+ln +']'];
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
		BASE_SITE = 'main.be-we.ru'

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

window.hsvToRgb = hsvToRgb

default_site =
  _Apps : ['generic.'  + BASE_SITE, 'theshop.' + BASE_SITE]
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
        is_removable: true

      "about":
          layout:'same'
          title:"About"
          is_removable: true
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



class Constructor
  constructor: ->
    @init = (do_constr=false, site_id) ->
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

# END of Main.coffee


window.Constructor.redraw = -> # Done
        @clear();
        @draw();
window.Constructor.clear = ->
        @page_cont.find( "*").remove()
        $("#controls>.widget-control").remove()

window.Constructor.draw= (custom_cont = @page_cont, custom_head=$('head'), custom_hash) -> #Done
      log("CH", custom_hash)
      if custom_hash
        @_init_page custom_hash.slice(1), custom_head
      else
        @_init_page()
      @init_grid(custom_cont, custom_head)

window.Constructor._init_page = (hash_ = window.location.hash.slice(1).split('?'), head = $('head') ) -> #Done
  @page_vars= {} if not @page_vars?
  page_name = hash_[0].replace('!','')
  params = if hash_[1]?
      hash_[1]
    else ""
  @current_page = page_name
  pdata = @getPageData(page_name)
  #log(pdata)
  if  pdata.params
    for p, val of pdata.params
      do (p, val) =>
        log(@, p, val)
        @page_vars[p] = val

  #log('c')
  t = head.find('title')
  if not t.length
    t = $('<title>').appendTo head
  @head_tag = head
  # log (@head_tag)
  @_set_description  pdata.description
  @_set_keywords pdata.keywords
  t.text (pdata.title + '|' + @Site.seo.title)
  head.append(@Site.seo.metas.yandex) if @Site.seo.metas.yandex
  head.append(@Site.seo.metas.google) if @Site.seo.metas.google
  if params
    a = params.split('&')
    for p in a
      do (p) =>
        log(p)
        _p = p.split('=')
        name = _p[0]
        val =  _p[1]
        if name and val
          @page_vars[name] = val
  # log("FFF", @page_vars)
  @layout = @Site.layout
  @base_height = @layout.base_height
  @inited_blocks = []



window.Constructor.getPageData = ( page_name ) -> # DOne
  @load_site();
  # log(page_name,this.Site.pages[page_name]);
  @Site.pages[page_name]
  #log(@Site.pages, page_name)


window.Constructor.load_site = (do_reload = false ) -> #done
  log( not @Site? or  do_reload )

  if   not @Site? or do_reload
    S = DB.get_objects("generic." + BASE_SITE, this._site_type, {} )
    if S.total_amount isnt 0
      @Site = S.objects[0];
      if not @Site.layout.grid?
        @Site.layout.grid = this.Site.layout.padding
        @Site.layout.padding = {top:50, left:10}
    else
      @Site = default_site

    apps_ = {}
    for app_name in @Site._Apps
      do (app_name) =>
        app = @getApp(app_name)
        if app
          apps_[app_name] = app

    #log(apps_);
    @Site['Applications'] = apps_;

    delete @Site.version
    @page_order_index = {};
    @page_amount = 0
    for i,page in @Site.pages
      @page_order_index[page.order] = i
      @page_amount +=1




window.Constructor.getAppJson = (name) ->
    xhr = $.ajax({url: window.get_application_url + name + "/",async: false})
    log(xhr.status)
    if xhr.status is 200
      JSON.parse(xhr.responseText)
    else false



window.Constructor.getApp = (name) ->
  app_egg = @getAppJson name
  if app_egg
    #app_egg = JSON.parse(scr)
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
window.Constructor.getBlockSettings = getBlockSettings




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
				var H  = this.head_tag;
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
				var H  = this.head_tag;
				var d = H.find('meta[name=description]');

				if(d.length){
				}else{
					d = $('<meta>').appendTo(H).attr('name','description');
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








get_color = `function (c){
				this._make_pallette()
				console.log(this.Site.colors, c)
				if (c.v == 'C') {// color from custom palette
					return this.Site.colors.custom_pallette[c.ix]

				}else{
					return this.Site.colors.pallette[c.v][c.ix]
				}


			}`
window.Constructor.get_color = get_color



###
    set_colors = (c) =>
    s = "<style id='a_stylo'>
  {{#link_color}}a:link {color: {{link_color}} }  {{/link_color}}
  {{#text_color}}body   {color: {{text_color}} }  {{/text_color}}
  {{#visited_color}}a:visited {color: {{visited_color}} }  {{/visited_color}}
  {{#active_color}}a:active {color: {{active_color}} }  {{/active_color}}
  {{#hover_color}}a:hover {color: {{hover_color}} }  {{/hover_color}}

    </style>"
    lc = {}
    for k in ["text_color", "link_color", "visited_color", "active_color", 'hover_color']
      if c[k]?
        lc[k] = hsvToRgb(@get_color(c[k]))
      else
        lc[k] = defaults[k]
    #$('head').find('#a_stylo')

    $('head').html(Mustache.render(s,lc))
###


###

init_grid = `function ( to, head ){
        // log(to,head);
				var block_width = this._block_width();
				var base_height = this.layout.base_height;
				var self = this;

				if (this.layout.fixed){
					var e = "px"
				}else{
					var e = '%'
				}

				$('body').css('margin', 0)

				var total_height = this.Site.layout.drawen_lines * (this.Site.layout.base_height + 2*(this.Site.layout.grid.ver)) ,
					window_width = window.innerWidth,
					width = this.Site.layout.width,
					w_left = window_width - width,
					left = w_left / 2;

				log("TOTAL", this.Site)
				this.layout_cont = $("<div>")
					.css('position', 'absolute')

					.css('width', this.layout.width + e)
					// .css('margin-left','auto')
					.css('top', this.Site.layout.padding.top)
					.css('left', left )
					.css('height', total_height)
					// .css('margin-right','auto')
					.appendTo(to)
				c_off = this.layout_cont.offset();
				to.css('top', '0px');





				// console.log("OFFSET", c_off)
				this._main_offset = c_off;

				this.redraw_background();
				this._busy_regions = [];
				this._moved_block_ = [] ;


				//console.log(this.Site.blocks)
				var bw = self._block_width(1);
				var bh = self._block_height(1);
				var bhp = self.Site.layout.grid.hor;
				var bvp = self.Site.layout.grid.ver;
				var gw = bw + (bhp * 2);
				var gh = bh + (bvp * 2);
				var gp = self.Site.layout.padding.left;
				//var gvvp = self.Site.layout.padding.t
				var gmp =  (gp - ( bhp * 2 ))
				if(this.is_constructor){
					var gridd = $('<div>')
					.addClass('empty-block')
					.appendTo(this.layout_cont)
					.css('position', 'absolute')
					// .css('border-radius', '10px')
					.css('background-color','white')
					.css('background','linear-gradient(90deg, rgba(0,0,0,.5) 1px, transparent 1px),'+
				 					  'linear-gradient(90deg, rgba(255,255,255,.5) 2px, transparent 1px),'+

									  'linear-gradient(90deg, rgba(255,255,255,.5) 2px, transparent 1px),' +
									  'linear-gradient(90deg, rgba(0,0,0,.5) 1px, transparent 1px),'+
									  // now verticals
									  'linear-gradient(rgba(0,0,0,.5) 1px, transparent 1px),'+
									  'linear-gradient(rgba(255,255,255,.5) 2px, transparent 1px),'+

									  'linear-gradient(rgba(255,255,255,.5) 2px, transparent 1px),'+
									  'linear-gradient(rgba(0,0,0,.5) 1px, transparent 1px)'

								  )
					.css('background-size',gw +'px 1px,  '+gw+'px 1px,  '+gw+'px 1px,  '+gw+'px 1px, 1px '+gh+'px, 1px '+gh+'px, 1px '+gh+'px, 1px '+gh+'px  ')
					.css('background-position', gp + 'px 0px, '+ (gp + 1) +'px 0px, '+gmp+'px 0px, '+(gmp + 1)+'px 0px, 0px 0px,0px 1px, 0px -'+(bvp*2)+'px,0px -'+((bvp*2)-1)+'px' )
					//.css('opacity','0.7')
					.css('left',0)
					.css('top',0)
					// .css('border', '1px solid black')
					.css('width', this.Site.layout.width )
					.css('height', total_height )
					//.zIndex(-100)
				}


				$.each(this.Site.blocks, function(ix, block){
					if(block.display_on == 'all'){
						//console.log(block.dont_display_on , self.current_page)
						if (block.dont_display_on.indexOf(self.current_page) != -1 ){
							//console.log('do not display it', ix)
							return
						}
					}else if(block.display_on != self.current_page)
					{
						return
					}


					var set = self.getBlockSettings(ix)
					//console.log("IG",set)

					var bw = set ? set.border_width : 0
					var x = block.x; //Number(koords.split(':')[0]);
					var y = block.y; // Number(koords.split(':')[1]);
					if(!(set.unsnap_to_grid)){
						//console.log('orig', x,y)
						var xx = self._calc_left(x+1) - bw;
						var yy = self._calc_top(y)	- bw;
					}else{
						//self.move_block(ix, 0, 0)
						//consmoveole.log('my', x,y)
						var xx = x;
						var yy = y;

					}
					//console.log("XX", xx,yy, self._calc_left(2), self._calc_top(5) )

					var w = block.width;
					var h = block.height;
					if(!(set.unsnap_to_grid))
					{
						var W = self._calc_width(w);
						var H = self._calc_height(h);

					}else{

						var W = w;
						var H = h;
						// console.log(W,H)

					}
					// console.log(block_list);
					var gp = { jq : $("<div>")
										.appendTo(self.layout_cont)
										.css('position','absolute')
										.css('left', xx ).css('top',yy)
										.width(W).css('height',H)
										.css('overflow','hidden'),

							 pos: ix
						}
					self.init_block(block, gp)
				})
			}`
###
window.Constructor.getTextColors = ->
  colors = if not @Site.textColors? then {} else @Site.textColors
  defaults =
    text_color : "rgb(0,0,0)"
    link_color : "#0000ff"
    visited_color : "#800080"
    active_color : "#ff0000"
    hover_color  : "#0000ff"
  lc = {}
  #log('W', @Site.textColors, colors)
  for k in ["text_color", "link_color", "visited_color", "active_color", 'hover_color']

    if colors[k]? and colors[k].index?
      lc[k] = hsvToRgb(@get_color(colors[k].index))
    else
      lc[k] = defaults[k]
  log("FINAL", lc)
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
  #log "TOTAL", @Site

  # .css('margin-left','auto')

  # .css('margin-right','auto')
  @layout_cont = $("<div>").css("position", "absolute").css("width", @layout.width + e).css("top", @Site.layout.padding.top).css("left", left).css("height", total_height).appendTo(to)
  c_off = @layout_cont.offset()
  to.css "top", "0px"

  # console.log("OFFSET", c_off)
  @_main_offset = c_off
  @redraw_background()
  @_busy_regions = []
  @_moved_block_ = []

  #console.log(this.Site.blocks)
  bw = self._block_width(1)
  bh = self._block_height(1)
  bhp = self.Site.layout.grid.hor
  bvp = self.Site.layout.grid.ver
  gw = bw + (bhp * 2)
  gh = bh + (bvp * 2)
  gp = self.Site.layout.padding.left

  #var gvvp = self.Site.layout.padding.t
  gmp = (gp - (bhp * 2))

  # .css('border-radius', '10px')


  #log head.find('#a_stylo').length
  ###

  if head.find('#a_stylo').length is 0
    colors = @getTextColors()
    s = """<style id='a_stylo'>
    {{#link_color}}A:link {color: {{link_color}}; };  {{/link_color}}
    {{#text_color}}#id-top-cont *  {color: {{text_color}} !important; };  {{/text_color}}
    {{#visited_color}}A:visited {color: {{visited_color}}; };  {{/visited_color}}
    {{#active_color}}A:active {color: {{active_color}}; };  {{/active_color}}
    {{#hover_color}}A:hover {color: {{hover_color}}; };  {{/hover_color}}

      </style>"""

    s = Mustache.render(s,colors)
    #log("STYLE", s)
    head.append(s)
  ###



  # now verticals

  #.css('opacity','0.7')

  # .css('border', '1px solid black')
  gridd = $("<div>").addClass("empty-block").appendTo(@layout_cont).css("position", "absolute").css("background-color", "white").css("background", "linear-gradient(90deg, rgba(0,0,0,.5) 1px, transparent 1px)," + "linear-gradient(90deg, rgba(255,255,255,.5) 2px, transparent 1px)," + "linear-gradient(90deg, rgba(255,255,255,.5) 2px, transparent 1px)," + "linear-gradient(90deg, rgba(0,0,0,.5) 1px, transparent 1px)," + "linear-gradient(rgba(0,0,0,.5) 1px, transparent 1px)," + "linear-gradient(rgba(255,255,255,.5) 2px, transparent 1px)," + "linear-gradient(rgba(255,255,255,.5) 2px, transparent 1px)," + "linear-gradient(rgba(0,0,0,.5) 1px, transparent 1px)").css("background-size", gw + "px 1px,  " + gw + "px 1px,  " + gw + "px 1px,  " + gw + "px 1px, 1px " + gh + "px, 1px " + gh + "px, 1px " + gh + "px, 1px " + gh + "px  ").css("background-position", gp + "px 0px, " + (gp + 1) + "px 0px, " + gmp + "px 0px, " + (gmp + 1) + "px 0px, 0px 0px,0px 1px, 0px -" + (bvp * 2) + "px,0px -" + ((bvp * 2) - 1) + "px").css("left", 0).css("top", 0).css("width", @Site.layout.width).css("height", total_height)  if @is_constructor

  #.zIndex(-100)
  $.each @Site.blocks, (ix, block) ->
    if block.display_on is "all"

      #console.log(block.dont_display_on , self.current_page)

      #console.log('do not display it', ix)
      return  unless block.dont_display_on.indexOf(self.current_page) is -1
    else return  unless block.display_on is self.current_page
    set = self.getBlockSettings(ix)

    #console.log("IG",set)
    bw = (if set then set.border_width else 0)
    x = block.x #Number(koords.split(':')[0]);
    y = block.y # Number(koords.split(':')[1]);
    unless set.unsnap_to_grid

      #console.log('orig', x,y)
      xx = self._calc_left(x + 1) - bw
      yy = self._calc_top(y) - bw
    else

      #self.move_block(ix, 0, 0)
      #consmoveole.log('my', x,y)
      xx = x
      yy = y

    #console.log("XX", xx,yy, self._calc_left(2), self._calc_top(5) )
    w = block.width
    h = block.height
    unless set.unsnap_to_grid
      W = self._calc_width(w)
      H = self._calc_height(h)
    else
      W = w
      H = h

    # console.log(W,H)

    # console.log(block_list);
    gp =
      jq: $("<div>").appendTo(self.layout_cont).css("position", "absolute").css("left", xx).css("top", yy).width(W).css("height", H).css("overflow", "hidden")
      pos: ix

    self.init_block block, gp






apply_block_settings = `function (obj, settings, widget){
				//console.log("HHHHH", obj)
				var w = obj.jq,
				bl = this.get_block(obj.pos);
				if(widget.disobey.indexOf('border_color') == -1){
					if(typeof settings.border_color == 'string'){
						w.css('border-color', settings.border_color);
					}else{
						if (typeof settings.border_color == 'undefined'){
							settings.border_color = {v:0, ix:0}
						}
						// console.log('border-color', settings.border_color)
						var color = this.get_color(settings.border_color)
						var c = hsvToRgb(color);
						w.css('border-color', c);
					}

				}

				if(widget.disobey.indexOf('bg_opacity') == -1)w.css('opacity', settings.bg_opacity);
				if(widget.disobey.indexOf('border_radius')== -1 )w.css('border-radius', settings.border_radius +'px')
				if(widget.disobey.indexOf('border_width') == -1){
					if(!(settings.unsnap_to_grid)){
						var xx = this._calc_left(bl.x+1) - settings.border_width
						var yy = this._calc_top(bl.y) - settings.border_width
					}else{
						var xx = bl.x
						var yy = bl.y

					}
					w.css('border-width', settings.border_width +'px')
					w.css('left',  xx)
					w.css('top',  yy)
					w.css('border-style','solid')

				}

				if(widget.disobey.indexOf('line_height') == -1)w.css('line-height', settings.line_height +'px')
				if(widget.disobey.indexOf('font_size') == -1)w.css('font-size', settings.font_size +'px')

				if(widget.disobey.indexOf('padding_left_right') == -1){
					C = w.children().eq(0);
					W = w.width();

					C.css('margin-left',settings.padding_left_right +'px')
					C.css('margin-right',settings.padding_left_right +'px')
					C.width( W - settings.padding_left_right * 2)
				}

				if(widget.disobey.indexOf('padding_top') == -1)C.css('padding-top',settings.padding_top +'px')
				if (settings.background.type == 'color'){
					if(widget.disobey.indexOf('background_color') == -1){
						if(typeof settings.background.color == 'string'){
							w.css('background' , settings.background.color );
						}else{
							var color = this.get_color(settings.background.color)
							var c = hsvToRgb(color);
							w.css('background', c);
						}
					}
				}else if(settings.background.type == 'none'){
							w.css('background', '');
				} else if(settings.background.type == 'pattern'){
					patt = settings.background.pattern
					if (['image', 'constructor'].indexOf(patt.type ) != -1){
						w.css('background', 'url(' + patt.image +' ) repeat' )
					}else{
						this._draw_css_background(w, patt.image);
					}

				}

			}`
window.Constructor.apply_block_settings = apply_block_settings







window.Constructor.init_block = (bl, to) ->

  # console.log (bl)

  # console.log(W,H)
  init_resizer = ->
  newWidget = (c, t, p, cp) ->

    #log("New widget", t.Site.Applications, widget_name,app_name );
    t.Site.Applications[app_name].widgets[widget_name].init c, t, p, cp
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
  w = $("<div>").css("width", to.jq.width()).css("height", to.jq.height()).appendTo(to.jq).addClass("draggable-module")
  draga = undefined
  Widget = newWidget(w, this, to.pos)
  #log( widget_name, app_name)
  Widget.draw()
  settings = self.getBlockSettings(to.pos)

  #console.log("B", w.width() )
  self.apply_block_settings to, settings, Widget
  if settings.unsnap_to_grid
    W = bl.width
    H = bl.height

  # console.log("WH", W,H)
  if @is_constructor
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
        unless settings.unsnap_to_grid
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


  #console.log("A", w.width() )
  if @is_constructor
    to.jq.dblclick ->
      for blix of self.inited_blocks
        bl = self.inited_blocks[blix]
        bl.unbind "click"

      #bl.mouseleave();
      #bl.unbind("mouseleave")
      $("#controls>.widget-control").hide()
      to.jq.draggable "destroy"

      # console.log("CLICK UNBIND")
      control_panel = $("<div>").appendTo($("#controls"))

      # console.log(w)
      control_panel.css("position", "absolute").position(
        of: w
        my: "left top"
        at: "right top"
        collision: "none none"
      ).css("border", "2px solid black").css("background-color", "white").draggable(scroll: false).css "padding", "10"
      wco = self.init_block_cp(to, control_panel, Widget)
      Widget.settings control_panel  if Widget.settings
      $("<div>").css("background-color", "orange").appendTo(to.jq).css("position", "absolute").position(
        of: to.jq
        my: "left top"
        at: "right top"
        collision: "none"
      ).addClass("ui-icon ui-icon-gripsmall-diagonal-se").width(20).height 20
      $("<div>").css("background-color", "green").appendTo(to.jq.parent()).css("position", "absolute").position(
        of: to.jq
        my: "left top"
        at: "left-20 top"
        collision: "none none"
      ).addClass("ui-icon ui-icon-gripsmall-diagonal-se").width(20).height(20).click ->
        Widget.save()  if Widget.save
        wco.save()
        self._save_site()
        self.redraw.apply self, []
        control_panel.remove()

      $("<div>").css("background-color", "red").appendTo(to.jq.parent()).css("position", "absolute").position(
        of: to.jq
        my: "left top"
        at: "left-20 top+30"
        collision: "none none"
      ).addClass("ui-icon ui-icon-gripsmall-diagonal-se").width(20).height(20).click ->
        Widget.cancel()  if Widget.cancel
        control_panel.remove()
        self.redraw.apply self, []


    mouseWidth = W
    mouseHeight = H
    start_x = undefined
    start_y = undefined

    # .css('cursor', 'se-resize')

    #.position({of:to.jq, my:"right top", at:"right-20 top"})
    delete_marker = $("<div>").appendTo($("#controls")).css("position", "absolute").addClass("delete-marker widget-control").css("background-color", "blue").css("border-radius", "5px").css("border", "1px solid black").addClass("ui-icon ui-icon-closethick").width("20px").height("20px").hide().click(->
      self.delete_block to.pos
      self.redraw.apply self, []
    )

    # .position({of:to.jq, my:"right top", at:"right bottom", collision:'none none'})

    # .css('padding', '')

    #console.log("FALSE")
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

        #console.log("FFF")
        if self.resize_frame
          self.resize_frame.remove()
          self.resize_frame = false
          self.Site.blocks[to.pos].width = mouseWidth
          self.Site.blocks[to.pos].height = mouseHeight

          #console.log('redraw')
          self.redraw.apply self, []


      #console.log('move evtnt')
      to.jq.parent().mousemove((evt) ->
        fr = self.resize_frame
        if fr
          if fr.size()
            nh = evt.clientY - start_y + H
            nw = evt.clientX - start_x + W
            unless settings.unsnap_to_grid
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

    #console.log("top", p , h , mh, "left",	w , mw)
    resize_marker.css "top", po.top + o.top + he - mh
    resize_marker.css "left", po.left + o.left + wi - mw
    delete_marker.css "top", po.top
    delete_marker.css "left", po.left + o.left + wi - mw
    to.jq.click (e) ->
      $("#controls>.widget-control").hide()

      #$('#controls>.resize-marker').hide()
      delete_marker.show().zIndex 1000
      resize_marker.show().zIndex 1000


  # var left = p.left + o.left
  # var top= p.top + o.top
  # var within_x = e.pageX >= left+15 && e.pageX <= left + w;
  # var within_y = e.pageY >= top+15 && e.pageY <= top + h;
  #console.log(e.pageX >= left , e.pageX , left + w, within_y)
  #if( within_x && within_y){
  #	 resize_marker.show()

  #	 resize_marker
  #	delete_marker
  #	delete_marker.show()

  #	}else{
  #	resize_marker.hide();
  #		delete_marker.hide();
  #	}
  to.jq








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
					if( is_done ){ // все процессы отработали
						DB.save_cache(hashes)
						is_saved = true
					}else{
						setTimeout(perform_caching, 1000);
					}

				}

				var render_page = function(hash){
					if(hash in hashes){ return }

					active_renderers[hash] = true;
					var custom_cont = $('<div>');
					var custom_head = $('<div>');
					var content, head_content;
					try{
						self.is_constructor = false;
						self.draw(custom_cont, custom_head, hash)
						self.is_constructor = true;
					}finally{
						self.is_constructor = true
						// throw
					}




					setTimeout(function(){
						var content = custom_cont.html();
						var head_content = custom_head.html();
						var link_list = [];
						var as = custom_cont.find('a');
						$.each(as, function(ix, a){
							 var h = "#" + $(a).prop('href').split('#')[1]
							 if(typeof h == 'undefined' || h == 'undefined'){
							 }
							 render_page(h);
						})
						custom_cont.remove();
						var h = $('<html>')
						var b = $('<body>')
						.prop('style', body_style.cssText)
						.html(content).appendTo(h)

						hashes[hash] = {'body':h.html(), head:head_content}
						active_renderers[hash] = false;
					}, 5000)
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
window.Constructor._make_pallette = _make_pallette
###

_draw_css_background = `function (to, css_pattern) {
				// var preview = to
				var sizes = [];
				var poss  = [];
				var grads = [];
				$.each(css_pattern.gradients, function(ix, grad){
					var stops = [];

					if(grad.stops.length <2){
						// need two color stops at least
						return;
					}
					$.each(grad.stops, function(ix, st){
						var rgba = hsvToRgb(st.col)
						var s = rgba + ' ' + st.size.v + st.size.m;
						stops.push(s);

					})

					if(grad.type == 'linear'){
						var gr = 'linear-gradient('+grad.deg+'deg, ' + stops.join(', ') +')'
					}else{
						var position = grad.rad_w.v + grad.rad_w.m + ' ' + grad.rad_h.v + grad.rad_h.m;
						var size = 'circle at '+grad.rad_l.v + grad.rad_l.m + ' ' + grad.rad_t.v + grad.rad_t.m;
						var gr = 'radial-gradient('+ size+', '+ stops.join(', ') +') 	' + position
					}
					grads.push(gr)
					poss.push(grad.pos[0].v + grad.pos[0].m +' ' + grad.pos[1].v + grad.pos[1].m)
					sizes.push(grad.size[0].v + grad.size[0].m +' ' + grad.size[1].v + grad.size[1].m)
				})

				to.css({
					'background-image': grads.join(',') ,
					'background-size': sizes.join(', '),
					'background-position':poss.join(', ')

				})
			 }`
###
window.Constructor._draw_css_background =(to, css_pattern) ->

  # var preview = to
  sizes = []
  poss = []
  grads = []
  $.each css_pattern.gradients, (ix, grad) ->
    stops = []

    # need two color stops at least
    return  if grad.stops.length < 2
    $.each grad.stops, (ix, st) ->
      rgba = hsvToRgb(st.col)
      s = rgba + " " + st.size.v + st.size.m
      stops.push s

    if grad.type is "linear"
      gr = "linear-gradient(" + grad.deg + "deg, " + stops.join(", ") + ")"
    else
      position = grad.rad_w.v + grad.rad_w.m + " " + grad.rad_h.v + grad.rad_h.m
      size = "circle at " + grad.rad_l.v + grad.rad_l.m + " " + grad.rad_t.v + grad.rad_t.m
      gr = "radial-gradient(" + size + ", " + stops.join(", ") + ") \t" + position
    grads.push gr
    poss.push grad.pos[0].v + grad.pos[0].m + " " + grad.pos[1].v + grad.pos[1].m
    sizes.push grad.size[0].v + grad.size[0].m + " " + grad.size[1].v + grad.size[1].m

  to.css
    "background-image": grads.join(",")
    "background-size": sizes.join(", ")
    "background-position": poss.join(", ")



###
redraw_background = `function (){
				var self = this;
				$.each(this.Site.backgrounds, function(name, imgo){
					if (name == 'body'){
						var C = $('body')
						c = C[0];


					}else if (name == 'content'){
						var C = self.layout_cont;
					}
					if (imgo.type == 'pattern'){
						if( typeof imgo.pattern  == 'undefined'){
							C.css('background-image', '' );
							return
						}
						if (['image','constructor'].indexOf(imgo.pattern.type) != -1){
							var pat = imgo.pattern.image;
							C.css('background', 'url("' + pat +'") repeat' );
						}
						else{
							var pat = imgo.pattern.image
							self._draw_css_background(C, pat);
						}
					}else if(imgo.type == 'color'){
						var c = self.get_color(imgo.color);
						C.css('background', hsvToRgb(c))

					}else if(imgo.type == 'none'){
						C.css('background', '' );
					}

				})
			}`
###
window.Constructor.redraw_background = ->

  log( "BGs", @Site.backgrounds )
  if @Site.backgrounds?
    log("DOne")
    $.each @Site.backgrounds, (name, imgo) =>
      if name is "body"
        C = $("body")
        #c = C[0]
      else C = @layout_cont  if name is "content"
      if imgo.type is "pattern"
        if typeof imgo.pattern is "undefined"
          C.css "background-image", ""
          return
        unless ["image", "constructor"].indexOf(imgo.pattern.type) is -1
          pat = imgo.pattern.image
          C.css "background", "url(\"" + pat + "\") repeat"
        else
          pat = imgo.pattern.image
          @_draw_css_background C, pat
      else if imgo.type is "color"
        c = @get_color(imgo.color)
        C.css "background", hsvToRgb(c)
      else C.css "background", ""  if imgo.type is "none"


###

draw_color_chooser = `function (onSelectColor){
				color_chooser = $('<div>')
				.css('position','absolute')
				.css('background-color','white')
				.css('border', '1px solid black')
				.css('padding', '10px')
				.width(400)
				.zIndex(10000)
				.draggable({scroll:false})
				var self = this;


				this._make_pallette();
				$.each(this.Site.colors.pallette , function(l, vars){
					var b, main
					if (l == 0){
						//console.log(l, vars)
						$.each ( vars, function(i, col_){
							if(typeof col_.a  == 'undefined'){col_.a = 1}
							var col = hsvToRgb(col_);

							 if(i == 0){

								b = $('<div>').css('float','left').width(100).height(100).appendTo(color_chooser)
							}

							$('<button>').css('padding','0').css('border','0').css('display','block').css('background-color', col).css('float','left').width(100).height(100/6).appendTo(b)
							.click(function(evt){
								onSelectColor(col, {v:l, ix:i}, col_ )
								evt.preventDefault(), evt.stopPropagation()
								color_chooser.remove();
							})

						})
					}
					else{
						// console.log(l, vars)
						 $.each ( vars, function(i, col_){
 							if(typeof col_.a  == 'undefined'){col_.a = 1}

							var col = hsvToRgb(col_);
							if(i == 0){
								b = $('<div>').css('float','left').width(100).height(100).appendTo(color_chooser)
								main = $('<button>').css('padding','0').css('border','0').css('display','block').css('background-color', col).css('float','left').width(100).height(50)
								.click(function(evt){
									onSelectColor(col, {v:l, ix:i}, col_ )
									color_chooser.remove();
									evt.preventDefault(), evt.stopPropagation()})
							 }else{
								if(i == 3){
									main.appendTo(b);
								}
								$('<button>').css('padding','0').css('border','0').css('display','block').css('background-color', col).css('float','left').width(50).height(25).appendTo(b)
								.click(function(evt){	// console.log(col);
									onSelectColor(col,{v:l, ix:i}, col_);
									evt.preventDefault(), evt.stopPropagation()
									color_chooser.remove();
								})
							}
						})
					}
				})
				var customs = $('<div>').css('float','left').width(200).height(200).appendTo(color_chooser);
				$('<div>').text('Custom colors').width(200).height(25).appendTo(customs)
				$.each(this.Site.colors.custom_pallette , function(l, vars){
					if(typeof vars.a  == 'undefined'){vars.a = 1}

					var col = hsvToRgb(vars);
					var tr = $("<div>").css('background', "url(/static/images/bar-opacity.png) repeat" )
					.width(25).height(25).css('float','left').appendTo(customs)

					$('<button>').css('padding','0').css('border','0')
					.css('display','block')
					.css('background-color', col)
					.width(25).height(25).appendTo(tr)
					.click(function(evt){	// console.log(col);
						onSelectColor(col, {v:'C', ix:l }, vars );
						evt.preventDefault(), evt.stopPropagation()
						color_chooser.remove();
					})
				})

				$('<div>').css('clear','both').appendTo(color_chooser)
				var butts = $('<div>').appendTo(color_chooser).css('border-top', '1px solid black')
				.css('margin-top', '20px')
				$('<input>').attr('value','Закрыть').button().appendTo(butts).click(function(){
					color_chooser.remove()
				})

				//$('<input>').attr('value','Прозрачный').button().appendTo(butts).click(function(){
				//	onSelectColor("clear");
				//	color_chooser.remove()

				//})
				$('<input>').button().text('Другой цвет').appendTo(butts).attr('value','Выбрать другой цвет').button()
					.colorpicker({inline:false, alpha:true, colorFormat:'RGBA', ok: function(evt, color){
						var hsv = color.hsv
						hsv.s = hsv.s * 100;
						hsv.b = hsv.v * 100;
						hsv.h = hsv.h * 360;
						hsv.a = color.a
						delete hsv.v
						console.log(hsv)
						self.Site.colors.custom_pallette.push(hsv)
						var ix = self.Site.colors.custom_pallette.length - 1
						color_chooser.remove()
						onSelectColor(color.formatted, {v:'C', ix: ix }, hsv)

					}})
				return color_chooser;
			}`


###

window.Constructor.draw_color_chooser = (onSelectColor) ->
  color_chooser = $("<div>").css("position", "absolute").css("background-color", "white").css("border", "1px solid black").css("padding", "10px").width(400).zIndex(10000).draggable(scroll: false)
  self = this
  @_make_pallette()
  $.each @Site.colors.pallette, (l, vars) ->
    b = undefined
    main = undefined
    if l is 0

      #console.log(l, vars)
      $.each vars, (i, col_) ->
        col_.a = 1  if typeof col_.a is "undefined"
        col = hsvToRgb(col_)
        b = $("<div>").css("float", "left").width(100).height(100).appendTo(color_chooser)  if i is 0
        $("<button>").css("padding", "0").css("border", "0").css("display", "block").css("background-color", col).css("float", "left").width(100).height(100 / 6).appendTo(b).click (evt) ->
          color_chooser.remove()
          onSelectColor col,
            v: l
            ix: i
          , col_

          evt.preventDefault()
          evt.stopPropagation()


    else

      # console.log(l, vars)
      $.each vars, (i, col_) ->
        col_.a = 1  if typeof col_.a is "undefined"
        col = hsvToRgb(col_)
        if i is 0
          b = $("<div>").css("float", "left").width(100).height(100).appendTo(color_chooser)
          main = $("<button>").css("padding", "0").css("border", "0").css("display", "block").css("background-color", col).css("float", "left").width(100).height(50).click((evt) ->
            color_chooser.remove()
            onSelectColor col,
              v: l
              ix: i
            , col_
            log("HERE", color_chooser )


            evt.preventDefault()
            evt.stopPropagation()
          )
        else
          main.appendTo b  if i is 3
          $("<button>").css("padding", "0").css("border", "0").css("display", "block").css("background-color", col).css("float", "left").width(50).height(25).appendTo(b).click (evt) -> # console.log(col);
            onSelectColor col,
              v: l
              ix: i
            , col_
            evt.preventDefault()
            evt.stopPropagation()

            color_chooser.remove()



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

      console.log hsv
      self.Site.colors.custom_pallette.push hsv
      ix = self.Site.colors.custom_pallette.length - 1
      color_chooser.remove()
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
				var base_width = Math.round ((this.layout.width - (this.layout.padding.left) ) / this.layout.cols)
				var block_width = (base_width - ( 2 * this.layout.grid.hor ) )
				// console.log(base_width, block_width)

				return Math.round(block_width)

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
				return (this.layout.padding.left + w + P*this.layout.grid.hor) // + this._main_offset.left;

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
				//if (this._c_bw){
				//	cbw = this._c_bw
				//}
				//else{
					this._c_bw = this._block_width()
					cbw = this._c_bw
					// }

				// console.log( "CALC WIDTH", this._c_bw,cbw , w , (this.layout.grid.hor *2 * (w-1)) )
				return (cbw * w) + (this.layout.grid.hor *2 * (w-1) )


			}`
window.Constructor._calc_width = _calc_width




move_block = `function ( ix, x, y, dont_save){
				var bl = this.Site.blocks.splice(ix,1)[0]
				bl.x = x; bl.y = y;
				this.Site.blocks.push(bl)
				if(!(dont_save)){
					this._save_site();
				}
			}`
window.Constructor.move_block = move_block





addCustomColor = `function (color){
				if (this.Site.colors.custom_pallette){
					ix = this.Site.colors.custom_pallette.push(color) - 1
				}else{
					this.Site.colors.custom_pallette = [color];
					ix = 0
				}
				return ix
			}`
window.Constructor.addCustomColor = addCustomColor




###
add_block = `function (x,y, type, ds){

				this.Site.blocks.push(	{width:ds[0],height:ds[1],
									x:x, y:y,
									widget:{name:type, data: ''	 },
									display_on : this.current_page,
									dont_display_on :[]
								});
			}`

###

window.Constructor.add_block = (x, y, type, ds) ->
  @Site.blocks.push
    width: ds[0]
    height: ds[1]
    x: x
    y: y
    widget:
      name: type
      data: ""

    display_on: @current_page
    dont_display_on: []



delete_block = `function (ix){
				this.Site.blocks.splice(ix,1)

			}`
window.Constructor.delete_block = delete_block







_set_base_hue = `function (hue){
				this.Site.colors['base'] = hue;
			}`
window.Constructor._set_base_hue = _set_base_hue




_set_scheme_type = `function (type){
				this.Site.colors['type'] = type;
			}`
window.Constructor._set_scheme_type = _set_scheme_type





setBlockSettings = `function (page_pos, s){
				this.Site.blocks[page_pos].settings = s;
			}`
window.Constructor.setBlockSettings = setBlockSettings




setDefaultBlockSettings = `function (s){
				this.Site.default_block_settings = s;
			}`
window.Constructor.setDefaultBlockSettings = setDefaultBlockSettings




setWidgetData = `function (pos, data){
				this.Site.blocks[pos].widget.data = data;

			}`
window.Constructor.setWidgetData = setWidgetData





init_cp_marker = `function (){
				var self = this
				C = $('div#controls');
				this.CPmarker = $('<div>')
				.css('position' ,'fixed')
				.css('top',0).css('left',0)
				.css('background-color', 'orange')
				.width(30)
				.height(30).text('CP').appendTo(C).click(function(){
					self.show_CP(C)
					self.CPmarker.hide();
				})

			}`
window.Constructor.init_cp_marker = init_cp_marker


redraw_cp = `function (active_tab){
				if (this.cp_acc){
					this.cp_acc.remove()
				}
				this.show_CP(active_tab)
			}`
window.Constructor.redraw_cp = redraw_cp



_save_site = `function ( do_cache ){
				if(typeof do_cache == 'undefined'){
					do_cache = false;
				}
				this.Site['site_id'] = this.site_id;
				self = this;
				if (do_cache){
					setTimeout(function(){self.caching()}, 100)
				}
				var saving_obj = $.extend(true, {}, self.Site);
				delete saving_obj['Applications']
				DB.save_object_sync('generic.' + BASE_SITE, this._site_type, saving_obj, function(){
				},

				function(xhr){
					O = eval("[" + xhr.responseText +"]")[0]
					self.Site['_id'] = O._id
				})


			}`
window.Constructor._save_site = _save_site

###

init_block_cp = `function (obj,to, widget){

				var m = $('<div>').appendTo(to);
				var self = this;
				var w = obj;
				var settings = self.getBlockSettings(obj.pos);
				var old_settings = $.extend(true, {}, settings)

				//console.log ("HAHAHA", obj, w, to)

				var onPatternChoice = function (pattern){
				  settings.background = {type:'pattern', pattern: pattern}
				  self.apply_block_settings(w, settings, widget)

				}
				var onColorChoice = function (color, pal_ix, hsba ) {
					if(col == 'clear') {
						settings.background = { type:'none'}
					}else{
						settings.background = { type:'color', color: pal_ix }
					}
					self.apply_block_settings( w, settings, widget)
					$(this).dialog('close')

				}

				var onCancel = function () {
				 settings = old_settings;
				 self.apply_block_settings( w, old_settings, widget)
				 $(this).dialog('close')

				}
				var onSave = function () {
   				 $(this).dialog('close')

				}





				if(widget.disobey.indexOf('background_color') == -1){
					cl = $('<button>').button().text('Выбор фона').click(function(){

						self.drawBackgroundSelectorDialog(onPatternChoice, onColorChoice, onCancel, onSave);



					}).appendTo(m)
				}

				//console.log(widget.disobey.indexOf('border_color') == -1)
				if(widget.disobey.indexOf('border_color') == -1){

					cl = $('<button>').button().text('выбрать цвет рамки').click(function(){
						cb = function(col, ix){
							if(col != 'clear'){
								settings.border_color = ix
								self.apply_block_settings( w, settings, widget )
							}

						}
						cc = self.draw_color_chooser( cb );
						cc.appendTo( to ).position({of:this, my:'left top', at:'left top' } )

					}).appendTo(m)
				}




				vf = function(a,d){

					return typeof(a) == 'undefined'? d : a
				}
				var ul =$('<ul>').appendTo(m).addClass('cp-ul')

				if(widget.disobey.indexOf('bg_opacity') == -1){
					var li = $('<li>').appendTo(ul)
					$('<span>').text('Прозрачность блока').appendTo(li)
					$("<div>").width(250).slider({min:0, max:100,value:vf(settings.bg_opacity,100)*100, slide:function(event, ui){
						settings.bg_opacity = ui.value/100 ;
						self.apply_block_settings( w, settings, widget )

						// w.css('opacity', settings.bg_opacity);
					}} ).appendTo(li)
				}
				if(widget.disobey.indexOf('border_radius') == -1){

					var li = $('<li>').appendTo(ul)
					$('<span>').text('Радиус границы').appendTo(li)

					$("<div>").width(250).slider({min:0, max:100,value:vf(settings.border_radius,0), slide:function(event, ui){
						settings.border_radius = ui.value ;
						self.apply_block_settings( w, settings, widget)

						//w.css('border-radius', settings.border_radius +'px');
					}} ).appendTo(li)
				}
				if(widget.disobey.indexOf('border_width') == -1){
					var li = $('<li>').appendTo(ul)
					$('<span>').text('Ширина границы').appendTo(li)
					$("<div>").width(250).slider({min:0, max:100,value: vf(settings.border_width,0)*10, slide:function(event, ui){
						settings.border_width = ui.value/10 ;
						self.apply_block_settings( w, settings, widget)

					}} ).appendTo(li)
				}
				if(widget.disobey.indexOf('line_height') == -1){
					var li = $('<li>').appendTo(ul)
					$('<span>').text('Межстрочный интервал').appendTo(li)

					def_lh =obj.jq.width() / settings.font_size *0.75;

					var lhs = $("<div>").width(250).slider({min:0, max:300,value:vf(def_lh,0)*10, slide:function(event, ui){
						settings.line_height = ui.value/10 ;
						self.apply_block_settings( w, settings, widget)

						// w.css('line-height', settings.line_height +'px');

					}} ).appendTo(li)
				}
				if(widget.disobey.indexOf('font_size') == -1){
					var li = $('<li>').appendTo(ul)
					$('<span>').text('Размер шрифта').appendTo(li)
					$("<div>").width(250).slider({min:0, max:300,value:vf(settings.font_size,0)*10, slide:function(event, ui){
						settings.font_size = ui.value/10 ;

						settings.line_height	= obj.jq.width() / settings.font_size *0.75;
						self.apply_block_settings( w, settings, widget)

						//w.css('font-size', settings.font_size +'px');
						//w.css('line-height', lh +'px');
						lhs.slider('value', settings.line_height * 10)


					}} ).appendTo(li)
				}
				if(widget.disobey.indexOf('padding_top') == -1){
					var li = $('<li>').appendTo(ul)
					$('<span>').text('отступ сверху').appendTo(li)
					var pt = settings.padding_top ? settings.padding_top*10 : 0

					$("<div>").width(250).slider({min:0, max:300,value:pt, slide:function(event, ui){
						settings.padding_top = ui.value/10 ;
						self.apply_block_settings( w, settings, widget)
					}} ).appendTo(li)
				}
				if(widget.disobey.indexOf('padding_left_right') == -1){
					var li = $('<li>').appendTo(ul)
					$('<span>').text('Отступ слева-справа').appendTo(li)
					var plr = settings.padding_left_right ? settings.padding_left_right*10 : 0
					$("<div>").width(250).slider({min:0, max:300,value:plr, slide:function(event, ui){
						settings.padding_left_right = ui.value/10 ;
						self.apply_block_settings( w, settings, widget)
					}} ).appendTo(li)
				}

				$("<label for='available_all_pages'>").appendTo(m).append('Показывать на всех страницах')
				cb = $("<input type='checkbox' id='available_all_pages'>").appendTo(m).click(function(){
					// console.log(self.Site.blocks, to)
					if(self.Site.blocks[obj.pos].display_on == 'all')
					{
						self.Site.blocks[obj.pos].display_on = self.current_page
					}else{
						self.Site.blocks[obj.pos].display_on = 'all'
					}
				})
				cb.prop('checked', self.Site.blocks[obj.pos].display_on == 'all')
				$("<br>").appendTo(m)
				// ------
				$("<label for='unsnap_to_grid'>").appendTo(m).append('Свободный блок')
				cb = $("<input type='checkbox' id='unsnap_to_grid'>").appendTo(m).click(function(){
					bl = self.get_block(obj.pos);
					settings.unsnap_to_grid = this.checked
					if (this.checked){
						self.move_block(obj.pos, self._calc_left(bl.x + 1) + settings.border_width,
												 self._calc_top(bl.y + 1) + settings.border_width,
												 true)
 						self.Site.blocks[obj.pos].width  = self._calc_width(bl.width);
 						self.Site.blocks[obj.pos].height = self._calc_height(bl.height);

					}else{
						// x = obj.jq.css('left')
						self.move_block(obj.pos, self._uncalc_left(bl.x ) + settings._border_width,
												 self._uncalc_top(bl.y ) + settings._border_width,
												 true)
						self.Site.blocks[obj.pos].width  /= self._block_width();
						self.Site.blocks[obj.pos].height /=  self._block_height();

					}

				})
				cb.prop('checked', settings.unsnap_to_grid )
				$("<br>").appendTo(m)
				// ------

				cl = $('<button>').button().text('Применить для всех новых блоков').click(function(){
					self.Site.default_block_settings = settings;
					self.redraw()
					m.remove();

				})
				.css('display','block')
				.css('padding','5px')
				.css('margin-bottom', '10px')
				.appendTo(m)

				cl = $('<button>').button().text('Применить для всех имеющихся блоков').click(function(){
					self.Site.default_block_settings = settings;
					$.each(self.Site.blocks, function(i, bl){
						delete bl['settings']

						// console.log(bl)
					})


					self.redraw();
					to.remove()

				}).appendTo(m)
				.css('display','block')
				.css('padding','5px')
				.css('margin-bottom', '10px')
				var o = {
					save: function(){
						//console.log(settings)
						self.setBlockSettings(obj.pos,settings)
					},
					cancel:function(){

					}
				}
				return o;
			}`
###
window.Constructor.init_block_cp = (obj, to, widget) ->
  m = $("<div>").appendTo(to)
  self = this
  w = obj
  settings = self.getBlockSettings(obj.pos)
  old_settings = $.extend(true, {}, settings)

  #console.log ("HAHAHA", obj, w, to)
  onPatternChoice = (pattern) ->
    settings.background =
      type: "pattern"
      pattern: pattern

    self.apply_block_settings w, settings, widget

  onColorChoice = (color, pal_ix, hsba) ->
    if col is "clear"
      settings.background = type: "none"
    else
      settings.background =
        type: "color"
        color: pal_ix
    self.apply_block_settings w, settings, widget
    $(this).dialog "close"

  onCancel = ->
    settings = old_settings
    self.apply_block_settings w, old_settings, widget
    $(this).dialog "close"

  onSave = ->
    $(this).dialog "close"

  if widget.disobey.indexOf("background_color") is -1
    cl = $("<button>").button().text("Выбор фона").click(->
      self.drawBackgroundSelectorDialog onPatternChoice, onColorChoice, onCancel, onSave
    ).appendTo(m)

  #console.log(widget.disobey.indexOf('border_color') == -1)
  if widget.disobey.indexOf("border_color") is -1
    cl = $("<button>").button().text("выбрать цвет рамки").click(->
      cb = (col, ix) ->
        unless col is "clear"
          settings.border_color = ix
          self.apply_block_settings w, settings, widget

      cc = self.draw_color_chooser(cb)
      cc.appendTo(to).position
        of: this
        my: "left top"
        at: "left top"

    ).appendTo(m)
  vf = (a, d) ->
    (if typeof (a) is "undefined" then d else a)

  ul = $("<ul>").appendTo(m).addClass("cp-ul")
  if widget.disobey.indexOf("bg_opacity") is -1
    li = $("<li>").appendTo(ul)
    $("<span>").text("Прозрачность блока").appendTo li

    # w.css('opacity', settings.bg_opacity);
    $("<div>").width(250).slider(
      min: 0
      max: 100
      value: vf(settings.bg_opacity, 100) * 100
      slide: (event, ui) ->
        settings.bg_opacity = ui.value / 100
        self.apply_block_settings w, settings, widget
    ).appendTo li
  if widget.disobey.indexOf("border_radius") is -1
    li = $("<li>").appendTo(ul)
    $("<span>").text("Радиус границы").appendTo li

    #w.css('border-radius', settings.border_radius +'px');
    $("<div>").width(250).slider(
      min: 0
      max: 100
      value: vf(settings.border_radius, 0)
      slide: (event, ui) ->
        settings.border_radius = ui.value
        self.apply_block_settings w, settings, widget
    ).appendTo li
  if widget.disobey.indexOf("border_width") is -1
    li = $("<li>").appendTo(ul)
    $("<span>").text("Ширина границы").appendTo li
    $("<div>").width(250).slider(
      min: 0
      max: 100
      value: vf(settings.border_width, 0) * 10
      slide: (event, ui) ->
        settings.border_width = ui.value / 10
        self.apply_block_settings w, settings, widget
    ).appendTo li
  if widget.disobey.indexOf("line_height") is -1
    li = $("<li>").appendTo(ul)
    $("<span>").text("Межстрочный интервал").appendTo li
    def_lh = obj.jq.width() / settings.font_size * 0.75

    # w.css('line-height', settings.line_height +'px');
    lhs = $("<div>").width(250).slider(
      min: 0
      max: 300
      value: vf(def_lh, 0) * 10
      slide: (event, ui) ->
        settings.line_height = ui.value / 10
        self.apply_block_settings w, settings, widget
    ).appendTo(li)
  if widget.disobey.indexOf("font_size") is -1
    li = $("<li>").appendTo(ul)
    $("<span>").text("Размер шрифта").appendTo li

    #w.css('font-size', settings.font_size +'px');
    #w.css('line-height', lh +'px');
    $("<div>").width(250).slider(
      min: 0
      max: 300
      value: vf(settings.font_size, 0) * 10
      slide: (event, ui) ->
        settings.font_size = ui.value / 10
        settings.line_height = obj.jq.width() / settings.font_size * 0.75
        self.apply_block_settings w, settings, widget
        lhs.slider "value", settings.line_height * 10
    ).appendTo li
  if widget.disobey.indexOf("padding_top") is -1
    li = $("<li>").appendTo(ul)
    $("<span>").text("отступ сверху").appendTo li
    pt = (if settings.padding_top then settings.padding_top * 10 else 0)
    $("<div>").width(250).slider(
      min: 0
      max: 300
      value: pt
      slide: (event, ui) ->
        settings.padding_top = ui.value / 10
        self.apply_block_settings w, settings, widget
    ).appendTo li
  if widget.disobey.indexOf("padding_left_right") is -1
    li = $("<li>").appendTo(ul)
    $("<span>").text("Отступ слева-справа").appendTo li
    plr = (if settings.padding_left_right then settings.padding_left_right * 10 else 0)
    $("<div>").width(250).slider(
      min: 0
      max: 300
      value: plr
      slide: (event, ui) ->
        settings.padding_left_right = ui.value / 10
        self.apply_block_settings w, settings, widget
    ).appendTo li
  $("<label for='available_all_pages'>").appendTo(m).append "Показывать на всех страницах"
  cb = $("<input type='checkbox' id='available_all_pages'>").appendTo(m).click(->

    # console.log(self.Site.blocks, to)
    if self.Site.blocks[obj.pos].display_on is "all"
      self.Site.blocks[obj.pos].display_on = self.current_page
    else
      self.Site.blocks[obj.pos].display_on = "all"
  )
  cb.prop "checked", self.Site.blocks[obj.pos].display_on is "all"
  $("<br>").appendTo m

  # ------
  $("<label for='unsnap_to_grid'>").appendTo(m).append "Свободный блок"
  cb = $("<input type='checkbox' id='unsnap_to_grid'>").appendTo(m).click(->
    bl = self.get_block(obj.pos)
    settings.unsnap_to_grid = @checked
    if @checked
      self.move_block obj.pos, self._calc_left(bl.x + 1) + settings.border_width, self._calc_top(bl.y + 1) + settings.border_width, true
      self.Site.blocks[obj.pos].width = self._calc_width(bl.width)
      self.Site.blocks[obj.pos].height = self._calc_height(bl.height)
    else

      # x = obj.jq.css('left')
      self.move_block obj.pos, self._uncalc_left(bl.x) + settings._border_width, self._uncalc_top(bl.y) + settings._border_width, true
      self.Site.blocks[obj.pos].width /= self._block_width()
      self.Site.blocks[obj.pos].height /= self._block_height()
  )
  cb.prop "checked", settings.unsnap_to_grid
  $("<br>").appendTo m

  # ------
  cl = $("<button>").button().text("Применить для всех новых блоков").click(->
    self.Site.default_block_settings = settings
    self.redraw()
    m.remove()
  ).css("display", "block").css("padding", "5px").css("margin-bottom", "10px").appendTo(m)

  # console.log(bl)
  cl = $("<button>").button().text("Применить для всех имеющихся блоков").click(->
    self.Site.default_block_settings = settings
    $.each self.Site.blocks, (i, bl) ->
      delete bl["settings"]

    self.redraw()
    to.remove()
  ).appendTo(m).css("display", "block").css("padding", "5px").css("margin-bottom", "10px")
  o =
    save: ->

      #console.log(settings)
      self.setBlockSettings obj.pos, settings

    cancel: ->

  o


drawBackgroundSelectorDialog = `function (onPatternChoice, onColorChoice, onCancel, onSave){
				var self = this;
				var patt_div = $('<div>')
				.css({
								//'position': 'absolute',
								//'width': 600,
								//'background-color': 'white',
								//'height': 300
							})
								.appendTo( $('#controls' ))
								//.position({of:this, my:'left top', at:'left top' } )
								//.zIndex(10);

								// Запихать в этот див кучу паттернов для бэкграунда
				//var to = this._app_admin_contents;


				var show_img_patt_choice = function(where, t){
					$.each(DB.get_objects('generic.' + BASE_SITE, 'pattern', {type:t}).objects, function(ix, obj){
						// console.log(ix, obj)
						if (obj.image.blob){
							var url = DB.get_blob_url(obj.image)
						}else{
							var url = obj.image;
						}
						$('<div>').css('float','left')
							  .css('background', 'url(' + url+')')
							  .css('background-size', '32px 32px')
							  .width(32).height(32)
							  .css('margin', '5px').appendTo(where)
							  .css('cursor','pointer')
							  .on('mouseenter', function(){})
							  .on('click', function(){
								  onPatternChoice.apply(patt_div, [obj] )
							  })

					})
				}
				var show_css_patt_choice = function(where){
					//var inp = $('<div>').appendTo(where).width('100%').height('100%')

					$.each(DB.get_objects('generic.' + BASE_SITE,'pattern', {type:'css'}).objects, function(ix, obj){
						// console.log(ix, obj)
						var d = $('<div>').css('float','left')
							  // .css('background', 'url(' + obj.image+')')
							  .css('background-size', '32px 32px')
							  .width(32).height(32)
							  .css('margin', '5px').appendTo(where)
							  .css('cursor','pointer')
							  .on('mouseenter', function(){})
							  .on('click', function(){
								  onPatternChoice.apply(patt_div, [obj] )
							  })
							  self._draw_css_background( d, obj.image )

					})
				}



				patt_div.find('*').remove()
				atabs = $('<div>').appendTo(patt_div)
				ul = $("<ul>").appendTo(atabs);
				$("<li>").append($("<a>").prop('href', "#image-pattern" ).text("Узор из картинки") ).appendTo(ul)
				$("<li>").append($("<a>").prop('href', "#constructor-pattern" ).text("Собранный узор") ).appendTo(ul)
				$("<li>").append($("<a>").prop('href', "#css-pattern" ).text('CSS-узор') ).appendTo(ul)

				var pic_patt = $("<div>")//.width('300')
				.height(300)
				.prop('id',"image-pattern").appendTo(atabs)
				show_img_patt_choice(pic_patt,'image')

				var my_patt = $("<div>")
				//.width('100%')
				.height(300)
				.prop('id',"constructor-pattern").appendTo(atabs)
				show_img_patt_choice(my_patt,'constructor')

				var css_patt = $("<div>")
				//.width('100%')
				.height(300).prop('id',"css-pattern").appendTo(atabs)
				show_css_patt_choice(css_patt)

				// prod_cont.text("okey")


				//orders_cont = $("<div>").prop('id',"orders").appendTo(atabs)
				// orders_cont.text("O okey
				atabs.tabs();
				patt_div.dialog({title:'Выбор заднего фона',width:600, height:500,
					buttons:{"Готово" : function(){
											onSave.apply(patt_div, [])
										},
							 "Отмена": function(){
								 			onCancel.apply(patt_div, [])
										},
							 "Выбор цвета": function(){
											cc = self.draw_color_chooser( onColorChoice );
											cc.appendTo( $('#controls') )
											.position({of:this, my:'left top', at:'left top' } )
										 }
					}})

			}`
window.Constructor.drawBackgroundSelectorDialog = drawBackgroundSelectorDialog



showColorScheme = `function (){
				var to = this._app_admin_contents;
				var self = this;
				to.find('*').remove()
				this._app_admin_cont.show()
				var c = $("<div>")


				self._pallete_drawer = function(C){

					C.find('*').remove()
					self._make_pallette();
					for (k in self.Site.colors.pallette){
						var vars = self.Site.colors.pallette[k];
						// // // console.log("PAL", k, vars);
						for (i in vars){
							if(i == 0){
								var b = $('<div>').css('float','left').width(100).height(1350).appendTo(C)
								var main = $('<div>').css('background-color',hsvToRgb(vars[i])).css('float','left').width(100).height(50)
							}else{
								// // // // console.log(i)
								if(i == 3){
									main.appendTo(b);
								}

								$('<div>').css('background-color',hsvToRgb(vars[i])).css('float','left').width(50).height(25).appendTo(b)
							}

						}
						if (vars){
							vars[5]={h:0, s:0, b:0}
							vars[6]={h:0, s:0, b:100}
							for (var i =0; i < 7; i++){
								for (var j =0; j < 7; j++){
									//// // // console.log;
									if (!((j==i) || (i==5 &&j==6) || (i==6&&j==5)	) ){
										$("<div>").text('Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab illo inventor')
										.css('overflow','hidden').css('float','left').width(100).height(50).css('font-size','10pt')
										.css('background-color', hsvToRgb( vars[i]) )
										.css('color', hsvToRgb(vars[j]) ).appendTo(b)

									}
								}


							}

						}
					}
				}
				var S = $('<div>').append(
											$('<input>').prop('name','scheme').prop('type','radio').prop('id','mono').click(function(){ self._set_scheme_type('mono');self.showColorScheme(); }),		$('<label>').prop('for','mono').text('Mono'),
											$('<input>').prop('name','scheme').prop('type','radio').prop('id','complement').click(function(){ self._set_scheme_type('complement');self.showColorScheme()}),$('<label>').prop('for','complement').text('Complement'),
											$('<input>').prop('name','scheme').prop('type','radio').prop('id','triada').click(function(){ self._set_scheme_type('triada');self.showColorScheme();}),	$('<label>').prop('for','triada').text('Triada'),
											$('<input>').prop('name','scheme').prop('type','radio').prop('id','split-trio').click(function(){ self._set_scheme_type('split-trio');self.showColorScheme();}),$('<label>').prop('for','split-trio').text('Split-trio'),
											$('<input>').prop('name','scheme').prop('type','radio').prop('id','analogous').click(function(){ self._set_scheme_type('analogous');self.showColorScheme();}), $('<label>').prop('for','analogous').text('Analogoues'),
											$('<input>').prop('name','scheme').prop('type','radio').prop('id','accent').click(function(){ self._set_scheme_type('accent');self.showColorScheme();}),	$('<label>').prop('for','accent').text('Accent')
											//$('<input>').prop('type','radio').prop('id','mono'),$('<label>').prop('for','mono').text('Mono'),

				).buttonset().appendTo(to)
				$("<span>").text('brightness').appendTo(to)
				$("<div>").width(250).slider({min:0, max:100,value:self.Site.colors.brightness, slide:function(event, ui){ self.Site.colors.brightness = ui.value;self._pallete_drawer.apply(self,[c])	}} ).appendTo(to)

				$("<span>").text('saturation').appendTo(to)
				$("<div>").width(250).slider({min:0, max:100,value:self.Site.colors.saturation, slide:function(event, ui){ self.Site.colors.saturation = ui.value; self._pallete_drawer.apply(self,[c])	 }} ).appendTo(to)

				$("<span>").text('lights').appendTo(to)
				$("<div>").width(250).slider({min:0, max:100,value:self.Site.colors.lights, slide:function(event, ui){ self.Site.colors.lights = ui.value; self._pallete_drawer.apply(self,[c])	 } } ).appendTo(to)

				$("<span>").text('shadows').appendTo(to)
				$("<div>").width(250).slider({min:0, max:100,value:self.Site.colors.shadows, slide:function(event, ui){ self.Site.colors.shadows = ui.value; self._pallete_drawer.apply(self,[c])} } ).appendTo(to)

				var C = $('<canvas>').appendTo(to)
				.css('display','block')
				.width(360)
				.height(30)

				var context = C[0].getContext('2d');
				for(var h = 0; h< 360; h++){
					// // // console.log(rgbc)
					context.beginPath()
					context.moveTo(h*0.85,0)
					context.lineWidth = 1;
					context.strokeStyle = hsvToRgb({h:h,s:100,b:100});;
					context.lineTo(h*0.85,300)
					context.closePath()
					context.stroke()
				}
				c.appendTo(to)
				self._pallete_drawer(c);

				var orig;
				var point = function(evt){
					//// // console.log(evt.clientX),
					orig = evt.clientX
					self._pallete_drawer(c)
				}
				var unpoint = function(evt){
					var off = C.offset();
					self._set_base_hue(evt.clientX - off.left);
					orig = false
					self.redraw()

				}
				var dragger=function(evt){
					if (orig){
						var off = C.offset()
						self._set_base_hue(evt.clientX - off.left)
						self._pallete_drawer.apply(self,[c])
						// // // console.log(evt.clientX - off.left)
					}
				}

				C.mouseup(unpoint).mousedown(point).mousemove(dragger)
			}`
window.Constructor.showColorScheme = showColorScheme



showLayoutScheme = `function (){

				var to = this._app_admin_contents;
					to.find('*').remove()
					to.width(500)
				var self = this

					lo = $.extend(true, {}, this.Site.layout);
				var ul = $("<ul>").appendTo(to).width(500)

				$.each(lo, function(i, val){
					var l = $("<li>").text(i).appendTo(ul)

					if(i == 'grid' ||	i == 'padding' ){
						var inner =$("<ul>").appendTo(l)
						$.each(val, function(j, val){

							var l = $("<li>").text(j).appendTo(inner)
							var sp = $('<input>').appendTo(l).spinner({spin:function(event, ui){
								//console.log("do");
								self.Site.layout[i][j] = ui.value
								self.redraw();
							} }	)
							sp.spinner('value', val)

						})

					}else{
						var sp = $('<input>').appendTo(l).spinner({spin:function(event, ui){
								//console.log("do");
								self.Site.layout[i]= ui.value
								self.redraw();
							} }	)
						sp.spinner('value', val)
					}
				})
				$('<button>').text('save').click(function(){
					self._save_site()
				}).appendTo(to)
				$('<button>').text('cancel').click(function(){
					self.Site.layout = lo;
					self.showLayoutScheme();
					self.redraw()
				}).appendTo(to)
				this._app_admin_cont.show()
			 }`
window.Constructor.showLayoutScheme = showLayoutScheme




showFontsScheme = `function (){
				var available_fonts_serif = ['Georgia', 'Palatino Linotype', 'Times New Roman'],
					available_fonts_sans= ["Arial", "Arial Black", "Comic Sans MS", "Impact", "Lucida Sans Unicode", "Tahoma", "Trebuchet MS", "Verdana"],
					available_fonts_mono= ["Courier New", "Lucida Console"],
					self = this;

				var to = this._app_admin_contents;
					to.find('*').remove()
					// head sans
					D = $("<div>").width(600).css('margin-left',150).css('float', 'left')
					.text("Here's fonts scheme with Sans in headers, Serifs in texts").appendTo(to)
					// console.log(hsvToRgb({h:0, s: 50, b:100 } ) )
					$.each(available_fonts_sans, function(i, h){
						$.each(available_fonts_serif, function(i, c){
							D = $("<div>").width(200).css('margin-left',150).css('float', 'left').height(200).css('overflow','hidden')
							.mouseenter(function(){ $(this).css('background-color', hsvToRgb({h:0, s: 10, b:100 } ) ) })
							.mouseleave(function(){ sho$(this).css('background-color', hsvToRgb({h:0, s: 0, b:100 } ) ) })
							$("<h3></h3>").css('font-family', h).appendTo(D).text("Header with font " + h)
							$("<p>").css('font-family', c).text(c).appendTo(D)
							$("<p>").css('font-family', c).appendTo(D)
							.text(test_block_content.split(' ').slice(0,39).join(' ') )

							D.appendTo(to).click(function(){
								self.Site.fonts = {header: h, content: c}
								self.redraw()

							})
						} )
					})
					D = $("<div>").width(600).css('margin-left',150).css('float', 'left')
					.text("Here's fonts scheme with Serifs in headers, Sans in texts").appendTo(to)

					// head serif
					$.each(available_fonts_serif, function(i, h){
						$.each(available_fonts_sans, function(i, c){
							D = $("<div>").width(200).css('margin-left',150).css('float', 'left').height(200).css('overflow','hidden')
							.mouseenter(function(){ $(this).css('background-color', hsvToRgb({h:0, s: 10, b:100 } ) ) })
							.mouseleave(function(){ $(this).css('background-color', hsvToRgb({h:0, s: 0, b:100 } ) ) })

							$("<h3></h3>").css('font-family', h).appendTo(D).text("Header with font " + h)
							$("<p>").css('font-family', c).text(c).appendTo(D)
							$("<p>").css('font-family', c).appendTo(D)

							.text(test_block_content.split(' ').slice(0,39).join(' ') )

							D.appendTo(to).click(function(){
								self.Site.fonts = {header: h, content: c}
								self.redraw()
							})
						} )
					})

				this._app_admin_cont.show()
			 }`
window.Constructor.showFontsScheme = showFontsScheme




showBackgroundScheme = `function (){
				var to = this._app_admin_contents;
					to.find('*').remove()
					atabs = $('<div>').appendTo(to)
					ul = $("<ul>").appendTo(atabs);
					$("<li>").append($("<a>").prop('href', "#image-pattern" ).text("Узор из картинки") ).appendTo(ul)
					$("<li>").append($("<a>").prop('href', "#constructor-pattern" ).text("Сборка узора") ).appendTo(ul)

					$("<li>").append($("<a>").prop('href', "#css-pattern" ).text('CSS-узор') ).appendTo(ul)

					pic_patt = $("<div>").prop('id',"image-pattern").appendTo(atabs)
					this._show_picture_based_background_list(pic_patt)

					my_patt = $("<div>").prop('id',"constructor-pattern").appendTo(atabs)
					this._show_pattern_editor(my_patt)

					css_patt = $("<div>").prop('id',"css-pattern").appendTo(atabs)
					this._show_css_pattern_editor(css_patt)

					// prod_cont.text("okey")


					//orders_cont = $("<div>").prop('id',"orders").appendTo(atabs)
					// orders_cont.text("O okey")

					atabs.tabs();
				this._app_admin_cont.show()
			 }`
window.Constructor.showBackgroundScheme = showBackgroundScheme




_show_css_pattern_editor = `function (to) {
				 'use strict'
 				var self = this;
 				to.find('*').remove();
 				var control = $('<div>').appendTo(to).width(600).height(400).css('float','left').css('overflow','auto')
 				to.height(400);
 				var preview = $('<div>').appendTo(to).width(400).height(400).css('float','left')

 				$('<span>').text('Мои паттерны').appendTo(control)
 				var pat_cont = $('<div>').width(400).height(300).appendTo(control).css('overflow','auto')
 				$.each(DB.get_objects( 'generic.' + BASE_SITE, 'pattern', {type:'css'}).objects, function(ix, obj){
 					var icon=$('<div>').css('float','left')
						.width(64).height(64)
						.css('margin', '5px')
						.appendTo(pat_cont)
						.css('cursor','pointer')
						.on('mouseenter', function(){})
						.on('click', function(){
								preview.find('*').remove()
								var ch = $('<div>').width('100%').height('100%').appendTo(preview).css('background',"url(/static/images/bar-opacity.png) repeat" )
								var pr = $('<div>').appendTo(ch).width('100%').height('100%')
								self._draw_css_background(pr, obj.image)
						})
						console.log(icon, obj);
						self._draw_css_background(icon, obj.image);

 				})
				function show_control(css_pattern){
					var put_grad = function(){
						preview.find('*').remove()

						var ch = $('<div>').width('100%').height('100%').appendTo(preview).css('background',"url(/static/images/bar-opacity.png) repeat" )
						var pr = $('<div>').appendTo(ch).width('100%').height('100%')
						self._draw_css_background(pr, css_pattern)

					}
					put_grad()

					var grads_cont = $("<div>").appendTo(control)// .width('100%').height('100%');
					$('<div>').css('clear','both').appendTo(control);
					var add_gradient_controls = function(i, grad){
						var grc = $('<div class="grc grc-inactive">').appendTo(grads_cont)
											.css('font-size','5pt')
											.css('width', '100%')
											.css('border', '2px solid grey')
											.css('margin-bottom','10px')
											.css('padding', '20px').on('mouseenter', function(){ $(this).css('border-color','black') })
											.on('mouseleave', function(){ $(this).css('border-color','grey') })
						var g_grad = css_pattern.gradients[i];
						var di, // degree input
							ds, // degree slider
							spec_cont,
							cenli, //center left input
							cenls, // center left slider
							centi, //center top input
							cents, //center top slider
							sizewi, //size width inpur
							sizews, //size width inpur
							sizehi, //size height inpur
							sizehs; //size height inpur

						var appLinear=function(to){
							to.find('*').remove()
							var C = $('<div>').width(150)
												.appendTo(to).css('float','left')
												.css('padding-left','20px') // .css('padding-right','20px');
							$('<span>').text('deg').appendTo(C).css('font-size','10pt').css('margin-right','10px' )
							di = $('<input>').val(g_grad.deg).appendTo(C).width(30).keyup(function(){ console.log($(this).val());var v = parseInt($(this).val());g_grad.deg = v; ds.slider('value',v);put_grad() })
							ds = $("<div>").width(30).slider({min:0, max:360,value:grad.deg, slide:function(event, ui){ g_grad.deg = ui.value ;di.val(ui.value) ;put_grad();}} ).css('display','inline-block' ).appendTo(C)

						}

						var appRadial=function(to){
							to.find('*').remove()

							var C = $('<div>').width(150)
												.appendTo(to).css('float','left')
												.css('padding-left','20px') // .css('padding-right','20px');
							$('<span>').text('left').appendTo(C).css('font-size','10pt').css('margin-right','10px' )
							cenli = $('<input>').val(g_grad.rad_l.v).appendTo(C).width(30).keyup(function(){ console.log($(this).val());var v = parseInt($(this).val());g_grad.rad_l.v = v; cenls.slider('value',v);put_grad() })
							cenls = $("<div>").width(30).slider({min:0, max:360,value:g_grad.rad_l.v, slide:function(event, ui){ g_grad.rad_l.v = ui.value ;cenli.val(ui.value) ;put_grad();}} ).css('display','inline-block' ).appendTo(C)
							$('<select>').appendTo(C).append($('<option>').text('%').val('%')).append( $('<option>').text('px').val('px')).change(function(){g_grad.rad_l.m = $(this).val();put_grad(); })

							var C = $('<div>').width(150)
												.appendTo(to).css('float','left')
												.css('padding-left','20px') // .css('padding-right','20px');
							$('<span>').text('top').appendTo(C).css('font-size','10pt').css('margin-right','10px' )
							centi = $('<input>').val(g_grad.rad_t.v).appendTo(C).width(30).keyup(function(){ console.log($(this).val());var v = parseInt($(this).val());g_grad.rad_t.v = v; cents.slider('value',v);put_grad() })
							cents = $("<div>").width(30).slider({min:0, max:360,value:grad.rad_t.v, slide:function(event, ui){ g_grad.rad_t.v = ui.value ;centi.val(ui.value) ;put_grad();}} ).css('display','inline-block' ).appendTo(C)
							$('<select>').appendTo(C).append($('<option>').text('%').val('%')).append( $('<option>').text('px').val('px')).change(function(){g_grad.rad_t.m = $(this).val();put_grad(); })



							var C = $('<div>').width(150)
												.appendTo(to).css('float','left')
												.css('padding-left','20px') // .css('padding-right','20px');
							$('<span>').text('width').appendTo(C).css('font-size','10pt').css('margin-right','10px' )
							sizewi = $('<input>').val(g_grad.rad_w.v).appendTo(C).width(30).keyup(function(){ console.log($(this).val());var v = parseInt($(this).val());g_grad.rad_w.v = v; sizews.slider('value',v);put_grad() })
							sizews = $("<div>").width(30).slider({min:0, max:360,value:grad.rad_w.v, slide:function(event, ui){ g_grad.rad_w.v = ui.value ;sizewi.val(ui.value) ;put_grad();}} ).css('display','inline-block' ).appendTo(C)
							$('<select>').appendTo(C).append($('<option>').text('%').val('%')).append( $('<option>').text('px').val('px')).change(function(){g_grad.rad_w.m = $(this).val();put_grad(); })

							var C = $('<div>').width(150)
												.appendTo(to).css('float','left')
												.css('padding-left','20px') // .css('padding-right','20px');
							$('<span>').text('height').appendTo(C).css('font-size','10pt').css('margin-right','10px' )
							sizehi = $('<input>').val(g_grad.rad_h.v).appendTo(C).width(30).keyup(function(){ console.log($(this).val());var v = parseInt($(this).val());g_grad.rad_h.v = v; sizehs.slider('value',v);put_grad() })
							sizehs = $("<div>").width(30).slider({min:0, max:360,value:grad.rad_h.v, slide:function(event, ui){ g_grad.rad_h.v = ui.value ;sizehi.val(ui.value) ;put_grad();}} ).css('display','inline-block' ).appendTo(C)
							$('<select>').appendTo(C).append($('<option>').text('%').val('%')).append( $('<option>').text('px').val('px')).change(function(){g_grad.rad_h.m = $(this).val();put_grad(); })


						}
						var C = $('<div>').width(50).appendTo(grc).css('padding-left','20px').css('padding-right','20px');
						var sel =$('<select>').appendTo(C)
						$.each(['linear','radial'], function(_,t){$('<option>').text(t).val(t).appendTo(sel) })
						sel.val(grad.type).change(function(){
							g_grad.type = $(this).val();
							if (g_grad.type =='radial'){
								delete g_grad['deg']
								di.parent().remove()
								var b = ['rad_l','rad_t','rad_w','rad_h'];
								for (i=0; i<b.length; i++){
									g_grad[b[i]] = {v:1, m:'px'}
								}

								appRadial(spec_cont)
							}else{
								var a = [cenli, centi,sizewi,sizehi];
								var b = ['rad_l','rad_t','rad_w','rad_h'];
								for (i=0; i<a.length; i++){
									_c = a[i];
									_c.remove();
									delete g_grad[b[i]]
								}
								g_grad.deg = 0
								appLinear(spec_cont)

							}
							put_grad()

						})



						var wi, ws, C = $('<div>').width(150)
											.appendTo(grc).css('float','left')
											.css('padding-left','20px') // .css('padding-right','20px');
						$('<span>').text('W').appendTo(C).css('font-size','10pt').css('margin-right','10px' )
						wi = $('<input>').val(g_grad.size[0].v).appendTo(C).width(30).keyup(function(){ var v = parseInt($(this).val());g_grad.size[0].v = v; ws.slider('value',v);put_grad() })
						ws = $("<div>").width(30).slider({min:0, max:100,value:grad.size[0].v, slide:function(event, ui){ g_grad.size[0].v = ui.value ;put_grad(); wi.val(ui.value)}} ).css('display','inline-block' ).appendTo(C)
						$('<select>').appendTo(C).append($('<option>').text('%').val('%')).append( $('<option>').text('px').val('px')).change(function(){g_grad.size[0].m = $(this).val();put_grad(); })

						var hi, hs, C = $('<div>').appendTo(grc).width(150)
											.appendTo(grc).css('float','left')
											.css('padding-left','20px') // .css('padding-right','20px');
						$('<span>').text('H').appendTo(C).css('font-size','10pt').css('margin-right','10px' )
						hi = $('<input>').val(g_grad.size[1].v).appendTo(C).width(30).keyup(function(){ var v = parseInt($(this).val());g_grad.size[1].v = v; hs.slider('value',v);put_grad() })
						hs = $("<div>").width(30).slider({min:0, max:100,value:grad.size[1].v, slide:function(event, ui){ g_grad.size[1].v = ui.value; hi.val(ui.value) ;put_grad();}} ).css('display','inline-block' ).appendTo(C)
						$('<select>').appendTo(C).append($('<option>').text('%').val('%')).append( $('<option>').text('px').val('px')).change(function(){g_grad.size[1].m = $(this).val();put_grad(); })

						var li,ls, C = $('<div>').appendTo(grc).width(200)
											.appendTo(grc).css('float','left')
											.css('padding-left','20px') // .css('padding-right','20px');
						$('<span>').text('L').appendTo(C).css('font-size','10pt').css('margin-right','10px' )
						li = $('<input>').val(g_grad.pos[0].v).appendTo(C).width(30).keyup(function(){ var v = parseInt($(this).val());g_grad.pos[0].v = v; ls.slider('value',v);put_grad() })
						ls = $("<div>").width(60).slider({min:-100, max:100,value:grad.pos[0].v, slide:function(event, ui){ g_grad.pos[0].v = ui.value ;li.val(ui.value) ;put_grad();}} ).css('display','inline-block' ).appendTo(C)
						$('<select>').appendTo(C).append($('<option>').text('%').val('%')).append( $('<option>').text('px').val('px')).change(function(){g_grad.pos[0].m = $(this).val();put_grad(); })

						var ti, ts, C = $('<div>').appendTo(grc).width(200)
											.appendTo(grc).css('float','left')
											.css('padding-left','20px') // .css('padding-right','20px');
						$('<span>').text('T').appendTo(C).css('font-size','10pt').css('margin-right','10px' )
						ti = $('<input>').val(g_grad.pos[1].v).appendTo(C).width(30).keyup(function(){ var v = parseInt($(this).val());g_grad.pos[1].v = v; ts.slider('value',v);put_grad() })
						ts = $("<div>").width(60).slider({min:-100, max:100,value:grad.pos[1].v, slide:function(event, ui){ g_grad.pos[1].v = ui.value ;ti.val(ui.value) ;put_grad();}} ).css('display','inline-block' ).appendTo(C)
						$('<select>').appendTo(C).append($('<option>').text('%').val('%')).append( $('<option>').text('px').val('px')).change(function(){g_grad.pos[1].m = $(this).val();put_grad(); })

						$('<div>').css('clear','both').appendTo(grc);

						spec_cont = $('<div>').appendTo(grc);
						if(grad.type == 'linear'){
							appLinear(spec_cont)
						}else{
							appRadial(spec_cont)
						}
						$('<div>').css('clear','both').appendTo(grc);
						var stops_cont =$('<div class="stops-cont">').appendTo(grc)

						$('<div>').css('clear','both').appendTo(grc);
						$("<button>").button().text('remove gradient').appendTo(grc).click(function(){
							if(css_pattern.gradients.length <2){
								alert('в узоре должен быть хотя бы один градиент')
								return ;
							}
							css_pattern.gradients.splice(i,1);
							grc.remove();
							put_grad();
							//console.log(css_pattern)
						})

						var expand = function(evt){
							if ($(this).hasClass('grc-inactive')){

								$(this).parent().find('.grc').addClass('grc-inactive')
								$(this).removeClass('grc-inactive')
								$(this).parent().find('.grc-inactive ul.-stops').remove()

								var stops = $('<ul class="-stops">').appendTo(stops_cont)
								var add_stop_controls=function(i, stop){
									var li = $('<li>').appendTo(stops);
									var ai,as;
									var g_stop = g_grad.stops[i]
									$('<div>').width(32).height(32).css('background', "url(/static/images/bar-opacity.png) repeat")
									.css('border', '1px solid black').appendTo(li)
									.css('display','inline-block')
									.append($('<div>').width(32).height(32).css('background-color', hsvToRgb(g_stop.col) )
									.click(function(evt){
										var butt = $(this);
										var fc = function(col, smt, hsva ){
											// console.log(col, smt, hsva)
											g_stop.col = hsva;
											butt.css('background-color', hsvToRgb(hsva))
											if(ai){ai.val(hsva.a*100)}
											if(as){as.slider('value',hsva.a*100)}
											put_grad();
										}
										var ch = self.draw_color_chooser(fc)
										ch.appendTo($('#controls')).position({of:evt, my:'top left', at:'top left'})
									}))
									var ci,cs;
									$('<span>').text('T').appendTo(li).css('font-size','10pt').css('margin-right','10px' )
									ci = $('<input>').val(stop.size.v).appendTo(li).width(30).keyup(function(){ var v = parseInt($(this).val());g_stop.size.v = v; cs.slider('value',v);put_grad() })
									cs = $("<div>").width(30).slider({min:0, max:100,value:stop.size.v, slide:function(event, ui){ g_stop.size.v = ui.value ;ci.val(ui.value) ;put_grad();}} ).css('display','inline-block' ).appendTo(li)
									$('<select>').appendTo(li).append($('<option>').text('%').val('%')).append( $('<option>').text('px').val('px')).change(function(){g_stop.size.m = $(this).val();put_grad(); })

									var ai,as;
									$('<span>').text('A').appendTo(li).css('font-size','10pt').css('margin-right','10px' )
									ai = $('<input>').val(stop.col.a*100).appendTo(li).width(30).keyup(function(){ var v = parseInt($(this).val());g_stop.col.a = v/100; as.slider('value',v);put_grad() })
									as = $("<div>").width(30).slider({min:0, max:100,value:stop.col.a*100, slide:function(event, ui){ g_stop.col.a = ui.value/100 ;ai.val(ui.value) ;put_grad();}} ).css('display','inline-block' ).appendTo(li)

									$('<button>').button().text('Remove color').appendTo(li).click(function(){
										if(g_grad.stops.length <= 2){
											alert('cannot remove color stop. Needed at least two color stops to render gradient')
										}else{
											g_grad.stops.splice(i,1);
											li.remove();
											put_grad();

										}

									})

								}
								$.each(g_grad.stops, function(i, stop){
									add_stop_controls(i,stop)
								})
								$('<button>').text('Добавить цвет').appendTo(stops_cont).click(function(){
									var abc = {col:{h:10,s:0, v:100, a:1 } , size: {v:0,m:'%'} };
									g_grad.stops.push(abc)
									add_stop_controls(g_grad.stops.length-1, abc)
									put_grad();
								})
							}

						}
						grc.on('click', expand);

					}
					$.each(css_pattern.gradients, function(i,grad){
						add_gradient_controls(i, grad)
					})

					$("<div>").appendTo(control).append($('<button>').text('Добавить градиент').click(function(){
						var abc = {type:'linear', deg:90, size:[{v:100,m:'%'}, {v:100,m:'%'}],pos:[{v:0,m:'%'},{v:0,m:'%'}], stops:[{col:{h:10,s:0, v:100, a:0.5 } , size: {v:0,m:'%'} },
																																	{col:{h:10,s:100, v:0, a:0.5 }, size: {v:100,m:'%'} }]}
						css_pattern.gradients.push(abc)
						add_gradient_controls(css_pattern.gradients.length-1, abc)
						put_grad();
					})).append($('<button>').text('Сохранить').click(function(){
						// var ready_image = S[0].toDataURL("image/png")
						var pattern = {image:css_pattern, type: 'css' }
						DB.save_object('generic.'+BASE_SITE, 'pattern', pattern,function(){}, function(){})
						self._show_css_pattern_editor(to)
					})).append($('<button>').text('Отменить').click(function(){

						self._show_css_pattern_editor(to)
					}))

				}

				$('<button>').appendTo(control).text('Новый').click(function(){
					control.find('*').remove()

					var css_pattern = {gradients:[]
											  };
					show_control(css_pattern)



				})

 			}`
window.Constructor._show_css_pattern_editor = _show_css_pattern_editor



_show_pattern_editor = `function (to){
				var self = this;
				to.find('*').remove();
				var control = $('<div>').appendTo(to).width(290).height(400).css('float','left').css('overflow','auto')
				to.height(400);
				var preview = $('<div>').appendTo(to).width(605).height(400).css('float','left')

				$('<span>').text('Мои паттерны').appendTo(control)
				var pat_cont = $('<div>').width(400).height(300).appendTo(control).css('overflow','auto')
				$.each(DB.get_objects('generic.' + BASE_SITE, 'pattern', {type:'constructor'}).objects, function(ix, obj){
					// console.log(ix, obj)
					$('<div>').css('float','left')
							  .css('background', 'url(' + obj.image+')')
							  .css('background-size', '32px 32px')
							  .width(32).height(32)
							  .css('margin', '5px').appendTo(pat_cont)
							  .css('cursor','pointer')
							  .on('mouseenter', function(){})
							  .on('click', function(){
								  preview.find('*').remove();
								  var prev = $('<div>').width('100%').height('100%').appendTo(preview)
								  prev.css('background', 'url(' + obj.image+')')
							  })

				})

				var show_control = function (args) {
					control.find('*').remove()
					preview.find('*').remove()

					var my_patt = $('<div>').appendTo(control);



					var flright = $('<div>').appendTo(preview) .css('float','left')
											// .css('padding', 10)
											.width(300)
											.height(300)
											.css('border', '1px solid black')
											.css('background',  "url(/static/images/bar-opacity.png) repeat")
					var prev = $('<div>').appendTo(preview).css('float','left')
											.width(300)
											.height(300)
											.css('border', '1px solid black')
											.css('background',  "url(/static/images/bar-opacity.png) repeat")



					var Cjq = $('<canvas>').appendTo(flright)
					var C   = Cjq[0]
					var S = $('<canvas>')[0] //.appendTo(flright)[0]
					var ctx = C.getContext('2d')


					var sctx = S.getContext('2d')
					var base = 128;
					// var WA = 0, HA = 0,
					var A  = 0;
					var GA = 1;
					//  iWA = true, iHA = true;
					var Z = 0.25 // 0.08;
					var opacity;
					self._make_pallette()

					var BG = {v:1, ix:3},//this.Site.colors.pallette[0][3]
						FG = {v:1, ix:0};// this.Site.colors.pallette[0][0]



					var result, image, buffData, library_ix = false;

					function redraw_ctx(){
						Cjq .css('margin-left', (300 - base) / 2)
							.css('margin-top', (300 - base) / 2 );
						C.width = base
						C.height = base

						var iw = image.width * Z;
						var ih = image.height * Z;

						function dr_im(x,y,bx,by){


							ctx.save()
							ctx.translate(x, y)
							ctx.scale(Z,Z)
							rad = A* (3.14/180)
							ctx.rotate(rad)
							ctx.globalAlpha = opacity / 100;
							ctx.drawImage(image, -(iw/2), -(ih/2), iw, ih)
							ctx.restore()
						}

						if (BG){
							//console.log(BG)
							if ('ix' in BG){
								c = self.get_color(BG)
							}else{
								c = BG
							}
							c.a = GA;
							ctx.fillStyle =	 hsvToRgb(c)// "rgba( 255,255, 255, 255)";
						}
						ctx.rect(0,0, C.width, C.height)
						ctx.fill()
						ctx.save()
						ctx.clip();

						dr_im(base/2, base/2)

						dr_im(0, 0)
						dr_im(0, base)
						dr_im(base, 0)
						dr_im(base, base)
						ctx.closePath();
						ctx.restore()

						var img = C.toDataURL()
						prev.css('background', 'url(' + img + ') repeat' );

					}
					make_image = function(){

						img = new Image()
						img.onload = function(){
							exc_color(img)

						}
						img.src = result
					}
					var exc_color = function (img_) {
						S.width = img_.width
						S.height = img_.height
						sctx.drawImage(img_,0,0)
						buffData = sctx.getImageData(0,0, img_.width, img_.height)
						if( 'ix' in FG){
							var c = self.get_color(FG)
						}else { var c = FG}

							//}
						FGA = hsvToRgb(c, true)
						alphas = {};
						for(x =0; x<buffData.width; x++){
							for(y=0; y <buffData.height; y++){
								ix = (x+ ( y* buffData.width ))*4
								buffData.data[ix] = FGA[0]; //red
								buffData.data[ix+1] = FGA[1]; //green
								buffData.data[ix+2] = FGA[2]; //blue
							}

						}
						console.log(alphas)
						sctx.putImageData(buffData, 0,0)
						var du = S.toDataURL();
						_I = new Image()
						_I.onload = function(){
							image = _I
							redraw_ctx();
						}
						_I.src = du;
					}


					$('<span>').text('Элемент узора').appendTo(my_patt)
					var img_cont = $('<div>').width(290).height(100).css('overflow','auto').appendTo(my_patt);

					console.log("ICONS", back_icons_urls);
					$.each(back_icons_urls, function(i,url){

						$(new Image()).one('load', function(){
							// console.log("fdfdf", this);
							var img_self = this;
							//var img = scaleImage(this, 64, 64);
							$('<div>').css('float','left').width(64).height(64)
							.css('border', '2px solid black')
							.css('background', 'url(' + this.src + ') no-repeat' )
							.css('background-size', '64px 64px')
							.css('margin', '5px')
							// .append($(img))
							.appendTo(img_cont)
							.on('mouseenter', function(){ $(this).css('border-color','black') })
							.on('mouseleave', function(){ $(this).css('border-color','grey') })

							// $(this)
							.on('click', function(){
								//console.log("CLICK", )
								exc_color( img_self );
								//redraw_ctx();
								//make_image();
							})

						}).prop('src', url);

					})


					$('<input>').prop('type', 'file').change(function(){
						fr = new FileReader()
						fr.onload = function(){
							result = this.result;
							make_image();
						}
						fr.readAsDataURL(this.files[0]);
					}).appendTo(my_patt);

					choose_bg = function(col, ix, hsva ){
						//if (col != 'clear'){
						//	BG =
						//}else{
						//	BG = false
						//}
						BG = hsva
						redraw_ctx()
					}
					choose_fg = function(col, ix, hsva ){
						//if (col != 'clear'){
						FG = hsva
						exc_color(image);

							//}else{
							//FG = false
							//}
						redraw_ctx()
					}
					ul = $('<li>').appendTo(my_patt)

					$('<button>').click(function(e){ self.draw_color_chooser( choose_bg ).appendTo(my_patt) }).appendTo(my_patt).text("Background")
					$('<button>').click(function(e){ self.draw_color_chooser( choose_fg ).appendTo(my_patt) }).appendTo(my_patt).text("Foreground")

					var li = $('<li>').appendTo(ul)
					$('<span>').text('Угол поворота узора').appendTo(li)
					$("<div>").width(250).slider({min:0, max:360,value:0, slide:function(event, ui){ A = ui.value ;redraw_ctx()}} ).appendTo(li)

					var li = $('<li>').appendTo(ul)
					$('<span>').text('Размер узора').appendTo(li)
					$("<div>").width(250).slider({min:1, max:100,value:Z*100, slide:function(event, ui){ Z = (ui.value)/100 ;redraw_ctx()}} ).appendTo(li)

					var li = $('<li>').appendTo(ul)
					$('<span>').text('Размер тайла').appendTo(li)
					$("<div>").width(250).slider({min:64, max:300,value:base, slide:function(event, ui){ base = ui.value ;redraw_ctx()}} ).appendTo(li)

					var li = $('<li>').appendTo(ul)
					$('<span>').text('Прозрачность узора').appendTo(li)
					$("<div>").width(250).slider({min:0, max:100,value:100, slide:function(event, ui){ opacity = ui.value ;redraw_ctx()}} ).appendTo(li)

					var li = $('<li>').appendTo(ul)
					$('<span>').text('Прозрачность фона').appendTo(li)
					$("<div>").width(250).slider({min:0, max:100,value:GA*100, slide:function(event, ui){ GA = ui.value/100 ;redraw_ctx()}} ).appendTo(li)






				$("<div>").appendTo(control)//.append()
				 .append($('<button>').text('Сохранить').click(function(){
					var ready_image = C.toDataURL("image/png")
					var pattern = {image:ready_image, type: 'constructor' }

					DB.save_object('generic.'+BASE_SITE, 'pattern', pattern,function(){}, function(){})

					self._show_pattern_editor(to)
				})).append($('<button>').text('Отменить').click(function(){

					self._show_pattern_editor(to)
				}))
			}


			$('<button>').appendTo(control).text('Новый').click(function(){
				control.find('*').remove()

				//var css_pattern = {gradients:[]
										  	// };
				show_control()



			})

			}`
window.Constructor._show_pattern_editor = _show_pattern_editor





_show_picture_based_background_list = `function (to){
				var self = this;
				to.find('*').remove();
				var control = $('<div>').appendTo(to).width(400).height(400).css('float','left').css('overflow','auto')
				to.height(400);
				var preview = $('<div>').appendTo(to).width(400).height(400).css('float','left')

				$('<span>').text('Мои паттерны').appendTo(control)
				var pat_cont = $('<div>').width(400).height(300).appendTo(control).css('overflow','auto')
				$.each(DB.get_objects('generic.' + BASE_SITE,'pattern',{type:'image'}).objects, function(ix, obj){
					// console.log(ix, obj)
					if (obj.image.blob){
						var url = DB.get_blob_url(obj.image)
					}else{
						var url = obj.image;
					}

					$('<div>').css('float','left')
							  .css('background', 'url(' + url +')')
							  .css('background-size', '64px 64px')
							  .css('border', '2px solid grey')
							  .width(64).height(64)
							  .css('margin', '5px').appendTo(pat_cont)
							  .css('cursor','pointer')
							  .on('mouseenter', function(){ $(this).css('border-color','black') })
							  .on('mouseleave', function(){ $(this).css('border-color','grey') })

							  .on('click', function(){
								  preview.css('background', 'url(' + obj.image+')')
							  })

				})


			 	// First - picture template based
				$('<input>').prop('type','file').change(function(){
					var fr = new FileReader()
					fr.onloadend = function(){
						"use strict";

						var result = this.result;

						control.find('*').remove()

						var C = $('<canvas>')// .appendTo(control)
						var S = $('<canvas>')// .appendTo()
						var sctx = S[0].getContext('2d')

						var img = new Image()
						img.onload = function(){
							// // // console.log (img.width, img.height);
							var canv_div = $('<div>').width(400).height(150).css('overflow','auto').appendTo(control)
							C.appendTo( canv_div )
							C[0].width = img.width;
							C[0].height = img.height;
							C.css('border', '1px solid black')
							var ctx = C[0].getContext('2d')

							var R = {left:0,top:0, width:img.width, height:img.height}

							$("<button>").appendTo(control).text("Сохранить").click(function(){
								var ready_image = S[0].toDataURL("image/png")
								var pattern = {image:ready_image, type: 'image' }
								DB.save_object('generic.' +BASE_SITE, 'pattern', pattern,function(){}, function(){})
								self._show_picture_based_background_list(to)

							})
							$("<button>").appendTo(control).text("Отменить").click(function(){
								self._show_picture_based_background_list(to)
							})

							var _fpreview =  function(){
								var ready_image = S[0].toDataURL("image/png")
								preview.css('background-image','url("' + ready_image +' ")').css('background-repeat','repeat')


							}

							function redraw(st){
								ctx.clearRect(0,0,img.width,img.height)
								ctx.drawImage(img,0,0);
								S[0].width = R.width;
								S[0].height = R.height;

								sctx.drawImage(img,-R.left,-R.top)


								ctx.strokeStyle = 'rgba(128,128,0, 1)';
								ctx.fillStyle =	 'rgba(0,0,0, 0.7)';
								ctx.lineWidth = 2;
								ctx.beginPath();
								ctx.rect(R.left, 0, img.width - R.left, R.top);
								ctx.rect(R.left+R.width, R.top, img.width-R.width-R.left, img.height -R.top);

								ctx.rect(0, (R.top+R.height), R.left + R.width, img.height -R.top -R.height);

								ctx.rect(0, 0, R.left, R.height + R.top);

								ctx.fill();
								ctx.closePath();
								if (st){
									if (st.point){
										ctx.strokeStyle = 'rgba(255,255,255, 1)';
										ctx.fillStyle =	 'rgba(0,0,0, 0.7)';
										ctx.lineWidth = 2;

										ctx.beginPath();
									ctx.rect(st.left-2.5, st.top-2.5, 5, 5);

									ctx.closePath();
									ctx.fill(); ctx.stroke();
								}else{
									ctx.strokeStyle = 'rgb(50,50,50)';
									ctx.strokeWidth = 15;
									ctx.beginPath();

										ctx.moveTo(st.begin.left, st.begin.top);
										ctx.lineTo(st.end.left, st.end.top);
										ctx.closePath();

										ctx.beginPath();
										ctx.moveTo(st.begin.left, st.begin.top);
										ctx.lineTo(st.end.left, st.end.top);
										ctx.closePath();

										ctx.stroke();


									}

								}
								_fpreview();
								//ctx.beginPath();
								//ctx.rect(R.top,R.left,R.width,R.height)
							}
							redraw(false);
							//ctx.stroke();
							var thresh = 15
							var is_closeP=function(point,evt){
								var off = C.offset();
								var cx = evt.clientX - off.left;
								var cy = evt.clientY - off.top;
								return Math.abs(point.top-cy ) < thresh && Math.abs(point.left-cx) < thresh;

							};
							var is_closeL=function(line,evt){
								var off = C.offset()
								var cx = evt.clientX - off.left;
								var cy = evt.clientY - off.top;

								if(line.begin.top == line.end.top){
									//horisontal
									var line_left = Math.min(line.begin.left, line.end.left)
									var line_right = Math.max(line.begin.left, line.end.left)

									return	(cx > line_left && cx < line_right) && Math.abs(line.begin.top - cy ) < thresh
								}else{
									var line_top = Math.min(line.begin.top, line.end.top)
									var line_bottom = Math.max(line.begin.top, line.end.top)
									return	(cy > line_top && cy < line_bottom) && Math.abs(line.begin.left - cx ) < thresh
								}

							};

							var drag = false;
							var gpoint, gline, whole, start, prev;
							C.mousedown(function(evt){
								drag = true;

								var off = C.offset()
								var cx = evt.clientX - off.left;
								var cy = evt.clientY - off.top;
								prev = {top:evt.clientY-off.top, left: evt.clientX - off.left};
								start = {top:evt.clientY-off.top, left: evt.clientX - off.left};

								if(cx > R.left && cy >R.top){
									if(Math.abs(R.left - cx) < R.width && Math.abs(R.top - cy) < R.height){
										whole = true
									} else{
										whole = false
									}
								}

							})
							C.mouseup(function(evt){
								drag = false
							})
							C.mousemove(function(evt) {
								if(drag){
									// wait for diff in 5 px in any axis
									var off = C.offset();
									var cx = evt.clientX - off.left;
									var cy = evt.clientY - off.top;

									var diff = {top : cy - prev.top, left: cx - prev.left}
									prev = {top:evt.clientY-off.top, left: evt.clientX - off.left}

									if(Math.abs(cx - start.left) > 5 || Math.abs(cy - start.top) >5){
											if (gpoint){
												// // console.log("AAAA",gpoint)
												switch(gpoint.type){
													case 'tl':
														R.top += diff.top; R.left += diff.left;
														R.width -= diff.left;
														R.height -= diff.top;
														gpoint.top = R.top; gpoint.left = R.left;
														redraw(gpoint)
														return ;
													case 'tr':
														R.top += diff.top;
														R.height -= diff.top;

														R.width += diff.left;

														gpoint.top = R.top; gpoint.left = R.left + R.width;
														redraw(gpoint)
														return ;
													case 'bl':
														//R.top += diff.top;
														R.left += diff.left;
														R.width -= diff.left;

														R.height += diff.top;


														gpoint.top = R.top+R.height; gpoint.left = R.left;
														redraw(gpoint)
														return ;

													case 'br':
														R.width += diff.left;
														R.height += diff.top;
														gpoint.left = R.left+R.width; gpoint.top = R.top+R.height;
														redraw(gpoint)
														return ;


												}
											}
											if(gline){
												switch(gline.type){
													case 't':
														R.top += diff.top;
														R.height -= diff.top;
														gline.begin.top = gline.end.top = R.top;
														redraw(gline);
														return;
													case 'r':
														R.width += diff.left;
														gline.begin.left =	gline.end.left = R.width + R.left;
														redraw(gline);
														return;
													case 'b':
														R.height += diff.top;
														gline.begin.top =gline.end.top = R.height + R.top;
														redraw(gline);
														return;
													case 'l':
														R.left += diff.left;
														R.width -= diff.left;
														gline.begin.left =	gline.end.left = R.left;
														redraw(gline);
														return;

												}
											}
											if(whole){
												R.top += diff.top; R.left += diff.left;
												redraw(false);

											}
										}

										//actually start dragging



								}else{
									var p1 = {top:R.top, left:R.left, type:'tl'},
										p2 = {top: R.top, left: R.left + R.width, type:'tr'},

										p3 = {top:R.top+R.height, left:R.left+R.width, type:'br'},
										p4 = {top:R.top+R.height, left:R.left, type:'bl'},

										l1 = {begin:p1, end:p2, type:'t'},
										l2 = {begin:p2, end:p3, type:'r'},

										l3 = {begin:p3, end:p4, type:'b'},
										l4 = {begin:p4, end:p1, type:'l'};

									var points = [p1,p2,p3,p4];
									var lines = [l1, l2, l3, l4];
									for(var p in points){
										var point = points[p];
										if (is_closeP(point,evt)){
											point['point']=true;
											gpoint = point;

											redraw(point);
											return;
										}else{
											gpoint = false
										}
									}

									for(var l in lines){
										var line = lines[l];
										if (is_closeL(line,evt)){
											//// // console.log(line)
											line['point'] = false
											gline = line
											redraw(line)
											return;
										}else{
											gline = false;
										}

									}
									//// // console.log('not found')
									redraw(false);
								}
							})
						}
						img.src = result;


					 }
					 ext = this.files[0].type.split('/')[1]

					 if(['jpeg','png','gif'].indexOf(ext) != -1 ){
						 fr.readAsDataURL(this.files[0]);
						 $(this).remove()

					 }else{
						 alert('Принимаются только изображения')
					 }


					}).appendTo(control);






			}`
window.Constructor._show_picture_based_background_list = _show_picture_based_background_list




addPage = `function (is_removable, is_menu_item, title, name, expected_parameters){
				var amount = 0
				for (k in this.Site.pages){amount += 1};

				if (typeof name == 'undefined'){
					slug = "Untitled_page_" + (amount + 1);
					title = "Untitled page " + (amount + 1)

				}else{
					slug = name
					title = title
				}
				if (expected_parameters){
					// expected parameters
					// {parameter: default_value}
				}
				var newPage = {title: title,
								 blocks :[],
								 removable: is_removable,
								 show_in_menu: is_menu_item,
								 layout : 'same',
								 params: expected_parameters,
								 order: amount + 1}
				this.Site.pages[slug] = newPage;
				//

			}`
window.Constructor.addPage = addPage




deletePage = `function (name){
				delete this.Site.pages[name] ;
				this.redraw_cp(1);

			}`
window.Constructor.deletePage = deletePage



downPage = `function (name) {
				var ix = this.Site.pages[name].order

				this.Site.pages[name].order = ix + 1

				var subst = this.page_order_index[ix+1]
				//console.log(name, subst, this.page_order_index)
				var ix_s = this.Site.pages[subst].order
				this.Site.pages[subst].order = ix_s -1
				this._save_site();
				this.load_site()
				this.redraw_cp(1);
			}`
window.Constructor.downPage = downPage




upPage = `function (name) {
				var ix = this.Site.pages[name].order
				//new_order = ix-1
				this.Site.pages[name].order = ix-1


				var subst = this.page_order_index[ix-1]
				//console.log(name, subst, this.page_order_index)
				var ix_s = this.Site.pages[subst].order
				// new_order_subst = ix_s +1
				this.Site.pages[subst].order = ix_s +1
				this._save_site();

				this.load_site()
				this.redraw_cp(1);
			}`
window.Constructor.upPage = upPage


###
showUserScheme = `function () {
				// Сначала, мы должны отобразить всех пользователей, который авторизованы для этого сайта
				// Потом мы должны отобразить все роли, которыми располагают приложения
				// Потом мы должны создать возможность давать приглашения пользователям чтобы редактировать наш сайт

				// this._app_admin_contents = $('<div>').appendTo(this._app_admin_cont)

				var self = this;
				var dialog = $('<div>').appendTo('#controls')
				.dialog({title:'Назначение ролей другим пользователям',
						 buttons:{'Пригласить другого пользователя':function(){
							 			var invited = $('<div>').appendTo($('#controls'));
										$('<input>').addClass('email').appendTo(invited)
							 			invited.dialog({width:400, height:200, buttons:{'Пригласить': function () {
										var email = invited.find('input.email').val()
										var my_hostname = window.location.host
										var ID= DB.save_object_sync('generic.' + BASE_SITE, 'invite', {'email': email, 'to': my_hostname, is_unique:true})
										// console.log(ID);
										DB.send_email(email, 'invite to access ' + my_hostname,
															"this is invite to take part in be-web.ru project http://" + my_hostname +
															". You can create your account <a href='http://be-web.ru/register/'>here</a>" )

															self.Site.Roles.push({user: email, roles: [] })
															self._save_site()
															invited.dialog('close')
															self.showUserScheme();
															invited.dialog('close')

							 			}


						 				}
									})

							 			console.log('inviting')
									},
									'Закрыть': function(){ dialog.dialog('close') },
									'Применить': function(){
										self._save_site();
									}
					 			},

						 width:600, height:500})

				$.each( this.Site.Roles , function(ix, obj){
					var user= obj.user
					var ROLES = obj.roles

					// console.log(user, ROLES)
					var user_control = $('<div>').appendTo(dialog).css('border','1px solid black').addClass('inactive users')
					var expand = function(evt){
						if ($(this).hasClass('inactive')){
							$(this).parent().find('.users').addClass('inactive')
							$(this).removeClass('inactive')
							$(this).parent().find('inactive ul.-stops').remove()
							var ul = $('<ul>').appendTo($(this)).addClass('-stops');
							var add_group_controls=function(_ix, app ){
								log("check app_name", _ix, app)
								for (var i=0; i < app.roles.length; i++){
									var role;
									role = app.roles[i] + '#' + _ix
									// log("INSERTING ROlES",app.roles[i], app.default_role)

									if(app.roles[i] != app.default_role){
										var li = $("<li>").appendTo(ul);
										var ch = $('<input >').prop('id','id_ch_'+role)
														  .prop('type','checkbox').appendTo(li)
														  .click(function(evt){
															  var is_on = $(this).prop('checked')
															  if (is_on){
																  self.Site.Roles[ix].roles.push(role)

															  }else{
																  var ixxx = self.Site.Roles[ix].roles.indexOf(role)
																  self.Site.Roles[ix].user.splice(ixxx,1)
															  }

														  })
										var lch = $('<label>').prop('for','id_ch_'+role)
														  .prop('type','checkbox').appendTo(li).text(role)
										log("WHAT ?,", role, ROLES);
										if(ROLES.indexOf(role) != -1){
											ch.prop('checked', true)
										}

									}
								}
							}
							$.each( self.Site.Applications , add_group_controls)
						}

					}
					user_control.text(user)
					user_control.on('click', expand);

				})

			}`
###
window.Constructor.showUserScheme = ->

  # Сначала, мы должны отобразить всех пользователей, который авторизованы для этого сайта
  # Потом мы должны отобразить все роли, которыми располагают приложения
  # Потом мы должны создать возможность давать приглашения пользователям чтобы редактировать наш сайт

  # this._app_admin_contents = $('<div>').appendTo(this._app_admin_cont)
  self = this
  dialog = $("<div>").appendTo("#controls").dialog(
    title: "Назначение ролей другим пользователям"
    buttons:
      "Пригласить другого пользователя": ->
        invited = $("<div>").appendTo($("#controls"))
        $("<input>").addClass("email").appendTo invited
        invited.dialog
          width: 400
          height: 200
          buttons:
            "Пригласить": ->
              email = invited.find("input.email").val()
              my_hostname = window.location.host
              DB.save_object_sync("generic." + BASE_SITE, "invite",
                email: email
                to: my_hostname
                is_unique: true
              )

              DB.send_email email, "invite to access " + my_hostname, "this is invite to take part in be-web.ru project http://" + my_hostname + ". You can create your account <a href='http://be-web.ru/register/'>here</a>"
              self.Site.Roles.push
                user: email
                roles: []

              self._save_site()
              invited.dialog "close"
              self.showUserScheme()
              invited.dialog "close"

        # console.log "inviting"

      "Закрыть": ->
        dialog.dialog "close"

      "Применить": ->
        self._save_site()

    width: 600
    height: 500
  )
  log "SITE ROLES", @Site.Roles
  if not  @Site.Roles?
    $("<div>").appendTo(dialog).text("Чтобы управлять пользователями надо сначала сохранить сайт хотя бы один раз")
  else
    $.each @Site.Roles, (ix, obj) ->
      user = obj.user
      ROLES = obj.roles

      # console.log(user, ROLES)
      user_control = $("<div>").appendTo(dialog).css("border", "1px solid black").addClass("inactive users")
      expand = (evt) ->
        if $(this).hasClass("inactive")
          $(this).parent().find(".users").addClass "inactive"
          $(this).removeClass "inactive"
          $(this).parent().find("inactive ul.-stops").remove()
          ul = $("<ul>").appendTo($(this)).addClass("-stops")
          add_group_controls = (_ix, app) ->
            log "check app_name", _ix, app
            i = 0

            while i < app.roles.length
              role = undefined
              role = app.roles[i] + "#" + _ix

              # log("INSERTING ROlES",app.roles[i], app.default_role)
              unless app.roles[i] is app.default_role
                li = $("<li>").appendTo(ul)
                ch = $("<input >").prop("id", "id_ch_" + role).prop("type", "checkbox").appendTo(li).click((evt) ->
                  is_on = $(this).prop("checked")
                  if is_on
                    self.Site.Roles[ix].roles.push role
                  else
                    ixxx = self.Site.Roles[ix].roles.indexOf(role)
                    self.Site.Roles[ix].user.splice ixxx, 1
                )
                lch = $("<label>").prop("for", "id_ch_" + role).prop("type", "checkbox").appendTo(li).text(role)
                # log "WHAT ?,", role, ROLES
                ch.prop "checked", true  unless ROLES.indexOf(role) is -1
              i++

          $.each self.Site.Applications, add_group_controls

      user_control.text user
      user_control.on "click", expand


###


showSEOScheme = `function () {
				var self = this;
				var meta_yandex, meta_google, sname;

				var save_metas = function () {
					// console.log('>');
					var my = meta_yandex.val();
					var mg = meta_google.val();
					var sname_ = sname.val();
					if ('seo' in self.Site){
						self.Site['seo']['metas'] = { yandex:my, google:mg };
					}else{
						self.Site['seo'] = {'metas': { yandex:my, google:mg } };
					}
					self.Site['seo']['title'] = sname_
				}

				var seod = $('<div>').dialog({title:"Оптимизация для поисковых систем",width:500, height:400,
					buttons:{'Сохранить': function(){
						save_metas();
						self._save_site()
						self.redraw();

					}

					}
				})

				var ul = $('<ul>').appendTo(seod)

				var li = $('<li>').appendTo(ul)
				$('<span>').text('Наименование сайта (отображается в title)').appendTo(li);
				sname = $('<input>').appendTo(li).change(function(){
					save_metas()
				})
				if ('seo' in self.Site){
					sname.val(self.Site['seo']['title'] )
				}

				var li = $('<li>').appendTo(ul)
				$('<span>').text('Яндекс').appendTo(li);
				meta_yandex = $('<input>').appendTo(li).change(function(){
					save_metas()
				})
				if ('seo' in self.Site){
					meta_yandex.val(self.Site['seo']['metas']['yandex'] )
				}
				var li = $('<li>').appendTo(ul)
				$('<span>').text('Google').appendTo(li);
				meta_google = $('<input>').appendTo(li).change(function(){
					save_metas()
				})
				if ('seo' in self.Site){
					meta_google.val(self.Site['seo']['metas']['google'] )
				}


				var li = $('<li>').appendTo(ul)
				$('<span>').text('Кеширование содержимого - обязательно').appendTo(li);
				$('<input type="button">').val('Запустить').button()
				.appendTo(li).click(function(){
					$(this).hide();
					self.caching();
					$(this).show();

				})



			}`
###
window.Constructor.showSEOScheme = ->
  self = this
  meta_yandex = undefined
  meta_google = undefined
  sname = undefined
  save_metas = ->

    # console.log('>');
    my = meta_yandex.val()
    mg = meta_google.val()
    sname_ = sname.val()
    if "seo" of self.Site
      self.Site["seo"]["metas"] =
        yandex: my
        google: mg
    else
      self.Site["seo"] = metas:
        yandex: my
        google: mg
    self.Site["seo"]["title"] = sname_

  seod = $("<div>").dialog(
    title: "Оптимизация для поисковых систем"
    width: 500
    height: 400
    buttons:
      "Сохранить": ->
        save_metas()
        self._save_site()
        self.redraw()
  )
  ul = $("<ul>").appendTo(seod)
  li = $("<li>").appendTo(ul)
  $("<span>").text("Наименование сайта (отображается в title)").appendTo li
  sname = $("<input>").appendTo(li).change(->
    save_metas()
  )
  sname.val self.Site["seo"]["title"]  if "seo" of self.Site
  li = $("<li>").appendTo(ul)
  $("<span>").text("Яндекс").appendTo li
  meta_yandex = $("<input>").appendTo(li).change(->
    save_metas()
  )
  meta_yandex.val self.Site["seo"]["metas"]["yandex"]  if "seo" of self.Site and 'metas' of self.Site.seo
  li = $("<li>").appendTo(ul)
  $("<span>").text("Google").appendTo li
  meta_google = $("<input>").appendTo(li).change(->
    save_metas()
  )
  meta_google.val self.Site["seo"]["metas"]["google"]  if "seo" of self.Site and 'metas' of self.Site.seo
  li = $("<li>").appendTo(ul)
  $("<span>").text("Кеширование содержимого - обязательно").appendTo li
  $("<input type=\"button\">").val("Запустить").button().appendTo(li).click ->
    $(this).hide()
    self.caching()
    $(this).show()


window.Constructor.showTextColorScheme = ->

  templ = "
<div>
  <ul>
  <li> Текст <div name ='text_color' style='width:30px; height:20px; background-color:{{ text_color }}; display:inline-block'></div></li>
  <li> Ссылки <div name ='link_color' style='width:30px; height:20px; background-color:{{ link_color }}; display:inline-block'></div></li>
  <li> Посещенные ссылки <div name ='visited_color' style='width:30px; height:20px; background-color:{{ visited_color }}; display:inline-block'></div></li>
  <li> Активные ссылки <div name ='active_color' style='width:30px; height:20px; background-color:{{ active_color }}; display:inline-block'></div></li>
  <li> Ссылка под курсором <div name ='hover_color' style='width:30px; height:20px; background-color:{{ hover_color }}; display:inline-block'></div></li>


</ul>
<p> Могут примениться только после перезагрузки всего сайта это требует его сохранения</p>
</div>
"

  #colors = @getTextColors()
  hsbas = {}
  if @Site.textColors?
    for attr, val of @Site.textColors
      hsbas[attr] = val
  current_cols = @getTextColors()



  ht = Mustache.render(templ, current_cols)
  cold = $("<div>").html(ht)
  cold.find('div[name]').click (e) =>
    col_type = $(e.target).attr('name')
    d =$(e.target)
    setter = (col, ix, hsba) ->
      d.css('background-color', col )
      hsbas[col_type] = {index:ix,rgb:col}
      {}

    color_chooser = @draw_color_chooser setter
    color_chooser.appendTo($('#controls')).position({of:$(e.target), my:'left top', at:'right bottom'})

  #log("SMT")
  cold.dialog(
    title: "Цвет ссылок и текста"
    width: 400
    height: 400
    buttons:
      "Сохранить и перезагрузить": =>
        log(@)
        @Site.textColors = hsbas
        @_save_site()

        cold.dialog('close')
        window.location.reload()
      "Сохранить без перезагрузки": =>
        log(@)
        @Site.textColors = hsbas
        @_save_site()
        @redraw()
        cold.dialog('close')

      "Отмена": =>
        @redraw()
        cold.dialog('close')

  )

window.Constructor.backgroundChooser =(type) ->
  self = this

  if @Site.backgrounds?
    old_background = $.extend(true, {}, @Site.backgrounds[type])
  else
    old_background = {}
    @Site.backgrounds = {}
    @Site.backgrounds[type] = {}

  onPattern = (patt) =>
    @Site.backgrounds[type] =
      type: "pattern"
      pattern: patt

    @redraw_background()

  onColor = (color, pal_ix, hsba) ->
    self.Site.backgrounds[type] =
      type: "color"
      color: pal_ix

    self.redraw_background()

  onCancel = ->
    self.Site.backgrounds[type] = old_background
    self.redraw_background()
    $(this).dialog "close"

  onSave = ->
    self.redraw_background()
    self._save_site()
    $(this).dialog "close"

  self.drawBackgroundSelectorDialog onPattern, onColor, onCancel, onSave


window.Constructor.getAppSource = (app_name) ->
  T = """
{
name : "{{name}}",
title:"{{title}}",
roles: {{& roles }},
default_role:'{{default_role}}',
data:{{& data}},
Main: function(constr, appid ){
	   {{& Main.body }}
	},
	getter: function(constr, appid){
	  return this.Main()
	} }
"""
  app = @getAppJson(app_name)
  #app.Main = (new Function(app.Main.attr, app.Main.body)).toString()
  # app.Main = app.Main.body
  app.data = JSON.stringify(app.data) if app.data and app.data?
  app.roles = JSON.stringify(app.roles)
  app.name = app.app_name.split('.')[0]

  result = Mustache.render(T, app)
  log(result)
  result


window.Constructor.show_CP = (active_tab) ->
  self = this
  C = $("div#controls")
  @cp = $("<div>").appendTo(C).width(360).height(window.innerHeight).css("position", "fixed").css("top", 0).css("left", 0)
  @_app_admin_cont = $("<div>").css("position", "fixed").css("overflow", "scroll").css("top", 0).css("left", 240).width(1100).height(window.innerHeight).css("background", "white").zIndex(2000).appendTo(C).hide()
  $("<div>").css("background", "orange").width(@_app_admin_cont.width()).append($("<button>").text("HIDE").click(->
    self._app_admin_cont.hide()
  )).appendTo @_app_admin_cont
  @_app_admin_contents = $("<div>").appendTo(@_app_admin_cont)
  $("<div>").height(50).width("100%").appendTo(@cp).append $("<button>").button().text("hide").click(->
    self.cp.remove()
    self.CPmarker.show()
  )
  @cp_acc = $("<div>").appendTo(@cp)
  $("<h3>").text("Основные").appendTo @cp_acc
  d = $("<div>").appendTo(@cp_acc)
  ul = $("<ul>").appendTo(d)
  $("<li>").append($("<a>").prop("href", "#").text("Фон сайта").click(->self.backgroundChooser "body")).appendTo ul
  $("<li>").append($("<a>").prop("href", "#").text("Фон центральной части сайта").click(->self.backgroundChooser "content")).appendTo ul
  $("<li>").append($("<a>").prop("href", "#").text("Цветовая схема").click(->
    self.showColorScheme()
  )).appendTo ul
  $("<li>").append($("<a>").prop("href", "#").text("Цвет текста").click(->
    self.showTextColorScheme()
  )).appendTo ul

  $("<li>").append($("<a>").prop("href", "#").text("Создание фонов").click(->
    self.showBackgroundScheme()
  )).appendTo ul
  $("<li>").append($("<a>").prop("href", "#").text("Шрифты").click(->
    self.showFontsScheme()
  )).appendTo ul
  $("<li>").append($("<a>").prop("href", "#").text("Управление геометрией").click(->
    self.showLayoutScheme()
  )).appendTo ul
  $("<li>").append($("<a>").prop("href", "#").text("Управление доменами").click(->
    self.showDomainScheme()
  )).appendTo ul
  $("<li>").append($("<a>").prop("href", "#").text("Управление Ролями и пользователями").click(->
    self.showUserScheme()
  )).appendTo ul
  $("<li>").append($("<a>").prop("href", "#").text("Поисковые системы").click(->
    self.showSEOScheme()
  )).appendTo ul
  $("<li>").append($("<a>").prop("href", "#").text("Сохранение сайта").css("color", "red").click(->
    self._save_site true
  )).appendTo ul
  $("<h3>").text("Мои страницы").appendTo @cp_acc
  d = $("<div>").appendTo(@cp_acc)
  ul = $("<ul>").css("padding", "0").appendTo(d)
  $("<li>").append($("<a>").prop("href", "#").text("Добавить").click(->
    page = undefined
    title = undefined
    kw = undefined
    descr = undefined
    diag = $("<div>").dialog(
      title: "Опции страницы"
      width: 600
      height: 300
      buttons:
        "Сохранить": ->
          self.addPage true, true, title.val(), page.val()
          self._save_site false
          self.redraw_cp 1
          self.redraw()
          diag.dialog "close"
    )
    ul = $("<ul>").appendTo(diag)
    li = $("<li>").appendTo(ul)
    $("<span>").appendTo(li).text "Отображаемое название"
    title = $("<input>").appendTo(li).val("Новая страница")
    li = $("<li>").appendTo(ul)
    $("<span>").appendTo(li).text "slug(англ)"
    amount = 0
    for k of self.Site.pages
      amount += 1
    page = $("<input>").appendTo(li).val("untitled_page_" + amount)
  )).appendTo ul
  pages = $.extend(true, {}, @Site.pages)
  pa = []
  $.each pages, (i, p) ->
    p.slug = i
    pa.push p

  pa.sort (a, b) ->
    a.order - b.order

  $.each pa, (ix, p) ->
    i = p.slug
    li = $("<li>").appendTo(ul)
    unless p.order is 0
      li.append $("<button>").button(icons:
        primary: "ui-icon-arrowthick-1-n"
      ).width(32).height(32).css("margin-left", "5px").css("background-size", "120% 120%").click(->
        self.upPage i
        self.redraw()
      )
    unless (self.page_amount - 1) is p.order
      li.append $("<button>").button(icons:
        primary: "ui-icon-arrowthick-1-s"
      ).width(32).height(32).css("margin-left", "5px").css("background-size", "120% 120%").click(->
        self.downPage i

        #self._save_site()
        self.redraw()
      )
    a = $("<a>").prop("href", "#!" + i).text(p.title).click((e) ->
      window.location.hash = i
      e.preventDefault()
    ).appendTo(li)

    # log('descr', $(this), $(this).val());
    li.append($("<button>").button(icons:
      primary: "ui-icon-pencil"
    ).width(32).height(32).css("margin-left", "20px").css("background-size", "120% 120%").click(->
      diag = $("<div>").dialog(
        title: "Опции страницы"
        width: 600
        height: 300
        buttons:
          "Сохранить": ->
            self._save_site false
            self.redraw()
            self.redraw_cp 1
      )
      ul = $("<ul>").appendTo(diag)
      li = $("<li>").appendTo(ul)
      $("<span>").appendTo(li).text "Отображаемое название"
      $("<input>").appendTo(li).val(p.title).keyup ->
        self.Site.pages[i].title = $(this).val()

      li = $("<li>").appendTo(ul)
      $("<span>").appendTo(li).text "slug(англ)"
      if i isnt ""
        $("<input>").appendTo(li).val(i).keyup ->
          np = $.extend(true, {}, self.Site.pages[i])
          delete self.Site.pages[i]

          ix = $(this).val()
          self.Site.pages[ix] = np

      else
        $("<span>").css("color", "red").appendTo(li).text "Не изменяется для главной страницы"
      li = $("<li>").appendTo(ul)
      $("<span>").appendTo(li).text "Ключевые слова через запятую"
      kw = $("<input>").appendTo(li).val(self.Site.pages[i].keywords).keyup(->
        self.Site.pages[i].keywords = $(this).val()
      )
      li = $("<li>").appendTo(ul)
      $("<span>").appendTo(li).text "Описание страницы"
      descr = $("<textarea>").appendTo(li).val(self.Site.pages[i].description).keyup(->
        self.Site.pages[i].description = $(this).val()
        #log self.Site.pages[i]
      )
    )).css "padding-bottom", "10px"
    if self.Site.pages[i].removable
      li.append $("<button>").button(icons:
        primary: "ui-icon-closethick"
      ).width(32).height(32).css("margin-left", "5px").css("background-size", "120% 120%").click(->
        self.deletePage i
        self._save_site()
        self.redraw()
      )

# Applications 3
  app_menu_template = '
<div>
  <ul id="id_app_list">
    {{#apps}}
      <li> <a id="id_open_admin" href="#" app_name={{val.app_name}}>{{ val.title }} </a>{{#val.is_own}}<a id="id_edit_app" href="#" app_name="{{ val.app_name }}" >edit</a>{{/val.is_own}}</li>
    {{/apps}}
  </ul>
</div>'
  template_create = '
  <div id = "app_dialog">
    <div id="app_tabs">
    <ul>
      <li> <a href="#source"> Sourcecode         </a></li>
      <li> <a href="#publishing"> Publishing     </a></li>
    </ul>
    <div id="publishing">
      Here is publishing utils
    </div>
    <div id=source>
        <textarea id="id_source_textarea" style="width:600px; height:700px">{{ source }}</textarea>
    </div></div></div>'
  template_searcher = "
    <div id='id_search_dialog'>
      <ul id='my_apps'>
        {{# apps }}
          <li> {{ title }} {{^in_app}} <input class='_add_button' type='button' app_name='{{ app_name }}' value='+'> {{/in_app}}</li>
        {{/apps }}

      </ul>
      <input id='id_app_search_input' />
      <div id='id_search_results'>
      </div>
    </div>
  "
  template_search_results = "
  <ul>
    {{#apps}}
      <li> {{ title }} {{^in_app}}<input class='_add_button' type='button' app_name='{{app_name}}' value='+'>{{/in_app}} </li>
    {{/apps}}
  </ul>
  "


  E = (evt) =>

    app = $(evt.target).attr 'app_name'
    #log "FFFuuu", app

    if app?
        source = @getAppSource app
    else
        source = @default_app
    html = Mustache.render(template_create , {source: source } )
    @_app_admin_contents.html html
    @_app_admin_contents.find('#app_tabs').tabs()
    @_app_admin_contents.find('#app_dialog').dialog
      title : "Новое приложение"
      width: 800
      height: 900
      buttons:
        save: ->
          t = editAreaLoader.getValue("id_source_textarea")
          res = eval("(" + t + ")")
          res = JSON.stringify(res, (key, val) ->
            if typeof val is "function"
              fstr = val.toString()
              startBody = fstr.indexOf("{") + 1
              endBody = fstr.lastIndexOf("}")
              body = fstr.substring(startBody, endBody)
              {is_function: true,body: body}
            else val
          )
          #log( typeof res )
          DB.save_application res  # if "Main" of res and "getter" of res and "roles" of res and "data" of res
    editAreaLoader.init
      id: "id_source_textarea"
      syntax: "js"
      start_highlight: true
      replace_tab_by_spaces: 4


  $("<h3>").text("Приложения").appendTo @cp_acc
  app_menu = $( Mustache.render(app_menu_template, {'apps':({key:k,val:v } for k,v of @Site.Applications )}) )
  @cp_acc.append app_menu
  ul = app_menu.find('#id_app_list')
  app_menu.find('a#id_edit_app').click E
  #log("LINKS WHERE", app_menu.find('a#id_open_admin').bind)
  app_menu.find('a#id_open_admin').css('cursor','pointer').bind 'click', (e)=>
    app_name = $(e.target).attr('app_name')
    app = @Site.Applications[app_name]
    if app.admin_page?
      app.admin_page(self._app_admin_contents);
      self._app_admin_cont.show()



  adder = (e) =>
    app_name = $(e.target).attr 'app_name'
    if app_name not in @Site._Apps
      @Site._Apps.push app_name
      @_save_site();



  SF = (evt) =>
    $.ajax
      url: "/app/list/",
      dataType: "JSON",
      success: (js) =>
        vals = for k in js.apps
          if k.app_name in @Site._Apps
            k['in_app'] = true
          k
        dhtml = Mustache.render(template_searcher, {apps:vals})
        #log(@, @@)
        @_app_admin_contents.html dhtml
        res_cont = @_app_admin_contents.find("#id_search_results")
        @_app_admin_contents.find('._add_button').click adder

        dialog=@_app_admin_contents.find( "#id_search_dialog").dialog
          width:600
          height:600
        dialog.find('#id_app_search_input').bind 'keyup', (e)=>
          val = $(e.target).val()
          $.ajax
            url: "/app/list/"
            data:
              iname: val
            dataType: 'JSON'
            success: (js)=>
              vals = for k in js.apps
                if k.full_name in @Site._Apps
                  k['in_app'] = true
                k

              reshtml = Mustache.render(template_search_results, {apps:vals} )
              res_cont.html reshtml
              res_cont.find('._add_button').click adder

          # TODO: отобразить диалог

  $("<li>").appendTo(ul).append( $("<a>").prop("href", "#").text("Создать").click (E) )
  $("<li>").appendTo(ul).append( $("<a>").prop("href", "#").text("Найти и добавить").click (SF) )







  $("<h3>").text("Виджеты").appendTo @cp_acc
  d = $("<div>").appendTo(@cp_acc)
  ul = $("<ul>").appendTo(d)
  $.each @Site.Applications, (app_name, app) =>
    if app.widgets
      li = $("<li>").text(app.title).appendTo(ul)
      ul_ = $("<ul>").appendTo(li)
      $.each app.widgets, (name, w) =>
        $("<li>").text(w.title).appendTo(ul_).prop("type", name + "." + app_name).draggable
          scroll: false
          start: ->
          helper: -> $("<div>").text "drag me"
          drag: (event, ui) =>
            left = event.clientX + $(document).scrollLeft() - self._main_offset.left
            top = event.clientY + $(document).scrollTop() - self._main_offset.top
            #log(@)
            ll = @_stepping_left(left)
            tt = @_stepping_top(top)
            @widget_drag_state = {left: ll.block, top: tt.block}
            ui.position =
              top: tt.val - $(document).scrollTop() + self._main_offset.top
              left: ll.val - $(document).scrollLeft() + self._main_offset.left
          stop: (e)=>
            type = $(e.target).prop("type")
            # log("We just stopped",type, @widget_drag_state)
            @add_block @widget_drag_state.left, @widget_drag_state.top, type, w.default_size
            @redraw()




  if active_tab
    @cp_acc.accordion({active: active_tab, heightStyle: "fill"})
  else
    @cp_acc.accordion()



###

    #  buttons:
    #    save: ->
    #      t = editAreaLoader.getValue("id_source_textarea")
    #      res = eval_("(" + t + ")")
    #      res = JSON.stringify(res, (key, val) ->
    #        if typeof val is "function"
    #          fstr = val.toString()
    #          startBody = fstr.indexOf("{") + 1
    #          endBody = fstr.lastIndexOf("}")
    #          body = fstr.substring(startBody, endBody)
    #          fobj =
    #            is_function: true
    #            body: body
    #
    #            return fobj
    #        val
    #      )
    #      DB.save_application res  if "Main" of res and "getter" of res and "roles" of res and "data" of res
    #)
###