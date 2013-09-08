var scaleImage;

scaleImage = function(img, maxWidth, maxHeight, useMax) {
  var h, height, scale, w, width;
  if (useMax == null) {
    useMax = false;
  }
  w = img.width;
  h = img.height;
  width = img.width;
  height = img.height;
  if (useMax) {
    scale = Math.max(maxWidth / width, maxHeight / height);
  } else {
    scale = Math.min(maxWidth / width, maxHeight / height);
  }
  width = parseInt(width * scale, 10);
  height = parseInt(height * scale, 10);
  img.width = width;
  img.height = height;
  return img;
};

function dummyIniter(){
    WidgetIniter.call(this);
    this.default_size = [4,4];
    this.title = "Пустышка";
    this._draw = function(){
        this._jq = $('<span></span>').appendTo(this.my_cont)
    };
}

function textIniter(){
    WidgetIniter.call(this);
    this.default_size = [4,4];
    this.title = "Текстовое поле";
    this._def_data = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
	
    this._draw = function(){
        if (typeof this.C.Site.fonts == 'undefined' ){
            font = 'Times New Roman'
        } else{ font = this.C.Site.fonts.content}
        this._jq = $("<div>")
            .addClass('text-data')
            .html(this._data()).appendTo(this.my_cont)
            .css('font-family', font )
    };
    this._change_text = function(command,val){
       r = document.execCommand(command, false, val);
    };
    this._save = function(){
        this.data = this._jq.html();
    };
    this._settings= function(controls){
        var self =this;
        var d;
        this._d_remover=function(){
            if (d != null){d.remove()}
        }
        function saveSelection() {
            if (window.getSelection) {
                sel = window.getSelection();
                if (sel.getRangeAt && sel.rangeCount) {
                    return sel.getRangeAt(0);
                }
            } else if (document.selection && document.selection.createRange) {
                return document.selection.createRange();
            }
            return null;
        }
        function restoreSelection(range) {
            if (range) {
                if (window.getSelection) {
                    sel = window.getSelection();
                    sel.removeAllRanges();
                    sel.addRange(range);
                } else if (document.selection && range.select) {
                    range.select();
                }
            }
        }
        if(this.C){
            this._jq.prop('contentEditable', 'true') //.prop('id', eid)
            var initer = function(){
                var closer = function(){
                    if(d != null){
                        d.remove();
                        d = null;
                    }
                    setTimeout(initer, 500);
                }
                $(document).one('mouseup', function(evt){
                    var sel = window.getSelection()
                    // console.log(sel);
                    if ( (sel.focusOffset - sel.anchorOffset)  !=  0){
                        if (d != null){
                            d.remove();
                        }
                        d = $('<div></div>').css({
                            'position':'absolute',
                            'background-color':'white'
                            }).appendTo($('#controls'))
                            .position({of:evt, my:'right top', at:'left top'})
                        $('<button>').html('X').appendTo(d).click(function(){self._change_text("RemoveFormat"); closer()})
                        $('<button>').html('<b>B</b>').appendTo(d).click(function(){self._change_text("bold"); closer()})
                        $('<button>').html('<i>i</i>').appendTo(d).click(function(){self._change_text("italic");closer() })
                        $('<button>').html('<u>U</u>').appendTo(d).click(function(){self._change_text("underline");closer() })
                        $('<button>').html('<s>S</s>').appendTo(d).click(function(){self._change_text("StrikeThrough");closer() })
                        $('<button>').text('color').appendTo(d).click(function(){
                            cb = function(col,ix,hsba) {
                                var hex = hsvToHex(hsba)
                                self._change_text('forecolor', hex);closer()
                            };
                            self.color_chooser = self.constr.draw_color_chooser(cb);
                            self.color_chooser.appendTo($('#controls')).position({of:$(this), my:'left top', at:'right bottom'})
                        })
                        $('<button>').html('Unlink').appendTo(d).click(function(){
                            self._change_text('Unlink');closer()

                        })
                        $('<button>').html('Link').appendTo(d).click(function(){
                            var di = $('<div></div>').appendTo($('#controls'));
                            var link_choice = $("<ul>").appendTo(di)
                            var namer = function(pname, page){
                                var _ret = function(){
                                    var a;
                                    if (pname == null){
                                        a = page;
                                    }else{
                                        a = "#!" + pname;
                                    }
                                    document.execCommand('createLink', false, a);
                                    di.dialog('close');
                                    closer();
                                }
                                return _ret;
                            }
                            $.each(constructor_inst.Site.pages, function(pname, page){
                                var li = $('<li></li>').appendTo(link_choice)
                                $('<button></button>').text(page.title).appendTo(li)
                                    .click(namer(pname, page))
                            })
                            var li = $('<li>Ссылка не на мой сайт:</li>').appendTo(link_choice)
                            // var link = '';
                            var sel;
                            var inp =$('<input type="text">').appendTo(li)
                                .on('mousedown',function (){ sel = saveSelection()} );
                            $('<button>').text("Создать").appendTo(li).mousedown(function(e){
                                var link = inp.val();
                                var r = namer(null, link)
                                restoreSelection(sel);
                                r(e);
                            })
                            di.dialog({title: "Вставить ссылку"})
                        })
                        setTimeout(initer, 3000)
                    }else{
                        if (d != null){
                            d.remove();
                        }
                        initer();
                    }
                })// Document.one mouseup
            }
            initer()
            var cp = $("<div>").appendTo(controls )
        }
    }
}

