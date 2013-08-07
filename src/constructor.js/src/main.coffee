
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
