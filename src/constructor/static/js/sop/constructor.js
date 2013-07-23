
	
({	
	Constructor : function (){
		//base_height = 5; // em
		var test_block_content = "Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt, explicabo. Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos, qui ratione voluptatem sequi nesciunt, neque porro quisquam est, qui dolorem ipsum, quia dolor sit, amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt, ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit, qui in ea voluptate velit esse, quam nihil molestiae consequatur, vel illum, qui dolorem eum fugiat, quo voluptas nulla pariatur? At vero eos et accusamus et iusto odio dignissimos ducimus, qui blanditiis praesentium voluptatum deleniti atque corrupti, quos dolores et quas molestias excepturi sint, obcaecati cupiditate non provident, similique sunt in culpa, qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio, cumque nihil impedit, quo minus id, quod maxime placeat, facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet, ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.";
		var Site = false; 
		default_site = {
					_Apps:['generic', 'theshop'] ,
					layout:{cols:12, 
							fixed: true, 
							grid: {hor:10, ver:3}, 
							padding: {left:10, top:10},
							width:960,
							drawen_lines:30,
							base_height:50},	
					colors:{type:'mono', 
							base:120, 
							brightness:100, 
							lights:50, 
							saturation:100, 
							shadows:50},	
					backgrounds:{},
					patterns: [],
					blocks:[{x:0,y:0, width:3, height:3,widget:{name:'generic.text', data:test_block_content } , display_on:'all', dont_display_on : [] },
							{x:3,y:0, width:4, height:2,	 widget:{name:'generic.text', data:test_block_content } , display_on:'', dont_display_on : [] },
							{x:7,y:0, width:5, height:2,	 widget:{name:'generic.image', data:{} } , display_on:'about', dont_display_on : [] },
							
							 ],
					default_block_settings :false,
											
					pages : {"": {layout:"same",
								title:"Main page of my project",
								
								//blocks: [{x:0,y:0, width:3, height:3, ix:1} ,
								//		 {x:3,y:0, width:4, height:2, ix:1, settings:{background_color:{h:15,s:100, b:100}, border_width:0} } ,
								//		 {x:7,y:0, width:5, height:5, widget:{name:'generic.image', data:{} } } ],
										 
							},
							"about":{layout:'same',
										title:"Page about project",
										// blocks: [{x:0,y:0, width:3, height:3, widget:{name:'generic.text', data:test_block_content }} ,
										//			{x:3,y:0, width:4, height:2, widget:{name:'generic.text', data:test_block_content } } ,
										//			{x:7,y:0, width:5, height:5, widget:{name:'generic.image', data:{} } } ],
										
						},
					}
				}
				
		function scaleImage(img,  maxWidth, maxHeight, useMax){
			
			var width = img.width,
				height = img.height;
			if(useMax){
				scale = Math.max(maxWidth / width, maxHeight / height); 
			}else{
				scale = Math.min(maxWidth / width, maxHeight / height); 
			}
				
				
			width = parseInt(width * scale, 10);
			height = parseInt(height * scale, 10);
			
			img.width = width;
			img.height = height;
			return img;


			}
		function clone(obj) {
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
			}
		function rgb2hsv () {
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
		function hsvToRgb(o, as_array)	{
			var h, s, v;
			var r, g, b;
			var i;
			var f, p, q, t;
			// h = o.h, s=o.s, v = o.v
			// Make sure our arguments stay in-range
			h = Math.max(0, Math.min(360, o.h));
			s = Math.max(0, Math.min(100, o.s));
			v = Math.max(0, Math.min(100, o.b));
		 
			// We accept saturation and value arguments from 0 to 100 because that's
			// how Photoshop represents those values. Internally, however, the
			// saturation and value are calculated from a range of 0 to 1. We make
			// That conversion here.
			s /= 100;
			v /= 100;
		 
			if(s == 0) {
				// Achromatic (grey)
				r = g = b = v;
				//return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
			}else{
				 h /= 60; // sector 0 to 5
				 i = Math.floor(h);
				 f = h - i; // factorial part of h
				 p = v * (1 - s);
				 q = v * (1 - s * f);
				 t = v * (1 - s * (1 - f));
		 
				 switch(i) {
					 case 0:
						 r = v;
						 g = t;
						 b = p;
						 break;
		 
					 case 1:
						 r = q;
						 g = v;
						 b = p;
						 break;
		 
					 case 2:
						 r = p;
						 g = v;
						 b = t;
						 break;
		 
					 case 3:
						 r = p;
						 g = q;
						 b = v;
						 break;
		 
					 case 4:
						 r = t;
						 g = p;
						 b = v;
						 break;
		 
					 default: // case 5:
						 r = v;
						 g = p;
						 b = q;
				 }
				
			}
		 
			if(as_array){
				
				return [Math.round(r*255) , Math.round(g*255) , Math.round(b*255) ]
			}else{
				
				var rgb = Math.round(b*255) | (Math.round(g*255) << 8) | (Math.round(r*255) << 16);
				rgbc =	"#" + (0x1000000 | rgb).toString(16).substring(1);
				
				return rgbc
			}

		}
		var pg = {
			// blocks : [],
			page_vars : {},
			_app_cache:{},
			rect: function(x,y,w,h){
			return {left:x, top:y, width:w, height:h}	 ;
			},
			set_app_cache: function (name, c) {
				if (this._app_cache){
					this._app_cache[name] = c
				}
				
			},
			get_app_cache: function (name) {
				if (this._app_cache[name]){
					return this._app_cache[name]
				}else{
					return {}
				}
				
			},
			
			
			
			move_block: function( ix, x, y, dont_save){
				var bl = this.Site.blocks.splice(ix,1)[0]
				bl.x = x; bl.y = y;
				this.Site.blocks.push(bl)
				if(!(dont_save)){
					this._save_site();
				}
			},
			add_block:function(x,y, type, ds){
				
				this.Site.blocks.push(	{width:ds[0],height:ds[1], 
									x:x, y:y,
									widget:{name:type, data: ''	 },
									display_on : this.current_page,
									dont_display_on :[], 
								});
				
			

			},
			get_block:function(p){
				return this.Site.blocks[p]

			},
			delete_block:function(ix){
				this.Site.blocks.splice(ix,1)
				
			},
			getApp: function(name){
				var scr = $.ajax({
								url: STATIC + "js/sop/" + name + ".js",
								async:false
							}).responseText;
							
				var C = eval("[" + scr + "]")[0];
				// console.log("WTF", ;
				App = C.getter(this)
			
			return App;
			},
			
			load_site:function(do_reload){
				if(typeof (do_reload) == 'undefined'){
					do_reload = false
				}else{
					do_reload = true
				}
				var is_site = typeof this.Site != 'undefined'
				//console.log(do_reload)
				if (is_site & !do_reload){
					return
				}else{
					// AJAX HERE
					S = DB.get_objects(this._site_type, {} )
					// // // console.log(S)
					
					if (S.total_amount != 0 ) {
						this.Site = S.objects[0];
						if (typeof this.Site.layout.grid == 'undefined'){
							this.Site.layout.grid = this.Site.layout.padding;
							this.Site.layout.padding = {top:50, left:10}
						}
						
					}else{
						// // // console.log("LLLL");
						this.Site = default_site;
					}
					var apps = this.Site._Apps;
					var apps_ = {};
					for (ax in apps){
						var app_name =	apps[ax];
						var app = this.getApp(app_name)
						apps_[app_name] = app
					}
					this.Site['Applications'] = apps_;
					
					if(! this.Site.blocks){
						this.Site.blocks = []
						//var self = this;
						for(page in this.Site.pages){
							var blocks = $.map(this.Site.pages[page].blocks, function(o){o.display_on = page; o.dont_display_on = []; return o})
							for (var i =0; i< blocks.length; i++){
								this.Site.blocks.push(blocks[i])
							}
							// console.log("SB", this.Site.blocks)
							
						}
						// console.log(this.Site.blocks)
					}
					
					
					delete this.Site.version
					this.page_order_index = {};
					this.page_amount = 0
					for (i in this.Site.pages){
						this.page_order_index[this.Site.pages[i].order] = i
						this.page_amount +=1;
					}
				}
				
				
			},
			getPageData: function( page_name ){
				// ajax magic:
				this.load_site();
				// this.Site = Site;
				// // // console.log(this.Site);
				return this.Site.pages[page_name]
			},
			
			getBlockSettings: function(pos){
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

			},
			setBlockSettings: function(page_pos, s){
				this.Site.blocks[page_pos].settings = s;
			},
			setDefaultBlockSettings: function(s){
				this.Site.default_block_settings = s;
			},
			
			setWidgetData: function(pos, data){
				//// // console.log(this.Site.pages,this.Site.pages[this.current_page], pos)
				//console.log('Set Wid Data', this, this.current_page,pos);
				//console.log(pos)
				this.Site.blocks[pos].widget.data = data;
				
			},
			getWidgetData: function(pos, def){
				//// // console.log(this.Site.pages,this.Site.pages[this.current_page], pos)
				//console.log('Set Wid Data', this, this.current_page,pos);
				//console.log(pos)
				var self = this;
				return (function(i){
					 var d = self.Site.blocks[pos].widget.data;
					if (d){
						return d
					}
					return def;
					
				})(pos)
				
				
			},
			_init_page: function(){
				
				var hash_ = window.location.hash.slice(1).split('?')
				// console.log(hash_)
				var page_name = hash_[0].replace('!','')
				var params = hash_[1]
				this.current_page = page_name
				if (params){
					a = params.split('&')
					for(i in a){
						var par = a[i].split('=')
						if (par[1]){
							val = par[1]
						 }else{val = true}
						this.page_vars[par[0]] = val
						
					}
					
				}
				// console.log(this.page_vars)
				
				
				pdata = this.getPageData(page_name);
				this.layout = this.Site.layout 
				this.base_height = this.layout.base_height;//pdata.layout.base_height;
				this.inited_blocks = [];
				
			
				
			},
			_save_site: function(){
				// s_str = this.Site
				this.Site['site_id'] = this.site_id;
				self = this;
				DB.save_object_sync(this._site_type, this.Site, function(){ console.log("okey")}, 
				function(xhr){
					O = eval("[" + xhr.responseText +"]")[0]
					self.Site['_id'] = O._id
					// console.log(self.Site, id);
					// console.log('save_complete')
					})
				
				
			},
			init: function(do_construction, site_id){
				this.site_id = site_id;
				this._site_type = "sites"
				this.is_constructor = do_construction
				this.page_cont = $('#id-top-cont');
				var self = this;
				$(window).resize(function(){
					self.redraw();
				})
				window.onhashchange=function(){
					// console.log('hash changed')
					self._init_page();
					self.redraw()
					
					
				}

				
				if(this.is_constructor){
					this.init_cp_marker()
					
				}
				this.redraw()
				// // // console.log(JSON.stringify(this.Site)) 
				
			},
			redraw_cp: function(active_tab){
				
				this.cp_acc.remove()
				this.show_CP(active_tab)
			},
			init_cp_marker: function (){
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
				
			},
			showColorScheme : function(){
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
			},
			_make_pallette:function(){
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
				// lights = [b:95, s:75; b95, s52]
				// shadows = [b:60, s75; b52, s100]
				sat_koef = [0.89, 0.5, 0.5, 0.01];
				br_koef	 = [0.05, 0.05, 0.45 ,0.3];
				
				colors = [h,a,s,A];

				var greys = new Array();
				am = 5
				for(c =0; c <= am; c++){
					_c = {h:0,s:0, b: c * (100/am) }
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
								 
							vars[Number(i)+1] = {h:color,s:sat, b:bri} 
						} 
						this.Site.colors.pallette.push( vars)
						
					}else{
						this.Site.colors.pallette.push(false) ;
					}
				}
			},
			_set_base_hue: function(hue){
				this.Site.colors['base'] = hue;
			},
			_set_scheme_type: function(type){
				this.Site.colors['type'] = type;
			},
			showLayoutScheme:function(){
					
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
			 },
			
			showFontsScheme:function(){
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
			 },
/*		
			showBackgroundScheme:function(){
				var to = this._app_admin_contents;
					to.find('*').remove()
					atabs = $('<div>').appendTo(to)
					ul = $("<ul>").appendTo(atabs);
					$("<li>").append($("<a>").prop('href', "#pic-pattern" ).text("Паттерн от картинки") ).appendTo(ul)
					$("<li>").append($("<a>").prop('href', "#products" ).text("Создание паттерна ") ).appendTo(ul)
					
					$("<li>").append($("<a>").prop('href', "#orders" ).text('orders') ).appendTo(ul)
					
					pic_patt = $("<div>").prop('id',"pic-pattern").appendTo(atabs)
					this._show_picture_based_background_list(pic_patt)
					
					my_patt = $("<div>").prop('id',"pic-pattern").appendTo(atabs)
					this._show_pattern_editor(my_patt)
					
					// prod_cont.text("okey")
					 
					
					orders_cont = $("<div>").prop('id',"orders").appendTo(atabs)
					orders_cont.text("O okey")
					
					atabs.tabs();
				this._app_admin_cont.show()
			 },
					
			_show_pattern_editor: function(to){
				$.each(this.Site.patterns, function(name, pattern){
					
					$("<div>").width(250).slider({min:0, max:100,value:self.Site.colors.brightness, slide:function(event, ui){ self.Site.colors.brightness = ui.value;self._pallete_drawer.apply(self,[c])	}} ).appendTo(to)
				})
			
			},
				
			_show_picture_based_background_list:function(to){
				
			 // First - picture template based
			 $('<input>').prop('type','file').change(function(){
				 var fr = new FileReader()
				 fr.onloadend = function(){
					 "strict";
						var result = this.result;
						var C = $('<canvas>').appendTo(to)
						var S = $('<canvas>')// .appendTo()
						sctx = S[0].getContext('2d')
						
						var img = new Image()
						img.onload = function(){
							// // // console.log (img.width, img.height);
							C[0].width = img.width;
							C[0].height = img.height;
							C.css('border', '1px solid black')
							var ctx = C[0].getContext('2d')
							
							var R = {left:0,top:0, width:img.width, height:img.height}
							var preview = $("<button>").appendTo(to).text("Применить как фон").click(function(){
								ready_image = S[0].toDataURL("image/png")
								$('body')
								.css('background-image','url("' + ready_image +' ")')
								.css('background-repeat','repeat')
								
								
							})
							 
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
								//ctx.stroke();
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
									line_left = Math.min(line.begin.left, line.end.left)
									line_right = Math.max(line.begin.left, line.end.left)
									
									return	(cx > line_left && cx < line_right) && Math.abs(line.begin.top - cy ) < thresh
								}else{
									line_top = Math.min(line.begin.top, line.end.top)
									line_bottom = Math.max(line.begin.top, line.end.top)
									return	(cy > line_top && cy < line_bottom) && Math.abs(line.begin.left - cx ) < thresh
									//vertical
								}
								//return Math.abs(point.top-cy ) < 5 && Math.abs(poing.left-cx) < 5
								
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
										// // // console.log('qqq')
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
									for(p in points){
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
									
									for(l in lines){
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
				 fr.readAsDataURL(this.files[0]);
				 $(this).remove()
				 
				 
				}).appendTo(to);
				
				
				
				
				
				
			},
			*/
			get_color:function(c){
				this._make_pallette()
				// console.log(this.Site.colors, c)
				if (c.v == 'C') {// color from custom palette
					return this.Site.colors.custom_pallette[c.ix]
					
				}else{
					return this.Site.colors.pallette[c.v][c.ix]
				}
				
				
			},
			addCustomColor: function(color){
				if (this.Site.colors.custom_pallette){
					ix = this.Site.colors.custom_pallette.push(color) - 1
				}else{
					this.Site.colors.custom_pallette = [color];
					ix = 0
				}
				return ix
			},
			redraw_background: function(){
				//ßßconsole.log('redraw background', this.Site.backgrounds)
				var self = this;
				$.each(this.Site.backgrounds, function(name, imgo){
					// // console.log(name,imgo)
					
					if (name == 'body'){
						var C = $('body')
						c = C[0];
						
						
					}else if (name == 'content'){
						var C = self.layout_cont;
						
					
					}
					if(imgo.type == 'images'){
						if ( imgo.color ){
							var c = self.get_color( imgo.color )
							C.css('background-color', hsvToRgb( c) ) 
						}
						$('div.background').remove();
						var off = self._main_offset;
						
						$.each(imgo.images,function(i, bg){
							var img = new Image()
							img.onload = function(){
								$('<div>').css('position','absolute')
								.addClass('background')
								.css('background-image', 'url("' + img.src +'")' )
								.css('background-repeat','no-repeat')
								.css('background-size', 'cover')
								.zIndex(-10000).prop('id',i)
								.css('top', off.top + bg.position.top ) // Указание положения относительно центральной части
								.css('left', off.left + bg.position.left ).appendTo($('body'))
								.width(	 img.width	* bg.zoom) 
								.height( img.height * bg.zoom )
							}
							if(bg.data.blob){
								img.src = DB.get_blob_url( bg.data )
							}else{
								img.src = bg.data
							}
							
						})
					}else if (imgo.type == 'pattern'){
						var pat = self.Site.patterns[ imgo.data ]
						
						// console.log("Pattern_id", imgo.data)
						if(name == 'body'){
							c = C[0]
							
							c.background = pat
						}
						else{
							C.css('background-image', 'url("' + pat +'")' );
						}
							
						C.css('background-repeat','repeat')
						.css('background-position','0px 0px')
						
						
						
					}else if(imgo.type == 'none'){
						if(name == 'body'){
							c = C[0]
							c.background = false; 
						}
						else{
							C.css('background-image', '' );
						}
					}
					
						
						
					
				})
			},
			backgroundChooser:function(type) {
				
				
				//var to = this._app_admin_contents;
				//	to.find('*').remove()
				var self = this;
				var cp_ = $('<div>').css('position','absolute').appendTo($('#controls'))
				.position({of: $('body'), my:'left top', at: 'left+200 top_50'})
				.css('padding', '20px').css('background-color', 'orange')
				.draggable({scroll:false})
				$('<button>').text("X").click(function(){
					cp_.remove();
				}).appendTo(cp_);
				$("<button>").text('Убрать фон').click(function(){
					self.Site.backgrounds[type] = {type:'none'};
					self.redraw_background();
				}).appendTo(cp_);
				
					atabs = $('<div>').appendTo(cp_)
					ul = $("<ul>").appendTo(atabs);
					$("<li>").append($("<a>").prop('href', "#pic-patterns" ).text("Библиотека узоров") ).appendTo(ul)
					$("<li>").append($("<a>").prop('href', "#own-patterns" ).text("Создание узоров") ).appendTo(ul)
					$("<li>").append($("<a>").prop('href', "#image-bg" ).text('Иcпользование изображений') ).appendTo(ul)
					
					pic_patt = $("<div>").prop('id',"pic-patterns").appendTo(atabs)
					
					my_patt = $("<div>").prop('id',"own-patterns").appendTo(atabs)
					
					image_bg = $("<div>").prop('id',"image-bg").appendTo(atabs)
					
					atabs.tabs();
					
					
				
					var appendNewImage = function( bg, i, to ){
						var img = new Image();
						//var display = new Image();
						var display_screen = $('<div>').addClass('background').prop('id',i);
						
						var li = $('<li>').appendTo(to)
						img.onload = function(){
							
							var W = img.width
							var H = img.height
							var Z = self.Site.backgrounds[type].images[i].zoom ?	 self.Site.backgrounds[type].images[i].zoom : 1
							var off = self._main_offset
							display_screen
							.appendTo($('body'))
							.css('top', self.Site.backgrounds[type].images[i].position.top + off.top )
							.css('left', self.Site.backgrounds[type].images[i].position.left + off.left  )
							.css('background-image', 'url("' + img.src + '")' )
							//.css('background-color', '#fff')
							//.css('border', '0px solid white')
							.css('position','absolute')
							.css('background-size', '100% auto')
							//.css('padding','1px')
							.width(W * Z )
							.height(H * Z)
							.zIndex(-10000)
							
							var thumb = scaleImage(img, 64,64);
							$(thumb).appendTo(li)
							
								$('<button>').text('move-scale').click(function(evt){
										var	but = this;
										var md =function(evt){
											is_move = true
											old_p = {top: evt.clientY,
												 left : evt.clientX} 
											evt.preventDefault();
											evt.stopPropagation();
						
										} 
									function zoom(zf, px, py, ox, oy , oz){
										var z = oz
										var x = ox
										var y = oy
										
										//if (z < 0.2) zf /=10;
										// if (z > 1.5) zf *= 5;
										
										
										var nz = z + zf;
										if (nz > 0.02 && nz <5){ 
												var K = (z*z + z*zf)
												
												var nx = x - ( (px*zf) / K );
												var ny = y - ( (py*zf) / K);
											}
										else{
											nx = ox
											ny = oy
											nz = oz
										}
										return [nx,ny,nz]
									}
												 
										var mu = function(evt){is_move = false}
										var scroll = function(evt, dt){
											// console.log("wheel", dt)
											if(evt.type == 'mousewheel'){
											 
											 z =	 (self.Site.backgrounds[type].images[i].zoom ? self.Site.backgrounds[type].images[i].zoom : 1)
											 zf = (dt/Math.abs(dt) ) * 0.01
											 z += zf
											 self.Site.backgrounds[type].images[i].zoom = z // res[2]
											 //console.log(self.Site.backgrounds[type].images[i])
												 display_screen.width(W * z).height( H * z )
												
											 
							 
											}
											evt.preventDefault();
											evt.stopPropagation();
											}
										var mm =function(evt){
											if(is_move){
												var left = evt.clientX;		
												var top = evt.clientY;
												var p = {left:left, top:top}
												var diff = {left: p.left - old_p.left, top: p.top - old_p.top}
											
											self.Site.backgrounds[type].images[i].position.top+= diff.top;
											self.Site.backgrounds[type].images[i].position.left += diff.left;
											display_screen
											.css('top', self.Site.backgrounds[type].images[i].position.top + off.top )
											.css('left', self.Site.backgrounds[type].images[i].position.left + off.left)
										
											old_p = p
											
											 }
										}
										var kp = function(evt){
											if(evt.keyCode == 27 ){ //ESC
												 kpu();
											}
										}			
										var kpu = function(){
												 $(but).text('move-scale')
												 $(document).unbind('mousedown', md)
												 $(document).unbind('mouseup', mu)
												 $(document).unbind('mousemove', mm)
												 $(document).unbind('keypress', kp)
												 $(document).unbind('MozMousePixelScroll', scroll)
												 $(document).unbind('DOMMouseScroll', scroll)
												 $(document).unbind('mousewheel', scroll);
						
										}
										$(document).bind('mousedown', md)
										$(document).bind('mouseup', mu)
										$(document).bind('mousewheel DOMMouseScroll	MozMousePixelScroll', scroll)
										$(document).bind('mousemove', mm)
										$(document).bind('keypress', kp)
										$(this).text("Press esc when DONE").click(function(){kpu()})
								}).appendTo(li)
							$('<button>').text('remove').click(function(){
								self.Site.backgrounds[type].images.splice(i, 1);
								$(this).parent().remove();
								
								$(display).remove();
							}).appendTo(li)
								
						}
						if(bg.data.blob){
							src = DB.get_blob_url(bg.data)
						}else{ src = bg.data}
						img.src = src;
						
					
						
						
					}
				
					var bg = self.Site.backgrounds[type]
					var images_ul = $('<ul>').appendTo(image_bg);
					//console.log("BG", bg)
					if (bg.type == 'images'){
						$('body').find('img').remove()
						
						$.each(bg.images, function(i, bg){
							appendNewImage(bg, i, images_ul)
							// img.id= "id-background-image-" + i;
							
						})
					}
				
				
				$("<input>").prop('type','file').change(function(evt){
					fr = new FileReader()
					fr.onload = function(){
						image= {data:this.result, position:{left:0, top:0}}
						if (self.Site.backgrounds[type].type == 'images'){
							var ix = self.Site.backgrounds[type].images.push(image ) - 1
							// console.log (ix)
							
						}else{
							self.Site.backgrounds[type] = {type:'images', images:[ image ] }
							var ix = 0;
						}
						appendNewImage(image, ix, ul);
						
					}	
					fr.readAsDataURL(this.files[0]);
										
					
				}).appendTo(image_bg);
				
				
				
				$("<div>").css('width', '100%').css('border', '1px solid black').appendTo(image_bg)
				$("<h3>").text('Цвет фона').appendTo(image_bg)
				if (self.Site.backgrounds[type].color){
					
					var col = self.get_color(self.Site.backgrounds[type].color);
				}else{var col = {h:0, s:0, b:100 }}
				//console.log("YES WE GOT COLOR",hsvToRgb(col) )
				
				var obj = $("<div>").width(40).height(30).css('border', '1px solid black').appendTo(image_bg)
				.css('background-color', hsvToRgb(col)	).click(function(evt ){
					function make_background_color(col, opt){
						self.Site.backgrounds[type].color = opt
						self.redraw_background()
						obj.css('background-color', col )
					}
				
					var cc = self.draw_color_chooser(make_background_color)
					cc.appendTo($('#controls')).position({of:obj, my:'left top', at:'left top' }).show();
					
				})
				
				
				var pds = [];
				var color;
				
				
				$("<button>").text('выбрать фон из картинки').appendTo(image_bg).click(function(){
					//console.log(pds,$('div.background'))
					if (pds.length == 0 ){
						//ÍÍconsole.log("Its empty")
						$.each($('div.background'), function(i, obj){
							var i_id = Number(obj.id )
							var C = $('<canvas>'); // .appendTo(image_bg)
							var ctx = C[0].getContext('2d')
							var img = new Image()
							img.onload = function(){
								C[0].width = img.width
								C[0].height = img.height
								ctx.drawImage( img, 0, 0 )
								var pd = ctx.getImageData(0,0, img.width, img.height)
								pds.push(pd)
							
							}
							if (self.Site.backgrounds[type].images[i_id].data.blob){
								data = DB.get_blob_url(self.Site.backgrounds[type].images[i_id].data)
							}else{data = self.Site.backgrounds[type].images[i_id].data}
							img.src = data;
						})
						
					}
					function mm (evt){
						var off = $(evt.target).offset()
						var id = Number(this.id);
						var pd = pds[id];
						var z = self.Site.backgrounds[type].images[id].zoom
						//ÍÍgroundconsole.log(evt.clientX, evt.clientY, off)
					
					
						var x = Math.floor((evt.clientX-off.left + $(document).scrollLeft() ) / z);
						var y = Math.floor((evt.clientY-off.top + $(document).scrollTop() )	/ z);
						var poff = ((y * pd.width) + x)*4;
					
						r = pd.data[poff]
						g = pd.data[poff+1]
						b = pd.data[poff+2]
					
						color = rgb2hsv(r,g,b)
					
						obj.css('background-color', 'rgb('+r +',' + g +',' + b+')')
					
						// console.log(x,y, poff, off, r,g,b)
					}
					function click(evt){
											ix = self.addCustomColor( color )
											col = {v:'C', ix : ix}
											self.Site.backgrounds[type].color = col
											$('body').off('mousemove', 'div.background', mm)
											$('body').off('click','div.background', click)
											self.redraw_background();
										}
					
					//console.log("BIND")
					$('body').on('mousemove','div.background',mm)
					$('body').on('click','div.background', click)
				})
				
				var is_move, old_p
				
				
				

				
				//var cp = $('<div>').appendTo(cp_)
				
				$('<span>').text('patterns').appendTo(pic_patt)
				$('<input>').prop('type', 'file').change(function(){
					fr = new FileReader()
					fr.onload = function(){
						var ix = self.Site.patterns.push(this.result)
						self.Site.backgrounds[type] = {data:ix-1 , type:'pattern', position:{left:0, top:0}}
						self.redraw_background();
					}
					fr.readAsDataURL(this.files[0]);
				}).appendTo(pic_patt);
				
				var fl_pats = $('<div>').appendTo(pic_patt)
				var redraw_pats = function(){
					fl_pats.find('*').remove();
					$.each(self.Site.patterns, function(ix, pat){
						var d = $('<div></div>').css('float','left').width(300).height(300).appendTo(fl_pats)
												.css('background-color', 'white')
						var img = new Image()
						img.onload = function(){
							$(img).appendTo(d).css('margin-left',(300-img.width)/2).css('margin-top', ((300-img.height)/2))
						}
						img.src = pat
						$('<button>').text('X').click(function(){
							if (self.Site.backgrounds[type].type == 'pattern'){
								if (ix <= self.Site.backgrounds[type].data){
								//console.log('reducing from ',self.Site.backgrounds[type].data)
									self.Site.backgrounds[type].data -= 1;
								}
								//console.log("before", self.Site.patterns.length)
								self.Site.patterns.splice(ix, 1)
								//console.log("after", self.Site.patterns.length )
	
								self.redraw_background();
								redraw_pats();

								
							}
							d.remove();
						}).appendTo(d)
						d.click(function(){
							self.Site.backgrounds[type] = {'type':'pattern', data:ix};
							self.redraw_background();
							redraw_pats();
						})
					})
					
				}
				redraw_pats()
				
			
				var flright = $('<div>').appendTo(my_patt).css('float','right')
										// .css('padding', 10)
										.width(300)
										.height(300)
										.css('border', '1px solid black')
										.css('background-color', 'white')
								
								
				var Cjq = $('<canvas>').appendTo(flright)
				var C   = Cjq[0]
				var S = $('<canvas>')[0]// .appendTo(my_patt)[0]
				var ctx = C.getContext('2d')
				
				
				var sctx = S.getContext('2d')
				var base = 128;	
				// var WA = 0, HA = 0, 
				var A = 0;
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
					
					iw = image.width * Z;
					ih = image.height * Z;

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
						c = self.get_color(BG)
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
					
					if(library_ix == false){
						if (self.Site.patterns){
							library_ix = self.Site.patterns.push(img)-1
						}else{
							self.Site.patterns = [img]
							library_ix = 0;
						}
						self.Site.backgrounds[type] = {data:library_ix , type:'pattern' }
					}else{
						// console.log('we shold change this');
						self.Site.patterns[library_ix] = img;
					}
					
					// console.log('index in lib', library_ix);
					redraw_pats();
					self.redraw_background();
				}
				make_image = function(){
					img = new Image()
					img.onload = function(){
						
						S.width = img.width
						S.height = img.height
						sctx.drawImage(img,0,0)
						buffData = sctx.getImageData(0,0, img	.width, img.height)
						if (FG){
							//console.log("FG", FG)
							var c = self.get_color(FG)
							
						}
						FGA = hsvToRgb(c, true)
						for(x =0; x<buffData.width; x++){
							for(y=0; y <buffData.height; y++){
								ix = (x+ ( y* buffData.width ))*4
								buffData.data[ix] = FGA[0]; //red
								buffData.data[ix+1] = FGA[1]; //green
								buffData.data[ix+2] = FGA[2]; //blue
							}
						}
						sctx.putImageData(buffData, 0,0)
						var du = S.toDataURL();
						_I = new Image()
						_I.onload = function(){
							image = _I
							redraw_ctx();
						}
						_I.src = du;
					}
					img.src = result
				}
				
				$('<span>').text('Элемент узора').appendTo(my_patt)
				$('<input>').prop('type', 'file').change(function(){
					fr = new FileReader()
					fr.onload = function(){
						result = this.result;
						make_image();

						
						
					}
					fr.readAsDataURL(this.files[0]);
				}).appendTo(my_patt);
				
				choose_bg = function(col, ix ){
					if (col != 'clear'){
						BG = ix
					}else{
						BG = false
					}
					redraw_ctx()
				}
				choose_fg = function(col, ix ){
					if (col != 'clear'){
						FG = ix
						make_image();
						
					}else{
						FG = false
					}
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
				$("<div>").width(250).slider({min:1, max:100,value:z*100, slide:function(event, ui){ Z = (ui.value)/100 ;redraw_ctx()}} ).appendTo(li)
				var li = $('<li>').appendTo(ul)
				$('<span>').text('Размер тайла').appendTo(li)
				
				$("<div>").width(250).slider({min:64, max:300,value:base, slide:function(event, ui){ base = ui.value ;redraw_ctx()}} ).appendTo(li)
				var li = $('<li>').appendTo(ul)
				$('<span>').text('Прозрачность').appendTo(li)
				
				$("<div>").width(250).slider({min:0, max:100,value:100, slide:function(event, ui){ opacity = ui.value ;redraw_ctx()}} ).appendTo(li)
				
				
				
			},
			show_CP: function(active_tab){
				
				var self = this;
				var C = $('div#controls');
				this.cp = $("<div>").appendTo(C)
				.width(360).height(window.innerHeight)
				.css('position','fixed').css('top',0).css('left',0)
				
				
				this._app_admin_cont = $('<div>').css('position','fixed').css('overflow', 'scroll')
				.css('top', 0).css('left', 240).width(1000).height(window.innerHeight)
				.css('background', 'white')
				.zIndex(2000)
				.appendTo(C).hide() ;
				
				$('<div>')
				.css('background', 'orange')
				.width(this._app_admin_cont.width())
				.append($('<button>').text('HIDE').click(function(){ self._app_admin_cont.hide() }))
				.appendTo(this._app_admin_cont);
				this._app_admin_contents = $('<div>').appendTo(this._app_admin_cont)
				
				
				
				this.cp_acc = $("<div>").appendTo(this.cp).zIndex(2000)
				//.css('background-color', 'orange')
				
				// .appendTo(C)
				
				// General Settings tab 0
				$("<h3>").text("Основные").appendTo(this.cp_acc)
				var d = $("<div>").appendTo(this.cp_acc)
				var ul = $("<ul>").appendTo(d)
				$("<li>").append($("<a>").prop('href','#').text("Управление фоном").click(function(){ self.backgroundChooser() }) ).appendTo(ul) 
				$("<li>").append($("<a>").prop('href','#').text("Цветовая схема").click(function(){ self.showColorScheme() }) ).appendTo(ul) 
				$("<li>").append($("<a>").prop('href','#').text("Создание фонов").click(function(){ self.showBackgroundScheme() }) ).appendTo(ul) 
				$("<li>").append($("<a>").prop('href','#').text("Шрифты").click(function(){ self.showFontsScheme() }) ).appendTo(ul) 
				$("<li>").append($("<a>").prop('href','#').text("Управление геометрией").click(function(){ self.showLayoutScheme() }) ).appendTo(ul) 
				$("<li>").append($("<a>").prop('href','#').text("Управление доменами").click(function(){ self.showDomainScheme() }) ).appendTo(ul) 
				

				$("<h3>").text("Мои страницы").appendTo(this.cp_acc)
				var d = $("<div>").appendTo(this.cp_acc)
				var ul = $("<ul>").css('padding','0').appendTo(d)
				
				$("<li>").append($("<a>").prop('href','#').text("Добавить").click(function(){ 
					self.addPage(true, true) 
					self._save_site();
					self.redraw();
				}) ).appendTo(ul)
				var pages = $.extend(true, {}, this.Site.pages)
				var pa = [];
				$.each(pages,function(i, p){
					p.slug = i
					pa.push(p)
				})
				
				pa.sort(function(a,b){ return a.order - b.order } )
				
				
				$.each(pa, function(ix,p){
					console.log(p.order)
					var i = p.slug
					var li = $("<li>").appendTo(ul)
					
					if( p.order != 0){
						li.append($("<button>")
						.button( { icons: { primary: "ui-icon-arrowthick-1-n" } } )
						.width(32)
						.height(32)
						.css('margin-left','5px')	
						.css('background-size','120% 120%')
						.click(function(){
							self.upPage(i);
							// self._save_site()
							self.redraw()
					
						}))
					}
					if((self.page_amount-1) != p.order){
						li.append($("<button>")
						.button( { icons: { primary: "ui-icon-arrowthick-1-s" } } )
						.width(32)
						.height(32)
						.css('margin-left','5px')	
						.css('background-size','120% 120%')
						.click(function(){
							self.downPage(i);
							//self._save_site()
							self.redraw()
					
						}))
					}
					var a =  $("<a>").prop('href','#!' + i).text(p.title).click(function(e){
											window.location.hash = i;
											e.preventDefault();
										}).appendTo(li)
									
					li.append($("<button>")
					.button( { icons: { primary: "ui-icon-pencil" } } )
					.width(32)
					.height(32)
					.css('margin-left','20px')	
					.css('background-size','120% 120%')
					.click(function(){
						$('<input>').val(p.title).insertAfter(a).change(function(){
							var val = $(this).val();
							self.Site.pages[i].title = val
							a.text(val)
							a.show()
							$(this).remove();
						})
						a.hide()
						
						
					})).css('padding-bottom','10px') 
					// console.log(self.Site.pages[i])
					if(self.Site.pages[i].removable){
						
						li.append($("<button>")
						.button( { icons: { primary: "ui-icon-closethick" } } )
						.width(32)
						.height(32)
						.css('margin-left','5px')	
						.css('background-size','120% 120%')
						.click(function(){
							self.deletePage(i);
							self._save_site()
							self.redraw()
						
						}))
					}
				})
				 
				// Applications 3
				$("<h3>").text("Приложения").appendTo(this.cp_acc)
				var d = $("<div>").appendTo(this.cp_acc)
				var ul = $("<ul>").appendTo(d)
				$.each(this.Site.Applications, function(name, app){
					if(app.admin_page){
						$("<li>").append($("<a>").prop('href','#').text(app.title).click(function(){ app.admin_page(self._app_admin_contents); self._app_admin_cont.show() }) ).appendTo(ul) 
						
					}
				})
				
				//$("<li>").append($("<a>").prop('href','#').text("Геометрия").click(function(){ self.showPageLayout() }) ).appendTo(ul) 
				//$("<li>").append($("<a>").prop('href','#').text("Геометрия").click(function(){ self.showPageLayout() }) ).appendTo(ul)
				
				 
				// Виджеты 4
				$("<h3>").text("Виджеты").appendTo(this.cp_acc)
				var d = $("<div>").appendTo(this.cp_acc)
				var ul = $("<ul>").appendTo(d)
				var self = this;
				var draga;
				$.each(this.Site.Applications, function(app_name, app){
					if(app.widgets){
						var li = $("<li>").text(app.title).appendTo(ul); 
						var ul_ = $("<ul>").appendTo(li);
						$.each(app.widgets, function(name, w){
									$("<li>")
									.text(w.title).appendTo(ul_)
									.prop('type', app_name + '.' + name) 
									.draggable({
										scroll:false,
										start:function(){
						
										 },
										helper: function(){
											return $("<div>").text("drag me")
						
										},
										drag:function(event, ui){
											//console.log(ui.position)
											var left = event.clientX+ $(document).scrollLeft() - self._main_offset.left ;
											var top =	event.clientY+$(document).scrollTop() - self._main_offset.top ;
											// console.log(left, top)
											var ll = self._stepping_left( left )
											var tt = self._stepping_top(	top	 )
											draga = {left:ll.block, top:tt.block };
					
											ui.position = {top:tt.val -$(document).scrollTop() + self._main_offset.top , 
														 left: ll.val - $(document).scrollLeft() + self._main_offset.left	
														};
										},
										stop: function(){
											var type = $(this).prop('type')
											self.add_block(draga.left, draga.top, type, w.default_size );
											self.redraw();
										}
						 			})		 
								})
							}
						})
						
				if (active_tab){
					this.cp_acc.accordion({active: active_tab, heightStyle:'fill'});
				}else{
					this.cp_acc.accordion()
				}
			},
			downPage: function (name) {
				var ix = this.Site.pages[name].order
				
				this.Site.pages[name].order = ix + 1
				
				var subst = this.page_order_index[ix+1]
				console.log(name, subst, this.page_order_index)
				var ix_s = this.Site.pages[subst].order
				this.Site.pages[subst].order = ix_s -1
				this._save_site();
				this.load_site()
				this.redraw_cp(1);
			},
			upPage: function (name) {
				var ix = this.Site.pages[name].order
				//new_order = ix-1
				this.Site.pages[name].order = ix-1
				
				
				var subst = this.page_order_index[ix-1]
				console.log(name, subst, this.page_order_index)
				var ix_s = this.Site.pages[subst].order
				// new_order_subst = ix_s +1
				this.Site.pages[subst].order = ix_s +1
				this._save_site();
				
				this.load_site()
				this.redraw_cp(1);
			},
			
			
			addPage: function(is_removable, is_menu_item, title, name){
				var amount = 0
				for (k in this.Site.pages){amount += 1};
				
				if (typeof name == 'undefined'){
					slug = "Untitled_page_" + (amount + 1);
					title = "Untitled page " + (amount + 1)

				}else{
					slug = name
					title = title
				}
				var newPage = {title: title,
								 blocks :[],
								 removable: is_removable,
								 show_in_menu: is_menu_item,
								 layout : 'same',
								 order: amount + 1}
				this.Site.pages[slug] = newPage;	 
				this.redraw_cp(1);
			
			},
			deletePage:function(name){
				delete this.Site.pages[name] ;	 
				this.redraw_cp(1);
				
			},
			redraw: function(){
				//this.show_CP();
				this.clear();
				this.draw();
				
				
				
			},
			clear : function(){
				this.page_cont.find('*').remove();
				$('#controls>.widget-control').remove()
				//// // console.log('cleared')
				
			},
			
			draw: function(){
				var C = this.page_cont;
				this._init_page()
				this.init_grid(C)
				
			},
			_stepping_left: function(left){
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
			},
			_stepping_top: function(w){
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
			},
			_stepping_height: function(w){
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
			
				
			},
			_stepping_width:function(w){
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
			
				
			},
			_block_width: function(){
				var base_width = Math.round ((this.layout.width - (this.layout.padding.left) ) / this.layout.cols)
				var block_width = (base_width - ( 2 * this.layout.grid.hor ) )
				console.log(base_width, block_width)
				
				return Math.round(block_width)
				
			},
			_block_left: function(){
				
			},
			_block_height: function(){
				block_height = this.layout.base_height;
				return block_height;
				
			},
			_uncalc_top: function (T) {
				return  T  / this._block_height(); 
				
			},
			_uncalc_left: function(L){
				return L / this._block_width();
			},
			
			_calc_top: function(t){
				var h = (this._calc_height(t))
				if (h == 0){ var P =0} else {var P = 2}
				return (h + P*this.layout.grid.ver) ;// + this._main_offset.top;
			},
			
			_calc_left: function(l){
				var w = (this._calc_width (l-1) )
				if (l > 1){var P =2 }else{var P=0}
				return (this.layout.padding.left + w + P*this.layout.grid.hor) // + this._main_offset.left;
				
				// console.log('LL', l)
				//var w = this._calc_width( l-1 ) // Ширина блока учитывается при значениях больше 1 (0,1)
				//return (this.layout.padding.left + w +(this.layout.grid.hor * (l-1)*2))
			},
			
			_calc_height: function(h){
				if (this._c_bh){
					cbh = this._c_bh
				} 
				else{
					this._c_bh = this._block_height()
					cbh = this._c_bh
				}
				return (cbh * h) + (this.layout.grid.ver *2 * (h-1)); 
				
				
			},
			_calc_width: function(w){
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
				
				
			},
			init_grid : function( to ){
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
					
				//console.log("TOTAL", total_height)
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
				if(this.is_constructor){
					$('<div>').css('background-color','orange').text('change background')
					.css('position','fixed')
					.css('top', 0).css('left','50px')
					.zIndex(1000)
					
					.appendTo($('#controls'))
					.click(function(){
						self.backgroundChooser('body')
						// // // console.log("change global BG")
					})
					
					$('<div>').css('background-color','orange').text('content background')
					.css('position','fixed')
					.css('top', 0).css('left','200px')
					.zIndex(1000)
					
					
					.appendTo($('#controls'))
					.click(function(){
						self.backgroundChooser('content')
						//// // console.log("change content BG")
					})
					
				}
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
										// .css('border', '1px solid black')
										.css('overflow','hidden'),
							
							 pos: ix,
						}
					 
					 
					 self.inited_blocks.push(self.init_block(block, gp))
					 if(self.is_constructor){
						 for (w = x; w< x + block.width; w++){
							 for (h = y; h < y+block.height; h++){
								 self._busy_regions.push(w +":"+ h ) 
					
							 }
						 }
			
					 }
					
					
					

				})
				

				
			},
			
			redraw_empty_blocks: function(){

			}, 
			draw_color_chooser: function(onSelectColor){
				color_chooser = $('<div>')
				.css('position','absolute')
				.css('background-color','white')
				.css('border', '1px solid black')
				.zIndex(1000)
				
				
				this._make_pallette();
				$.each(this.Site.colors.pallette , function(l, vars){
					var b, main
					if (l == 0){
						//console.log(l, vars)
						$.each ( vars, function(i, col_){
							var col = hsvToRgb(col_);
							
							 if(i == 0){
							
								b = $('<div>').css('float','left').width(100).height(100).appendTo(color_chooser)
							}
								
							$('<button>').css('padding','0').css('border','0').css('display','block').css('background-color', col).css('float','left').width(100).height(100/6).appendTo(b)
							.click(function(evt){
								onSelectColor(col, {v:l, ix:i} )
								evt.preventDefault(), evt.stopPropagation()
								color_chooser.remove();
							})

						})
					}
					else{
						// console.log(l, vars)
						 $.each ( vars, function(i, col_){
							 var col = hsvToRgb(col_);
							 if(i == 0){
								b = $('<div>').css('float','left').width(100).height(100).appendTo(color_chooser)
								main = $('<button>').css('padding','0').css('border','0').css('display','block').css('background-color', col).css('float','left').width(100).height(50)
								.click(function(evt){	
									onSelectColor(col, {v:l, ix:i} )
									color_chooser.remove();
									evt.preventDefault(), evt.stopPropagation()})
							 }else{
								if(i == 3){
									main.appendTo(b);
								}
								$('<button>').css('padding','0').css('border','0').css('display','block').css('background-color', col).css('float','left').width(50).height(25).appendTo(b)
								.click(function(evt){	// console.log(col);
									onSelectColor(col,{v:l, ix:i});
									evt.preventDefault(), evt.stopPropagation() 
									color_chooser.remove();
								})
							}
						})
					}
				})
				$('<input>').attr('value','Закрыть').button().appendTo(color_chooser).click(function(){
					color_chooser.remove()
				})
				
				$('<input>').attr('value','Прозрачный').button().appendTo(color_chooser).click(function(){
					onSelectColor("clear");
					color_chooser.remove()
					
				})

				return color_chooser; 	
			}, 
			apply_block_settings: function(obj, settings, widget){
				//console.log("HHHHH", obj)
				var w = obj.jq,
				bl = this.get_block(obj.pos);
				
				// console.log('apply_block-settings', settings)
				
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
							w.css('background-color' , settings.background.color );
						}else{
							var color = this.get_color(settings.background.color)
							var c = hsvToRgb(color);
							w.css('background-color', c);
						}
					}
				}else if(settings.background.type == 'none'){
							w.css('background-color', '');
				}
				
			},
			init_block_cp: function(obj,to, widget){
				
				var m = $('<div>').appendTo(to);
				var self = this;
				var w = obj;
				var settings = self.getBlockSettings(obj.pos);
				
				//console.log ("HAHAHA", obj, w, to)
				
				
				if(widget.disobey.indexOf('background_color') == -1){
					cl = $('<button>').button().text('Выбрать цвет фона').click(function(){
						cb = function(col, ix){ 
							if(col == 'clear') {
								settings.background = { type:'none'}
							}else{
								settings.background = { type:'color', color: ix }
								
							}
							//console.log(settings);
							self.apply_block_settings( w, settings, widget)
						}
						cc = self.draw_color_chooser( cb );
						cc.appendTo( to )
						.position({of:this, my:'left top', at:'left top' } )
					
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
						
					},
				}
				return o; 
			},
			init_block: function(bl, to){
				// console.log (bl)
				var r = bl.top,
					l = bl.left,
					w = bl.width,
					h = bl.height,
					self = this,
					W = this._calc_width(w),
					H = this._calc_height(h),
					widget = bl.widget.name.split('.'),
					wdata= bl.widget.data;
					
					
					// console.log(W,H)
				function newWidget(c, t,p, cp){
					return t.Site.Applications[widget[0]].widgets[widget[1]].init(c, t,p, cp);
				}
				
				var w = $("<div>").css('width','100%').css('height', '100%').appendTo(to.jq).addClass("draggable-module")
				var draga;
				
				var Widget = newWidget(w, this, to.pos);
				Widget.draw();
				var settings = self.getBlockSettings(to.pos)
				//console.log("B", w.width() )
				self.apply_block_settings(to, settings, Widget)
				
				if(settings.unsnap_to_grid){
					W = bl.width;
					H = bl.height;
				}
				// console.log("WH", W,H)
				if(this.is_constructor){
					
					to.jq.draggable({
						scroll:false,
						zIndex:100,
						cancel: '.resize-marker',
						start:function(event,ui){
							regs = [];
							for (w = bl.x; w < bl.x		+ bl.width; w++){
								for (h = bl.y; h < bl.y +bl.height; h++){
									regs.push(w +":"+ h ) 
										
								}
							}
							for ( i in self.inited_blocks){
								self.inited_blocks[i].unbind('mouseenter');
							}
							to.jq.unbind('mouseleave'); // , 'mouseenter')
							self._moved_block_ = regs ; 
							self.redraw_empty_blocks();
						},
						drag: function(event, ui){
							// // // console.log(ui)
							// var C = ui.helper;
							//console.log(settings)
							if (! (settings.unsnap_to_grid)){
								var ll = self._stepping_left(ui.position.left)
								var tt = self._stepping_top(ui.position.top)
								draga = {left:ll.block, top:tt.block };
							
								ui.position = {top:tt.val, left: ll.val};
							}else{
								draga = {left:ui.position.left, top:ui.position.top };
							}
							
						},
						stop:function(){
							self._moved_block = false;
							self.move_block(to.pos, draga.left, draga.top);
							self.redraw();
						
							
						},
	
					})
				}
				
				
				//console.log("A", w.width() )
				
				if (this.is_constructor){
					
						to.jq.dblclick(function(){
								
								for (blix in self.inited_blocks){
									var bl = self.inited_blocks[blix];
									bl.unbind("click")
									//bl.mouseleave();
									//bl.unbind("mouseleave")
								}
								
								 $('#controls>.widget-control').hide()
								
								to.jq.draggable('destroy');
								// console.log("CLICK UNBIND")
								
								var control_panel = $('<div>').appendTo($('#controls'))
								// console.log(w)
								
								control_panel.css('position','absolute')
											.position({of: w, my:"left top", at: "right top", collision:'none none'})
											 .css("border","2px solid black")
											 .css('background-color',"white")
											 .draggable({scroll:false})
											 .css('padding',"10")
											
								var wco	 = self.init_block_cp(to, control_panel, Widget )
								
								
								if (Widget.settings){
									 Widget.settings(control_panel);
								}
								
								$("<div>").css('background-color','orange').appendTo(to.jq).css('position','absolute')
								.position({of:to.jq, 
											my:"left top", 
											at:"right top",
											collision:"none"})
									.addClass("ui-icon ui-icon-gripsmall-diagonal-se").width(20).height(20);
									
								$("<div>").css('background-color','green').appendTo( to.jq.parent() ).css('position','absolute')
								.position({of:to.jq, my:"left top", at:"left-20 top", collision:'none none' })
								.addClass("ui-icon ui-icon-gripsmall-diagonal-se").width(20).height(20).click(function(){
									if(Widget.save){
										 Widget.save()
									}
									wco.save()
									self._save_site();
									self.redraw.apply(self,[])
									control_panel.remove()
								});
								
								$("<div>").css('background-color','red').appendTo( to.jq.parent() ).css('position','absolute')
								.position({of:to.jq, my:"left top", at:"left-20 top+30", collision:'none none' })
								.addClass("ui-icon ui-icon-gripsmall-diagonal-se").width(20).height(20).click(function(){
									if (Widget.cancel ){
										
										Widget.cancel()
									}
									control_panel.remove();
									
									self.redraw.apply(self,[])
								});
		
							})
							
						
						function init_resizer(){
							
						}
						var mouseWidth = W, mouseHeight = H,
						start_x, start_y;
						
						var delete_marker = $("<div>").appendTo($("#controls")).css('position','absolute')
						.addClass('delete-marker widget-control')
						.css('background-color', 'blue')
						// .css('cursor', 'se-resize')
						.css('border-radius', '5px')
						.css('border','1px solid black')
						//.position({of:to.jq, my:"right top", at:"right-20 top"})
						.addClass("ui-icon ui-icon-closethick").width('20px').height('20px').hide().click(function(){
							self.delete_block(to.pos);
							self.redraw.apply(self,[])
						})
						
						var resize_marker = $("<div>").appendTo($('#controls')).css('position','absolute')
					 // .position({of:to.jq, my:"right top", at:"right bottom", collision:'none none'})
						
						.addClass("ui-icon ui-icon-grip-diagonal-se").width('32px').height('32px').hide()
						.addClass('resize-marker widget-control')
						// .css('padding', '')
						.css('background-color', 'blue')
						.css('cursor', 'se-resize')
						.css('border-radius', '5px')
						.css('border','1px solid black')
						.mouseenter(function(){	 
							
						})
						.mouseup(function(evt){
							self.resize_frame = false;
							//console.log("FALSE")
						})
						.mousedown(function(evt){
							start_x = evt.clientX;
							start_y = evt.clientY;
							self.resize_frame = $("<div>")
													.css("position", 'absolute')
													.css('border', "1px solid black")
													.appendTo(to.jq.parent())
													.width(W)
													.height(H)
													.position({of:to.jq, my:'left top', at:'left top'});
															
							
							mouseWidth =bl.width;
							mouseHeight = bl.height ; 
							to.jq.parent().unbind('mouseup')
							to.jq.parent().unbind('mousemove')
							to.jq.parent().mouseup(function(){
								//console.log("FFF")
								if(self.resize_frame){
									self.resize_frame.remove()
									self.resize_frame = false;
									self.Site.blocks[to.pos].width = mouseWidth;
									self.Site.blocks[to.pos].height= mouseHeight;
									console.log('redraw')
									self.redraw.apply(self, [])
								}
								
							
								
							})
							
							to.jq.parent().mousemove(function(evt){
								var fr = self.resize_frame;
								
								if (fr){
									if (fr.size()){
										//console.log('move evtnt')
										var nh = evt.clientY - start_y + H,
											nw = evt.clientX - start_x + W;
											if(!(settings.unsnap_to_grid)){
												var width_step = self._stepping_width(nw),
													height_step = self._stepping_height(nh);
												fr.width(width_step.val)
												fr.height(height_step.val)
												mouseWidth =width_step.block;
												mouseHeight = height_step.block;
												
											}else{
												fr.width(nw)
												fr.height(nh)
												mouseWidth = nw;
												mouseHeight = nh;
												
											}
									 }
								}
								evt.preventDefault();
							}).css('cursor', 'se-resize')
							
							$(this).hide()
						})
						
						var po = to.jq.position();
						var wi = to.jq.width();
						var he = to.jq.height();
						var mw = resize_marker.width();
						var mh = resize_marker.height();
						var o = this._main_offset;
						
						//console.log("top", p , h , mh, "left",	w , mw)
						
						resize_marker.css('top', po.top+o.top+ he - mh)
						resize_marker.css('left', po.left +o.left+ wi - mw)
						
						delete_marker.css('top', po.top)
						delete_marker.css('left', po.left +o.left+ wi - mw)
						to.jq.click(function(e){
							
							
							$('#controls>.widget-control').hide()
							//$('#controls>.resize-marker').hide()
							delete_marker.show().zIndex(1000);
							resize_marker.show().zIndex(1000);
							

							// var left = p.left + o.left
							// var top= p.top + o.top
							// var within_x = e.pageX >= left+15 && e.pageX <= left + w;
							// var within_y = e.pageY >= top+15 && e.pageY <= top + h;
							//console.log(e.pageX >= left , e.pageX , left + w, within_y)
							//if( within_x && within_y){
							 //	 resize_marker.show()
							
							//	 resize_marker
							//	delete_marker
							//	delete_marker.show()
								
						//	}else{
							//	resize_marker.hide();
						//		delete_marker.hide();
						//	}
							
							
							
							
						})				}
				return to.jq
				}
				
			}
			return pg
		},
	 getter:function(){return this.Constructor()}
		
})
			