function sliderIniter(){
    WidgetIniter.call(this);
    this.title = "Слайдер";
    this.default_size = [4,4];

    this._draw = function(){
        var self = this;
        var timeout = 5000;
        self._jq = $('<div>').appendTo(self.my_cont)
        var removers = [];

        var redraw = function(id){
            //console.log(self.data)
            if (self.data != null && self.data.slides != null ){
                var next_id = (id + 1) % self.data.slides.length
                var slide = self.data.slides[id];
                var new_ = $('<div></div>')

                            .prependTo(self._jq)
                            .css('position','absolute')
                            .width(self.my_cont.width()).height(self.my_cont.height())
                            .hide()

                $(new Image()).one('load', function(){

                    scaleImage(this, self.my_cont.width(), self.my_cont.height(),true )


                    //$(this).appendTo(new_);

                    new_.css('background', 'url('+this.src+')')
                        .css('background-size', this.width+ "px " + this.height+'px')
                    if (set != null && self.set.border_radius) {
                        new_.css('border-radius', self.set.border_radius-2 +'px' )
                    }

                    $.each(slide.labels, function(ix, label){
                        var col = self.C.get_color( label.color );
                        // console.log(label.left);
                        $("<div></div>").appendTo(new_)
                            .css('position', 'absolute')
                            .css('top', label.top + '%')
                            .css('left', label.left + '%')
                            .css('width', label.width + '%')
                            .css('heigth', label.height + '%')
                            .css('font-size', label.font + 'pt')
                            .css('color', hsvToHex((self.C.get_color( label.color )) ) )
                            .text(label.text);

                    })
                    new_.show();
                    // console.log(removers)
                    if (removers.length != 0 ){
                        // console.log('rem')
                        removers[0]();
                        var a = removers.splice(0, 1)
                        // console.log(a,'removers', removers)
                    }
                    var remove = function(){
                        // console.log('collee');
                        new_.animate({opacity:0},{duration:1000, complete:function(){new_.remove()}})
                    }
                    removers.push(remove)

                }).prop('src', DB.get_blob_url(slide.image))
                setTimeout(function(){ redraw (next_id) }, timeout )

            }
        }
        redraw(0);
    };
    this._settings = function(){
        var self = this
        if (self.data == null){self.data = {slides:[]};}

        var dialog = $('<div></div>').appendTo($('#controls'))
        var slides_cont = $('<div></div>').appendTo( dialog )
        var editSlide;

        var reload_slides = function(){
            slides_cont.find('*').remove();

            var ul = $('<ol></ol>').appendTo(slides_cont)

            if (self.data.slides != null){
                $.each(self.data.slides, function(i, slide){
                    var li =  $('<li>').appendTo(ul);
                    var src;
                    if (slide.image.blob){
                        src = DB.get_blob_url(slide.image)
                    }else{
                        src = slide.image;
                    }
                    $(new Image()).one('load', function(){
                        scaleImage(this,64,64)

                        $(this).appendTo(li).on('dblclick', function(){
                            // console.log("slide num", i)
                            editSlide(i);
                        })

                    }).prop('src', src)

                })
            }
        }
        reload_slides();
        var editSlide = function ( slide_id ){

            var slide_d = $('<div></div>').appendTo( $('#controls') );
            var img_cont = $('<div></div>').appendTo(slide_d).width(self.my_cont.width()).height(self.my_cont.height()).css('float','left').css('overflow','hidden')

            $('<div></div>').css('clear','both').appendTo(slide_d);
            var lbs_cont = $('<div></div>').appendTo(slide_d).width(500).height(300).css('float','left')

            var slide;
            if (slide_id === null || slide_id === undefined ){

                slide = {'image':'', labels:[{text: "lorem ipsгь вщдщк ыше фьуе ыва ", width:10, heigth:10, top:10, left:10, color:{ix:0, v:1}, font:10 }]}
            }else{
                slide = self.data.slides[slide_id]
            }

            var redraw_slide = function(){
                img_cont.find('*').remove();
                if( slide.image ){
                    if (slide.image.blob){
                        src = DB.get_blob_url(slide.image)
                    }else{
                        src = slide.image;
                    }
                    $(new Image()).one('load', function(){
                        scaleImage(this, img_cont.width(), img_cont.height() , true);
                        $(this).appendTo($("<div></div>").css('float','left').appendTo(img_cont) );
                    }).prop('src', src);

                }
                $.each(slide.labels, function(ix, label){
                    var col = self.C.get_color( label.color );
                    var abs_cont = $("<div></div>").appendTo(img_cont).css('position','absolute').width(self.my_cont.width()).height(self.my_cont.height())
                    $("<div></div>").appendTo(abs_cont)
                        .css('position', 'absolute')
                        .css('top', label.top + '%')
                        .css('left', label.left + '%')
                        .css('width', label.width + '%')
                        .css('heigth', label.height + '%')
                        .css('font-size', label.font + 'pt')
                        .css('color', hsvToHex((self.C.get_color( label.color )) ) )
                        .text(label.text);

                })

            }
            var acc_cont;
			
            var draw_label_controls =function (){
                acc_cont.find('*').remove();
                var acc = $('<div ></div>').appendTo(acc_cont)

                $.each(slide.labels, function(ix, label){
                    // var lblc = $('<div></div>').appendTo(lbs_cont).addClass('');
                    if (label.text.length > 50){
                        $("<h3></h3>").text(label.text.slice(0,50) + "...").appendTo(acc)
                    }else{
                        $("<h3></h3>").text(label.text).appendTo(acc)
                    }
                    var lblc = $('<p>').appendTo($('<div></div>').appendTo(acc))

                    $('<textarea></textarea>').text(label.text).appendTo(lblc).on('keyup change', function(){
                        slide.labels[ix].text = $(this).val();
                        redraw_slide()
                    });

                    var c = function(n){
                        $("<br>").appendTo(lblc)
                        $('<span>').text(n).appendTo(lblc)
                        $('<div>').slider({min:0,max:100, value: label[n], slide:function(e, ui){
                            slide.labels[ix][n] = ui.value;
                            redraw_slide()
                        }}).appendTo(lblc);

                    }
                    c('left');
                    c('top');
                    c('width');
                    c('height');
                    c('font');

                    $("<br>").appendTo(lblc)
                    $('<span>').text('fonsize').appendTo(lblc)
                    $('<button>').text('choose color').appendTo(lblc).click(function(){
                        cb = function(col,ix,hsba) {
                            label.color = ix;
                            redraw_slide();
                        };
                        self.color_chooser = self.C.draw_color_chooser(cb);
                        self.color_chooser.appendTo($('#controls')).position({of:$(slide_d), my:'left top', at:'left top'})
                    })
                })


                $('<button>').text('add label').click(function(){
                    var l = {text: "lorem ipsгь вщдщк ыше фьуе ыва ", width:10, heigth:10, top:10, left:10, color:{ix:0, v:1}, font:10 }
                    if (slide.label == null){
                        slide.labels = [l]
                    }else{
                        slide.labels.push(l);
                    }

                    draw_label_controls();

                }).appendTo(acc_cont);
                acc.accordion();

            }
            var changer = $('<div></div>').appendTo(lbs_cont)
            acc_cont =  $('<div>').appendTo(lbs_cont)
            $('<span></span>').text("Изменить изображение").appendTo(changer)
            $('<input>').prop('type','file').appendTo(changer).change(function(){
                fr = new FileReader()
                fr.onload = function(){
                    slide.image = this.result
                    redraw_slide();
                }
                fr.readAsDataURL(this.files[0])
            })
            draw_label_controls();
            redraw_slide();

            slide_d.dialog({
                title:"Slide settings",
                width:700,
                height:700,
                buttons:{
                    save:function(){
                        if (slide_id != null){
                            self.data.slides[slide_id] = slide
                        }else{
                            if(self.data.slides != null ){
                                self.data.slides.push(slide);

                            }else{
                                self.data.slides = [slide];

                            }
                        }
                        slide_d.dialog('close');
                        reload_slides()
                    }
                }
            })
        }

        $('<button></button>').text('add Slide').appendTo(dialog).click(function(){
            //console.log("Button - new")
            editSlide()
        })
        dialog.dialog({
            title:"Slider settings",
            width:600,
            height:500,
            buttons:{save: function(){
                    self.save();
                }
            }
        })
    };
}

