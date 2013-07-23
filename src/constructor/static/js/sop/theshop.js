{
    Main:function(constr){
		console.log("CP", constr.Site.pages)
		var discount = function(product){ return true};
		var get_price = function(product){ return '50.00'};
		var get_base_price = function(product) {return '70.00'};
		if(!('shop' in constr.Site.pages)){
			constr.addPage(false, true,'Магазин','shop') //, show_in_menu : true, removable:false }
			
		}		
		if(!('product' in constr.Site.pages)){
			constr.addPage(false, false, 'Товар', 'Product')
			
		}

        var o = {
            title: "The shop",
            _common_per_page: 5,
            //_product_list_current_page : 0,
			_validators : {'int':{l:'Целое', f:function(v){return parseInt(v) } },
						   'string':{l:'Строка', f:function(v){return v } },
						   'bool':{l:'логическое', f:function(v){return v?true:false } },
						   'float':{l:'Дробное', f:function(v){return parseFloat(v) } },	 
			},
            _get_product_list: function(page){
                //console.log(this)
                return DB.get_objects('product', {}, {current_page:page, per_page:this._common_per_page})
            },
			_init_prod_props_list: function( prod_props_cont ){
				table = $('<table>').appendTo( prod_props_cont )
                props = DB.get_objects('property', {}, {})
				self  = this;
				self._props_cache = props
				
				
				tr = $('<tr>').appendTo(table)
				$('<th>').appendTo(tr ).text('Название') 
				$('<th>').appendTo(tr ).text('Валидатор') 
				
				$('<th>').appendTo(tr ).text('Единица измерения') 
				
				$.each(props.objects, function( ix, o ){
					console.log(o,ix)
					dtr = $('<tr>').appendTo(table);
					$('<td>').text( o.name ).appendTo(dtr)
					if (o.validator){
						$('<td>').text( self._validators[o.validator].l ).appendTo(dtr)
					}else{ $('<td>').text( o.validator ).appendTo(dtr)}
					$('<td>').text( o.measure ).appendTo(dtr)
					$('<input type="button" value="Удалить">').appendTo($('<td>').appendTo(dtr) ).click(function(){
						DB.remove_object('property', {'_id': o['_id']})
						prod_props_cont.find('*').remove()
						self._init_prod_props_list(prod_props_cont)
					})
					
					
				})
				
				tr = $('<tr>').appendTo(table)
				
				$('<input name="name">').appendTo($('<td>').appendTo(tr) )
				$('<select name="validator">').appendTo($('<td>').appendTo(tr) )
				.append( $('<option>').text('целое').val('int') )
				.append( $('<option>').text('дробное').val('float') )
				.append( $('<option>').text('строка').val('string') )
				.append( $('<option>').text('логич').val('bool') )
				$('<input name="measure">').appendTo($('<td>').appendTo(tr) )
				$('<input type="button" value="Добавить">').appendTo($('<td>').appendTo(tr) ).click(function(){
					o = {}
					tr = $(this).parent().parent()
					o.name = tr.find('input[name=name]').val()
					o.validator  = tr.find('select').val()
					o.measure   = tr.find('input[name=measure]').val()
					DB.save_object('property', o, function(){}, function(){})
					prod_props_cont.find('*').remove()
					self._init_prod_props_list(prod_props_cont)
					
					
				})
				
			},
            
            _init_product_list: function(to){
                var self = this;
                var cont = $('<div>').appendTo(to);
                this._display_page(cont)
                
                $('<button>').text('Add products' ).click(function(){self._add_product_form(to)}).appendTo(to)
                
                
            },
            _display_page: function(to, page){
				if (page){
					var current_page = page;
				}else{
					var current_page = 0 ;
				}
                var self = this;
                var result = this._get_product_list( current_page )
                var products = result.objects
                if (result.total_amount == 0){
                    $('<h3>').text('No products selected or exists').appendTo(to)
                }else{
                    
                    $.each(products, function(i,obj){
                        var prod = $('<div>').height(160).appendTo(to)
                        var image = obj.images[0]
                        var act = function(){
                            $('<div>').css('float', 'left').append(self._scaleImage($(this), 160, 160)).appendTo(prod)
							$('<h3>').text(obj.name).appendTo(prod).css({cursor:'pointer'}).click(function(){
								self._add_product_form(to.parent(), obj)
							})
                            $("<div>").append($('<p>').text(obj.description)).height(100).css('overflow','hidden').appendTo(prod);
                            
                        }
						
                        if (image.blob){
                            var img = $(new Image()).one('load', act)
										.prop('src', "/blob/"+ image._id['$oid'] + '/' )
						}else{
							var img = $(new Image()).one('load', act)
										.prop('src', image)
							
						}
						
            
				        })
				        if (result.total_pages -1 != this._product_list_current_page){
				            $('<button>').text('next page').click(function(){
				               
				                self._display_page.apply(self, [to, current_page + 1]);
				                $(this).remove()
				            }).appendTo(to);
            
				        }
        
				    }
    
				},
				_scaleImage : function(img, maxHeight, maxWidth){
				    var width = img[0].width,
				        height = img[0].height,
				        scale = Math.min(maxWidth/width, maxHeight /height);    
				    //console.log(width,height)
				    if (scale < 1) {
				        var width = parseInt(width * scale, 10);
				        var height = parseInt(height * scale, 10);
				    }
				    img.width(width);
				    img.height(height);
				    return img
    
				},
				_add_product_form : function(to, obj){
					if(obj){
						this._product_draft = obj
					}
				  to.find('*').remove()
				  var self = this;
				  //console.log('init')
				  if(this._product_draft == undefined || !this._product_draft){
				    this._product_draft = {}
				    this._product_draft.images = []
				  }
				  var self = this;
				  //console.log("PD", !this._product_draft, this._product_draft);
  
				  to.append($('<h3>').text("Product form" ))
				  var ul = $("<ul>")  
				  R = $("<div>").height(600).append(
				  $('<div>').width(400).css('float','left').append(ul)).appendTo(to)
  
				  function clc(evt){
				      var i = $(this)
				      var n = $(this).prop('name');
				      if (i.prop('type') == 'checkbox'){
				          var v = i[0].checked;
				      }else{
				          var v = $(this).val()
          
				      }
				      self._product_draft[n] = v;
				  }
				  var base_inps = { name:{t:'text',l:'name'},
				                    sku :{t:'text',l:'sku'},
				                    tags:{t:'text',l:'tags'},
				                    category:{t:'text',l:'category'} }
					
				function put_inpts(ii, dst){
				  $.each( ii, function(k, t){
				      var l = $('<label>').text(t.l).prop('for', l)
				      var i = $('<input>').prop('type',t.t).val(self._product_draft[k] ).prop('name',k).prop('id', 'id_'+k).change(clc)
				      $('<li>').append(l,i).appendTo(dst)
				  })
				}                                 

				var stock_inps = { track_stock:{t:'checkbox',l:'Track Stock'},
				                   in_stock   :{t:'text',l:'In stock'},
								   base_price :{t:'text', l:'Base Price' } }
				put_inpts(base_inps, ul)                               

				var ul = $('<ul>')
				R.append($('<div>').width(400).css('float','left').append(ul))

				put_inpts(stock_inps, ul)                               

				var Desc = $('<div>')
				R.append($('<div>').width(400).css('float','left').append(Desc) )
				$('<h4>').text('Description').appendTo(Desc)
				$('<textarea>').prop('name','description' ).width(Desc.width()).appendTo(Desc).change(clc)


				R.append($("<div>")
				        .css('display','block')
				        .css('clear', 'both'))
						
        
	            var d = $('<div>').css('float','left')
	            R.append(d)      
				ul = $('<ul>').appendTo(d)  
				if (! self._product_draft.properties){
					self._product_draft.properties = {}	
				}  
				$.each(self._props_cache.objects, function(ix, o){
					if (o.validator == 'bool'){
						var input = $('<input type="checkbox">').prop('name',o.name).prop('checked', self._product_draft.properties[o.name])
						.change(function(){
							self._product_draft.properties[o.name] = this.checked
						})
					}else{
						var input = $('<input type="text">').prop('name',o.name).val(self._product_draft.properties[o.name])
						.change(function(){
							self._product_draft.properties[o.name] = $(this).val();
						})
			
					}
					
					$("<li>").append( o.name )
					.append(input)
					.append( o.measure )
					.appendTo(ul)
				})
				
				R.append($("<div>")
                        .css('display','block')
                        .css('clear', 'both'))
				
                        
                  
              var d = $('<div>').css('float','left')
              R.append(d)
              $.each(self._product_draft.images, function(ix, imgd){
                  
				  if (imgd.blob){
					  src = DB.get_blob_url(imgd)
					  
				  }else{ src = imgd }
				  $(new Image()).one('load', function(){
				  	$('<div>').css('float', 'left').append(self._scaleImage($(this), 160, 160)).appendTo(d) 
				  }).prop('src', src)
				  
              })
              
              var f = function(_to){
                  
                  $('<input type="file">').change(function(){
                        var fr = new FileReader()
                        var _this = this;
                        $(this).hide();

                        fr.onloadend = function(){
                            var result = this.result;
                            mime_type  = this.result.split(';')[0].split(':')[1].split('/')[0]
                            if(mime_type !== 'image'){
                                alert('Not an image')
                                $(_this).show();
                            }else{
                                self._product_draft['images'].push( result )
                                self._add_product_form(to)
                            }

                        }
                        fr.readAsDataURL(this.files[0]);
                       
                  }).appendTo(_to)
              }
              f(d);
              
              
              var progress_f = function(){
                  //console.log('progress', this)
              }
              var complete_f = function(){
                  // console.log('complete', this)
                  self._product_draft = false;
              }

              
              $("<button>").text("save").click(function(evt){
                  DB.save_object('product', self._product_draft, progress_f, complete_f)
                  self.admin_page(to.parent().parent())
              }).appendTo(to)
              $("<button>").text('close form').click(function(evt){
                  self.admin_page(to.parent().parent() )
              }).appendTo(to)
              
              
              
            },
            admin_page: function(to){
                    //$("<div>").text("This is " + this.title + " admin page").appendTo(to) 
                    // Need to draw
                    // 1. Product form
                    // 2. import  button
                    // 3. Main View
                    to.find('*').remove()
                    atabs = $('<div>').appendTo(to)
                    ul = $("<ul>").appendTo(atabs);
                    $("<li>").append($("<a>").prop('href', "#products" ).text("Products") ).appendTo(ul)
                    $("<li>").append($("<a>").prop('href', "#product_props" ).text("Product props") ).appendTo(ul)
                    $("<li>").append($("<a>").prop('href', "#orders" ).text('orders') ).appendTo(ul)
                    
                    prod_cont = $("<div>").prop('id',"products").appendTo(atabs)
                    this._init_product_list(prod_cont)
                    // prod_cont.text("okey")
                     
                    
                    orders_cont = $("<div>").prop('id',"orders").appendTo(atabs)
                    orders_cont.text("O okey")


                    prod_props_cont = $("<div>").prop('id',"product_props").appendTo(atabs)
					this._init_prod_props_list( prod_props_cont )
                    
                    atabs.tabs();
                    
                    
                    
                },
            widgets:{
				"product": {
					title:'Демонстрация продукта',
					default_size: [6,4],
					init : function (my_cont,  constructor_inst, pos, cp) {
						var o = {
							my_cont:my_cont,
			  				constr :constructor_inst,
				            _common_per_page: 16,
				            _product_list_current_page : 0,
		  				
			  				disobey:['padding_left_right', 'padding_top'],
			  				cp:cp,
			  				pos: pos,
			  				settings_draw :false,
							draw: function(){
								var product_id = constructor_inst.page_vars.product_id;
								var product = DB.get_objects('product', {_id: { '$oid':product_id }}).objects[0]
								var W = my_cont.width();
								var H = my_cont.height();
								
								img_div = $("<div>").css({
									float:'left',
									'background-color':'green',
									width:W/2,
									height:H
								}).appendTo(my_cont)
								
								desc_div = $("<div>").css({
									'background-color':'red',
									float:'left',
									width:W/2,
									height:H
								}).appendTo(my_cont)
								
								console.log(product)
								
								
							},
						
						}
						return o;
					},
					
					
					
					
				},
				'product_basket':{
					title:'Положить в корзину',
					default_size: [2,2],
					init : function (my_cont,  constructor_inst, pos, cp) {
						var o = {
							my_cont:my_cont,
			  				constr :constructor_inst,
				            _common_per_page: 16,
				            _product_list_current_page : 0,
		  				
			  				disobey: [], //['padding_left_right', 'padding_top'],
			  				cp:cp,
			  				pos: pos,
			  				settings_draw :false,
							_redraw: function () {
								my_cont.find('*').remove()
								this.draw();
							},
							
							draw: function(){
								var product_id = constructor_inst.page_vars.product_id;
								var cache = constructor_inst.get_app_cache("theshop");
								var self = this;
								if (cache[product_id]){
									product = cache[product_id]
									
								}else{
									if(product_id){
										var product = DB.get_objects('product', {_id: { '$oid':product_id }}).objects[0];
										cache[product_id] = product;
										constructor_inst.set_app_cache("theshop", cache)
										
									}else{
										var product = DB.get_objects('product').objects[0];
									}
									
								}
								 
								var W = my_cont.width();
								var H = my_cont.height();
								
								
								
								
								if( discount(product) ){
									$('<div>').appendTo(my_cont).text( get_price(product) )
									.css({
										//'background-color':'red',
									'float':'left',
										margin: 'auto',
										'text-align': 'center',
									})
									$('<div>').appendTo(my_cont).text( get_base_price(product) )
									.css({
										//'background-color':'red',
									'text-decoration': 'line-through',
									'float':'left',
										margin: 'auto',
										'text-align': 'center',
									})
									
								}else{
									$('<div>').appendTo(my_cont).text( get_base_price(product) )
									.css({
										//'background-color':'red',
										margin: 'auto',
										'text-align': 'center',
									})
									
								}
								basket_id = window.location.hostname + "_basket"
								basket_str = localStorage.getItem(basket_id)
								if (basket_str){
									basket = JSON.parse( basket_str )
								}else{
									basket = {products:{}}
								}
								
								
								if( (product._id['$oid']) in basket.products){
									$('<input>').val('убрать').prop('type','button').click(function(evt){
										
										delete basket.products[product._id['$oid']]
										localStorage.setItem(basket_id, JSON.stringify( basket ))
										self._redraw()
										
									}).appendTo(my_cont)
								}else{
									$('<input>').val('положить в корзину').prop('type','button').click(function(evt){
										basket.products[product._id['$oid']] = 1
										localStorage.setItem(basket_id, JSON.stringify( basket ))
										
										self._redraw()
										
									}).appendTo(my_cont)
									
								}
								
								
								
								
								
							},
						
						}
						return o;
					},
				},
				'product_properties':{
					title:'Свойства продукта',
					default_size: [2,2],
					init : function (my_cont,  constructor_inst, pos, cp) {
						var o = {
							my_cont:my_cont,
			  				constr :constructor_inst,
				            _common_per_page: 16,
				            _product_list_current_page : 0,
		  				
			  				disobey: [], //['padding_left_right', 'padding_top'],
			  				cp:cp,
			  				pos: pos,
			  				settings_draw :false,
							draw: function(){
								var product_id = constructor_inst.page_vars.product_id;
								var cache = constructor_inst.get_app_cache("theshop")
								if (cache[product_id]){
									product = cache[product_id]
									
								}else{
									if(product_id){
										var product = DB.get_objects('product', {_id: { '$oid':product_id }}).objects[0];
										cache[product_id] = product;
										constructor_inst.set_app_cache("theshop", cache)
										
									}else{
										var product = DB.get_objects('product').objects[0];
									}
									
								}
								 
								var W = my_cont.width();
								var H = my_cont.height();
								
								
								
								$("<h3>").text("Основные свойства").appendTo(my_cont);
								var c = $("<div>").appendTo(my_cont);
								if(product.properties){
									$.each(product.properties, function(n,v){
										$('<div>').text(n).css('float','left').appendTo(c)
										$('<div>').text(v).css('float','right').appendTo(c)
										$('<div>').css({'display':'block', 'clear':'both'}).appendTo(c)
										
									
									
									})
								}
								
								
								
								
								
							},
						
						}
						return o;
					},
				},
				'product_description':{
					title:'Описание продукта',
					default_size: [2,2],
					init : function (my_cont,  constructor_inst, pos, cp) {
						var o = {
							my_cont:my_cont,
			  				constr :constructor_inst,
				            _common_per_page: 16,
				            _product_list_current_page : 0,
		  				
			  				disobey: [], //['padding_left_right', 'padding_top'],
			  				cp:cp,
			  				pos: pos,
			  				settings_draw :false,
							draw: function(){
								var product_id = constructor_inst.page_vars.product_id;
								var cache = constructor_inst.get_app_cache("theshop")
								if (cache[product_id]){
									product = cache[product_id]
									
								}else{
									if(product_id){
										var product = DB.get_objects('product', {_id: { '$oid':product_id }}).objects[0];
										cache[product_id] = product;
										constructor_inst.set_app_cache("theshop", cache)
										
									}else{
										var product = DB.get_objects('product').objects[0];
									}
									
								}
								 
								var W = my_cont.width();
								var H = my_cont.height();
								var desc = product.description;
								
								
								$("<h3>").text("Описание").appendTo(my_cont);
								$("<span>").text(desc).appendTo(my_cont);
								
								
								
								
								
							},
						
						}
						return o;
					},
				},
				'product_image':{
					title:'Изображение продукта',
					default_size: [2,2],
					init : function (my_cont,  constructor_inst, pos, cp) {
						var o = {
							my_cont:my_cont,
			  				constr :constructor_inst,
				            _common_per_page: 16,
				            _product_list_current_page : 0,
		  				
			  				disobey: ['padding_left_right', 'padding_top'],
			  				cp:cp,
			  				pos: pos,
			  				settings_draw :false,
							draw: function(){
								var product_id = constructor_inst.page_vars.product_id;
								var cache = constructor_inst.get_app_cache("theshop")
								if (cache[product_id]){
									product = cache[product_id]
									
								}else{
									if(product_id){
										var product = DB.get_objects('product', {_id: { '$oid':product_id }}).objects[0];
										cache[product_id] = product;
										constructor_inst.set_app_cache("theshop", cache)
										
									}else{
										var product = DB.get_objects('product').objects[0];
									}
									
								}
								 
								var W = my_cont.width();
								var H = my_cont.height();
								
								image = product.images[0]
								if(product.images[0].blob){
									src = DB.get_blob_url(product.images[0])
								}else{
									src = product.images[0]
								}
								$(new Image()).one('load', function(){
									my_cont.append(scaleImage(this, W, H, true))
								}).prop('src', src )
								
								
								
								
								
							},
						
						}
						return o;
					},
				},
				"gallery": {
					title:"Витрина",
					default_size: [6,4],
					init: function(my_cont,  constructor_inst, pos, cp){
						var o = {
						my_cont:my_cont,
		  				constr :constructor_inst,
			            _common_per_page: 16,
			            _product_list_current_page : 0,
		  				
		  				disobey:['padding_left_right', 'padding_top'],
		  				cp:cp,
		  				pos: pos,
		  				settings_draw :false,

						
			            _get_product_list: function(){
							var cur_page = parseInt(constructor_inst.page_vars['page'])
							if(! cur_page){cur_page = 0}
			                
			                return DB.get_objects('product', {}, {current_page:cur_page, per_page:this._common_per_page})
			            },
						draw: function(){
							if (typeof this.constr.Site.fonts == 'undefined' ){
								font = 'Times New Roman'
							} else{ font = this.constr.Site.fonts.content}
							
							if(typeof this.data == 'undefined'){
								this.data = this.constr.getWidgetData(pos, false)||{rows:2, cols:3, margin:6};
							}
																					
							var cont = $("<div>").css({'list-style-type': 'none',
								 					  margin: 0, padding: 0,
													  overflow:'auto', 
													  display: 'block', 
													  'text-align':'center', 
													  height:'100%'});
							var self = this;
							my_cont.find('*').remove();
					
							var R = this.data.rows || 4,
								C = this.data.cols || 3,
								m = this.data.margin || 5,
								spaceR = R*m,
								spaceC = C*m,
							
								hc = (( my_cont.height()) / R)- 20,
								wc = (( my_cont.width()) / C) ;
						
								self._common_per_page = R * C;
								// console.log(wc,wc*3, my_cont.width())
							products = self._get_product_list()
							var rows_filled, counter;
							var pr_cont = $('<div>').appendTo(my_cont).width(wc * C).height(hc*R)
							
							$.each(products.objects, function(ix, obj){
								counter += 1
								var cc = $('<div>').appendTo(pr_cont)
								.css({
									//'background-color': 'white',
								'font-family':font,
								float:'left',
								width:wc, height:hc})
								
								var ccc = $('<div>').appendTo(cc)
								.css({
									//'background-color':'green',
									margin: m + 'px',
									width: wc - (m*2),
									height: hc - (m*2),
								})
								img_w = ccc.width()
								img_h = ccc.height() * 0.7
								desc_h = ccc.height() * 0.3
								
								var img_div = $('<div>').appendTo(ccc)
								.css({
									//'background-color':'blue',
									margin: 'auto',
									'text-align':'center',
									width: img_w,
									height: img_h,
									overflow:'hidden',
								})
								h_h = desc_h / 2
								$('<div>').appendTo(ccc)
								.css({
									//'background-color':'red',
									margin: 'auto',
									// cursor: 'pointer',
									'text-align': 'center',
									width: img_w,
									height: h_h,
								}).append($('<a>').text(obj.name).prop('href', "#!product?product_id=" + obj._id['$oid']).click(function(evt){
									// console.log(obj)
									//window.location.hash="!" + 'product' + "?product_id="+  obj._id['$oid'];

									//evt.preventDefault();
								}))
								if( discount(obj) ){
									$('<div>').appendTo(ccc).text( get_price(obj) )
									.css({
										//'background-color':'red',
									'float':'left',
										margin: 'auto',
										'text-align': 'center',
										width: img_w/2,
										height: h_h,
									})
									$('<div>').appendTo(ccc).text( get_base_price(obj) )
									.css({
										//'background-color':'red',
									'text-decoration': 'line-through',
									'float':'left',
										margin: 'auto',
										'text-align': 'center',
										width: img_w/2,
										height: h_h,
									})
									
								}else{
									$('<div>').appendTo(ccc).text( get_base_price(obj) )
									.css({
										//'background-color':'red',
										margin: 'auto',
										'text-align': 'center',
										width: img_w,
										height: h_h,
									})
									
								}
								if(obj.images[0].blob){
									src = DB.get_blob_url(obj.images[0])
								}else{
									src = obj.images[0]
								}
								//console.log(src)
								$(new Image()).one('load',function(){
									// console.log(img_w, img_h)
									var I = scaleImage(this, img_w, img_h,true)
									
									img_div.append(I);
								}).prop('src', src)
								
							})
							
							$("<div>").css({display:'block', clear:'both'}).appendTo(my_cont)
							
							$("<div>").css({height:20, 'font-family':font, width:my_cont.width(),
								'text-align':'center','vertical-align':'middle'})
								.appendTo(my_cont)
								.text('pagination')
							
							
					
							this._jq = cont;
							this._jq.appendTo(my_cont);
						
						}
					}
					return o
				  	
				  }
            	}
				
            }
        }
        return o;
    },
    getter: function(constr){
		return this.Main(constr)
	},
}