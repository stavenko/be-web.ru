
var o = {

	
	admin_page: function(to){
		to.find('*').remove()
		$("<div>").text("This is " + this.title + " admin page").appendTo(to) 
	},
	widgets: {
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
*/
									
		"menubar" : {title:"Меню сайта", 
					default_size: [3,1],
					init: function(my_cont, constructor_inst, pos, cp){
			var data = data;
			var o = {
					my_cont:my_cont,
					constr :constructor_inst,
					
					disobey:[],
					cp : cp,
					pos: pos,
					_jq : false,

					draw: function(){
						if (typeof this.constr.Site.fonts == 'undefined' ){
							font = 'Times New Roman'
						} else{ font = this.constr.Site.fonts.content}


						this._jq = $("<ul>")
									.appendTo(this.my_cont)
									.css('font-family', font )
									// .css('font-size', my_cont.width() / 40)
									.css('padding',0).css('margin', 0)


						var current_page = constructor_inst.current_page
						var self = this;
						var pages = 0
						for(i in constructor_inst.Site.pages){
							pages+=1
						}
						//var width = my_cont.width();
						//var item_width = width / pages;

						var pages = $.extend(true, {}, constructor_inst.Site.pages)
						var pa = [];
						$.each(pages,function(i, p){
							p.slug = i
							pa.push(p)
						})
				        pa.sort(function(a,b){ return a.order - b.order } )
				
				
						$.each(pa, function(ix,p){	
							var i = p.slug
							if( p.show_in_menu ){
								var li = $("<li>").appendTo(self._jq)
													 .css('float', 'left') //.width(item_width)
													 .css('padding',0).css('margin-left', '2em')
													 .css('list-style-type','none')
								if (i == current_page){
									li.append(p.title)
								}else{
									$("<a>").prop('href', "#!" + i).click(function(evt){
										window.location.hash = "!" + i
										evt.preventDefault();
									}).append(p.title).appendTo(li)
								
								}
							}
							
						})

					},
					jq: function(){ return this._jq } 
				}
				return o;
				
			}
		},
		"empty" : {title:"Пустышка", 
					default_size: [4,4],
					init: function(my_cont, constructor_inst, pos, cp){
			//console.log(pos) 
			var data = data;
			var o = {
					my_cont:my_cont,
					constr :constructor_inst,
					
					disobey:[],
					cp : cp,
					pos: pos,
					_jq : false,
					draw: function(){
						this._jq = $('<span>')
					},
					jq: function(){ return this._jq } 
				}
				return o;
				
			}
		},
		"text" : {title:"Текстовое поле", default_size: [3,3],init: function(my_cont, constructor_inst, pos, cp){
			//console.log(pos) 
			var data = data;
			var o = {
					my_cont:my_cont,
					constr :constructor_inst,
					disobey:[],
					// data : data,
					
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
                            this._d_remover();


				
						}
					},
					cancel: function(){
                        this._d_remover();

					},
					_change_text: function(command,val){
						r = document.execCommand(command, false, val)

			
					},																				
					settings: function(controls){
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

						if(this.constr){
							this._jq.prop('contentEditable', 'true') //.prop('id', eid)
                            var initer = function(){
                                var closer = function(){
                                    if(d != null){
                                        d.remove();
                                        d = null;
                                    }
                                    setTimeout(initer, 500)
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
                                                    ;closer();
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
                                })
                            }
                            initer()
							var cp = $("<div>").appendTo(controls )
						}
						controls.show();
					},
					jq: function(){ return this._jq } 
				};
			 return o; 
	
			}

        },
        "page_header" : {title:"Заголовок страницы", 					default_size: [5,1],
            init: function(my_cont, constructor_inst, pos, cp){
                //console.log(pos)
                var data = data;
                var o = {

                    my_cont:my_cont,
                    constr :constructor_inst,
                    disobey:[], //['padding_top',
                                // 'padding_left_right'],
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

                            this._jq = $("<h1>")
                                .addClass('text-data')
                                .css('margin', '0')
                                .html(this._data().text).appendTo(this.my_cont)
                                // .css('font-size', this._data().size + 'px')
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
    "header" : {title:"Заголовок", default_size: [5,1],
        init: function(my_cont, constructor_inst, pos, cp){
            //console.log(pos)
            var data = data;
            var o = {
                my_cont:my_cont,
                    constr :constructor_inst,
                    disobey:[],
                    //disobey:['padding_top',
                    //         'padding_left_right'],
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

                            this._jq = $("<h3>")
                                .addClass('text-data')
                                .html(this._data().text).appendTo(this.my_cont)
                                .css('margin','0')
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
		}
			}
		 };	
		 
	return o
	
	
	
	