function menuIniter(){
    WidgetIniter.call(this);
    this.title = "Меню сайта";
    this.is_settings = false
    this.default_size = [4,1];
    this._def_data =[];
    this._settings = function(){this.is_settings = true;  this.redraw();  }
    this._save = function(){this.is_settings = false, this.redraw();}
    this._cancel = function(){this.is_settings = false, this.redraw();}

    this._draw = function(){
		
		var self = this;
		
        if(this._data().length == 0  ){
            var pages = $.extend(true, {}, self.C.Site.pages)
            var pa = []
            $.each(pages,function(i, p){
                p.name = i
                pa.push(p)
            })
            pa.sort(function(a,b){ return a.order - b.order } )
			self.data = self._data();
			

            _.chain(pa)
            .map(function(pval, pname) {
                    if (pval.show_in_menu ){
                        self.data.push({name: pval.name, title:pval.title})
                    }
                })
        }
        if (typeof this.C.Site.fonts == 'undefined' ){
            font = 'Times New Roman'
        } else{ font = this.C.Site.fonts.content}


        this._jq = $("<ul>")
                    .appendTo(this.my_cont)
                    .css('font-family', font )
                    // .css('font-size', my_cont.width() / 40)
                    .css('padding',0).css('margin', 0)


        var current_page = self.C.current_page
        var self = this;
        var pages = this.data.length

        var pages = this.data; // $.extend(true, {}, this.data)

        $.each(pages, function(ix,p){
            var i = p.name
            var li = $("<li>").appendTo(self._jq)
                                 .css('float', 'left') //.width(item_width)
                                 .css('padding',0).css('margin-right', '2em')
                                 .css('list-style-type','none')
                .css('display','block')
                .css('position','relative')

            if (i == current_page){
                var a = $("<span></span>").text(p.title)
                li.append(a)
            }else{
                var a = $("<a>").append(p.title).appendTo(li)

                if(i in self.C.Site.pages ){
                    a.prop('href', "#!" + i).click(function(evt){
                        window.location.hash = "!" + i
                        evt.preventDefault();
                    })
                }else{
                    a.prop('href', i )
                }

            }
			
            if (self.is_settings){
               var t = 0
               if (ix != 0){
                    $("<button></button>").text("<").appendTo(li).css('position','absolute').css('top',t).css('left',-10)
                        .click(function(){
                           var item = self.data[ix-1];
                           self.data[ix-1]= self.data[ix]
                           self.data[ix] = item;
                           self.redraw();
                           })
               }
               var rmb = $("<button></button>").text("x").appendTo(li).css('position','absolute').css('top',t).css('background-color', 'red')
               rmb.css('left',(li.width() - rmb.width())/2 )
               rmb.click(function(e){ self.data.splice(ix,1); self.redraw(); })
               if(ix != pages.length -1){

                   var rb = $("<button></button>").text(">").appendTo(li).css('position','absolute').css('top',t)
                   rb.css('left',li.width() - rb.width() + 10)
                       .click(function(){
                            var item = self.data[ix+1];
                            self.data[ix+1]= self.data[ix]
                            self.data[ix] = item;
                            self.redraw();
                       })
               }




            }

        })
        if(self.is_settings ){
            $('<button></button>').appendTo($('<li></li>').css('float', 'left') //.width(item_width)
                    .css('padding',0).css('margin-right', '2em')
                    .css('list-style-type','none')
                    .css('display','block')
                    .css('position','relative')
                .appendTo(self._jq)
            ).text("++").click(function(){
                var di = $('<div></div>').appendTo($('#controls'));
                var link_choice = $("<ul>").appendTo(di)
                var namer = function(pname, title){
                    var _ret = function(){
                        var a;
                        item = {name:pname, title:title}
                        self.data.push (item)
                        // console.log(self.data)

                        di.dialog('close');
                        self.redraw();

                    }
                    return _ret;
                }
                $.each(self.C.Site.pages, function(pname, page){
                    var li = $('<li></li>').appendTo(link_choice)
                    $('<button></button>').text(page.title).appendTo(li)
                        .click(namer(pname, page.title))
                })
                var li = $('<li>Ссылка не на мой сайт:</li>').appendTo(link_choice)
                var li = $('<li>URL</li>').appendTo(link_choice)

                // var link = '';
                var sel;
                var inp =$('<input type="text">').appendTo(li)
                    .on('mousedown',function (){ //sel = saveSelection()
                    } );
                var li = $('<li>Надпись в меню</li>').appendTo(link_choice)
                var inpl = $('<input type="text">').appendTo(li)

                $('<button>').text("Создать").appendTo(li).mousedown(function(e){
                    var link = inp.val();
                    var name = inpl.val();
                    var r = namer( link, name)
                    // restoreSelection(sel);
                    r(e);
                })
                di.dialog({title: "Вставить ссылку"})
            })
        }
    }
}

