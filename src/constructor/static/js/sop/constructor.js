
    
({    
    Constructor : function (){
        //base_height = 5; // em
        var test_block_content = "Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt, explicabo. Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos, qui ratione voluptatem sequi nesciunt, neque porro quisquam est, qui dolorem ipsum, quia dolor sit, amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt, ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit, qui in ea voluptate velit esse, quam nihil molestiae consequatur, vel illum, qui dolorem eum fugiat, quo voluptas nulla pariatur? At vero eos et accusamus et iusto odio dignissimos ducimus, qui blanditiis praesentium voluptatum deleniti atque corrupti, quos dolores et quas molestias excepturi sint, obcaecati cupiditate non provident, similique sunt in culpa, qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio, cumque nihil impedit, quo minus id, quod maxime placeat, facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet, ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.";
        var Site = false; 
        default_site = {
                    _Apps:['generic', 'theshop'] ,
                    layout:{cols:12, 
                            fixed: true, 
                            padding: {hor:10, ver:3}, 
                            width:960,
                            drawen_lines:30,
                            base_height:50},    
                    colors:{type:'mono', base:120, brightness:100, lights:50, saturation:100, shadows:50},  
                    backgrounds:{},
                    //background:{type:'color', param: {h:0, s:0, b:100}}  ,
                    // backgrounds:{},
                    //bodyback:{},
                    //contentback:{},
                                              
                    pages : {"": {layout:"same",
                                  title:"Main page of my project",
                                  
                                  blocks:{'0:0': {width:3, height:3, widget:{name:'generic.text', data:test_block_content } },
                                          '8:0': {width:4,height:2, widget:{name:'generic.text', data:test_block_content } },
                                          '3:0': {width:5,height:5, widget:{name:'generic.image', data:{} } },
                                         }
                              },
                              "about":{layout:'same',
                                        title:"Page about project",
                                        blocks:{'0:0': {width:12, height:3, widget:{name:'generic.text', data:test_block_content } },
                                                '0:3': {width:12,height:2, widget:{name:'generic.text', data:test_block_content } },
                                                '0:5': {width:5,height:5, widget:{name:'generic.text', data: test_block_content } },
                                        }
                          },
                    }
                }
                
        function hsvToRgb(o, as_array)  {
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
                return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
            }
         
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
         
            if(as_array){
                return [Math.round(r*255) , Math.round(g*255) , Math.round(b*255) ]
            }else{
                
                var rgb = Math.round(b*255) | (Math.round(g*255) << 8) | (Math.round(r*255) << 16);
                // return rgb.toString(16);
                rgbc =  "#" + (0x1000000 | rgb).toString(16).substring(1);
                // // // console.log(r,g,b,rgb, rgbc)
                return rgbc
            }

            // return "rgb(" + Math.round(r * 255) +',' +Math.round(g * 255)+','+ Math.round(b * 255) + ')';
        }
        var pg = {
            // blocks : [],
            page_vars : {},
            rect: function(x,y,w,h){
              return {left:x, top:y, width:w, height:h}  ;
            },
            move_block: function(from, to){
                if(from !== to){
                    this.blocks[to] = this.blocks[from]
                    delete this.blocks[from];
                }
                this._save_site();
            },
            add_block:function(type, to){
                this.blocks[to] = {width:1,height:1, 
                                    widget:{name:type, data: ''  } 
                                };
            this._save_site();

            },
            getApp: function(name){
                var scr = $.ajax({
                                  url: STATIC + "js/sop/" + name + ".js",
                                  async:false
                            }).responseText;
							
            var C = eval("[" + scr + "]")[0];
            
            App = C.getter()
            
            return App;
            },
            load_site:function(){
                
                if (this.Site){
                    return
                }else{
                    // AJAX HERE
                    S = DB.get_objects(this._site_type, {site_id: this.site_id} )
                    // // // console.log(S)
                    
                    if (S.total_amount != 0 ) {
                        this.Site = S.objects[0];
                        
                    }else{
                        // // // console.log("LLLL");
                        this.Site = default_site;
                    }
                    var apps = this.Site._Apps;
                    var apps_ = {};
                    for (ax in apps){
                        var app_name =  apps[ax];
                        var app = this.getApp(app_name)
                        apps_[app_name] = app
                    }
                    this.Site['Applications'] = apps_;
                    delete this.Site.version
                }
                
                
            },
            getPageData: function( page_name ){
                // ajax magic:
                this.load_site();  
                // this.Site = Site;
                // // // console.log(this.Site);
                return this.Site.pages[page_name]
            },
            
            
            setWidgetData: function(pos, data){
                //// // console.log(this.Site.pages,this.Site.pages[this.current_page], pos)
                //console.log('Set Wid Data', this, this.current_page,pos);
                this.Site.pages[this.current_page].blocks[pos].widget.data = data;
                
            },
            _init_page: function(){
                
                var hash_ = window.location.hash.slice(1).split('?')
                var page_name = hash_[0]
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
                    // // // console.log(this.page_vars)
                }
                
                
                pdata = this.getPageData(page_name);
                if (pdata.layout === 'same'){
                    this.layout = this.Site.layout 
                }else{
                    this.layout = pdata.layout;
                }
                this.blocks = pdata.blocks;
                this.base_height = pdata.layout.base_height;
                this.inited_blocks = [];
                
                // this.layout_padding = 10;
                
                
                //this.redraw();
            
                
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
                this._site_type = "generic_site"
                this.is_constructor = do_construction
                this.page_cont = $('#id-top-cont');
                //var cur_page = window.location.hash
                //var current_page = cur_page.slice(1);
                // this._init_page()
                
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
                                    if (!((j==i) || (i==5 &&j==6) || (i==6&&j==5)   ) ){
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
                                            $('<input>').prop('name','scheme').prop('type','radio').prop('id','mono').click(function(){ self._set_scheme_type('mono');self.showColorScheme(); }),      $('<label>').prop('for','mono').text('Mono'),
                                            $('<input>').prop('name','scheme').prop('type','radio').prop('id','complement').click(function(){ self._set_scheme_type('complement');self.showColorScheme()}),$('<label>').prop('for','complement').text('Complement'),
                                            $('<input>').prop('name','scheme').prop('type','radio').prop('id','triada').click(function(){ self._set_scheme_type('triada');self.showColorScheme();}),    $('<label>').prop('for','triada').text('Triada'),
                                            $('<input>').prop('name','scheme').prop('type','radio').prop('id','split-trio').click(function(){ self._set_scheme_type('split-trio');self.showColorScheme();}),$('<label>').prop('for','split-trio').text('Split-trio'),
                                            $('<input>').prop('name','scheme').prop('type','radio').prop('id','analogous').click(function(){ self._set_scheme_type('analogous');self.showColorScheme();}), $('<label>').prop('for','analogous').text('Analogoues'),
                                            $('<input>').prop('name','scheme').prop('type','radio').prop('id','accent').click(function(){ self._set_scheme_type('accent');self.showColorScheme();}),    $('<label>').prop('for','accent').text('Accent')
                                            //$('<input>').prop('type','radio').prop('id','mono'),$('<label>').prop('for','mono').text('Mono'),
                                            
                ).buttonset().appendTo(to)
                $("<span>").text('brightness').appendTo(to)
                $("<div>").width(250).slider({min:0, max:100,value:self.Site.colors.brightness, slide:function(event, ui){ self.Site.colors.brightness = ui.value;self._pallete_drawer.apply(self,[c])  }} ).appendTo(to)
                
                $("<span>").text('saturation').appendTo(to)
                $("<div>").width(250).slider({min:0, max:100,value:self.Site.colors.saturation, slide:function(event, ui){ self.Site.colors.saturation = ui.value; self._pallete_drawer.apply(self,[c])  }} ).appendTo(to)
                
                $("<span>").text('lights').appendTo(to)
                $("<div>").width(250).slider({min:0, max:100,value:self.Site.colors.lights, slide:function(event, ui){ self.Site.colors.lights = ui.value; self._pallete_drawer.apply(self,[c])  } } ).appendTo(to)
                
                $("<span>").text('shadows').appendTo(to)
                $("<div>").width(250).slider({min:0, max:100,value:self.Site.colors.shadows, slide:function(event, ui){ self.Site.colors.shadows = ui.value; self._pallete_drawer.apply(self,[c])  } } ).appendTo(to)

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
                    var off = C.offset()
                        self._set_base_hue(evt.clientX - off.left)  
                    orig = false
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
                var h =  this.Site.colors.base,
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
                br_koef  = [0.05, 0.05, 0.45 ,0.3];
                colors = [h,a,s,A];
                for( col in colors){
                    var color = colors[col];
                    var vars = [{h:color,s:saturation,b:brightness}];
                    
                    if (color){
                        for (i in sat_koef){
                            // // // console.log("K", Number(i)+1)
                            // // // console.log(saturation*( (sat_koef[i]/100)),sat_koef[i], saturation)
                            ds = saturation * sat_koef[i]
                            db = brightness * br_koef[i]
                            
                            if (i < 2){ // lights
                                dsat = ds * lights /100
                                dbri = db  * lights /100
                                
                            }else{// shadows
                                dsat = ds * shadows /100
                                dbri = db  * shadows /100
                                
                            }
                                sat = saturation - dsat;
                                bri = brightness - dbri;
                                // // // console.log(sat, bri)
                                   
                            vars[Number(i)+1] = {h:color,  s:sat, b:bri} 
                        } 
                        this.Site.colors.pallette[col] = vars
                        
                    }else{
                        
                    this.Site.colors.pallette[col] = false;
                    }
                        
                }
               
                
            },
            
           
            
            _set_base_hue: function(hue){
                this.Site.colors['base'] = hue;
            },
            _set_scheme_type: function(type){
                this.Site.colors['type'] = type;
            },
        
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
                    
                    $("<div>").width(250).slider({min:0, max:100,value:self.Site.colors.brightness, slide:function(event, ui){ self.Site.colors.brightness = ui.value;self._pallete_drawer.apply(self,[c])  }} ).appendTo(to)
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
                                ctx.fillStyle =  'rgba(0,0,0, 0.7)';
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
                                        ctx.fillStyle =  'rgba(0,0,0, 0.7)';
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
                                    
                                    return  (cx > line_left && cx < line_right) && Math.abs(line.begin.top - cy ) < thresh
                                }else{
                                    line_top = Math.min(line.begin.top, line.end.top)
                                    line_bottom = Math.max(line.begin.top, line.end.top)
                                    return  (cy > line_top && cy < line_bottom) && Math.abs(line.begin.left - cx ) < thresh
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
                                                        gline.begin.left =  gline.end.left = R.width + R.left;
                                                        redraw(gline);
                                                        return;
                                                    case 'b':
                                                        R.height += diff.top;
                                                        gline.begin.top =  gline.end.top = R.height + R.top;
                                                        redraw(gline);
                                                        return;
                                                    case 'l':
                                                        R.left += diff.left;
                                                        R.width -= diff.left;
                                                        gline.begin.left =  gline.end.left = R.left;
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
            redraw_background: function(){
                var self = this;
                $.each(this.Site.backgrounds, function(name, imgo){
                    // // console.log(name,imgo)
                    
                    if (name == 'body'){
                        var C = $('body')
						c = C[0];
						c.background = imgo.data;
						
                    }else if (name == 'content'){
                        var C = self.layout_cont;
						console.log(name, C, imgo.type)
						
	                    C.css('background-image', 'url("' +imgo.data +'")' ) 
					
                    }
                        
                    
                    if(imgo.type == 'image'){
                        C.css('background-repeat','no-repeat')
                        .css('background-position', [imgo.position.left + 'px' , imgo.position.top +'px' ].join(' ') )
                    }  else if (imgo.type == 'pattern'){
						C.css('background-repeat','repeat')
						.css('background-position','0px 0px')
                        
                    }
                        
                        
                    
                })
            },
            backgroundChooser:function(type) {
                // var to = this._app_admin_contents;
                var self = this;
                // to.find('*').remove()
                
                // this._app_admin_cont.show()
                var cp_ = $('<div>').css('position','absolute').appendTo($('#controls'))
                .position({of: $('body'), my:'left top', at: 'left+200 top_50'})
                .css('padding', '20px').css('background-color', 'orange')
                .draggable({scroll:false})
                
                
                $('<button>').text("X").click(function(){
                    cp_.remove();
                }).appendTo(cp_);
                
                var cp = $('<div>').appendTo(cp_)
                $('<span>').text('plain images:').appendTo(cp)
                
                $("<input>").prop('type','file').change(function(evt){
                    fr = new FileReader()
                    fr.onload = function(){
                        self.Site.backgrounds[type] = {data:this.result,type:'image', position:{left:0, top:0}}
                        self.redraw_background();
                    }  
                    fr.readAsDataURL(this.files[0]);
                    
                    
                    
                }).appendTo(cp);
                var is_move, old_p
                $('<button>').text('move-scale').click(function(evt){
                        var  but = this;
                        // // console.log(evt);
                        var md =function(evt){
                           is_move = true
                           old_p = {top: evt.clientY,
                                    left : evt.clientX} 
                           evt.preventDefault();
                           evt.stopPropagation();
                            
                        }  
                        var mu = function(evt){
                            is_move = false
                        }
                       var scroll = function(evt){
                           // // console.log("wheel", evt)
                           if(evt.type == 'mousewheel'){
                               
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
                                // // console.log('MOE', old_p, p, diff)
                                self.Site.backgrounds[type].position.top += diff.top;
                                self.Site.backgrounds[type].position.left += diff.left;
                                old_p = p
                                self.redraw_background();
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
                       $(document).bind('mousewheel DOMMouseScroll  MozMousePixelScroll', scroll)
                       $(document).bind('mousemove', mm)
                       $(document).bind('keypress', kp)
                       $(this).text("Press esc when DONE").click(function(){kpu()})
                       
                       
                       
                }).appendTo(cp)

                
                var cp = $('<div>').appendTo(cp_)
                
                $('<span>').text('patterns').appendTo(cp)
                $('<input>').prop('type', 'file').change(function(){
                    fr = new FileReader()
                    fr.onload = function(){
                        self.Site.backgrounds[type] = {data:this.result,type:'pattern', position:{left:0, top:0}}
                        self.redraw_background();
                    }  
                    fr.readAsDataURL(this.files[0]);
                }).appendTo(cp);
              
                var cp = $('<div>').appendTo(cp_)
                var C = $('<canvas>').appendTo(cp)[0];
                var S = $('<canvas>').appendTo(cp)[0]
                var ctx = C.getContext('2d')
                //ctx.globalCompositeOperation = "xor";
                var sctx = S.getContext('2d')
                var base = 64;  
                var WA = 0, HA = 0, A = 0, iWA = true, iHA = true;
                var Z = 1 // 0.08;
                var opacity;
                self._make_pallette()
                var BG = this.Site.colors.pallette[0][3]
                var FG = this.Site.colors.pallette[0][0]
                // // console.log(BG,FG)
                
                
                var image, buffData
                
                function redraw_ctx(){
                    C.width = base * 2
                    C.height = base * 2
                    
                    iw = image.width * Z;
                    ih = image.height * Z;

                    function dr_im(x,y,bx,by){
                        
                        
                        ctx.save()
                        ctx.translate(x, y)
                        ctx.scale(Z,Z)
						rad = A* (3.14/180) 
                        ctx.rotate(rad)
						//R = iw / 1.4142135623730951 
						//dx = Math.cos(rad + (Math.PI/4)) * R
						//dy = Math.sin(rad + (Math.PI/4)) * R 
						//console.log(dx,dy)
						//ctx.translate(-dx,-dy)
						console.log(iw, ih)
                        ctx.globalAlpha = opacity / 100;
                        ctx.drawImage(image, -(iw/2), -(ih/2), iw, ih)
                        //ctx.putImageData(buffData, 0,0)
                        ctx.restore()
                    }
                    
                    ctx.fillStyle =  hsvToRgb(BG)  // "rgba( 255,255, 255, 255)";
                    ctx.rect(0,0, C.width, C.height)
                    ctx.fill()
                    WA = base * (WA/100)
                    HA = base * (HA/100)
                    
                    // FIRST TILE
                    
                    ctx.save()
                    ctx.beginPath()
                    ctx.rect(0, 0, base, base)
                    ctx.clip();
                    if (iWA){  dr_im(WA,0);        dr_im(base-WA,base )}
                    if (iHA){  dr_im(0,base - HA); dr_im(base,HA)     }
                    dr_im(base/2, base/2)
                    ctx.closePath();
                    ctx.restore()
                    
                    // SECOND - go down
                    // mirror from first and y + base
                    
                    ctx.save()
                    ctx.beginPath()
                    ctx.rect(0, base, base, base)
                    ctx.clip(); 
                    if (iWA){  dr_im(base - WA,base);        dr_im(WA,base+base)}
                    if (iHA){  dr_im(base,base - HA + base); dr_im(0, HA+base)     }
                    dr_im(base/2, base/2 + base)
                    ctx.restore()


                    // THIRD - go up then right
                    // mirror from first and y + base
                    ctx.save()
                    ctx.beginPath()
                    ctx.rect(base, 0, base, base)
                    ctx.clip(); 
                    if (iWA){  dr_im(base - WA+base,0);        dr_im(WA+base,base)}
                    if (iHA){  dr_im(base+base,base - HA ); dr_im(base, HA)     }
                    dr_im(base/2 + base, base/2 )
                    ctx.restore()
                    
                    // FOURTH - go up then right
                    // mirror from first and y + base
                    ctx.save()
                    ctx.beginPath()
                    ctx.rect(base, base, base, base)
                    ctx.clip(); 
                    if (iWA){  dr_im(WA+base,base);        dr_im(base-WA+base,base+base)}
                    if (iHA){  dr_im(base,base - HA+base); dr_im(base+base,HA+base)     }
                    dr_im(base/2+base, base/2+base)
                    ctx.restore()

                        
                    
                    var img = C.toDataURL()
                    self.Site.backgrounds[type] = {data: img, type:'pattern' }
                    self.redraw_background();
                }
                $('<span>').text('custom patterns').appendTo(cp)
                $('<input>').prop('type', 'file').change(function(){
                    fr = new FileReader()
                    fr.onload = function(){
                        //self.Site.backgrounds[type] = {data:this.result,type:'pattern', position:{left:0, top:0}}
                        // self.ÍÍground();
                        
                        img = new Image()
                        img.onload = function(){
                            
                            // image = this
                            S.width = img.width
                            S.height = img.height
                            sctx.drawImage(img,0,0)
                            buffData = sctx.getImageData(0,0, img   .width, img.height)
                            FGA = hsvToRgb(FG, true)
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
                        img.src = this.result
                        
                        
                    }  
                    fr.readAsDataURL(this.files[0]);
                }).appendTo(cp);
                $('<button>').click(function(e){ iWA = ! iWA;redraw_ctx()}).appendTo(cp).text("-")
                $('<button>').click(function(e){ iHA = ! iHA;redraw_ctx()}).appendTo(cp).text("|")
                
                $("<div>").width(250).slider({min:0, max:100,value:0, slide:function(event, ui){ WA = ui.value ;redraw_ctx() }} ).appendTo(cp)
                $("<div>").width(250).slider({min:0, max:100,value:0, slide:function(event, ui){ HA = ui.value;redraw_ctx() }} ).appendTo(cp)
                $("<div>").width(250).slider({min:0, max:360,value:0, slide:function(event, ui){ A = ui.value ;redraw_ctx()}} ).appendTo(cp)
                $("<div>").width(250).slider({min:1, max:100,value:1, slide:function(event, ui){ Z = (ui.value)/100 ;redraw_ctx()}} ).appendTo(cp)
                $("<div>").width(250).slider({min:16, max:512,value:1, slide:function(event, ui){ base = ui.value ;redraw_ctx()}} ).appendTo(cp)
                $("<div>").width(250).slider({min:0, max:100,value:100, slide:function(event, ui){ opacity = ui.value ;redraw_ctx()}} ).appendTo(cp)
                
                
                
            },
            show_CP: function(active_tab){
                var self = this;
                var C = $('div#controls');
                this.cp = $("<div>").appendTo(C)
                .width(240).height($(document).height())
                .css('position','fixed').css('top',0).css('left',0)
                
                this._app_admin_cont = $('<div>').css('position','fixed').css('overflow', 'scroll')
                .css('top', 0).css('left', 240).width(1000).height($(document).height())
                .css('background', 'white')
                .appendTo(C).hide() ;
                
                $('<div>')
                .css('background', 'orange')
                .width(this._app_admin_cont.width())
                .append($('<button>').text('HIDE').click(function(){ self._app_admin_cont.hide() }))
                .appendTo(this._app_admin_cont);
                this._app_admin_contents = $('<div>').appendTo(this._app_admin_cont)
                
                
                
                this.cp_acc = $("<div>").appendTo(this.cp)
                //.css('background-color', 'orange')
                
                // .appendTo(C)
                
                // General Settings tab 0
                $("<h3>").text("Основные").appendTo(this.cp_acc)
                var d = $("<div>").appendTo(this.cp_acc)
                var ul = $("<ul>").appendTo(d)
                $("<li>").append($("<a>").prop('href','#').text("Управление фоном").click(function(){ self.backgroundChooser() }) ).appendTo(ul) 
                $("<li>").append($("<a>").prop('href','#').text("Цветовая схема").click(function(){ self.showColorScheme() }) ).appendTo(ul) 
                $("<li>").append($("<a>").prop('href','#').text("Создание фонов").click(function(){ self.showBackgroundScheme() }) ).appendTo(ul) 
                $("<li>").append($("<a>").prop('href','#').text("Управление геометрией").click(function(){ self.showLayoutScheme() }) ).appendTo(ul) 
                $("<li>").append($("<a>").prop('href','#').text("Управление доменами").click(function(){ self.showDomainScheme() }) ).appendTo(ul) 
                //$("<li>").append($("<a>").prop('href','#').text("Шапка").click(function(){ self.showHeaderScheme() }) ).appendTo(ul) 
                // $("<li>").append($("<a>").prop('href','#').text("").click(function(){ self.showFooterScheme() }) ).appendTo(ul) 
                
                // Page settings 1
                $("<h3>").text("Страница").appendTo(this.cp_acc)
                var d = $("<div>").appendTo(this.cp_acc)
                var ul = $("<ul>").appendTo(d)
                $("<li>").append($("<a>").prop('href','#').text("Общие").click(function(){ self.showPageSettings() }) ).appendTo(ul) 
                $("<li>").append($("<a>").prop('href','#').text("Геометрия").click(function(){ self.showPageLayout() }) ).appendTo(ul) 
                $("<li>").append($("<a>").prop('href','#').text("Фон страницы").click(function(){ self.showPageBackgroundChooser() }) ).appendTo(ul)
                // Page selection 2
                $("<h3>").text("Мои страницы").appendTo(this.cp_acc)
                var d = $("<div>").appendTo(this.cp_acc)
                var ul = $("<ul>").appendTo(d)
                $("<li>").append($("<a>").prop('href','#').text("Добавить").click(function(){ self.addPage() }) ).appendTo(ul)
                $.each(this.Site.pages, function(i,p){
                    $("<li>").append($("<a>").prop('href','#' + i).text(p.title).click(function(e){
                        //// // console.log(i)
                        window.location.hash = i;
                        self._init_page();
                        e.preventDefault();
                    }) ).appendTo(ul) 
                })
                 
                // Applications 3
                $("<h3>").text("Приложения").appendTo(this.cp_acc)
                var d = $("<div>").appendTo(this.cp_acc)
                var ul = $("<ul>").appendTo(d)
                $.each(this.Site.Applications, function(name, app){
                    if(app.admin_page){
                        $("<li>").append($("<a>").prop('href','#').text(app.title).click(function(){ app.admin_page(self._app_admin_contents); self._app_admin_cont.show() }) ).appendTo(ul) 
                        
                    }
                    //// // console.log(name, app)
                })
                
                //$("<li>").append($("<a>").prop('href','#').text("Геометрия").click(function(){ self.showPageLayout() }) ).appendTo(ul) 
                //$("<li>").append($("<a>").prop('href','#').text("Геометрия").click(function(){ self.showPageLayout() }) ).appendTo(ul)
                
                 
                // Виджеты 4
                $("<h3>").text("Виджеты").appendTo(this.cp_acc)
                var d = $("<div>").appendTo(this.cp_acc)
                var ul = $("<ul>").appendTo(d)
                $.each(this.Site.Applications, function(app_name, app){
                    if(app.widgets){
                        // // console.log(app.title);
                        var li = $("<li>").text(app.title).appendTo(ul); 
                        var ul_ = $("<ul>").appendTo(li);
                        $.each(app.widgets, function(name, w){
                            // // console.log(name, w);
                            $("<li>").addClass("draggable-module")
                            .text(w.title).appendTo(ul_)
                            .prop('type', app_name + '.' + name) 
                            .draggable({helper: function( event ) {
                                    return $( "<div class='ui-widget-header'>I'm a custom helper</div>" );
                                    } 
                                })
                        })
                        
                    }
                    //// // console.log(name, app)
                })
                
                //$("<li>").append($("<a>").prop('href','').text("Общие").click(function(){ self.showPageSettings() }) ).appendTo(ul) 
                //$("<li>").append($("<a>").prop('href','').text("Геометрия").click(function(){ self.showPageLayout() }) ).appendTo(ul) 
                //$("<li>").append($("<a>").prop('href','').text("Геометрия").click(function(){ self.showPageLayout() }) ).appendTo(ul)
                 
                if (active_tab){
                    this.cp_acc.accordion({active: active_tab, heightStyle:'fill'});
                }else{
                    this.cp_acc.accordion()
                }  
            },
            addPage: function(){
              var amount = 0
              for (k in this.Site.pages){amount += 1};
              slug = "Untitled_page_" + (amount + 1);
              var newPage = {title: "Untitled page " + (amount + 1),
                             blocks :[],
                             layout : 'same'}
              this.Site.pages[slug] = newPage;   
              this.redraw_cp(2);
              
            },
            redraw: function(){
                //this.show_CP();
                this.clear();
                this.draw();
                
                
                
            },
            clear : function(){
                this.page_cont.find('*').remove();
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
                    var ll   = this._calc_left(i+1);
                    var d    = Math.abs(left - ll);
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
                for (var i =0; i < 200; i++){
                    
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
                for (var i =0; i < 200; i++){
                    
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
                    ws[d] =  {val:ww,block:i+1}
                }
                return ws[sm]
            
                
            },
            _block_width: function(){
                block_width = (this.layout.width / this.layout.cols) - (2 * this.layout.padding.hor)
                return block_width
                
            },
            _block_left: function(){
                
            },
            _block_height: function(){
                block_height = this.layout.base_height;
                return block_height;
                
            },
            _calc_top: function(t){
                var h = (this._calc_height(t))
                if (h == 0){ var P =0} else {var P = 2}
                // // // console.log(cbw)
                return ( h + P*this.layout.padding.ver  ) ;// + this._main_offset.top;
                // return (cbh * t); //+ (this.layout.padding *2 * (w-1))
            },
            
            _calc_left: function(l){
                var w = (this._calc_width (l-1) )
                if (w == 0){var P =0}else{var P=2}
                return (this.layout.padding.hor + w + P*this.layout.padding.hor  ) + this._main_offset.left;
            },
            _calc_height: function(h){
                if (this._c_bh){
                    cbh = this._c_bh
                } 
                else{
                    this._c_bh = this._block_height()
                    cbh = this._c_bh
                }
                // // // console.log(cbw)
                return (cbh * h) + (this.layout.padding.ver *2 * (h-1)); 
                
                
            },
            _calc_width: function(w){
                if (w <= 0) return 0;
                if (this._c_bw){
                    cbw = this._c_bw
                } 
                else{
                    this._c_bw = this._block_width()
                    cbw = this._c_bw
                }
                
                return (cbw * w) + (this.layout.padding.hor *2 * (w-1)) 
                
                
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
                
                total_height = this.Site.layout.drawen_lines * (this.Site.layout.base_height + 2*(this.Site.layout.padding.ver))
                this.layout_cont = $("<div>")
                            .css('width', this.layout.width + e)
                            .css('margin-left','auto')
                            .css('top',0)
                            .css('height', total_height)
                            .css('margin-right','auto').appendTo(to),
                    c_off = this.layout_cont.offset();
                to.css('top',0);
                    
                this.redraw_background();
                if(this.is_constructor){
                    $('<div>').css('background-color','orange').text('change background')
                    .css('position','fixed')
                    .css('top', 0).css('left','50px')
                    
                    .appendTo($('#controls'))
                    .click(function(){
                        self.backgroundChooser('body')
                        // // // console.log("change global BG")
                    })
                    
                    $('<div>').css('background-color','orange').text('content background')
                    .css('position','fixed')
                    .css('top', 0).css('left','200px')
                    
                    .appendTo($('#controls'))
                    .click(function(){
                        self.backgroundChooser('content')
                        //// // console.log("change content BG")
                    })
                    
                }
               
                this._main_offset = c_off;

                        this._busy_regions = [];
                        this._moved_block_ = [] ;
                        $.each(this.blocks, function(koords, block){
                            var x = Number(koords.split(':')[0]);
                            var y = Number(koords.split(':')[1]);
                            var xx = self._calc_left(x+1);
                            var yy = self._calc_top(y);
                            
                            // // // console.log('We got', xx, yy);
                        
                            var gp = { jq : $("<div>")
                                                .appendTo(self.layout_cont)
                                                .css('position','absolute')
                                                .css('left', xx ).css('top',  yy)
                                                .css('border', '1px solid black')
                                                .css('overflow','hidden'),
                                                
                                                // .css('height', this.layout.base_height),
                                                // .css('margin-left', this.layout.padding)
                                                // .css('margin-right', this.layout.padding)
                                       pos: {row:y, ix:x},
                                }
                            self.inited_blocks.push(self.init_block(block, gp, koords))
                            if(self.is_constructor){
                                for (w = x; w< x + block.width; w++){
                                    for (h = y; h < y+block.height; h++){
                                        self._busy_regions.push(w +":"+ h ) 
                                        
                                    }
                                }
                                
                            }

                        })
                        
                        if(this.is_constructor) {
                            this.redraw_empty_blocks();
                        }
                        
                       
                
            },
            redraw_empty_blocks: function(){
                $('.empty_blocks').remove();
                for (cols = 0; cols < this.layout.cols; cols++){
                    for(row = 0; row < this.Site.layout.drawen_lines; row++){
                        var c = cols + ":" + row;
                        is_busy = this._busy_regions.indexOf(c) !== -1
                        is_moved = this._moved_block_.indexOf(c) !== -1
                        
                        
                        if(!is_busy || is_moved){
                            xx = this._calc_left(cols+1) // + c_off.left;
                            yy = this._calc_top(row);
                            
                            $('<div>')
                            .addClass('empty-block')
                            .appendTo(this.layout_cont)
                            .css('position', 'absolute')
                            .css('border-radius', '10px')
                            .css('left',xx)
                            .css('top',yy)
                            .css('border', '1px dotted black ')
                            .css('width', this._calc_width(1) )
                            .css('height', this._calc_height(1) )
                            .css('left',xx)
                            
                        } 
                    }
                }
                
            },
            
            init_block: function(bl, to, my_pos){
                var r = bl.top,
                    l = bl.left,
                    w = bl.width,
                    h = bl.height,
                    self = this,
                    W = this._calc_width(w),
                    H = this._calc_height(h),
                    widget = bl.widget.name.split('.'),
                    wdata  = bl.widget.data;
                function newWidget(c,data, t,p){
                    return t.Site.Applications[widget[0]].widgets[widget[1]].init(c, data, t,p);
                }
                    
                
                    
                
                // to.prop('pos',my_pos);
                var w = $("<div>").width(W).css('height',H).appendTo(to.jq).prop("pos", my_pos).addClass("draggable-module")
                var draga;
                if(this.is_constructor){
                    
                    to.jq.draggable({
                        scroll:false,
                        zIndex:100,
                        cancel: '.resize-marker',
                        start:function(event,ui){
                            regs = [];
                            for (w = to.pos.ix; w < to.pos.ix     + bl.width; w++){
                                for (h = to.pos.row; h < to.pos.row +bl.height; h++){
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
                            var ll = self._stepping_left(ui.position.left)
                            var tt = self._stepping_top(ui.position.top)
                            draga = {left:ll.block, top:tt.block };
                            
                            ui.position = {top:tt.val, left: ll.val};
                            
                            
                        },
                        stop:function(){
                            var oldpos = to.pos.ix +':' +  to.pos.row  ;
                            var new_pos = draga.left + ':' + draga.top;
                            self._moved_block = false;
                            self.move_block(oldpos, new_pos);
                            self.redraw();
                            
                        },
    
                    })
                }
                // console.log (self.Site);
                var Widget = newWidget(w, wdata, this, my_pos);
                //console.log ("new Widget", Widget);
                Widget.draw();
                // // // console.log('ok');
                
                
                
                // var dg = $("<div>").addClass('drag-handle').appendTo(w).css('background-color','orange').css('cursor','move')
                // .css('position','absolute').width(to.jq.width()).height('20px').position({of: to.jq, my:"left top", at:"left top", collision:'none' })
                // .disableSelection().text("module drag").hide()
                
                //var prop_button = $('<div>').addClass('porperties-button').appendTo(to.jq).css('position', 'absolute')
                //    .position({of: to.jq, my:'right top', at:'right-14 top', collision:'none none'}).addClass("ui-icon ui-icon-note").width(20).height(20).hide()
                if (this.is_constructor){
                    
                        to.jq.dblclick(function(){
                                //// // console.log("CLICK UNBIND")
                                
                                for (blix in self.inited_blocks){
                                    var bl = self.inited_blocks[blix];
                                    bl.unbind("mouseenter")
                                    bl.mouseleave();
                                    bl.unbind("mouseleave")
                                    
                                }
                                to.jq.draggable('destroy');
                                Widget.settings();
                                
                                $("<div>").css('background-color','orange').appendTo(to.jq).css('position','absolute')
                                .position({of:to.jq, 
                                              my:"left top", 
                                              at:"right top",
                                              collision:"none"})
                                    .addClass("ui-icon ui-icon-gripsmall-diagonal-se").width(20).height(20);
                                    
                                $("<div>").css('background-color','green').appendTo( to.jq.parent() ).css('position','absolute')
                                .position({of:to.jq, my:"left top", at:"left-20 top", collision:'none none' })
                                .addClass("ui-icon ui-icon-gripsmall-diagonal-se").width(20).height(20).click(function(){
                                    Widget.save()
                                    self._save_site();
                                    self.redraw.apply(self,[])
                                });
                                
                                $("<div>").css('background-color','red').appendTo( to.jq.parent() ).css('position','absolute')
                                .position({of:to.jq, my:"left top", at:"left-20 top+30", collision:'none none' })
                                .addClass("ui-icon ui-icon-gripsmall-diagonal-se").width(20).height(20).click(function(){
                                    
                                    self.redraw.apply(self,[])
                                });
        
                            })
                            
                        
                        
                        var resize_marker = $("<div>").appendTo(to.jq).prop('pos', my_pos).css('position','absolute')
                        .position({of:to.jq, my:"right bottom", at:"right-14 bottom-14"})
                        .css('background-color','black')
                        .addClass("ui-icon ui-icon-gripsmall-diagonal-se").width('20px').height('20px').hide()
                        .addClass('resize-marker')
                        .mouseenter(function(){ console.log('enter') })
                        .mousedown(function(evt){
                            self.resize_frame = $("<div>")
                                                    .css("position", 'absolute')
                                                    .css('border', "1px solid black")
                                                    // .addClass('resize-frame')
                                                    .appendTo(to.jq.parent())
                                                    .width(W)
                                                    .height(H)
                                                    .prop('orig_w', W)
                                                    .prop('orig_h', H)
                                                    .prop('begin_x', evt.clientX)
                                                    .prop('begin_y', evt.clientY)
                                                    .position({of:to.jq, my:'left top', at:'left top'});
                            
                            to.jq                   
                            .prop('cur_width', bl.width)
                            .prop('cur_height',bl.height)
                            //evt.stopPropagation();
                            //evt.preventDefault();
                            to.jq.parent().unbind('mouseup')
                            //to.jq.parent().unbind('mousedown')
                            to.jq.parent().unbind('mousemove')
                            
                            to.jq.parent().mouseup(function(){
                                //// // console.log(to.pos);
            
                                // // // console.log("we finished")
                                if(self.resize_frame){
                                    self.resize_frame.remove()
                                    self.resize_frame = false;
                                    // // // console.log(to)
                                    var myw = to.jq.prop("cur_width");
                                    var myh = to.jq.prop("cur_height");
                                    var pos = to.pos.ix +':' +  to.pos.row  ;
                                    
                                    
                                    //// // console.log("here it is", myw, myh, pos, self.blocks)
                                    
                                    self.blocks[pos].width = myw;
                                    self.blocks[pos].height= myh;
                                    self.redraw.apply(self, [])
                                    // // // console.log(myw , myh )
                                    //evt.stopPropagation();
                                    //evt.preventDefault();
                                }
                                
                            })
                            to.jq.parent().mousemove(function(evt){
                                //// // console.log('mousemove');
                                var fr = self.resize_frame;
                                //// // console.log("here is", fr);
                                if (fr){
                                    //`// // console.log("we got fr");
                                    if (fr.size()){
                                        var W  = fr.prop('orig_w'),
                                            H  = fr.prop('orig_h'),
                                            mx = fr.prop('begin_x'),
                                            my = fr.prop('begin_y'),
                                            nh = evt.clientY - my + H,
                                            nw = evt.clientX - mx + W,
                                            width_step = self._stepping_width(nw),
                                            height_step = self._stepping_height(nh);
                                        // // // console.log(nw, nh, width_step)
                                        fr.width(width_step.val)
                                        fr.height(height_step.val)
                                        to.jq.prop("cur_width", width_step.block)
                                        to.jq.prop("cur_height", height_step.block)

                                       }
                                    
                                    
                                }
                                    
                            })
                        })
                        
                        
        
                        // // // console.log(to.jq);             
                        to.jq.mouseenter(function(e){
                            //// // console.log('MENTER');
                            //Widget.jq().css('opacity','0.3')
                            //dg.show()
                            resize_marker.show()
                            resize_marker.zIndex(1000);
                            // prop_button.show()
                            
                            
                        }).mouseleave(function(){
                            //// // console.log('MLEAVE');
        
                            //dg.hide()
                            resize_marker.hide()
                            // Widget.jq().css('opacity','1')
                            //prop_button.hide()
        
                        })
                }
                return to.jq
                }
                
            }
            return pg
        },
       getter:function(){return this.Constructor()}
        
})
            