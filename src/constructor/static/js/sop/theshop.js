{
    Main:function(){
        var o = {
            title: "The shop",
            _common_per_page: 5,
            _product_list_current_page : 0,
            _get_product_list: function(page){
                //console.log(this)
                return DB.get_objects('product', {}, {current_page:page, per_page:this._common_per_page})
            },
            _init_product_list: function(to){
                var self = this;
                var cont = $('<div>').appendTo(to);
                this._display_page(cont)
                
                $('<button>').text('Add products' ).click(function(){self._add_product_form(to)}).appendTo(to)
                
                
            },
            _display_page: function(to){
                var self = this;
                var result = this._get_product_list(this._product_list_current_page)
                var products = result.objects
                if (result.total_amount == 0){
                    $('<h3>').text('No products selected or exists').appendTo(to)
                }else{
                    
                    $.each(products, function(i,obj){
                        var prod = $('<div>').height(160).appendTo(to)
                        var image = obj.images[0]
                        if (image.blob){
                            // console.log(image)
                            var img = $('<img>').prop('src', "/blob/"+ image._id['$oid'] + '/' )
                            var act = function(){
                                
                                $('<div>').css('float', 'left').append(self._scaleImage(img, 160, 160)).appendTo(prod)
                                $('<h3>').text(obj.name).appendTo(prod)
                                
                                $("<div>").append($('<p>').text(obj.description)).height(100).css('overflow','hidden').appendTo(prod);
                                
                            }
                            setTimeout(act, 200)
                        }
                    })
                    if (result.total_pages -1 != this._product_list_current_page){
                        $('<button>').text('next page').click(function(){
                            self._product_list_current_page += 1;
                            self._display_page.apply(self, [to]);
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
            _add_product_form : function(to){
              to.find('*').remove()
              //console.log('init')
              if(this._product_draft == undefined || !this._product_draft){
                    this._product_draft = {}
                    this._product_draft.images = []
              }
              var self = this;
              //console.log("PD", !this._product_draft, this._product_draft);
              
              to.append($('<h3>').text("Product form" ))
              var ul = $("<ul>")  
              R = $("<div>").height(400).append(
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
                  // console.log(self._product_draft)
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
                                in_stock   :{t:'text',l:'In stock'}}
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
              $.each(self._product_draft.images, function(ix, imgd){
                  
                  var img = $('<img>').prop('src', imgd)
                  var act = function(){
                      $('<div>').css('float', 'left').append(self._scaleImage(img, 160, 160)).appendTo(d) 
                  }
                  setTimeout(act, 100);
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
                  self.admin_page(to.parent())
              }).appendTo(to)
              $("<button>").text('close form').click(function(evt){
                  self.admin_page(to.parent() )
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
                    $("<li>").append($("<a>").prop('href', "#orders" ).text('orders') ).appendTo(ul)
                    
                    prod_cont = $("<div>").prop('id',"products").appendTo(atabs)
                    this._init_product_list(prod_cont)
                    // prod_cont.text("okey")
                     
                    
                    orders_cont = $("<div>").prop('id',"orders").appendTo(atabs)
                    orders_cont.text("O okey")
                    
                    atabs.tabs();
                    
                    
                    
                },
            widgets:{}
        }
        return o;
    },
    getter: function(){return this.Main()},
}