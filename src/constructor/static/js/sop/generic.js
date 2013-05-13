

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
                                            console.log(pos) 
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
                                                            console.log(this);
                                                            this.constr.setWidgetData(this.pos,this._jq.html()) 
                                                            
                                                        }
                                                    },                                                                                
                                                    settings: function(){
                                                        if(this.constr){
                                                            var eid = "my-" + this._rand_id();
                                                            var tbid = "tb" + this._rand_id();
                                                            this._jq.prop('id', eid)
                                                            
                                                            this.cp = $("<div>").appendTo(this.my_cont.parent().parent() ).css('position','absolute')
                                                                        .position({of: this.my_cont, my:"left top", at: "right top", collision:'flip'})
                                                                        .css('padding',"10")
                                                                        .css("border","2px solid black").css('background-color',"orange")
                                                                        .prop("id", tbid).draggable({scroll:false});
                                                            
                                                            this.area = new nicEditor( );
                                                            this.area.setPanel(tbid);
                                                            this.area.addInstance(eid);
                                                            
                                                            
                                                            
                                                            
                                                        }
                                                    },
                                                    jq: function(){ return this._jq } 
                                                };
                                             return o; 
                                                
                                           }
                                        
                                    
                                   },
                          "image": {title:"Картинка", init:function(my_cont, data, constructor_inst,pos){
                              var p = new paper.PaperScope();
                              paper = p;
                               for (i in paper.tools){
                                   tool = paper.tools[i];
                                   tool.remove()
                               }
                               paper.tools = [];
                              for (i in paper.projects){
                                   tool = paper.projects[i];
                                   tool.remove()
                               }
                               paper.projects = [];
                               var o = {
                                                    my_cont:my_cont,
                                                    constr :constructor_inst,
                                                    data : data,
                                                    pos: pos,
                                                    _jq : false,
                                                    settings_draw :false, 
                                                    paper_script : "// Create a new path once, when the script is executed: "
                                                        +"var myPath = new Path();"
                                                        +"console.log('exe');"
                                                        +"myPath.strokeColor = 'black';"
                                                        
                                                        +"function onMouseDown(event) {"
                                                        +"    myPath.add(event.point);"
                                                    +"}",
                                                    draw: function(){
                                                        var data = this.data;
                                                        var self = this
                                                        if (data.image){
                                                            this._dr()
                                                            /*
                                                            this._jq = $("<img>").prop('src', data.image).appendTo(this.my_cont)
                                                                        .width(this.my_cont.width())
                                                                        .height(this.my_cont.height()) ;
                                                            */
                                                        }else{
                                                            this._jq = $("<button>").text("add")
                                                            .appendTo(this.my_cont)
                                                            .css('margin',50)
                                                            
                                                            .click(function(){
                                                                    // console.log("i'm fucking pushing you")
                                                                    var input = $("<input>").attr('type','file').change(function(){
                                                                        var fr = new FileReader()
                                                                        var _this = this;
                                                                        fr.onloadend = function(){
                                                                            var result = this.result;
                                                                            $(_this).parent().remove();
                                                                            self.constr.setWidgetData(self.pos, {image:result, position:{x:0,y:0}, zoom:1})
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
                                                        
                                                    },
                                                    _dr : function(){
                                                        if (this._jq){
                                                             this._jq.remove()
                                                        }
                                                        this._jq = $("<canvas>").appendTo(this.my_cont)
                                                        .width(this.my_cont.width())
                                                        .height(this.my_cont.height())
                                                        
                                                        var c = this._jq[0];
                                                        console.log("reinit");
                                                        paper.install(window)
                                                        paper.setup(c);
                                                        

                                                        
                                                        var rast = new paper.Raster({source:this.data.image,position:paper.view.center })
                                                        //console.log(this.data.position, this.data.zoom)
                                                        // rast.scale(this.data.zoom)
                                                        // rast.translate(new Point(this.data.position.x, this.data.position.y) )
                                                        //console.log(this.settings_draw);
                                                        if (this.settings_draw){
                                                            this.settings_draw(c, rast)
                                                        }
                                                        paper.view.draw()
                                                    },
                                                    
                                                    save :function(){
                                                        var canvas = this._jq[0];
                                                        var image = canvas.toDataURL("image/png");
                                                        
                                                        var data = {image: image}
                                                        console.log("SAVE", data)
                                                       
                                                        this.constr.setWidgetData(self.pos, data)
                                                        this.constr.redraw();
                                                        
                                                        
                                                        
                                                    },                                                                    
                                                    settings: function(){
                                                        self = this
                                                        if (self._cp){
                                                            self._cp.remove()
                                                        }
                                                        function sd(canv, rast){
                                                            tool = new Tool()
                                                            
                                                            
                                                            //self.current_pos = self.data.position;
                                                            //self.current_zoom = self.data.zoom;
                                                            
                                                            tool.onMouseDrag = function(event){
                                                                //console.log("onMouseDrag")
                                                                var dp = event.downPoint;
                                                                var p  = event.point;
                                                                var diff = {x:p.x - dp.x, y: p.y-dp.y}
                                                                if (event.modifiers.shift){
                                                                    percent = event.delta.y / 100.
                                                                    rast.scale(1 + percent, event.downPoint);
                                                                    //self.current_zoom += percent;
                                                                }else{
                                                                    rast.translate(event.delta);
                                                                    // self.current_pos.x += event.delta.x ;
                                                                    // self.current_pos.y += event.delta.y ;
                                                                }
                                                            }
                                                                  
                                                                                                                   
                                                        }
                                                        this.settings_draw = sd
                                                        this._dr()
                                                        
                                                    },
                                                    jq: function(){ return this._jq } 
                                                };
                                             return o; 
                                                
                                           }
                                       }
                          }
                     };
                          
                // o.prototype = Application;
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
