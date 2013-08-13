    'use strict';
    var discount = function(product){ return true};
    var get_price = function(product){ return '50.00'; };
	var get_base_price = function(product) {return '70.00'; };
	if(  constr.Site.pages.shop == null ) {
        constr.addPage(false, true,'Магазин','shop',{'per_page':6, 'page':0 }) //, show_in_menu : true, removable:false }
			
    }else{
        constr.Site.pages.shop.show_in_menu = true;

    }
    if(constr.Site.pages.Product == null ) {
        constr.addPage(false, false, 'Товар', 'Product', {'product_id':''})

    }

    var _getProduct = function (id){
        var cache = constr.get_app_cache("theshop");
        console.log(cache)
        if (cache[id]){
            product = cache[id]
        }else{
            if(id){
                var product = DB.get_objects(appid, 'product', {_id: { '$oid':id }}).objects[0];
                cache[id] = product;
                constr.set_app_cache("theshop", cache)

            }else{
                // Это на случай, если нам надо показать страницу в редакторе сайта с неопределенным товаром
                // В таком случае сохраним в кеш под идентификатором 'null'

                if (cache['null']){
                    var product = cache['null'];
                }else{
                    var product = DB.get_objects(appid, 'product').objects[0];
                    cache['null'] = product
                }
                constr.set_app_cache("theshop", cache )
            }
        }
        return product;
    }
    var _setBasket = function(b){
        var basket_id = window.location.hostname + "_basket"
        localStorage.setItem(basket_id, JSON.stringify( b ))
    }

    var _getBasket = function(){
        var basket_id = window.location.hostname + "_basket";

        var basket_str = localStorage.getItem(basket_id);
        var basket = {products:{} };
        if (basket_str){
            var b_json = JSON.parse( basket_str );
            if (b_json.products != null){
                basket.products = b_json.products;
            }
        }
        console.log(basket);
        return basket

    }
    var _incProduct = function(id){
        // console.log('inc', id)
        var product = _getProduct(id)
        console.log("Prod", product)
        var basket = _getBasket();

        if (basket.products[ id ] == null ){
            basket.products[ product._id['$oid'] ] = { amount:1, name: product.name, price: get_base_price(product) }
        }else{
            basket.products[ id ].amount += 1
        }
        _setBasket(basket)

        constr.fireEvent("basket_changed")

    }
    var _decProduct = function(id){
        var basket = _getBasket()
        var product = _getProduct(id)

        if (basket.products[id] == null ){
            // we must to do nothing
        }else{
            if (basket.products[id].amount > 1){
                basket.products[id].amount -= 1
            }else{
                delete basket.products[id]

            }
        }
        _setBasket(basket)
        constr.fireEvent("basket_changed")
    }
    var _scaleImage = function(img, maxHeight, maxWidth, useMax){
        var scale
        if (useMax == null){
            useMax = false
        }
        var width = img.width,
            height = img.height;
        if (!useMax){
            scale = Math.min(maxWidth/width, maxHeight /height);
        }else{
            scale = Math.max(maxWidth/width, maxHeight /height);

        }
        //if (scale < 1) {
            var width = parseInt(width * scale, 10);
            var height = parseInt(height * scale, 10);
        //}
        img.width = width;
        img.height = height;
        return img

    }
    var o = {

        _common_per_page: 5,
        //_product_list_current_page : 0,
        _validators : {'int':{l:'Целое', f:function(v){return parseInt(v) } },
                       'string':{l:'Строка', f:function(v){return v } },
                       'bool':{l:'логическое', f:function(v){return v?true:false } },
                       'float':{l:'Дробное', f:function(v){return parseFloat(v) } },
        },
        _get_product_list: function(page){
            console.log(appid)
            return DB.get_objects(appid, 'product', {}, {current_page:page, per_page:this._common_per_page})
        },
        _init_prod_props_list: function( prod_props_cont ){
            var table,self,props;
            table = $('<table>').appendTo( prod_props_cont );
            props = DB.get_objects(appid, 'property', {}, {})
            self  = this;
            self._props_cache = props


            var tr = $('<tr>').appendTo(table)
            $('<th>').appendTo(tr ).text('Название')
            $('<th>').appendTo(tr ).text('Валидатор')

            $('<th>').appendTo(tr ).text('Единица измерения')

            $.each(props.objects, function( ix, o ){
                var dtr = $('<tr>').appendTo(table);
                $('<td>').text( o.name ).appendTo(dtr)
                if (o.validator){
                    $('<td>').text( self._validators[o.validator].l ).appendTo(dtr)
                }else{ $('<td>').text( o.validator ).appendTo(dtr)}
                $('<td>').text( o.measure ).appendTo(dtr)
                $('<input type="button" value="Удалить">').appendTo($('<td>').appendTo(dtr) ).click(function(){
                    DB.remove_object(appid, 'property', {'_id': o['_id']})
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
                DB.save_object(appid, 'property', o, function(){}, function(){})
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
              if(this._product_draft == undefined || !this._product_draft){
                this._product_draft = {}
                this._product_draft.images = []
              }
              var self = this;

              to.append($('<h3>').text("Product form" ))
              var ul = $("<ul>")
              var R = $("<div>").height(600).append(
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
            $('<textarea>').prop('name','description' ).val(self._product_draft.description).width(Desc.width()).appendTo(Desc).change(clc)


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
                $('<div>').css('float', 'left').append(_scaleImage($(this), 160, 160)).appendTo(d)
              }).prop('src', src)

          })

          var f = function(_to){

              $('<input type="file">').change(function(){
                    var fr = new FileReader()
                    var _this = this;
                    $(this).hide();

                    fr.onloadend = function(){
                        var result = this.result;
                        var mime_type  = this.result.split(';')[0].split(':')[1].split('/')[0]
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
          }
          var complete_f = function(){
              self._product_draft = false;
          }


          $("<button>").text("save").click(function(evt){
              DB.save_object(appid, 'product', self._product_draft, progress_f, complete_f)
              self.admin_page(to.parent().parent())
          }).appendTo(to)
          $("<button>").text('close form').click(function(evt){
              self.admin_page(to.parent().parent() )
          }).appendTo(to)



        },
        _init_orders_list: function(cont){
            var showDets;
            var orders = DB.get_objects(appid, 'order' )
            var d = $('<div></div>').appendTo(cont).height(500).css('overflow','auto')


            var table = $('<table>').appendTo($('<div>').appendTo(d).css('float','left').css('width','50%')).width('100%')
            var dets  = $('<table>').appendTo($('<div>').appendTo(d).css('float','left').css('width','50%')).width('100%')
            var tr = $('<tr>').appendTo(table)
            var td = $('<th>').appendTo(tr).text( "Электронный адрес" )
            var td = $('<th>').appendTo(tr).text( "телефон" )
            var td = $('<th>').appendTo(tr).text( 'Сумма' )
            var sum = function(xs){
                console.log(xs);
                var s=0
                for(var i =0; i < xs.length; i++){
                   s+=xs[i];
                }
                return s
            }
            var toTuple=function(obj){
                var _res = [];
                for (k in obj){
                    var v = obj[k];
                    v['_key'] = k
                    _res.push(v)

                }
                return _res;
            }

            $.each(orders.objects, function(ix, obj){
                var tr = $('<tr>').appendTo(table).on('click', function(){showDets(obj)})
                                    .on('mouseenter', function(){ $(this).css('background-color','grey')})
                                    .on('mouseleave', function(){ $(this).css('background-color','white')})
                $('<td>').appendTo(tr).text( obj.email )
                $('<td>').appendTo(tr).text( obj.phone )
                $('<td>').appendTo(tr).text( sum($(toTuple(obj.products)).map(function(i, o){ console.log(o); return (parseInt(o.amount) * parseFloat(o.price)) } ) ))
                var td = $('<td>').appendTo(tr)
                $('<input type="button" >').val('Удалить').click(function(){
                    DB.remove_object(appid, 'order', {'_id': obj['_id']}, function(js){
                        tr.remove();
                    })

                }).appendTo(td);

            })
            showDets = function( order ){
                dets.find('*').remove();
                var tr = $('<tr>').appendTo(dets)
                var td = $('<th>').appendTo(tr).text( 'Наименование товара' )
                var td = $('<th>').appendTo(tr).text( "кол-во" )
                var td = $('<th>').appendTo(tr).text( "Цена"  )
                var td = $('<th>').appendTo(tr).text( "Сумма" )

                $.each(order.products, function(ix, obj){
                    var tr = $('<tr>').appendTo(dets)
                    var td = $('<td>').appendTo(tr).text(obj.name)
                    var td = $('<td>').appendTo(tr).text(obj.amount)
                    var td = $('<td>').appendTo(tr).text(obj.price )
                    var td = $('<td>').appendTo(tr).text(parseInt(obj.amount) * parseFloat(obj.price) )


                })

            }
        },

        admin_page: function(to){
                //$("<div>").text("This is " + this.title + " admin page").appendTo(to)
                // Need to draw
                // 1. Product form
                // 2. import  button
                // 3. Main View
                to.find('*').remove()
                var atabs = $('<div>').appendTo(to)
                var ul = $("<ul>").appendTo(atabs);
                $("<li>").append($("<a>").prop('href', "#products" ).text("Products") ).appendTo(ul)
                $("<li>").append($("<a>").prop('href', "#product_props" ).text("Product props") ).appendTo(ul)
                $("<li>").append($("<a>").prop('href', "#orders" ).text('orders') ).appendTo(ul)

                var prod_cont = $("<div>").prop('id',"products").appendTo(atabs)
                this._init_product_list(prod_cont)
                // prod_cont.text("okey")


                var orders_cont = $("<div>").prop('id',"orders").appendTo(atabs)
                this._init_orders_list(orders_cont)
                // orders_cont.text("O okey")


                var prod_props_cont = $("<div>").prop('id',"product_props").appendTo(atabs)
                this._init_prod_props_list( prod_props_cont )

                atabs.tabs();



            },
        remove: function(){
            if(  constr.Site.pages.shop != null ) {
                constr.Site.pages.shop.show_in_menu=false
                console.log("remove app", constr.Site.pages)

            }

        },
        widgets:{
            'total_basket':{
                title:'Корзина на странице',
                default_size: [3,1],
                init : function (my_cont,  constructor_inst, pos, cp) {

                    var cart_base64 = "data:image/png;base64,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"
                    var o = {
                        my_cont:my_cont,
                        constr :constructor_inst,
                        _common_per_page: 16,
                        _product_list_current_page : 0,
                        disobey:[],
                        cp:cp,
                        pos: pos,
                        settings_draw :false,
                        _redraw: function () {
                            my_cont.find('*').remove()
                            this.draw();
                        },
                        setSEO: function(){
                            var is_set = constructor_inst._get_page_var('title_set')
                            if(is_set){
                                return
                            }else{
                                constructor_inst._add_title( this.product.name)
                                constructor_inst._set_page_var('title_set', true);
                            }
                        },
                        draw: function(){
                            var self = this;

                            constructor_inst.registerEvent( "basket_changed", function(){
                                console.log('it fired')
                                self._redraw()
                            })

                            var product_id = constructor_inst.page_vars.product_id;
                            var cache = constructor_inst.get_app_cache("theshop");

                            this.product = _getProduct(product_id);
                            this.setSEO();


                            var W = my_cont.width();
                            var H = my_cont.height();


                            var basket_id = window.location.hostname + "_basket";
                            var basket_str = localStorage.getItem(basket_id);
                            var total = 0, items = 0
                            if (basket_str){
                                var basket = JSON.parse( basket_str )
                                for (i in basket.products){
                                    total += parseFloat(basket.products[i].price * basket.products[i].amount)
                                    items += parseInt(basket.products[i].amount)
                                }
                            }

                            var c =$("<div>").appendTo(my_cont)
                            var img = $(new Image() ).one('load' , function(e){
                                var b = H
                                var div = $("<div>").css('vertical-align','middle').width(W).height(b).appendTo(c)
                                img = _scaleImage(this, b*5, H)
                                $(img).appendTo(div)
                                    .css('display', 'inline-block')
                                    .css('vertical-align','middle')
                                    .css('margin-left','0.3em');
                                var d = $('<div>')
                                    .css('display','inline-block')
                                    .css('padding-left','1em')
                                    .css('vertical-align','middle').appendTo( div );
                                if( ! items  ){

                                    d.text("Корзина пуста")
                                }else{
                                    d.text("Оформить заказ: " + total + "руб." )
                                }

                            }).prop('src', cart_base64);

                            if(!constructor_inst.is_constructor){
                                var cont, overley, attrs = {}, total, items;

                                c.click(function(){
                                var ordering = function(){
                                    var _t = [cont, overley]
                                    for (i in _t){
                                        if (_t[i]){_t[i].remove()}
                                    }
                                        overley = $('<div>').css({
                                            position: 'fixed',
                                            top: '0',
                                            left: '0',
                                            width: '100%' ,
                                            height: '100%',
                                            'background-color': '#000',
                                            filter:'alpha(opacity=50)',
                                            '-moz-opacity':'0.5',
                                            '-khtml-opacity': '0.5',
                                            opacity: '0.5',
                                            'z-index': '10000'
                                        }).appendTo('#controls');
                                        cont = $('<div>').css({
                                            position: 'fixed',
                                            'margin-left': 'auto',
                                            'margin-right': 'auto',
                                            top:' 5%',
                                            left:'20%',
                                            width: '60%' ,
                                            height: '90%',
                                            'background-color': '#fff',
                                            'z-index': '10001',
                                            'padding':'20'
                                        }).appendTo('#controls')

                                        var footer = $('<div></div>')
                                                        .css('position','absolute')
                                                        .css('top', '85%')
                                                        .height('15%')
                                                        .width('100%').appendTo(cont);

                                        var overflow_cont = $("<div>").appendTo( cont).height('85%').css('overflow', 'auto')

                                        var _tempo = _getBasket().products;


                                        var t = "<b>Укажите ваши данные для получения информации о заказе</b><div id='id-user-inputs'><input name='email'/> </div><div><input name='phone'/></div>"
                                        overflow_cont.append(t)
                                        var ch = function(e){
                                            var v = $( e.target).val()
                                            var n = $(e.target).attr('name')
                                            attrs[n] = v;
                                            console.log(attrs)
                                        }
                                        overflow_cont.find('input').on('keyup change', ch).width(170).height(20);
                                        overflow_cont.find('input[name=email]').watermark('email address')
                                        overflow_cont.find('input[name=phone]').watermark('phone number')

                                        $("<div></div>").css('font-weight','bold').text('Список товаров').appendTo(overflow_cont)
                                        var T = $('<table>').css('width','100%').appendTo(overflow_cont)
                                            var c = $("<tr>").appendTo(T).height('30px')
                                            $("<th>").appendTo(c).text("Наименование")
                                            $("<th>").appendTo(c).text("Количество")

                                            $("<th>").appendTo(c).text("Цена")
                                            $("<th>").appendTo(c).text("Стоимость")
                                            $("<th>").appendTo(c).text("!")
                                            $("<th>").appendTo(c).text("!")


                                        total = 0;
                                        $.each( _tempo , function(i,p){
                                            var p = _tempo[i]
                                            var tr = $("<tr>").appendTo(T).height('30px')
                                            $("<td>").appendTo(tr).text(p.name)
                                            $("<td>").appendTo(tr).text(p.amount)

                                            $("<td>").appendTo(tr).text(p.price + ' руб.')
                                            var st = (parseInt(p.amount ) * parseFloat(p.price));
                                            total += st
                                            $("<td>").appendTo(tr).text( st + ' руб.')
                                            // console.log("where is fucking buttons")
                                            var inc = $('<td>').appendTo(tr); // console.log(i,tr)
                                            var dec = $('<td>').appendTo(tr);
                                            $("<button>").appendTo(inc).text("Добавить").click(function(){ _incProduct( i); ordering() });
                                            $("<button>").appendTo(dec).text("Убрать").click(function(){ _decProduct( i); ordering() });
                                            // console.log('aa')

                                        })
                                        $("<div>").appendTo(overflow_cont).text("Итоговая стоимость: " + total + 'руб.').height('30px')

                                        $('<button>').text('Закрыть').appendTo(footer).click(function(){
                                            cont.remove();
                                            overley.remove();
                                        })
                                        $('<button>').text('Оформить заказ').appendTo(footer).click(function(){
                                            if (attrs.email == null || attrs.phone == null){
                                                alert('Укажите ваш e-mail  и номер телефона')
                                                return
                                            }else{
                                                var order = {"products": _getBasket().products,
                                                         "email": attrs.email,
                                                         "phone": attrs.phone };

                                                var oid = DB.save_object(appid, 'order', order, function(){}, function(xhr){
                                                    console.log(xhr, this);
                                                    var resp = JSON.parse(xhr.responseText )
                                                    var client_message_body = "Здравствуйте!" +
                                                    "На ваш адрес зарегистрирован заказ номер " + resp._id['$oid'] + " в магазине " + constr.Site.seo.title +". " +
                                                    "Наш менеджер будет уведомлен и в ближайшее время свяжется с вами. " +
                                                    "Спасибо!";

                                                    var manager_message_body = "На вашем сайте "+ window.location.host +" зарегистрирован заказ номер " + resp._id['$oid'] + " в магазине " + constr.Site.seo.title +". " +
                                                    "Детали заказа смотрите пожалуйста на сайте в интерфейсе администратора" +
                                                    "Спасибо!"

                                                    DB.send_email(attrs.email, "Ваш заказ сформирован", client_message_body)
                                                    DB.send_email('manager#' + appid, "Сформирован заказ", manager_message_body)
                                                    _setBasket({})
                                                    cont.remove();
                                                    overley.remove();



                                                })



                                            }
                                        })
                                    };
                                    ordering();

                                })


                            }




                        },

                    }
                    return o;
                },
            },
            'product_basket':{
                title:'Положить в корзину',
                default_size: [2,2],

                init : function (my_cont,  constructor_inst, pos, cp) {
                    var cart_base64 = "data:image/png;base64,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"
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
                        setSEO: function(){
                            var is_set = constructor_inst._get_page_var('title_set')
                            if(is_set){
                                return
                            }else{
                                constructor_inst._add_title( this.product.name)
                                constructor_inst._set_page_var('title_set', true);
                            }
                        },
                        draw: function(){
                            var product_id = constructor_inst.page_vars.product_id;
                            var self = this;

                            this.product = _getProduct(product_id );
                            this.setSEO();


                            var W = my_cont.width();
                            var H = my_cont.height();


                            var basket = _getBasket()

                            if( basket.products[product_id] ){
                                var this_product = basket.products[ product_id ]
                                if (typeof this_product !== 'object'){
                                    var this_product = false
                                }
                            }else{
                                var this_product = false
                            }

                            var c =$("<div>").appendTo(my_cont)
                            var img = $(new Image() ).one('load' , function(e){
                                var b = H
                                var div = $("<div>").css('vertical-align','middle').width(W).height(b).appendTo(c)
                                img = _scaleImage(this, b*5, H)
                                $(img).appendTo(div).css('display', 'inline-block').css('vertical-align','middle')
                                    .css('margin-left','0.3em')
                                var d = $('<div>')
                                    .css('display','inline-block')
                                    .css('padding-left','1em')
                                    .css('vertical-align','middle').appendTo(div)
                                if( ! this_product  ){
                                    d.text("Положить в корзину")
                                }else{
                                    d.text("Добавить еще")
                                }

                            }).prop('src', cart_base64);



                            if(!constructor_inst.is_constructor){
                                c.click(function(){
                                    // console.log(this_product)
                                    _incProduct( product_id )

                                    self._redraw()


                                })
                            }
                        }
                    }
                    return o;
                }
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
                        disobey:[],
                        cp:cp,
                        pos: pos,
                        setSEO: function(){
                            var is_set = constructor_inst._get_page_var('title_set')
                            if(is_set){
                                return
                            }else{
                                constructor_inst._add_title( this.product.name)
                                constructor_inst._set_page_var('title_set', true);
                            }
                        },
                        draw: function(){
                            var product_id = constructor_inst.page_vars.product_id;
                            var cache = constructor_inst.get_app_cache("theshop")

                            this.product = _getProduct(product_id);
                            this.setSEO();

                            var W = my_cont.width();
                            var H = my_cont.height();

                            $("<div>").css('font-weight','bold').css('font-size','1.17em').css('margin-bottom','0.5em').text("Основные свойства").appendTo(my_cont);

                            if(this.product.properties){
                                $.each(this.product.properties, function(n,v){
                                    $('<div>').text(n).css('float','left').appendTo(my_cont)
                                    $('<div>').text(v).css('float','right').appendTo(my_cont)
                                    $('<div>').css({'display':'block', 'clear':'both'}).appendTo(my_cont)
                                })
                            }
                        }
                    }
                    return o;
                }
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

                        disobey:[],
                        cp:cp,
                        pos: pos,
                        settings_draw :false,
                        setSEO: function(){
                            var is_set = constructor_inst._get_page_var('title_set')
                            if(is_set){
                                return
                            }else{
                                constructor_inst._add_title( this.product.name)
                                constructor_inst._set_page_var('title_set', true);
                            }
                        },
                        draw: function(){
                            var product_id = constructor_inst.page_vars.product_id;
                            var cache = constructor_inst.get_app_cache("theshop")

                            this.product = _getProduct(product_id);
                            this.setSEO();

                            var W = my_cont.width();
                            var H = my_cont.height();
                            var desc = this.product.description;

                            $("<div>").css('font-weight','bold').css('font-size','1.17em').css('margin-bottom','0.5em').text("Описание").appendTo(my_cont);

                            $("<span>").text(desc).appendTo(my_cont);

                        }

                    }
                    return o;
                }
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
                        depends_on_settings:true,
                        setSEO: function(){
                            var is_set = constructor_inst._get_page_var('title_set')
                            if(is_set){
                                return
                            }else{
                                constructor_inst._add_title( this.product.name)
                                constructor_inst._set_page_var('title_set', true);
                            }
                        },
                        draw: function(set){
                            var self = this;


                            if( this._img != null){
                                 if (set != null && set.border_radius) {
                                    this._img.css('border-radius', set.border_radius-2 +'px' )
                                }
                            }else{
                                var product_id = constructor_inst.page_vars.product_id;
                                this.product = _getProduct(product_id);
                                this.setSEO();

                                var W = my_cont.width();
                                var H = my_cont.height();

                                var image = this.product.images[0]
                                if(this.product.images[0].blob){
                                    var src = DB.get_blob_url(this.product.images[0])
                                }else{
                                    var src = this.product.images[0]
                                }
                                this._img = $('<div></div>');
                                $(new Image()).one('load', function(){
                                    _scaleImage(this, H, W, true)
                                    self._img.appendTo(my_cont)
                                        .css('background','url('+ this.src +') ')
                                        .css('background-size', this.width + 'px '+ this.height + 'px')
                                        .width(W)
                                        .height(H)
                                }).prop('src', src )

                            }





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

                    disobey:['padding_left_right', 'padding_top','line_height'],
                    cp:cp,
                    pos: pos,
                    settings_draw :false,


                    _get_product_list: function(){
                        var cur_page = parseInt(constructor_inst.page_vars['page'])
                        if(! cur_page){cur_page = 0}
                        this.cur_page = cur_page;

                        return DB.get_objects(appid,'product', {}, {current_page:cur_page, per_page:constructor_inst.page_vars['per_page']})
                    },
                    draw: function(){
                        var font;
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
                        var products = self._get_product_list()


                        if( products.total_pages > 1){
                            var pagination_height = 20;
                        }else{
                            var pagination_height = 0;

                        }

                        var R = this.data.rows || 4,
                            C = this.data.cols || 3,
                            m = this.data.margin || 6,
                            spaceR = R*m,
                            spaceC = C*m,

                            hc = (( my_cont.height()- pagination_height ) / R) ,
                            wc = Math.floor((( my_cont.width()) / C)) ;

                            self._common_per_page = R * C;
                        var rows_filled, counter;
                        var pr_cont = $('<div>').appendTo(my_cont).width(wc * C).height(hc*R - pagination_height)
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
                                height: hc - (m*2)
                            })
                            var img_w = ccc.width()
                            var img_h = ccc.height() * 0.7
                            var desc_h = ccc.height() * 0.3

                            var img_div = $('<div>').appendTo(ccc)
                            .css({
                                //'background-color':'blue',
                                margin: 'auto',
                                'text-align':'center',
                                width: img_w,
                                height: img_h,
                                overflow:'hidden'
                            })
                            var h_h = desc_h / 2
                            var lc = $('<div>').appendTo(ccc)
                            .css({
                                //'background-color':'red',
                                margin: 'auto',
                                // cursor: 'pointer',
                                'text-align': 'center',
                                width: img_w,
                                height: h_h
                            })
                            $('<a>').text(obj.name).prop('href', "#!Product?product_id=" + obj._id['$oid']).click(function(evt){} ).appendTo(lc)
                            if( discount(obj) ){
                                $('<div>').appendTo(ccc).text( get_price(obj) )
                                .css({
                                    //'background-color':'red',
                                'float':'left',
                                    margin: 'auto',
                                    'text-align': 'center',
                                    width: img_w/2,
                                    height: h_h
                                })
                                $('<div>').appendTo(ccc).text( get_base_price(obj) )
                                .css({
                                    //'background-color':'red',
                                'text-decoration': 'line-through',
                                'float':'left',
                                    margin: 'auto',
                                    'text-align': 'center',
                                    width: img_w/2,
                                    height: h_h
                                })

                            }else{
                                $('<div>').appendTo(ccc).text( get_base_price(obj) )
                                .css({
                                    //'background-color':'red',
                                    margin: 'auto',
                                    'text-align': 'center',
                                    width: img_w,
                                    height: h_h
                                })

                            }
                            var src;
                            // console.log(obj.images)
                            if(obj.images[0].blob){
                                src = DB.get_blob_url(obj.images[0])
                            }else{
                                src = obj.images[0]
                            }
                            $(new Image()).one('load',function(){
                                var I = _scaleImage(this, img_h, img_w, true)

                                img_div.append(I);
                            }).prop('src', src)

                        })

                        $("<div>").css({display:'block', clear:'both'}).appendTo(my_cont)

                        if (products.total_pages > 1 ){
                            var pagination = $("<div>").css({height:20, 'font-family':font, width:my_cont.width(),
                                'text-align':'center','vertical-align':'middle'})
                                .appendTo(my_cont)
                                var is_last_page = this.cur_page == products.total_pages - 1;
                                var is_first_page = this.cur_page == 0;
                                if(! is_first_page){
                                    $('<a>').text('Prev page').prop('href', "#!shop?page=" + (this.cur_page - 1)).appendTo(pagination)
                                }
                                if(! is_last_page){
                                    $('<a>').text('Next page').prop('href', "#!shop?page=" + (this.cur_page + 1)).appendTo(pagination)
                                }




                        }else{
                        }



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

