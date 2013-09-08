





var  NewsApplication = function(){
	this._common_per_page = 10;
	this._current_page = 0;
	this.getNewsList = function(){
		ns = [{body : "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
			   date_on : "23.01.3012",
		   	   title: "Good news"} ]
			   return ns
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
	
	this._get_list = function (page) {
        return DB.get_objects(appid, 'newsItem', {}, {current_page:page, per_page:this._common_per_page})
		
	};
    this._display_page =function(to, page){
        if (page){
            var current_page = page;
        }else{
            var current_page = 0 ;
        }
        var self = this;
        var result = this._get_list( current_page )
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
				
        if (result.total_pages -1 != this._current_page){
                $('<button>').text('next page').click(function(){

                    self._display_page.apply(self, [to, current_page + 1]);
                    $(this).remove()
                }).appendTo(to);

            }

            }

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
		$('<textarea>').prop('name','body' ).val(self._draft.body).width(R.width()).appendTo(R).change(clc)
		
		$('<button>').text('Сохранить').appendTo(R).click(function(){
			self._draft["created_on"] = new Date();
			
			DB.save_object(appid, 'newsItem', self._draft, function(){}, function(){
				self._draft = null;
				self.admin_page()
				// console.log('ok')
			});
			// console.log("save it", self._draft);
		})
		
	}
	
	this._initNewsList = function(to){
		var self = this;
        
        $('<button>').text('Add News' ).click(function(){self._add_news_form(to)}).appendTo(to)
		var cont = $('<div>').appendTo(to);
        this._display_page(cont)

		
	}
	this.remove = function(){};
	this.widgets = {};
	
	
	
	return this;
}

return new  NewsApplication()