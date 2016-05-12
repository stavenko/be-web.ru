





var  NewsApplication = function(){
	this._common_per_page = 10;
	this._current_page = 0;
	this.getNewsList = function(){
		ns = [{body : "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
			   date_on : "23.01.3012",
		   	   title: "Good news"} ]
			   return ns;
	}
	this.admin_page = function(to){
		if (to != null){
			this.main_container = to;
		}else{
			to = this.main_container;
		}
		
        to.find('*').remove()
        var atabs = $('<div>').appendTo(to).css('font-size', '80%');
        var ul = $("<ul>").appendTo(atabs);
        //$("<li>").append($("<a>").prop('href', "#nform" ).text("Новая новость") ).appendTo(ul)
        $("<li>").append($("<a>").prop('href', "#newslist" ).text("Список новостей") ).appendTo(ul)

        //var c1 = $("<div>").prop('id',"nform").appendTo(atabs)
        //this._initNewsForm(c1)
        // prod_cont.text("okey")


        var c2 = $("<div>").prop('id',"newsList").appendTo(atabs)
        this._initNewsList(c2)
        // orders_cont.text("O okey")

        atabs.tabs();
		
		

	};
	
	this._get_list = function (page, cb) {
		
        DB.get_objects_async(appid, 'newsItem', {}, {current_page:page, per_page:this._common_per_page}, false, [["created_on",-1]], cb)
		
	};
    this._display_page =function(to, page){
        if (page){
            var current_page = page;
        }else{
            var current_page = 0 ;
        }
        var self = this;
		var callback = function(result){
	        var items = result.objects
		
	        if (result.total_amount == 0){
	            $('<h3>').text('No products selected or exists').appendTo(to)
	        }else{

	            $.each(items, function(i,obj){
	                var prod = $('<div>').height(160).appendTo(to)
	                var act = function(){
	                    $('<h3>').text(obj.title + ' - ' + moment(obj.created_on).format("MMM Do YY")).appendTo(prod).css({cursor:'pointer'})
						.click(function(){
	                        self._add_news_form(to.parent(), obj)
	                    })
	                    $("<div>")
						.append($('<p>').text(obj.body)).height(100)
						.css('overflow','hidden').appendTo(prod);

	                }();
	                })
				
	        if (result.total_pages -1 != self._current_page){
	                $('<button>').text('next page').click(function(){

	                    self._display_page.apply(self, [to, current_page + 1]);
	                    $(self).remove()
	                }).appendTo(to);

	            }

	            }	
		}
        this._get_list( current_page, callback )
		// console.log(result)
		
        

        },
	

	this._add_news_form = function(to, obj){
        if(obj){
            this._draft = obj
        }
        to.find('*').remove()
        var self = this;
        if(this._draft == undefined || !this._draft){
          this._draft = {}
          // this._draft.images = []
        }
        var self = this;

        to.append($('<h3>').text("Product form" ))
        var R = $("<div>").height(600).appendTo(to)

        function clc(evt){
            var i = $(this)
            var n = $(this).prop('name');
            if (i.prop('type') == 'checkbox'){
                var v = i[0].checked;
            }else{
                var v = $(this).val()

            }
            self._draft[n] = v;
        }
		
		$('<span>').text("Название").appendTo(R)
		
		$('<input>').prop('name','title' ).val(self._draft.title).appendTo(R).change(clc)
		$('<textarea>').width(1000).height(300).prop('name','body' ).val(self._draft.body).width(R.width()).appendTo(R).change(clc)
		
		$('<button>').text('Сохранить').appendTo(R).click(function(){
			self._draft["created_on"] = new Date();
			
			DB.save_object(appid, 'newsItem', self._draft, function(){}, function(){
				self._draft = null;
				self.admin_page()
			});
		})
		$('<button>').text('отмена').appendTo(R).click(function(){
			self.admin_page()
		})
		
	}
	
	this._initNewsList = function(to){
		var self = this;
        
        $('<button>').text('Add News' ).click(function(){self._add_news_form(to)}).appendTo(to)
		var cont = $('<div>').appendTo(to);
        this._display_page(cont)

		
	}
	this.remove = function(){};
	var app = this;
	
	var newsFeedRSSWidget = function(){
	    WidgetIniter.call(this);
	    this.title = "Отображение новостей - Rss";
	    this.is_settings = false
	    this.default_size = [4,5];
	    this.do_not_apply = [];
	    this.need_redraw = false;
	    this._def_data =  '';
		this._save = function(){
			this._d.dialog('close');
		}
		this._cancel = function(){
			this._d.dialog('close');
			
		}
		this._settings = function(cp){
			var self = this;
			var data = this._data();
			var d= $("<div>").appendTo($('#controls'))
			self._d = d;
			var span = $('<span>').text('Адрес RSS-фида').appendTo(d)
			var input = $('<input>').appendTo(d).val(data).on('change keyup', function(e){
				var t = $(e.delegateTarget).val()
			})
			d.dialog({width:300, 
					  height:200, 
					  title:"Адрес фида",
					  buttons: {
						  "Сохранить": function(e){
							   self.data = input.val();
						   }
					   }
				
			})
			
		}
		this._draw = function(){
			// console.log('draw')
			this._jq = $('<div class="news-feed-rss-widget">').width(this.my_cont.width()).height(this.my_cont.height()).appendTo(this.my_cont);
			setFont(this._jq, this.C.Site.fonts.content)
			var is_first = true;
			var total_h = 0;
			var self = this;
			var data = this._data();
			if (data){
				$.ajax({
				  url      : document.location.protocol + '//ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=10&callback=?&q=' + encodeURIComponent(data),
				  dataType : 'json',
				  cache:false,
				  success  : function (data) {
				    if (data.responseData.feed && data.responseData.feed.entries) {
				      $.each(data.responseData.feed.entries, function (i, e) {
				        var title = e.title
				        var body = e.content;
				        var created_on = e.publishedDate;
				        var link = e.link
					
						var ni = $('<div>').css('margin-bottom','2em');
						$("<h4>").css('text-decoration','underline')
						.css('font-size', '1.1em')
						.css('font-weight',600)
						.appendTo(ni).html(title + "&nbsp;" )
						.append($('<i>').text(moment(created_on).format("MMM Do YY")));
						var p = $("<p>").text(body).appendTo(ni);
						
						var l = $('<a>').prop('href', link).text("Далее...").appendTo(ni)
					
						ni.appendTo(self._jq);
						total_h += ni.height();
			
						if (!is_first){
							if (total_h > self.my_cont.height()){
								ni.remove()
							}
						}
						is_first = false;
				      });
				    }
				  }
				});				
			}else{
				this._jq.html('<center> Укажите адрес источника в настройках..."). </center>')
			}
		}
	}
	var newsFeedWidget = function(){
	    WidgetIniter.call(this);
	    this.title = "Отображение новостей - сайт";
	    this.is_settings = false
	    this.default_size = [4,5];
	    this.do_not_apply = [];
	    this.need_redraw = false;
	    this._def_data =  [];
		this._draw = function(){
			this._jq = $('<div>').width(this.my_cont.width())
			.height(this.my_cont.height()).appendTo(this.my_cont);
			setFont(this._jq, this.C.Site.fonts.content)
			var is_first = true;
			var total_h = 0;
			var self = this;
			var callback = function(news){
				//console.log('inside CB');
				
				
				if (news.total_amount == 0){
					var ni = $('<div>').css('margin-bottom','2em');
					ni.html('<center> Пока нет новостей </center>')
					ni.appendTo(self._jq)
				}else{
					$.each(news.objects, function(ix, newsObj){
						var ni = $('<div>').css('margin-bottom','2em');
						$("<h4>").css('text-decoration','underline')
						.css('font-size',  '1.1em')
						.css('font-weight',600)
						.appendTo(ni).html(newsObj.title + "&nbsp;" )
						.append($('<i>').text(moment(newsObj.created_on).format("MMM Do YY")));
						$("<p>").text(newsObj.body).appendTo(ni);
						ni.appendTo(self._jq);
						total_h += ni.height();
			
						if (!is_first){
							if (total_h > self.my_cont.height()){
								ni.remove()
							}
						}
						is_first = false;
				
				
					})
				}	
			}
			var news = app._get_list(0, callback);
			
		}
		
		
	}
	
	
	this.widgets = {
		my_news: newsFeedWidget,
		rss_news: newsFeedRSSWidget
	}
	return this;
	
}

return new  NewsApplication()