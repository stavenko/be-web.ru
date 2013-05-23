

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
                widgets: {"text" : {title:"Текстовое поле", init: function(my_cont, data, constructor_inst,pos){
                                            //console.log(pos) 
                                            var o = {
                                                    my_cont:my_cont,
                                                    constr :constructor_inst,
                                                    data : data,
                                                    pos: pos,
                                                    _jq : false,
                                                    _data:function(){
                                                        if (this.data){
                                                            return this.data
                                                        }
                                                        return "Sample text"
                                                    },
                                                    draw: function(){   this._jq = $("<div>")
                                                                                  .addClass('text-data')
                                                                                   .html(this._data()).appendTo(this.my_cont) 
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
                                                    _change_text: function(command,val){
                                                        r = document.execCommand(command, false, val)
                                                        //console.log(command, val, r)
                                                        
                                                        
                                                    },                                                                                
                                                    settings: function(){
                                                        var self =this;
                                                        if(this.constr){
                                                            //var eid = "my-" + this._rand_id();
                                                            //var tbid = "tb" + this._rand_id();
                                                            this._jq.prop('contentEditable', 'true') //.prop('id', eid)
                                                            
                                                            this.cp = $("<div>").appendTo(this.my_cont.parent().parent() ).css('position','absolute')
                                                                        .position({of: this.my_cont, my:"left top", at: "right top", collision:'flip'})
                                                                        .css('padding',"10")
                                                                        .css("border","2px solid black").css('background-color',"orange")
                                                                        // .prop("id", tbid)
                                                                        .draggable({scroll:false});
                                                            $('<button>').html('<b>B</b>').appendTo(this.cp).click(function(){self._change_text("bold") })
                                                            $('<button>').html('<i>i</i>').appendTo(this.cp).click(function(){self._change_text("italic") })
                                                            $('<button>').html('<u>U</u>').appendTo(this.cp).click(function(){self._change_text("underline") })
                                                            $('<button>').html('<s>S</s>').appendTo(this.cp).click(function(){self._change_text("StrikeThrough") })
                                                            $('<button>').text('color').appendTo(this.cp).click(function(){
                                                                var cl = $('<div>')
                                                                .css('position','absolute')
                                                                .css('background-color','white')
                                                                .css('border', '1px solid black')
                                                                .appendTo($('#controls')).position({of:$(this), my:'left top', at:'right bottom'})
                                                                self.constr._make_pallette();
                                                                $.each(self.constr.Site.colors.pallette , function(l, vars){
                                                                                                                                    
                                                                    // var vars = self.constr.Site.colors.pallette[k];
                                                                    // console.log("PAL", k, vars);
                                                                    
                                                                    var b, main
                                                                    $.each ( vars, function(i, col_){
                                                                        var col = hsvToRgb(col_);
                                                                        if(i == 0){
                                                                            b = $('<div>').css('float','left').width(100).height(100).appendTo(cl)
                                                                            main = $('<button>').css('padding','0').css('border','0').css('display','block').css('background-color', col).css('float','left').width(100).height(50)
                                                                            .click(function(evt){  
                                                                                // console.log(col); 
                                                                                self._change_text('forecolor',  col); evt.preventDefault(), evt.stopPropagation()})
                                                                        }else{
                                                                            // console.log(i)
                                                                            if(i == 3){
                                                                                main.appendTo(b);
                                                                            }
                                                                            
                                                                            $('<button>').css('padding','0').css('border','0').css('display','block').css('background-color', col).css('float','left').width(50).height(25).appendTo(b)
                                                                            .click(function(evt){  // console.log(col);  
                                                                                self._change_text('forecolor', col); evt.preventDefault(), evt.stopPropagation() })
                                                                        }
                                                                        
                                                                    }) 
                                                
                                                                })
                                                                $('<button>').text('close').appendTo(cl).click(function(){cl.remove();})
                                                                
                                                            
                                                            })
                                                            
                                                        }
                                                    },
                                                    jq: function(){ return this._jq } 
                                                };
                                             return o; 
                                                
                                           }
                                        
                                    
                                   },
                          "image": {title:"Картинка", init:function(my_cont, data, constructor_inst,pos){
                              // console.log(data)
                               var o = {
                                                    my_cont:my_cont,
                                                    constr :constructor_inst,
                                                    data : data,
                                                    pos: pos,
                                                    _jq : false,
                                                    settings_draw :false,
                                                   


                                                    draw: function(){
                                                        // console.log("Exactly after initing", this)
                                                        var data = this.data;
                                                        var self = this
                                                        //console.log(data);
                                                        if (data.image){
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
                                                        this.img.src = this.data.image;
                                                        this.ctx = this.c.getContext('2d')
                                                        //console.log('Core of a draw', this)
                                                        this.img.onload=function(){
                                                            //console.log("this whould be image widget", self);
                                                            self.redraw_ctx()
                                                        }
                                                    },
                                                    redraw_ctx: function(){
                                                        var self = this;
                                                        
                                                            self.ctx.clearRect(0,0,self.my_cont.width(),self.my_cont.height())
                                                            self.ctx.save()
                                                            self.ctx.scale(self.data.zoom, self.data.zoom)
                                                            self.ctx.translate(self.data.position.left, self.data.position.top)
                                                            self.ctx.drawImage(self.img ,0,0)
                                                            self.ctx.restore();
                                                        
                                                       
                                                    },
                                                    
                                                    save :function(){
                                                        var canvas = this._jq[0];
                                                        //var image = canvas.toDataURL("image/png");
                                                        
                                                        var data = this.data
                                                        // console.log("SAVE", data)
                                                       
                                                        this.constr.setWidgetData(this.pos, data )
                                                        this.constr.redraw();
                                                        
                                                        
                                                        
                                                    },                                                                    
                                                    settings: function(){
                                                        this.my_cont.unbind('mousemove')
                                                        this.my_cont.unbind('mouseup')
                                                        this.my_cont.unbind('mousedown')
                                                        
                                                        var off = this._jq.offset()
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
                                                                    
                                                                    /// console.log(px,py, z, zf, px* zf/K, py*zf/K) 
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
                                                        var path =  new Path.Rectangle(p, s)
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
                                                            main:      r,
                                                            left_top :     {x: r.x - ms2, y:r.y - ms2,       w:marker_size, h:marker_size},
                                                            left_bottom :  {x: r.x - ms2, y:r.y - r.h - ms2, w:marker_size, h:marker_size},
                                                            right_top :    {x: r.x -r.w- ms2, y:r.y - ms2,       w:marker_size, h:marker_size},
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
