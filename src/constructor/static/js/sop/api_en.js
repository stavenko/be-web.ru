// Описание API

{ "image": {title:"Картинка", 
							
			init:function(my_cont,  constructor_inst, pos, cp){
				// my_cont - DOM-container where widget should be drawn
				// contructor_inst - Global constructor object which is used to get or set data of widget
				// pos - global index of a widget
				// cp - Not used
				
				// To get data from a widget we would call  getWidgetData method with 'pos' as input param
				var data  = this.constr.getWidgetData( pos )
				// Data object returned as reference
               var o = {
				draw: function(){},  // Drawing function my_cont
		        save :function(){this.constr.setWidgetData(this.pos, data )}, // Saving widget data
				cancel: function(){},   // Called when user stops editing and discarding.
		        settings: function(controls){}, // settings function called by constructor by double cliking on a widget. container gived to draw control dialog there
		        jq: function(){ return this._jq }  // backwards compatibility - returning root element of a widget
		        };
     		return o; 
        
   }
}






// EXAMPLE - widget of a image with positioning & zoom.

{ "image": {title:"Картинка", 
			init:function(my_cont,  constructor_inst, pos, cp){
               var o = {
	            my_cont:my_cont,
	            constr :constructor_inst,
	            // data : data,
				cp:cp,
	            pos: pos,
	            _jq : false,
		            settings_draw :false,
           


		            draw: function(){
		                // gitting data
		                var data = this.constr.getWidgetData(pos, false)
						if (data){
							var l = data.position ? data.position.left : 0,
								t = data.position ? data.position.top : 0;
								z = data.zoom ? data.zoom  : 1;
								
							this.data = {image:data.image, position:{left:l,
																	 top: t}, zoom: z}
					
						}else{
							// данные по умолчанию
							this.data = {image:data.image, position:{left:0,
																	 top:0}, zoom: 1}
					
						}
				
		                var self = this
		                if (this.data.image){
		                    this._dr()
		                }else{
		                    this._jq = $("<img>").prop('src', '/static/images/images.jpg')
		                    .appendTo(this.my_cont)
		                    .css('margin',10)
		                    if(this.constr.is_constructor){
		                        this._jq.click(function(){
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
		                    this.ctx.scale(this.data.zoom, this.data.zoom) // scale и translate - нульзя перепутать.
		                    this.ctx.translate(this.data.position.left, this.data.position.top)
		                    this.ctx.drawImage(this.img ,0,0)
		                    this.ctx.restore();
                
               
		            },
            
		            save :function(){
		                var canvas = this._jq[0];
						
						 var data = this.data
		                this.constr.setWidgetData(this.pos, data )
                
                
                
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
                                old_pos = cur_pos;
		                        self.redraw_ctx();
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