

{
	Main: function(){
		
		var o = {
				types : {"image": {"tip": "text",
							"name" : "text",
							"binary":"binary",
							"id":"id"},
					"text":{"id":"id",
							"content":"html"}},
				title: "Basic Site",
				admin_page: function(to){
					to.find('*').remove()
					$("<div>").text("This is " + this.title + " admin page").appendTo(to) 
				},
				widgets: {
					"menubar" : {title:"Меню сайта", init: function(my_cont, constructor_inst, pos, cp){
											//console.log(pos) 
											var data = data;
											var o = {
													my_cont:my_cont,
													constr :constructor_inst,
													default_size: [3,1],
													disobey:[],
													cp : cp,
													pos: pos,
													_jq : false,
													draw: function(){
														if (typeof this.constr.Site.fonts == 'undefined' ){
															font = 'Times New Roman'
														} else{ font = this.constr.Site.fonts.content}
														
														this._jq = $("<ul>")
																	// .addClass('text-data')
																	.appendTo(this.my_cont)
																	.css('font-family', font )
																	.css('padding',0).css('margin', 0)
														var current_page = constructor_inst.current_page
														var self = this;
														// console.log(constructor_inst.Site.pages)
														var pages = 0
														for(i in constructor_inst.Site.pages){
															pages+=1
														}
														var width = this._jq.width()
														var item_width = width / pages;
														//console.log(my_cont, item_width, width)
														$.each(constructor_inst.Site.pages, function(i, p){
															var li = $("<li>").appendTo(self._jq)
																				 .css('float', 'left').width(item_width)
																				 .css('padding',0).css('margin', 0)
																				 .css('list-style-type','none')
															if (i == current_page){
																li.append(p.title)
															}else{
																$("<a>").prop('href', "#" + i).click(function(evt){
																	window.location.hash = i
																	constructor_inst._init_page()
																	constructor_inst.redraw()
																	evt.preventDefault();
																}).append(p.title).appendTo(li)
																
															}
															
														})
													},
													jq: function(){ return this._jq } 
												}
												return o;
												
											}
										},
					"text" : {title:"Текстовое поле", init: function(my_cont, constructor_inst, pos, cp){
											//console.log(pos) 
											var data = data;
											var o = {
													my_cont:my_cont,
													constr :constructor_inst,
													disobey:[],
													// data : data,
													default_size: [3,3],
													cp : cp,
													pos: pos,
													_jq : false,
													_data:function(){
														if (this.data){
															return this.data
														}else{
															this.data = constructor_inst.getWidgetData(pos, "Sample text");
															return this.data;
														}
														
														
													},
													draw: function(){	
														if (typeof this.constr.Site.fonts == 'undefined' ){
															font = 'Times New Roman'
														} else{ font = this.constr.Site.fonts.content}
														this._jq = $("<div>")
																				.addClass('text-data')
																				.html(this._data()).appendTo(this.my_cont) 
																				.css('font-family', font )
													},
													_rand_id: function(){
														var text = "";
														var possible = "ABCDEFGJIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
														for(var i; i<8; i++){text += possible.charAt(Math.floor(Math.random()* possible.length)); }
														return text;
													},	
													save :function(){
														if (this.constr){
															
															this.constr.setWidgetData(this.pos,this._jq.html()) 
															
														}
													},
													cancel: function(){
														// this.cp.remove()
														// this.color_chooser.remove();
													},
													_change_text: function(command,val){
														r = document.execCommand(command, false, val)
														//console.log(command, val, r)
														
														
													},																				
													settings: function(controls){
														var self =this;
														if(this.constr){
															//var eid = "my-" + this._rand_id();
															//var tbid = "tb" + this._rand_id();
															this._jq.prop('contentEditable', 'true') //.prop('id', eid)
															
																		// .prop("id", tbid)
															
															var cp = $("<div>").appendTo(controls )
															
															//console.log(controls)
															$('<button>').html('<b>B</b>').appendTo(cp).click(function(){self._change_text("bold") })
															$('<button>').html('<i>i</i>').appendTo(cp).click(function(){self._change_text("italic") })
															$('<button>').html('<u>U</u>').appendTo(cp).click(function(){self._change_text("underline") })
															$('<button>').html('<s>S</s>').appendTo(cp).click(function(){self._change_text("StrikeThrough") })
															$('<button>').text('color').appendTo(cp).click(function(){
																cb = function(col) {self._change_text('forecolor', col)}; 
																self.color_chooser = self.constr.draw_color_chooser(cb);
																self.color_chooser.appendTo($('#controls')).position({of:$(this), my:'left top', at:'right bottom'})
																
																
															
															})
															
														}
														controls.show();
													},
													jq: function(){ return this._jq } 
												};
											 return o; 
												
										}
										
									
								},
								"header" : {title:"Заголовок", init: function(my_cont, constructor_inst, pos, cp){
																			//console.log(pos) 
																			var data = data;
																			var o = {
																						
																					my_cont:my_cont,
																					constr :constructor_inst,
																					default_size: [5,1],
																					disobey:['padding_top', 
																							 'padding_left_right'],
																					// data : data,
																					cp : cp,
																					pos: pos,
																					_jq : false,
																						
																					_data:function(){
																						if (this.data){
																							return this.data
																						}else{
																							this.data = constructor_inst.getWidgetData(pos, {text:"Sample Header", size:14} );
																							this._size = this.data.size
																							// console.log (this.data, this._size)
																							return this.data;
																						}
														
														
																					},
																					draw: function(){
																						if (typeof this.constr.Site.fonts == 'undefined' ){
																							font = 'Arial'
																						} else{ font = this.constr.Site.fonts.header}
																						
																							this._jq = $("<div>")
																													 .addClass('text-data')
																													.html(this._data().text).appendTo(this.my_cont)
																													.css('font-size', this._data().size + 'px')
																													.css('font-family', font )
																					},
																					
																					save :function(){
																						if (this.constr){
																								var text = this._jq.html()
																								var size = this._size;
															
																							this.constr.setWidgetData(this.pos, {text:text, size:size }) 
															
																						}
																					},
																					cancel: function(){
																						// this.cp.remove()
																						// this.color_chooser.remove();
																					},
																			_change_text: function(command,val){
																				r = document.execCommand(command, false, val)
																				//console.log(command, val, r)
											
											
																			},																				
																			settings: function(controls){
																				var self =this;
																				if(this.constr){
																					//var eid = "my-" + this._rand_id();
																					//var tbid = "tb" + this._rand_id();
																					this._jq.prop('contentEditable', 'true') //.prop('id', eid)
												
																								// .prop("id", tbid)
												
																					var cp = $("<div>").appendTo( controls )
												
																					//console.log(controls)
																					//$('<button>').html('<b>B</b>').appendTo(cp).click(function(){self._change_text("bold") })
																					//$('<button>').html('<i>i</i>').appendTo(cp).click(function(){self._change_text("italic") })
																					//$('<button>').html('<u>U</u>').appendTo(cp).click(function(){self._change_text("underline") })
																					//$('<button>').html('<s>S</s>').appendTo(cp).click(function(){self._change_text("StrikeThrough") })
																				$("<div>").width(250).slider({min:100, max:300,value:this._size*10, slide:function(event, ui){ 
																						self._size = ui.value/10;
																						self._jq.css('font-size', self._size + 'px')
																				}} ).appendTo(cp)
				
																					$('<button>').text('color').appendTo(cp).click(function(){
																						cb = function(col) {self._change_text('forecolor', col)}; 
																						self.color_chooser = self.constr.draw_color_chooser(cb);
																						self.color_chooser.appendTo($('#controls')).position({of:$(this), my:'left top', at:'right bottom'})
													
													
												
																					})
												
																				}
																				controls.show();
																			},
																			jq: function(){ return this._jq } 
																		};
																	 return o; 
									
																}
							
									
																	},								
						"image": {title:"Картинка", init:function(my_cont,constructor_inst, pos, cp){
							// console.log(data)
							var o = {
													my_cont:my_cont,
													constr :constructor_inst,
													// data : data,
													default_size: [4,4],
													disobey:['padding_top','padding_left_right'],
													cp:cp,
													pos: pos,
													_jq : false,
													settings_draw :false,
												


													draw: function(){
														// console.log("Exactly after initing", this)
														var data = this.constr.getWidgetData(pos, false)
														if (data){
															var l = data.position ? data.position.left : 0,
																t = data.position ? data.position.top : 0;
																z = data.zoom ? data.zoom: 1;
															this.data = {image:data.image, position:{left:l,
																									 top: t}, zoom: z}
															
														}else{
															this.data = {image:data.image, position:{left:0,
																									 top:0}, zoom: 1}
															
														}
														
														var self = this
														// console.log("MY DATA", this.data.position);
														if (this.data.image){
															//if (this.data.image.blob){
																
																//}
															this._dr()
														}else{
															this._jq = $("<img>").prop('src', '/static/images/images.jpg')
															.appendTo(this.my_cont)
															.css('margin',10)
															if(this.constr.is_constructor){
																this._jq.click(function(){
																	// console.log("i'm fucking pushing you")
																	var input = $("<input>").attr('type','file').change(function(){
																		var fr = new FileReader()
																		var _this = this;
																		fr.onloadend = function(){
																			var result = this.result;
																			$(_this).parent().remove();
																			self.constr.setWidgetData(self.pos, {image:result, position:{left:0,top:0}, zoom:1})
																			self.constr.redraw();
																		}
																		fr.readAsDataURL(this.files[0]);
																	}) 
																	$("<div>")
																	.css('position','absolute')
																	.append(input).appendTo(self.my_cont.parent().parent())
																	.css('padding',"10").css('background-color', "orange")
																	.position({of:self.my_cont, my:"left top", at:"left bottom", collision:"none none"})
																})
															}
															
														}
														
													},
													_dr : function(){
														// console.log ("POS", this.constr.Site.pages[''].blocks[2].widget.data.position)
														var self = this;
														if (this._jq){
															 this._jq.remove()
														}
														this._jq = $("<canvas>").appendTo(this.my_cont)
														this.c = this._jq[0];
														
														this.c.width = this.my_cont.width()
														this.c.height = this.my_cont.height()
														
														
														// console.log("reinit");
														
														// paper.install(window)
														// paper.setup(c);
														this.img = new Image();
														if (this.data.image.blob){
															this.img.src = DB.get_blob_url(this.data.image)
														}else{
															this.img.src = this.data.image;
														}
														this.ctx = this.c.getContext('2d')
														this.img.onload=function(){
															//console.log("this whould be image widget", self.data.position);
															self.redraw_ctx()
														}
													},
													redraw_ctx: function(){
														
														
															this.ctx.clearRect(0,0,this.my_cont.width(),this.my_cont.height())
															this.ctx.save()
															this.ctx.scale(this.data.zoom, this.data.zoom)
															this.ctx.translate(this.data.position.left, this.data.position.top)
															this.ctx.drawImage(this.img ,0,0)
															this.ctx.restore();
														
													
													},
													
													save :function(){
														var canvas = this._jq[0];
														//var image = canvas.toDataURL("image/png");
														
														var data = this.data
														// console.log("SAVE", data)
													
														 // console.log("Do we savinf data?");
														this.constr.setWidgetData(this.pos, data )
														// this.constr.redraw();
														
														
														
													},	
													cancel: function(){
														// this.constr.redraw();
													},																	 
													settings: function(controls){

																
																
														this.my_cont.unbind('mousemove')
														this.my_cont.unbind('mouseup')
														this.my_cont.unbind('mousedown')
														
														var off = this._jq.offset();
														var self = this;
														var start_pos, 
															is_drag, 
															old_pos;
														//console.log('okey');
														function zoom(zf, px, py){
															var z = self.data.zoom;
															var x = self.data.position.left;
															var y = self.data.position.top;
															
															
															if (z < 0.2) zf /=10;
															if (z > 1.5) zf *= 5;
															
															
															var nz = z + zf;
															if (nz > 0.02 && nz <10){ 
																	var K = (z*z + z*zf)
																	
																	var nx = x - ( (px*zf) / K );
																	var ny = y - ( (py*zf) / K);
																	
																	self.data.position.left = nx;
																	self.data.position.top = ny;
																	self.data.zoom = nz;
																	self.redraw_ctx();
															}
															
															
															
														}
											
													this.my_cont.bind('mousewheel DOMMouseScroll MozMousePixelScroll',function(evt, dt){
														evt.stopImmediatePropagation();
														evt.preventDefault();
														if(evt.type == 'DOMMouseScroll' || evt.type == 'MozMousePixelScroll'){
															
														}else{
															var a = dt / Math.abs(dt)
															zoom(0.1 *a, evt.clientX - off.left, evt.clientY - off.top)
															// console.log(evt,dt);
															
														}
														
														return true
													})
														this.my_cont.mousemove(function(evt){
															if (is_drag){
																var cur_pos = {x: evt.clientX - off.left,
																			y: evt.clientY - off.top}
																var diff = {x: cur_pos.x - old_pos.x,
																			y: cur_pos.y - old_pos.y}
																			
																			
																self.data.position.left += (diff.x / self.data.zoom);
																self.data.position.top += (diff.y / self.data.zoom);
																
																//self.data.position.left /= self.data.zoom;
																//self.data.position.top /= self.data.zoom ;																		 
																		 
																old_pos = cur_pos;
																self.redraw_ctx();
																/// console.log(evt);
															}
															
															
														})
														this.my_cont.mouseup(function(evt){
															is_drag = false;
														})
														this.my_cont.mousedown(function(evt){
															old_pos = {x: evt.clientX - off.left,
																		 y: evt.clientY - off.top}
															//console.log(start_pos)
															is_drag = true;
															
														})
														
												
														
													},
													jq: function(){ return this._jq } 
												};
											 return o; 
												
										}
									}
						}
					 };	
				return o
			 
		},
		getter: function(){
		return this.Main()
	},
	junk : function(){
		/*
		 * _rect_path:function(r, strokeWidth, strokeColor, dash){
														var p = new Point(r.x, r.y)
														var s = new Size(r.w, r.h)
														var path =	new Path.Rectangle(p, s)
														if (strokeWidth) {path.strokeWidth = strokeWidth}
														if (strokeColor) {path.strokeColor = strokeColor}
														if (dash) {path.dashArray = strokeColor}
														
														
													},
													_make_geom:function(r){
													rs = this._choosing_rect(r)
													res = {}
													for (i in rs){
														var r = rs[i];
														p = new Point(r.x,r.y);
														s = new Size(r.w, r.h);
														rect = new Path.Rectangle(p,s)
														res[i] = {geom:r, path:rect}
													}	 
													return res;
													},
													_choosing_rect: function(r){
														var marker_size = 8;
														var ms2 = marker_size / 2;
														var o = {
															main:	r,
															left_top :	{x: r.x - ms2, y:r.y - ms2,		 w:marker_size, h:marker_size},
															left_bottom :{x: r.x - ms2, y:r.y - r.h - ms2, w:marker_size, h:marker_size},
															right_top :	{x: r.x -r.w- ms2, y:r.y - ms2,		 w:marker_size, h:marker_size},
															right_bottom : {x: r.x -r.w- ms2, y:r.y -r.h - ms2, w:marker_size, h:marker_size},
															
														}
														return o
													},
													_is_within_rect: function(rs, point){
														var a = [];
														var is_within = function(r,point){
															var within_x = r.x <= point.x && (r.x + r.w) >= point.x
															var within_y = r.y <= point.y && (r.y + r.h) >= point.y; 
															return within_x && within_y
														}
														for (i in rs ){
															r = rs[i].geom
															if (is_within(r, point)){
																a.push(i)
															 }
														}
														return a;
													},
		 */
	}
	
}