function pageheaderIniter(){
    WidgetIniter.call(this);
    this.title = "Заголовок страницы";
    this.is_settings = false
    this.default_size = [4,1];
    this._def_data = "Site header H1";
    this._settings = function(){
        var self =this;
        if(this.C){
            this._jq.prop('contentEditable', 'true')

        }

    }
    this._save = function(){this.data = this._jq.text() }
    //this._cancel = function(){this.is_settings = false, this.redraw();}

    this._draw = function(){
        if (typeof this.C.Site.fonts == 'undefined' ){
            font = 'Arial'
        } else{ font = this.C.Site.fonts.header}
            var t = this._data()
            if (typeof t !== 'string'){
                t = t.text
            }

            this._jq = $("<h1>")
                .addClass('text-data')
                .css('margin', '0')
                .html(t).appendTo(this.my_cont)
                .css('font-family', font )
    }
}

function headerIniter(){
    WidgetIniter.call(this);
    this.title = "Заголовок раздела";
    this.is_settings = false
    this.default_size = [4,1];
    this._def_data = "Site header H3";
    this._settings = function(){
        var self =this;
        if(this.C){
            this._jq.prop('contentEditable', 'true')

        }

    }
    this._save = function(){this.data = this._jq.text() }

    this._draw = function(){
        if (typeof this.C.Site.fonts == 'undefined' ){
            font = 'Arial'
        } else{ font = this.C.Site.fonts.header}
            var t = this._data()
            if (typeof t !== 'string'){
                t = t.text
            }

            this._jq = $("<h3>")
                .addClass('text-data')
                .html(t).appendTo(this.my_cont)
                .css('margin','0')
                .css('font-family', font )
    }
}
function lineIniter(){
    WidgetIniter.call(this);
    this.title = "Линия";
    this.is_settings = false
    this.default_size = [4,1];
    this._def_data = "Site header H3";
    this.do_not_apply = ["border_width","border_color"];
    this.need_redraw = true;
    this._def_data = 'top';
    this._settings = function(cp ){
        var self = this;
        self.settings = true;


    }
    this._save = function(){ }

    this.draw = function(){
        var self = this;
        // console.log(this.set)
        var width = this.set.border_width
        if (typeof this.set.border_color !== 'string'){
            var col   = hsvToRgb(this.C.get_color(this.set.border_color))
        }else{
            var col = this.set.border_color
        }
        // console.log(col, width)
        this.my_cont.find('*').remove();
        this.my_cont.parent().css('border-width', 0);
        this._jq = $('<div></div>').appendTo(this.my_cont)
        .width(this.my_cont.width() ).height(this.my_cont.height() )
           this._jq.on('dblclick', function(){
               if (self.data == 'top'){
                   self.data = 'bottom'
               }else{
                   self.data = 'top'
               }
               self.draw();

           })

        this.my_cont.parent().css('border-' + this._data(), width + "px solid "+col)
            ///.width(this.my_cont.width() )
            //.width(this.my_cont.width() )


    }
    this._draw = this.draw;
}
function imageIniter(){
    WidgetIniter.call(this);
    this.title = "Изображение";
    this.is_settings = false
    this.default_size = [4,1];
    this.need_redraw = true;
    this._def_data = "Site header H3";
    this._settings = function(){

        this.my_cont.unbind('mousemove')
        this.my_cont.unbind('mouseup')
        this.my_cont.unbind('mousedown')

        var off = this._jq.offset();
        var self = this;
        var start_pos,
            is_drag,
            old_pos;
        function zoom(zf, px, py){
            var z = self.data.zoom;
            var x = self.data.position.left;
            var y = self.data.position.top;

            if (z < 0.4) zf /=10;
            if (z < 0.2) zf /=2;
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

        this.my_cont.bind('mousewheel DOMMouseScroll MozMousePixelScroll',function(evt){
            evt.stopImmediatePropagation();
            evt.preventDefault();
            // console.log(navigator.userAgent)
            var is_webkit = /WebKit/.test( navigator.userAgent )
            var is_firefox = /Firefox/.test( navigator.userAgent )
            var handle_event = function(){
                var dt;
                if (evt.originalEvent.type != 'mousewheel' ){
                    dt = evt.originalEvent.detail;
                }else {
                    dt = evt.originalEvent.wheelDelta;
                }
                // console.log(evt, dt);
                var a = dt / Math.abs(dt)
                zoom(0.1 *a, evt.originalEvent.pageX - off.left, evt.originalEvent.pageY - off.top)

            }
            if(evt.type == 'DOMMouseScroll') {
                //Handle in firefox
            }else if( evt.type == 'MozMousePixelScroll'){
                if( is_firefox ){
                    handle_event()
                }
                // Do not Handle
            }else{
                if(!is_firefox){
                    handle_event();
                }

            }

            return true
        })
        this.my_cont.mousemove(function(evt){
            if (is_drag){
                var cur_pos = {x: evt.pageX - off.left,
                            y: evt.pageY - off.top}
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
            old_pos = {x: evt.pageX - off.left,
                         y: evt.pageY - off.top}
            is_drag = true;

        })

    }
    this._save = function(){
        // console.log (this.data)
        //var canvas = this._jq[0];
        //var image = canvas.toDataURL("image/png");

        //var data = this.data
        // console.log("SAVE", data)

         // console.log("Do we savinf data?");
        // this.constr.setWidgetData(this.pos, data )
    }
    this._dr = function(){
				// console.log ("POS", this.constr.Site.pages[''].blocks[2].widget.data.position)
				var self = this;
				if (this._jq){
					 this._jq.remove()
				}

                this.border_radius = this.set.border_radius == null?0:this.set.border_radius;

                this.border_radius = Math.min (this.border_radius, this.my_cont.width()/2, this.my_cont.height()/2)

                this.canv = $("<canvas>").css('border-radius', this.border_radius * 0.94) // .appendTo(this.my_cont)

				this.c = this.canv[0];
                this._jq = $('<div></div>').appendTo(this.my_cont)
                d = $('<div>')
                    //.css('border-radius','50px')
                    .css('position','static')
                    .css('overflow','hidden')
                    .width( this.my_cont.width())
                    .height(this.my_cont.height())
                    .appendTo(this._jq).append(this.canv)


				this.c.width =  this.my_cont.width()
				this.c.height =  this.my_cont.height()


				this.img = new Image();
				if (this.data.image.blob){
					this.img.src = DB.get_blob_url(this.data.image)
				}else{
					this.img.src = this.data.image;
				}
                // console.log( this.img.src )
				this.ctx = this.c.getContext('2d')
				this.img.onload=function(){
                    // console.log('draw ctx');
					self.redraw_ctx();

                    self._jq.appendTo(self.my_cont);


				}
			}
    this.redraw_ctx= function(){
                    var W=this.my_cont.width(),
                        H = this.my_cont.height();
                    this.ctx.clearRect(0,0, W , H)

                    // Баг в гуглохроме -
                        var is_webkit = /WebKit/.test( navigator.userAgent )
                        if (is_webkit && W*H >60000 ){
                            var rectWidth = this.my_cont.width()
                            var rectHeight = this.my_cont.height()

                            if ( this.border_radius !== 0 ) {
                                var cr = this.border_radius * 0.9

                                var context = this.ctx

                                context.beginPath();
                                   // line
                                context.moveTo(cr, 0);
                                context.lineTo(rectWidth - cr, 0);
                                    //arc
                                //context.arcTo( rectWidth , 0,  rectWidth  , cr,  cr);
                                context.arc(rectWidth-cr, cr, cr, 1.5 * Math.PI, 0, false)

                                    // more line
                                context.lineTo(rectWidth , rectHeight-cr);

                                context.arc( rectWidth-cr, rectHeight -cr, cr,  0, 0.5 * Math.PI, false);

                                context.lineTo(cr , rectHeight );
                                context.arc( cr, rectHeight -cr, cr,   0.5 * Math.PI, Math.PI,false);

                                context.lineTo(0 , cr );
                                context.arc( cr, cr, cr,     Math.PI, 1.5 * Math.PI,false);

                                context.clip();

                            }

                        }

                        this.ctx.save()
						this.ctx.scale(this.data.zoom, this.data.zoom)
						this.ctx.translate(this.data.position.left, this.data.position.top)
						this.ctx.drawImage(this.img ,0,0)
						this.ctx.restore();

				},
    this._draw = function(){

        var self = this
        if ( this.data != null && this.data.image != null){
            //if (this.data.image.blob){

                //}
            this._dr()
        }else{
            this._jq = $("<img>").prop('src', '/static/images/images.jpg')
            .appendTo(this.my_cont)
            .css('margin',10)
            if(this.C.is_constructor){
                this._jq.click(function(){
                    // console.log("i'm fucking pushing you")
                    var input = $("<input>").attr('type','file').change(function(){
                        var fr = new FileReader()
                        var _this = this;
                        fr.onloadend = function(){
                            var result = this.result;
                            $(_this).parent().remove();
                            self.C.setWidgetData(self.pos, {image:result, position:{left:0,top:0}, zoom:1})
                            self.C.redraw();
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
    }
}



var o = {

	
	admin_page: function(to){
		to.find('*').remove()
		$("<div>").text("This is " + this.title + " admin page").appendTo(to) 
	},
	widgets: {
        "empty" : dummyIniter,
        "text" : textIniter,
        "slider": sliderIniter,
        "menubar": menuIniter,
        "page_header":  pageheaderIniter,
        "header" :  headerIniter,
        'image' : imageIniter,
        "line": lineIniter,
        /*

        "line" : {title:"Горизонтальная линия",

            default_size: [4,1],
            init: function(my_cont, constructor_inst, pos, cp){
			var data = data;
			var o = {
					my_cont:my_cont,
					constr :constructor_inst,

					disobey:['background_color'],
					cp : cp,
					pos: pos,
					_jq : false,
                    has_own_settings:true,
					draw: function(set){
                        if (set == null){
                            set = constructor_inst.getBlockSettings(pos)
                        }
                        var bc = set.border_color;
                        var bw = set.border_width;
                        // console.log(bc)
                        var col = hsvToRgb(constructor_inst.get_color(bc));

                        this._jq = $('<div></div>').width(my_cont.width()).css('border-top', bw + 'px solid ' + col)
                            .height(0).appendTo(my_cont);
                        my_cont.parent().css('border', '0px');


					},
					jq: function(){ return this._jq }
				}
				return o;

			}
		},



    },

	"image": {title:"Картинка",			default_size: [4,4] , init:function(my_cont,constructor_inst, pos, cp){
		// console.log(data)
		var o = {
			my_cont:my_cont,
			constr :constructor_inst,
            depends_on_settings: true,
			// data : data,

			disobey:['padding_top','padding_left_right'],
			cp:cp,
			pos: pos,
			_jq : false,
			settings_draw :false,



			draw: function(settings){
                this._settings = settings
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
                if (this._settings == null){
                    var set = constructor_inst.getBlockSettings(pos)
                    this._settings = set;
                }
                this.border_radius = this._settings.border_radius == null?0:this._settings.border_radius;

                this.border_radius = Math.min (this.border_radius, my_cont.width()/2, my_cont.height()/2)

                this.canv = $("<canvas>").css('border-radius', this.border_radius * 0.94) // .appendTo(this.my_cont)

				this.c = this.canv[0];
                this._jq = $('<div></div>').appendTo(this.my_cont)
                d = $('<div>')
                    //.css('border-radius','50px')
                    .css('position','static')
                    .css('overflow','hidden')
                    .width( my_cont.width())
                    .height(my_cont.height())
                    .appendTo(this._jq).append(this.canv)


				this.c.width =  this.my_cont.width()
				this.c.height =  this.my_cont.height()


				this.img = new Image();
				if (this.data.image.blob){
					this.img.src = DB.get_blob_url(this.data.image)
				}else{
					this.img.src = this.data.image;
				}
                // console.log( this.img.src )
				this.ctx = this.c.getContext('2d')
				this.img.onload=function(){
                    // console.log('draw ctx');
					self.redraw_ctx();

                    self._jq.appendTo(self.my_cont);


				}
			},
				redraw_ctx: function(){
                    var W=this.my_cont.width(),
                        H = this.my_cont.height();
                    this.ctx.clearRect(0,0, W , H)

                    // Баг в гуглохроме -
                        var is_webkit = /WebKit/.test( navigator.userAgent )
                        if (is_webkit && W*H >60000 ){
                            var rectWidth = this.my_cont.width()
                            var rectHeight = this.my_cont.height()

                            if ( this.border_radius !== 0 ) {
                                var cr = this.border_radius * 0.9

                                var context = this.ctx

                                context.beginPath();
                                   // line
                                context.moveTo(cr, 0);
                                context.lineTo(rectWidth - cr, 0);
                                    //arc
                                //context.arcTo( rectWidth , 0,  rectWidth  , cr,  cr);
                                context.arc(rectWidth-cr, cr, cr, 1.5 * Math.PI, 0, false)

                                    // more line
                                context.lineTo(rectWidth , rectHeight-cr);

                                context.arc( rectWidth-cr, rectHeight -cr, cr,  0, 0.5 * Math.PI, false);

                                context.lineTo(cr , rectHeight );
                                context.arc( cr, rectHeight -cr, cr,   0.5 * Math.PI, Math.PI,false);

                                context.lineTo(0 , cr );
                                context.arc( cr, cr, cr,     Math.PI, 1.5 * Math.PI,false);

                                context.clip();

                            }

                        }

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


				},
				cancel: function(){
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
					function zoom(zf, px, py){
						var z = self.data.zoom;
						var x = self.data.position.left;
						var y = self.data.position.top;

						if (z < 0.4) zf /=10;
                        if (z < 0.2) zf /=2;
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

				this.my_cont.bind('mousewheel DOMMouseScroll MozMousePixelScroll',function(evt){
					evt.stopImmediatePropagation();
					evt.preventDefault();
                    // console.log(navigator.userAgent)
                    var is_webkit = /WebKit/.test( navigator.userAgent )
                    var is_firefox = /Firefox/.test( navigator.userAgent )
                    var handle_event = function(){
                        var dt;
                        if (evt.originalEvent.type != 'mousewheel' ){
                            dt = evt.originalEvent.detail;
                        }else {
                            console.log('w')
                            dt = evt.originalEvent.wheelDelta;
                        }
                        // console.log(evt, dt);
                        var a = dt / Math.abs(dt)
						zoom(0.1 *a, evt.originalEvent.pageX - off.left, evt.originalEvent.pageY - off.top)

                    }
					if(evt.type == 'DOMMouseScroll') {
                        //Handle in firefox
                    }else if( evt.type == 'MozMousePixelScroll'){
                        if( is_firefox ){
                            handle_event()
                        }
						// Do not Handle
					}else{
                        if(!is_firefox){
                            handle_event();
                        }

					}

					return true
				})
					this.my_cont.mousemove(function(evt){
						if (is_drag){
							var cur_pos = {x: evt.pageX - off.left,
										y: evt.pageY - off.top}
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
						old_pos = {x: evt.pageX - off.left,
									 y: evt.pageY - off.top}
						is_drag = true;

					})
				},
				jq: function(){ return this._jq }
			};
		 return o;

			}
        */

        /*
        image_pane:{
            title:"Фотопанно",
		    default_size: [3,1],
		    init:function(my_cont,  constructor_inst, pos, cp){// console.log(data)
			  console.log(my_cont.width())
                var o = {
                    my_cont:my_cont,
                    constr :constructor_inst,

                    disobey:['padding_left_right', 'padding_top'],

                    cp:cp,
                    pos: pos,
                    settings_draw :false,
                    draw: function(){
                        var OW = my_cont.width();
                        var OH = my_cont.height();
                        var pic_amount = 0;
                        var portreits = 0;
                        var landscapes = 0;
                        var squares = 0;

                        dr_ = function(C){
                            var W = C.width();
                            var H = C.height();
                            // console.log('launch', W, H)
                            var thres = 250;

                            var is_portreit = W < H;
                            var M = Math.max(W,H);
                            var m = Math.min(W,H);
                            var ratio = M/m;
                            var is_square   = Math.abs(1-ratio) < 0.1;
                            var no_more_split = false;
                            var is_portreitf = function(w,h){return w < h }
                            var no_more_splitf = function(w, h){
                                if (is_portreitf(w,h)) {
                                    if (h  < thres ){
                                        return true;
                                    }
                                }else{
                                    if (w <thres){
                                        return true;
                                    }
                                }
                                return false;
                            }
                            no_more_split = no_more_splitf(W,H);
                            console.log('orient',is_square, is_portreit)
                            console.log("no_more_split", no_more_split);
                            if (no_more_split){
                                console.log(ratio)
                                pic_amount += 1;
                                if(is_square) squares +=1;
                                else{
                                    if(is_portreit )portreits +=1;
                                    else landscapes +=1;}
                                var c = {h: _.random(365), s: _.random(100), b:_.random(100),a:1}
                                $('<div></div>').width('100%').height('100%').css('background-color', hsvToRgb(c)).appendTo(C)

                            }else{
                                r = Math.round(ratio);

                                console.log("this ratio ", r, ratio, is_square );
                                if (r == 1){
                                    var r = 2 // _.random(2, 3);
                                    // is_portreit = _.random(0,1) === 1;
                                    if(_.random(0,1) === 1){
                                        var v = M;
                                        M = m;
                                        m = v;
                                        is_portreit = !is_portreit;

                                    }
                                }
                                var spl = Math.floor(M / r);
                                var total = 0;
                                var arr = [];
                                for (var i = 0; i < (r-1); i++){

                                    var f = _.random(0,1)? (function(a,b){return a-b}) :(function(a,b){return a+b})
                                    var per = f(1, _.random(30)/100)
                                    var nspl = Math.round(spl * per);
                                    console.log("what we got", spl, nspl, per)
                                    arr.push(nspl);
                                    total = total + nspl;
                                }
                                arr.push(M - total);

                                _.chain(arr)
                                .map(function(w){
                                    if(is_portreit){
                                        dr_($('<div></div>').appendTo(C).width(m).height(w))
                                    }else {dr_($('<div></div>').css('float','left').appendTo(C).width(w).height(m)) }
                                })

                            }
                        }


                        dr_(my_cont);
                        console.log('total pics', pic_amount, squares, portreits, landscapes)


                    }
                }
               return o
            }

        },

		"gallery": {
		  title:"Галерея",
		  default_size: [3,1],
		  init:function(my_cont,  constructor_inst, pos, cp){// console.log(data)
			  console.log(my_cont.width())
			var o = {
				my_cont:my_cont,
				constr :constructor_inst,
				
				disobey:['padding_left_right', 'padding_top'],
				
				cp:cp,
				pos: pos,
				settings_draw :false,
				_dr: function(){
					
					if(typeof this.data == 'undefined'){
						this.data = this.constr.getWidgetData(pos, false)||{images:[],rows:4, cols:4, margin:6};
					}															
					var cont = $("<div>").css({'list-style-type': 'none',
						 					  margin: 0, padding: 0,
											  overflow:'auto', 
											  display: 'block', 
											  'text-align':'center', 
											  height:'100%'});
					var self = this;
					my_cont.find('*').remove();
					
					if (this.data.images){
						var R = this.data.rows || 4,
							C = this.data.cols || 4,
							m = this.data.margin || 5,
							spaceR = R*m,
							spaceC = C*m,
							hc = (( my_cont.height()) / R)-1,
							wc = (( my_cont.width()) / C)-1 ,
							
							h = ((my_cont.height()-spaceR) / R)-1,
							w = ((my_cont.width()-spaceC) / C)-1;
							
							
						$.each(this.data.images, function(ix, obj){
							img = $(new Image()).one('load', function(){
								
								var I = $(scaleImage(this, w, h))
								$('<div>').append(I).appendTo(cont).css(
									{display:'inline-block',
									 // 'padding-top':m/2 + 'px',
									 width:wc, 
									 height:hc,
									 float:'left'
									 
								  });
								
							}).prop({src: obj}).css({margin:'auto',
													 'text-align':'center', 
													 'vertical-align':'middle'})
							
							
							
						})
					}
					this._jq = cont;
					this._jq.appendTo(my_cont);
				},
				
				draw: function(){
					
					var self = this;
					self._dr();
					if(this.constr.is_constructor){
						//----Загрузка картинок----
						function loadImg(event) {
							//console.log(this);
							if(typeof self.data.images != 'undefined'){
								self.data.images.push(this.result);
								
							}else{
								self.data.images = [this.result];
							}
							self._dr();
							
						}

						function displayFiles(files) { 
							$.each(files, function(i, file) {
							  if (!file.type.match(/image./)) {
								// Отсеиваем не картинки
								return true;
							  }
							  // Создаем объект FileReader и отображаем миниатюру 
							  var reader = new FileReader();
							  reader.onload = loadImg;
							  reader.readAsDataURL(file);
							});
						}
						var fInp = $('<input type="file" multiple>')
						 .bind('change', function() {
							displayFiles(this.files);
							this.files=[];
							//inputs.hide()
						}),
						urlInp = $('<input type="text"  title="адрес в интернете" placeholder="адрес в интернете">'),
						r = self.data.rows || 4,
						c = self.data.cols || 4;
						inputs = $("<div />")
						 .css({position:'absolute', zIndex:1})
						 .append(fInp).append('<hr>')
						 .append(urlInp)
						 .append('<label>строк: <input type="number" name="rows"\
						value='+r+'></label> \
						<label>столбцов: <input type="number" name="cols"\
						value='+c+'></label>\
						 ')
						 
						 // .appendTo(this.my_cont.parent().parent())
						 .css({padding:10, backgroundColor:'orange'})
						 // .position({of:this.my_cont, my:"left top", at:"left bottom", collision:"none none"})
						 .submit(loadImg)

					}
					this.settings=function(controls){
						var cp = $("<div>").appendTo(controls )
						self.my_cont.off('mousemove mouseup mousedown dblclick')
						self._jq.on('dblclick', 'li', function(){$(this).remove()})
						  .on('mousewheel DOMMouseScroll', function(e){
							e=e.originalEvent;
							var d=(e.detail||-e.wheelDelta)<0?1.05:(1/1.05);
							$(e.target).is('img')?(self.data.image_width *= d):(W*=d)
							W=Math.max(w,W);
							$('li',jq).css({width:W, lineHeight:W+'px'})
							$('img',jq).css({maxWidth:w, maxHeight:w})
							e.preventDefault();
							return false
						}).on('MozMousePixelScroll', function(e){
							e.preventDefault();
						}).on({
							dragenter:function(){return false},
							dragover: function(){return false},
							drop: function(e) { //--drag&drop
							  var dt = e.originalEvent.dataTransfer;
							  if (dt) displayFiles(dt.files);
							  return false;
							} 
						});
						$('input[type="number"]', inputs).change(function(e){
							self.data[this.name]=this.value=
							 Math.abs(parseInt(this.value)||1);
							self._dr();
							e.preventDefault();
							e.stopPropagation();
						}).width('3em')
						controls.show();
						
						inputs.appendTo(cp)// .show()

						// inputs.show()
					}
					this.save=function(){
						// inputs.remove();
						// console.log(my_cont.html())
						
						// data.size=w; data.cellSize=W
						self.constr.setWidgetData(self.pos,this.data )
					}
				},
				cancel: function(){this.constr.redraw()},
				jq: function(){ return this._jq } 
			};
			return o; 
		  }
        }, // конец галереи


		}*/
			}
		 };	
		 
	return o
	
	
	
	
