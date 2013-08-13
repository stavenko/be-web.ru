

move_block = `function ( ix, x, y, dont_save){
				var bl = this.Site.blocks.splice(ix,1)[0]
				bl.x = x; bl.y = y;
				this.Site.blocks.push(bl)
				if(!(dont_save)){
					this._save_site();
				}
			}`
window.Constructor.move_block = move_block





addCustomColor = `function (color){
				if (this.Site.colors.custom_pallette){
					ix = this.Site.colors.custom_pallette.push(color) - 1
				}else{
					this.Site.colors.custom_pallette = [color];
					ix = 0
				}
				return ix
			}`
window.Constructor.addCustomColor = addCustomColor




window.Constructor.add_block = (x, y, type, ds) ->
  @Site.blocks.push
    width: ds[0]
    height: ds[1]
    x: x
    y: y
    widget:
      name: type
      data: ""

    display_on: @current_page
    dont_display_on: []



delete_block = `function (ix){
				this.Site.blocks.splice(ix,1)

			}`
window.Constructor.delete_block = delete_block







_set_base_hue = `function (hue){
				this.Site.colors['base'] = hue;
			}`
window.Constructor._set_base_hue = _set_base_hue




_set_scheme_type = `function (type){
				this.Site.colors['type'] = type;
			}`
window.Constructor._set_scheme_type = _set_scheme_type





setBlockSettings = `function (page_pos, s){
				this.Site.blocks[page_pos].settings = s;
			}`
window.Constructor.setBlockSettings = setBlockSettings




setDefaultBlockSettings = `function (s){
				this.Site.default_block_settings = s;
			}`
window.Constructor.setDefaultBlockSettings = setDefaultBlockSettings




setWidgetData = `function (pos, data){
				this.Site.blocks[pos].widget.data = data;

			}`
window.Constructor.setWidgetData = setWidgetData





init_cp_marker = `function (){
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

			}`
window.Constructor.init_cp_marker = init_cp_marker


redraw_cp = `function (active_tab){
				if (this.cp_acc){
					this.cp_acc.remove()
				}
				this.show_CP(active_tab)
			}`
window.Constructor.redraw_cp = redraw_cp



_save_site = `function ( do_cache ){
				if(typeof do_cache == 'undefined'){
					do_cache = false;
				}
				this.Site['site_id'] = this.site_id;
				self = this;
				if (do_cache){
					setTimeout(function(){self.caching()}, 100)
				}
				var saving_obj = $.extend(true, {}, self.Site);
				delete saving_obj['Applications']
				DB.save_object_sync('generic.' + BASE_SITE, this._site_type, saving_obj, function(){
				},

				function(xhr){
					O = eval("[" + xhr.responseText +"]")[0]
					self.Site['_id'] = O._id
				})


			}`
window.Constructor._save_site = _save_site

window.Constructor.init_block_cp = (obj, to, widget) ->
  m = $("<div>").appendTo(to)
  self = this
  w = obj
  settings = self.getBlockSettings(obj.pos)
  old_settings = $.extend(true, {}, settings)

  onPatternChoice = (pattern) ->
    settings.background =
      type: "pattern"
      pattern: pattern

    self.apply_block_settings w, settings, widget

  onColorChoice = (color, pal_ix, hsba) ->
    log("DIAL", this)
    if color is "clear"
      settings.background = type: "none"
    else
      settings.background =
        type: "color"
        color: pal_ix
    self.apply_block_settings w, settings, widget
    #$(this).dialog "close"

  onCancel = ->
    settings = old_settings
    self.apply_block_settings w, old_settings, widget
    $(this).dialog "close"

  onSave = ->
    $(this).dialog "close"

  if widget.disobey.indexOf("background_color") is -1
    cl = $("<button>").button().text("Выбор фона").click(->
      self.drawBackgroundSelectorDialog onPatternChoice, onColorChoice, onCancel, onSave
    ).appendTo(m)

  #console.log(widget.disobey.indexOf('border_color') == -1)
  if widget.disobey.indexOf("border_color") is -1
    cl = $("<button>").button().text("выбрать цвет рамки").click(->
      cb = (col, ix) ->
        unless col is "clear"
          settings.border_color = ix
          self.apply_block_settings w, settings, widget

      cc = self.draw_color_chooser(cb)
      cc.appendTo(to).position
        of: this
        my: "left top"
        at: "left top"

    ).appendTo(m)
  vf = (a, d) ->
    (if typeof (a) is "undefined" then d else a)

  ul = $("<ul>").appendTo(m).addClass("cp-ul")
  if widget.disobey.indexOf("bg_opacity") is -1
    li = $("<li>").appendTo(ul)
    $("<span>").text("Прозрачность блока").appendTo li

    # w.css('opacity', settings.bg_opacity);
    $("<div>").width(250).slider(
      min: 0
      max: 100
      value: vf(settings.bg_opacity, 100) * 100
      slide: (event, ui) ->
        settings.bg_opacity = ui.value / 100
        self.apply_block_settings w, settings, widget
    ).appendTo li
  if widget.disobey.indexOf("border_radius") is -1
    li = $("<li>").appendTo(ul)
    $("<span>").text("Радиус границы").appendTo li

    #w.css('border-radius', settings.border_radius +'px');
    $("<div>").width(250).slider(
      min: 0
      max: 100
      value: vf(settings.border_radius, 0)
      slide: (event, ui) ->
        settings.border_radius = ui.value
        self.apply_block_settings w, settings, widget
    ).appendTo li
  if widget.disobey.indexOf("border_width") is -1
    li = $("<li>").appendTo(ul)
    $("<span>").text("Ширина границы").appendTo li
    $("<div>").width(250).slider(
      min: 0
      max: 100
      value: vf(settings.border_width, 0) * 10
      slide: (event, ui) ->
        settings.border_width = ui.value / 10
        self.apply_block_settings w, settings, widget
    ).appendTo li
  if widget.disobey.indexOf("line_height") is -1
    li = $("<li>").appendTo(ul)
    $("<span>").text("Межстрочный интервал").appendTo li
    # def_lh = obj.jq.width() / settings.font_size * 0.75

    # w.css('line-height', settings.line_height +'px');
    lhs = $("<div>").width(250).slider(
      min: 0
      max: 300
      value: settings.line_height
      slide: (event, ui) ->
        settings.line_height = ui.value / 10
        self.apply_block_settings w, settings, widget
    ).appendTo(li)
  if widget.disobey.indexOf("font_size") is -1
    li = $("<li>").appendTo(ul)
    $("<span>").text("Размер шрифта").appendTo li

    #w.css('font-size', settings.font_size +'px');
    #w.css('line-height', lh +'px');
    $("<div>").width(250).slider(
      min: 0
      max: 300
      value: settings.font_size
      slide: (event, ui) ->
        settings.font_size = ui.value / 10
        #settings.line_height = obj.jq.width() / settings.font_size * 0.75
        self.apply_block_settings w, settings, widget
        #lhs.slider "value", settings.line_height * 10
    ).appendTo li
  if widget.disobey.indexOf("padding_top") is -1
    li = $("<li>").appendTo(ul)
    $("<span>").text("отступ сверху").appendTo li
    pt = (if settings.padding_top then settings.padding_top * 10 else 0)
    $("<div>").width(250).slider(
      min: 0
      max: 300
      value: pt
      slide: (event, ui) ->
        settings.padding_top = ui.value / 10
        self.apply_block_settings w, settings, widget
    ).appendTo li
  if widget.disobey.indexOf("padding_left_right") is -1
    li = $("<li>").appendTo(ul)
    $("<span>").text("Отступ слева-справа").appendTo li
    plr = (if settings.padding_left_right then settings.padding_left_right * 10 else 0)
    $("<div>").width(250).slider(
      min: 0
      max: 300
      value: plr
      slide: (event, ui) ->
        settings.padding_left_right = ui.value / 10
        self.apply_block_settings w, settings, widget
    ).appendTo li
  $("<label for='available_all_pages'>").appendTo(m).append "Показывать на всех страницах"
  cb = $("<input type='checkbox' id='available_all_pages'>").appendTo(m).click(->

    # console.log(self.Site.blocks, to)
    if self.Site.blocks[obj.pos].display_on is "all"
      self.Site.blocks[obj.pos].display_on = self.current_page
    else
      self.Site.blocks[obj.pos].display_on = "all"
  )
  cb.prop "checked", self.Site.blocks[obj.pos].display_on is "all"
  $("<br>").appendTo m

  # ------
  $("<label for='unsnap_to_grid'>").appendTo(m).append "Свободный блок"
  cb = $("<input type='checkbox' id='unsnap_to_grid'>").appendTo(m).click(->
    bl = self.get_block(obj.pos)
    settings.unsnap_to_grid = @checked
    if @checked
      self.move_block obj.pos, self._calc_left(bl.x + 1) + settings.border_width, self._calc_top(bl.y + 1) + settings.border_width, true
      self.Site.blocks[obj.pos].width = self._calc_width(bl.width)
      self.Site.blocks[obj.pos].height = self._calc_height(bl.height)
    else

      # x = obj.jq.css('left')
      self.move_block obj.pos, self._uncalc_left(bl.x) + settings._border_width, self._uncalc_top(bl.y) + settings._border_width, true
      self.Site.blocks[obj.pos].width /= self._block_width()
      self.Site.blocks[obj.pos].height /= self._block_height()
  )
  cb.prop "checked", settings.unsnap_to_grid
  $("<br>").appendTo m

  # ------
  cl = $("<button>").button().text("Применить для всех новых блоков").click(->
    self.Site.default_block_settings = settings
    self.redraw()
    m.remove()
  ).css("display", "block").css("padding", "5px").css("margin-bottom", "10px").appendTo(m)

  # console.log(bl)
  cl = $("<button>").button().text("Применить для всех имеющихся блоков").click(->
    self.Site.default_block_settings = settings
    $.each self.Site.blocks, (i, bl) ->
      delete bl["settings"]

    self.redraw()
    to.remove()
  ).appendTo(m).css("display", "block").css("padding", "5px").css("margin-bottom", "10px")
  o =
    save: ->

      #console.log(settings)
      self.setBlockSettings obj.pos, settings

    cancel: ->

  o


drawBackgroundSelectorDialog = `function (onPatternChoice, onColorChoice, onCancel, onSave){
				var self = this;
				var patt_div = $('<div>')
				.css({
								//'position': 'absolute',
								//'width': 600,
								//'background-color': 'white',
								//'height': 300
							})
								.appendTo( $('#controls' ))
								//.position({of:this, my:'left top', at:'left top' } )
								//.zIndex(10);

								// Запихать в этот див кучу паттернов для бэкграунда
				//var to = this._app_admin_contents;


				var show_img_patt_choice = function(where, t){
					$.each(DB.get_objects('generic.' + BASE_SITE, 'pattern', {type:t}).objects, function(ix, obj){
						// console.log(ix, obj)
						if (obj.image.blob){
							var url = DB.get_blob_url(obj.image)
						}else{
							var url = obj.image;
						}
						$('<div>').css('float','left')
							  .css('background', 'url(' + url+')')
							  .css('background-size', '32px 32px')
							  .width(32).height(32)
							  .css('margin', '5px').appendTo(where)
							  .css('cursor','pointer')
							  .on('mouseenter', function(){})
							  .on('click', function(){
								  onPatternChoice.apply(patt_div, [obj] )
							  })

					})
				}
				var show_css_patt_choice = function(where){
					//var inp = $('<div>').appendTo(where).width('100%').height('100%')

					$.each(DB.get_objects('generic.' + BASE_SITE,'pattern', {type:'css'}).objects, function(ix, obj){
						// console.log(ix, obj)
						var d = $('<div>').css('float','left')
							  // .css('background', 'url(' + obj.image+')')
							  .css('background-size', '32px 32px')
							  .width(32).height(32)
							  .css('margin', '5px').appendTo(where)
							  .css('cursor','pointer')
							  .on('mouseenter', function(){})
							  .on('click', function(){
								  onPatternChoice.apply(patt_div, [obj] )
							  })
							  self._draw_css_background( d, obj.image )

					})
				}



				patt_div.find('*').remove()
				atabs = $('<div>').appendTo(patt_div)
				ul = $("<ul>").appendTo(atabs);
				$("<li>").append($("<a>").prop('href', "#image-pattern" ).text("Узор из картинки") ).appendTo(ul)
				$("<li>").append($("<a>").prop('href', "#constructor-pattern" ).text("Собранный узор") ).appendTo(ul)
				$("<li>").append($("<a>").prop('href', "#css-pattern" ).text('CSS-узор') ).appendTo(ul)

				var pic_patt = $("<div>")//.width('300')
				.height(300)
				.prop('id',"image-pattern").appendTo(atabs)
				show_img_patt_choice(pic_patt,'image')

				var my_patt = $("<div>")
				//.width('100%')
				.height(300)
				.prop('id',"constructor-pattern").appendTo(atabs)
				show_img_patt_choice(my_patt,'constructor')

				var css_patt = $("<div>")
				//.width('100%')
				.height(300).prop('id',"css-pattern").appendTo(atabs)
				show_css_patt_choice(css_patt)

				// prod_cont.text("okey")


				//orders_cont = $("<div>").prop('id',"orders").appendTo(atabs)
				// orders_cont.text("O okey
				atabs.tabs();
				patt_div.dialog({title:'Выбор заднего фона',width:600, height:500,
					buttons:{"Готово" : function(){
											onSave.apply(patt_div, [])
										},
							 "Отмена": function(){
								 			onCancel.apply(patt_div, [])
										},
							 "Выбор цвета": function(){
											cc = self.draw_color_chooser( onColorChoice );
											cc.appendTo( $('#controls') )
											.position({of:this, my:'left top', at:'left top' } )
										 }
					}})

			}`
window.Constructor.drawBackgroundSelectorDialog = drawBackgroundSelectorDialog



showColorScheme = `function (){
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
									if (!((j==i) || (i==5 &&j==6) || (i==6&&j==5)	) ){
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
											$('<input>').prop('name','scheme').prop('type','radio').prop('id','mono').click(function(){ self._set_scheme_type('mono');self.showColorScheme(); }),		$('<label>').prop('for','mono').text('Mono'),
											$('<input>').prop('name','scheme').prop('type','radio').prop('id','complement').click(function(){ self._set_scheme_type('complement');self.showColorScheme()}),$('<label>').prop('for','complement').text('Complement'),
											$('<input>').prop('name','scheme').prop('type','radio').prop('id','triada').click(function(){ self._set_scheme_type('triada');self.showColorScheme();}),	$('<label>').prop('for','triada').text('Triada'),
											$('<input>').prop('name','scheme').prop('type','radio').prop('id','split-trio').click(function(){ self._set_scheme_type('split-trio');self.showColorScheme();}),$('<label>').prop('for','split-trio').text('Split-trio'),
											$('<input>').prop('name','scheme').prop('type','radio').prop('id','analogous').click(function(){ self._set_scheme_type('analogous');self.showColorScheme();}), $('<label>').prop('for','analogous').text('Analogoues'),
											$('<input>').prop('name','scheme').prop('type','radio').prop('id','accent').click(function(){ self._set_scheme_type('accent');self.showColorScheme();}),	$('<label>').prop('for','accent').text('Accent')
											//$('<input>').prop('type','radio').prop('id','mono'),$('<label>').prop('for','mono').text('Mono'),

				).buttonset().appendTo(to)
				$("<span>").text('brightness').appendTo(to)
				$("<div>").width(250).slider({min:0, max:100,value:self.Site.colors.brightness, slide:function(event, ui){ self.Site.colors.brightness = ui.value;self._pallete_drawer.apply(self,[c])	}} ).appendTo(to)

				$("<span>").text('saturation').appendTo(to)
				$("<div>").width(250).slider({min:0, max:100,value:self.Site.colors.saturation, slide:function(event, ui){ self.Site.colors.saturation = ui.value; self._pallete_drawer.apply(self,[c])	 }} ).appendTo(to)

				$("<span>").text('lights').appendTo(to)
				$("<div>").width(250).slider({min:0, max:100,value:self.Site.colors.lights, slide:function(event, ui){ self.Site.colors.lights = ui.value; self._pallete_drawer.apply(self,[c])	 } } ).appendTo(to)

				$("<span>").text('shadows').appendTo(to)
				$("<div>").width(250).slider({min:0, max:100,value:self.Site.colors.shadows, slide:function(event, ui){ self.Site.colors.shadows = ui.value; self._pallete_drawer.apply(self,[c])} } ).appendTo(to)

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
					var off = C.offset();
					self._set_base_hue(evt.clientX - off.left);
					orig = false
					self.redraw()

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
			}`
window.Constructor.showColorScheme = showColorScheme


###
showLayoutScheme = `function (){

				var to = this._app_admin_contents;
					to.find('*').remove()
					to.width(500)
				var self = this

					lo = $.extend(true, {}, this.Site.layout);
				var ul = $("<ul>").appendTo(to).width(500)

				$.each(lo, function(i, val){
					var l = $("<li>").text(i).appendTo(ul)

					if(i == 'grid' ||	i == 'padding' ){
						var inner =$("<ul>").appendTo(l)
						$.each(val, function(j, val){

							var l = $("<li>").text(j).appendTo(inner)
							var sp = $('<input>').appendTo(l).spinner({spin:function(event, ui){
								//console.log("do");
								self.Site.layout[i][j] = ui.value
								self.redraw();
							} }	)
							sp.spinner('value', val)

						})

					}else{
						var sp = $('<input>').appendTo(l).spinner({spin:function(event, ui){
								//console.log("do");
								self.Site.layout[i]= ui.value
								self.redraw();
							} }	)
						sp.spinner('value', val)
					}
				})
				$('<button>').text('save').click(function(){
					self._save_site()
				}).appendTo(to)
				$('<button>').text('cancel').click(function(){
					self.Site.layout = lo;
					self.showLayoutScheme();
					self.redraw()
				}).appendTo(to)
				this._app_admin_cont.show()
			 }`
###
window.Constructor.showLayoutScheme = ->
  to = @_app_admin_contents
  to.find("*").remove()
  to.width 500
  self = this
  lo = $.extend(true, {}, @Site.layout)
  ul = $("<ul>").appendTo(to).width(500)
  labels =
    "drawen_lines":"Количество строк"
    "cols":"Количество столбцов"
    "padding":"Отступ"
    "top":"Сверху"
    "left":"Слева-справа"
    "width":"Ширина"
    "grid":"Расстояния"
    "hor":"Между столбцами"
    "ver":"между строками"
    "base_height":"Высота строки"

  s = undefined
  recount = =>
    s.text("Ширина блока: " + @_block_width(1) + "; Высота блока: " + @_block_height(1));
  $.each lo, (i, val) =>
    changer_1 = (event, ui) =>
          @Site.layout[i] = ui.value
          recount();
    unless i is 'fixed'
      l = $("<li>").text(labels[i]).appendTo(ul)
      if i is "grid" or i is "padding"
        inner = $("<ul>").appendTo(l)
        $.each val, (j, val) =>
          changer_2 = (event, ui) =>
            @Site.layout[i][j] = ui.value
            recount()

          l = $("<li>").text(labels[j]).appendTo(inner)
          sp = $("<input>").appendTo(l).spinner({spin: changer_2})
          sp.spinner "value", val
          sp.on('keyup', (e)=>
            v = $(e.target).val();
            @Site.layout[i][j] = parseInt(v)
            recount()
          )

      else
        sp = $("<input>").appendTo(l).spinner({spin: changer_1} )
        sp.spinner "value", val
        sp.on('keyup', (e)=>
            v = $(e.target).val();
            @Site.layout[i] = parseInt(v)
            recount();
          )

  s = $('<div></div>').text("Ширина блока: " + @_block_width(1) + "; Высота блока: " + @_block_height(1)).appendTo to

  $('<div></div>').text("Если оставить ширину или длину дробной - сайт может выглядеть криво из-за ограничений HTML - сложность отрисовки дробных пикселей").appendTo to
  finaldiv = $('<div></div>').appendTo to
  $("<button>").text("save").click(=>
    @_save_site()
  ).appendTo finaldiv
  $("<button>").text("cancel").click(=>
    @Site.layout = lo
    @showLayoutScheme()
    @redraw()
  ).appendTo finaldiv

  @_app_admin_cont.show()




showFontsScheme = `function (){
				var available_fonts_serif = ['Georgia', 'Palatino Linotype', 'Times New Roman'],
					available_fonts_sans= ["Arial", "Arial Black", "Comic Sans MS", "Impact", "Lucida Sans Unicode", "Tahoma", "Trebuchet MS", "Verdana"],
					available_fonts_mono= ["Courier New", "Lucida Console"],
					self = this;

				var to = this._app_admin_contents;
					to.find('*').remove()
					// head sans

					$("<h3>").text("Here's fonts scheme with Sans in headers, Serifs in texts").appendTo(to);

					// D = $("<div>").width(600).css('margin-left',150).css('float', 'left')

					$('<div>').appendTo(to).css('clear', 'both').css('display','none')
					// console.log(hsvToRgb({h:0, s: 50, b:100 } ) )
					$.each(available_fonts_sans, function(i, h){
						$.each(available_fonts_serif, function(i, c){
							var D = $("<div>").width(200).css('margin-left',150).css('float', 'left').height(200).css('overflow','hidden')
							.mouseenter(function(){ $(this).css('background-color', hsvToRgb({h:0, s: 10, b:100 } ) ) })
							.mouseleave(function(){ $(this).css('background-color', hsvToRgb({h:0, s: 0, b:100 } ) ) })
							$("<h3></h3>").css('font-family', h).appendTo(D).text("Header with font " + h)
							$("<p>").css('font-family', c).text(c).appendTo(D)
							$("<p>").css('font-family', c).appendTo(D)
							.text(test_block_content.split(' ').slice(0,39).join(' ') )

							D.appendTo(to).click(function(){
								self.Site.fonts = {header: h, content: c}
								self.redraw()

							})
						} )
					})
					// $("<h3>").text("Here's fonts scheme with Sans in headers, Serifs in texts").appendTo(to);

//					D = $("<div>").width(600).css('margin-left',150).css('float', 'left')
//					.text("Here's fonts scheme with Serifs in headers, Sans in texts").appendTo(to)

					// head serif
					$.each(available_fonts_serif, function(i, h){
						$.each(available_fonts_sans, function(i, c){
							var D = $("<div>").width(200).css('margin-left',150).css('float', 'left').height(200).css('overflow','hidden')
							.mouseenter(function(){ $(this).css('background-color', hsvToRgb({h:0, s: 10, b:100 } ) ) })
							.mouseleave(function(){ $(this).css('background-color', hsvToRgb({h:0, s: 0, b:100 } ) ) })

							$("<h3></h3>").css('font-family', h).appendTo(D).text("Header with font " + h)
							$("<p>").css('font-family', c).text(c).appendTo(D)
							$("<p>").css('font-family', c).appendTo(D)

							.text(test_block_content.split(' ').slice(0,39).join(' ') )

							D.appendTo(to).click(function(){
								self.Site.fonts = {header: h, content: c}
								self.redraw()
							})
						} )
					})

				this._app_admin_cont.show()
			 }`
window.Constructor.showFontsScheme = showFontsScheme




showBackgroundScheme = `function (){
				var to = this._app_admin_contents;
					to.find('*').remove()
					atabs = $('<div>').appendTo(to)
					ul = $("<ul>").appendTo(atabs);
					$("<li>").append($("<a>").prop('href', "#image-pattern" ).text("Узор из картинки") ).appendTo(ul)
					$("<li>").append($("<a>").prop('href', "#constructor-pattern" ).text("Сборка узора") ).appendTo(ul)

					$("<li>").append($("<a>").prop('href', "#css-pattern" ).text('CSS-узор') ).appendTo(ul)

					pic_patt = $("<div>").prop('id',"image-pattern").appendTo(atabs)
					this._show_picture_based_background_list(pic_patt)

					my_patt = $("<div>").prop('id',"constructor-pattern").appendTo(atabs)
					this._show_pattern_editor(my_patt)

					css_patt = $("<div>").prop('id',"css-pattern").appendTo(atabs)
					this._show_css_pattern_editor(css_patt)

					// prod_cont.text("okey")


					//orders_cont = $("<div>").prop('id',"orders").appendTo(atabs)
					// orders_cont.text("O okey")

					atabs.tabs();
				this._app_admin_cont.show()
			 }`
window.Constructor.showBackgroundScheme = showBackgroundScheme




_show_css_pattern_editor = `function (to) {
				 'use strict'
 				var self = this;
 				to.find('*').remove();
 				var control = $('<div>').appendTo(to).width(600).height(400).css('float','left').css('overflow','auto')
 				to.height(400);
 				var preview = $('<div>').appendTo(to).width(400).height(400).css('float','left')

 				$('<span>').text('Мои паттерны').appendTo(control)
 				var pat_cont = $('<div>').width(400).height(300).appendTo(control).css('overflow','auto')
 				$.each(DB.get_objects( 'generic.' + BASE_SITE, 'pattern', {type:'css'}).objects, function(ix, obj){
 					var icon=$('<div>').css('float','left')
						.width(64).height(64)
						.css('margin', '5px')
						.appendTo(pat_cont)
						.css('cursor','pointer')
						.on('mouseenter', function(){})
						.on('click', function(){
								preview.find('*').remove()
								var ch = $('<div>').width('100%').height('100%').appendTo(preview).css('background',"url(/static/images/bar-opacity.png) repeat" )
								var pr = $('<div>').appendTo(ch).width('100%').height('100%')
								self._draw_css_background(pr, obj.image)
						})
						console.log(icon, obj);
						self._draw_css_background(icon, obj.image);

 				})
				function show_control(css_pattern){
					var put_grad = function(){
						preview.find('*').remove()

						var ch = $('<div>').width('100%').height('100%').appendTo(preview).css('background',"url(/static/images/bar-opacity.png) repeat" )
						var pr = $('<div>').appendTo(ch).width('100%').height('100%')
						self._draw_css_background(pr, css_pattern)

					}
					put_grad()

					var grads_cont = $("<div>").appendTo(control)// .width('100%').height('100%');
					$('<div>').css('clear','both').appendTo(control);
					var add_gradient_controls = function(i, grad){
						var grc = $('<div class="grc grc-inactive">').appendTo(grads_cont)
											.css('font-size','5pt')
											.css('width', '100%')
											.css('border', '2px solid grey')
											.css('margin-bottom','10px')
											.css('padding', '20px').on('mouseenter', function(){ $(this).css('border-color','black') })
											.on('mouseleave', function(){ $(this).css('border-color','grey') })
						var g_grad = css_pattern.gradients[i];
						var di, // degree input
							ds, // degree slider
							spec_cont,
							cenli, //center left input
							cenls, // center left slider
							centi, //center top input
							cents, //center top slider
							sizewi, //size width inpur
							sizews, //size width inpur
							sizehi, //size height inpur
							sizehs; //size height inpur

						var appLinear=function(to){
							to.find('*').remove()
							var C = $('<div>').width(150)
												.appendTo(to).css('float','left')
												.css('padding-left','20px') // .css('padding-right','20px');
							$('<span>').text('deg').appendTo(C).css('font-size','10pt').css('margin-right','10px' )
							di = $('<input>').val(g_grad.deg).appendTo(C).width(30).keyup(function(){ console.log($(this).val());var v = parseInt($(this).val());g_grad.deg = v; ds.slider('value',v);put_grad() })
							ds = $("<div>").width(30).slider({min:0, max:360,value:grad.deg, slide:function(event, ui){ g_grad.deg = ui.value ;di.val(ui.value) ;put_grad();}} ).css('display','inline-block' ).appendTo(C)

						}

						var appRadial=function(to){
							to.find('*').remove()

							var C = $('<div>').width(150)
												.appendTo(to).css('float','left')
												.css('padding-left','20px') // .css('padding-right','20px');
							$('<span>').text('left').appendTo(C).css('font-size','10pt').css('margin-right','10px' )
							cenli = $('<input>').val(g_grad.rad_l.v).appendTo(C).width(30).keyup(function(){
							  //console.log($(this).val());
							  var v = parseInt($(this).val());g_grad.rad_l.v = v; cenls.slider('value',v);put_grad() })
							cenls = $("<div>").width(30).slider({min:0, max:360,value:g_grad.rad_l.v, slide:function(event, ui){ g_grad.rad_l.v = ui.value ;cenli.val(ui.value) ;put_grad();}} ).css('display','inline-block' ).appendTo(C)
							$('<select>').appendTo(C).append($('<option>').text('%').val('%')).append( $('<option>').text('px').val('px')).change(function(){g_grad.rad_l.m = $(this).val();put_grad(); })

							var C = $('<div>').width(150)
												.appendTo(to).css('float','left')
												.css('padding-left','20px') // .css('padding-right','20px');
							$('<span>').text('top').appendTo(C).css('font-size','10pt').css('margin-right','10px' )
							centi = $('<input>').val(g_grad.rad_t.v).appendTo(C).width(30).keyup(function(){
							//console.log($(this).val());
							var v = parseInt($(this).val());g_grad.rad_t.v = v; cents.slider('value',v);put_grad() })
							cents = $("<div>").width(30).slider({min:0, max:360,value:grad.rad_t.v, slide:function(event, ui){ g_grad.rad_t.v = ui.value ;centi.val(ui.value) ;put_grad();}} ).css('display','inline-block' ).appendTo(C)
							$('<select>').appendTo(C).append($('<option>').text('%').val('%')).append( $('<option>').text('px').val('px')).change(function(){g_grad.rad_t.m = $(this).val();put_grad(); })



							var C = $('<div>').width(150)
												.appendTo(to).css('float','left')
												.css('padding-left','20px') // .css('padding-right','20px');
							$('<span>').text('width').appendTo(C).css('font-size','10pt').css('margin-right','10px' )
							sizewi = $('<input>').val(g_grad.rad_w.v).appendTo(C).width(30).keyup(function(){
							//console.log($(this).val());
							var v = parseInt($(this).val());g_grad.rad_w.v = v; sizews.slider('value',v);put_grad() })
							sizews = $("<div>").width(30).slider({min:0, max:360,value:grad.rad_w.v, slide:function(event, ui){ g_grad.rad_w.v = ui.value ;sizewi.val(ui.value) ;put_grad();}} ).css('display','inline-block' ).appendTo(C)
							$('<select>').appendTo(C).append($('<option>').text('%').val('%')).append( $('<option>').text('px').val('px')).change(function(){g_grad.rad_w.m = $(this).val();put_grad(); })

							var C = $('<div>').width(150)
												.appendTo(to).css('float','left')
												.css('padding-left','20px') // .css('padding-right','20px');
							$('<span>').text('height').appendTo(C).css('font-size','10pt').css('margin-right','10px' )
							sizehi = $('<input>').val(g_grad.rad_h.v).appendTo(C).width(30).keyup(function(){
							//console.log($(this).val());
							var v = parseInt($(this).val());g_grad.rad_h.v = v; sizehs.slider('value',v);put_grad() })
							sizehs = $("<div>").width(30).slider({min:0, max:360,value:grad.rad_h.v, slide:function(event, ui){ g_grad.rad_h.v = ui.value ;sizehi.val(ui.value) ;put_grad();}} ).css('display','inline-block' ).appendTo(C)
							$('<select>').appendTo(C).append($('<option>').text('%').val('%')).append( $('<option>').text('px').val('px')).change(function(){g_grad.rad_h.m = $(this).val();put_grad(); })


						}
						var C = $('<div>').width(50).appendTo(grc).css('padding-left','20px').css('padding-right','20px');
						var sel =$('<select>').appendTo(C)
						// Exclude radial gradients for now
						$.each(['linear'], function(_,t){$('<option>').text(t).val(t).appendTo(sel) })
						sel.val(grad.type).change(function(){
							g_grad.type = $(this).val();
							if (g_grad.type =='radial'){
								delete g_grad['deg']
								di.parent().remove()
								var b = ['rad_l','rad_t','rad_w','rad_h'];
								for (i=0; i<b.length; i++){
									g_grad[b[i]] = {v:1, m:'px'}
								}

								appRadial(spec_cont)
							}else{
								var a = [cenli, centi,sizewi,sizehi];
								var b = ['rad_l','rad_t','rad_w','rad_h'];
								for (i=0; i<a.length; i++){
									_c = a[i];
									_c.remove();
									delete g_grad[b[i]]
								}
								g_grad.deg = 0
								appLinear(spec_cont)

							}
							put_grad()

						})



						var wi, ws, C = $('<div>').width(150)
											.appendTo(grc).css('float','left')
											.css('padding-left','20px') // .css('padding-right','20px');
						$('<span>').text('W').appendTo(C).css('font-size','10pt').css('margin-right','10px' )
						wi = $('<input>').val(g_grad.size[0].v).appendTo(C).width(30).keyup(function(){ var v = parseInt($(this).val());g_grad.size[0].v = v; ws.slider('value',v);put_grad() })
						ws = $("<div>").width(30).slider({min:0, max:100,value:grad.size[0].v, slide:function(event, ui){ g_grad.size[0].v = ui.value ;put_grad(); wi.val(ui.value)}} ).css('display','inline-block' ).appendTo(C)
						$('<select>').appendTo(C).append($('<option>').text('%').val('%')).append( $('<option>').text('px').val('px')).change(function(){g_grad.size[0].m = $(this).val();put_grad(); })

						var hi, hs, C = $('<div>').appendTo(grc).width(150)
											.appendTo(grc).css('float','left')
											.css('padding-left','20px') // .css('padding-right','20px');
						$('<span>').text('H').appendTo(C).css('font-size','10pt').css('margin-right','10px' )
						hi = $('<input>').val(g_grad.size[1].v).appendTo(C).width(30).keyup(function(){ var v = parseInt($(this).val());g_grad.size[1].v = v; hs.slider('value',v);put_grad() })
						hs = $("<div>").width(30).slider({min:0, max:100,value:grad.size[1].v, slide:function(event, ui){ g_grad.size[1].v = ui.value; hi.val(ui.value) ;put_grad();}} ).css('display','inline-block' ).appendTo(C)
						$('<select>').appendTo(C).append($('<option>').text('%').val('%')).append( $('<option>').text('px').val('px')).change(function(){g_grad.size[1].m = $(this).val();put_grad(); })

						var li,ls, C = $('<div>').appendTo(grc).width(200)
											.appendTo(grc).css('float','left')
											.css('padding-left','20px') // .css('padding-right','20px');
						$('<span>').text('L').appendTo(C).css('font-size','10pt').css('margin-right','10px' )
						li = $('<input>').val(g_grad.pos[0].v).appendTo(C).width(30).keyup(function(){ var v = parseInt($(this).val());g_grad.pos[0].v = v; ls.slider('value',v);put_grad() })
						ls = $("<div>").width(60).slider({min:-100, max:100,value:grad.pos[0].v, slide:function(event, ui){ g_grad.pos[0].v = ui.value ;li.val(ui.value) ;put_grad();}} ).css('display','inline-block' ).appendTo(C)
						$('<select>').appendTo(C).append($('<option>').text('%').val('%')).append( $('<option>').text('px').val('px')).change(function(){g_grad.pos[0].m = $(this).val();put_grad(); })

						var ti, ts, C = $('<div>').appendTo(grc).width(200)
											.appendTo(grc).css('float','left')
											.css('padding-left','20px') // .css('padding-right','20px');
						$('<span>').text('T').appendTo(C).css('font-size','10pt').css('margin-right','10px' )
						ti = $('<input>').val(g_grad.pos[1].v).appendTo(C).width(30).keyup(function(){ var v = parseInt($(this).val());g_grad.pos[1].v = v; ts.slider('value',v);put_grad() })
						ts = $("<div>").width(60).slider({min:-100, max:100,value:grad.pos[1].v, slide:function(event, ui){ g_grad.pos[1].v = ui.value ;ti.val(ui.value) ;put_grad();}} ).css('display','inline-block' ).appendTo(C)
						$('<select>').appendTo(C).append($('<option>').text('%').val('%')).append( $('<option>').text('px').val('px')).change(function(){g_grad.pos[1].m = $(this).val();put_grad(); })

						$('<div>').css('clear','both').appendTo(grc);

						spec_cont = $('<div>').appendTo(grc);
						if(grad.type == 'linear'){
							appLinear(spec_cont)
						}else{
							appRadial(spec_cont)
						}
						$('<div>').css('clear','both').appendTo(grc);
						var stops_cont =$('<div class="stops-cont">').appendTo(grc)

						$('<div>').css('clear','both').appendTo(grc);
						$("<button>").button().text('remove gradient').appendTo(grc).click(function(){
							if(css_pattern.gradients.length <2){
								alert('в узоре должен быть хотя бы один градиент')
								return ;
							}
							css_pattern.gradients.splice(i,1);
							grc.remove();
							put_grad();
							//console.log(css_pattern)
						})

						var expand = function(evt){
							if ($(this).hasClass('grc-inactive')){

								$(this).parent().find('.grc').addClass('grc-inactive')
								$(this).removeClass('grc-inactive')
								$(this).parent().find('.grc-inactive ul.-stops').remove()

								var stops = $('<ul class="-stops">').appendTo(stops_cont)
								var add_stop_controls=function(i, stop){
									var li = $('<li>').appendTo(stops);
									var ai,as;
									var g_stop = g_grad.stops[i]
									$('<div>').width(32).height(32).css('background', "url(/static/images/bar-opacity.png) repeat")
									.css('border', '1px solid black').appendTo(li)
									.css('display','inline-block')
									.append($('<div>').width(32).height(32).css('background-color', hsvToRgb(g_stop.col) )
									.click(function(evt){
										var butt = $(this);
										var fc = function(col, smt, hsva ){
											// console.log(col, smt, hsva)
											g_stop.col = hsva;
											butt.css('background-color', hsvToRgb(hsva))
											if(ai){ai.val(hsva.a*100)}
											if(as){as.slider('value',hsva.a*100)}
											put_grad();
										}
										var ch = self.draw_color_chooser(fc)
										ch.appendTo($('#controls')).position({of:evt, my:'top left', at:'top left'})
									}))
									var ci,cs;
									$('<span>').text('T').appendTo(li).css('font-size','10pt').css('margin-right','10px' )
									ci = $('<input>').val(stop.size.v).appendTo(li).width(30).keyup(function(){ var v = parseInt($(this).val());g_stop.size.v = v; cs.slider('value',v);put_grad() })
									cs = $("<div>").width(30).slider({min:0, max:100,value:stop.size.v, slide:function(event, ui){ g_stop.size.v = ui.value ;ci.val(ui.value) ;put_grad();}} ).css('display','inline-block' ).appendTo(li)
									$('<select>').appendTo(li).append($('<option>').text('%').val('%')).append( $('<option>').text('px').val('px')).change(function(){g_stop.size.m = $(this).val();put_grad(); })

									var ai,as;
									$('<span>').text('A').appendTo(li).css('font-size','10pt').css('margin-right','10px' )
									ai = $('<input>').val(stop.col.a*100).appendTo(li).width(30).keyup(function(){ var v = parseInt($(this).val());g_stop.col.a = v/100; as.slider('value',v);put_grad() })
									as = $("<div>").width(30).slider({min:0, max:100,value:stop.col.a*100, slide:function(event, ui){ g_stop.col.a = ui.value/100 ;ai.val(ui.value) ;put_grad();}} ).css('display','inline-block' ).appendTo(li)

									$('<button>').button().text('Remove color').appendTo(li).click(function(){
										if(g_grad.stops.length <= 2){
											alert('cannot remove color stop. Needed at least two color stops to render gradient')
										}else{
											g_grad.stops.splice(i,1);
											li.remove();
											put_grad();

										}

									})

								}
								$.each(g_grad.stops, function(i, stop){
									add_stop_controls(i,stop)
								})
								$('<button>').text('Добавить цвет').appendTo(stops_cont).click(function(){
									var abc = {col:{h:10,s:0, v:100, a:1 } , size: {v:0,m:'%'} };
									g_grad.stops.push(abc)
									add_stop_controls(g_grad.stops.length-1, abc)
									put_grad();
								})
							}

						}
						grc.on('click', expand);

					}
					$.each(css_pattern.gradients, function(i,grad){
						add_gradient_controls(i, grad)
					})

					$("<div>").appendTo(control).append($('<button>').text('Добавить градиент').click(function(){
						var abc = {type:'linear', deg:90, size:[{v:100,m:'%'}, {v:100,m:'%'}],pos:[{v:0,m:'%'},{v:0,m:'%'}], stops:[{col:{h:10,s:0, v:100, a:0.5 } , size: {v:0,m:'%'} },
																																	{col:{h:10,s:100, v:0, a:0.5 }, size: {v:100,m:'%'} }]}
						css_pattern.gradients.push(abc)
						add_gradient_controls(css_pattern.gradients.length-1, abc)
						put_grad();
					})).append($('<button>').text('Сохранить').click(function(){
						// var ready_image = S[0].toDataURL("image/png")
						var pattern = {image:css_pattern, type: 'css' }
						DB.save_object('generic.'+BASE_SITE, 'pattern', pattern,function(){}, function(){})
						self._show_css_pattern_editor(to)
					})).append($('<button>').text('Отменить').click(function(){

						self._show_css_pattern_editor(to)
					}))

				}

				$('<button>').appendTo(control).text('Новый').click(function(){
					control.find('*').remove()

					var css_pattern = {gradients:[]
											  };
					show_control(css_pattern)



				})

 			}`
window.Constructor._show_css_pattern_editor = _show_css_pattern_editor



_show_pattern_editor = `function (to){
				var self = this;
				to.find('*').remove();
				var control = $('<div>').appendTo(to).width(290).height(400).css('float','left').css('overflow','auto')
				to.height(400);
				var preview = $('<div>').appendTo(to).width(605).height(400).css('float','left')

				$('<span>').text('Мои паттерны').appendTo(control)
				var pat_cont = $('<div>').width(400).height(300).appendTo(control).css('overflow','auto')
				$.each(DB.get_objects('generic.' + BASE_SITE, 'pattern', {type:'constructor'}).objects, function(ix, obj){
					// console.log(ix, obj)
					$('<div>').css('float','left')
							  .css('background', 'url(' + obj.image+')')
							  .css('background-size', '32px 32px')
							  .width(32).height(32)
							  .css('margin', '5px').appendTo(pat_cont)
							  .css('cursor','pointer')
							  .on('mouseenter', function(){})
							  .on('click', function(){
								  preview.find('*').remove();
								  var prev = $('<div>').width('100%').height('100%').appendTo(preview)
								  prev.css('background', 'url(' + obj.image+')')
							  })

				})

				var show_control = function (args) {
					control.find('*').remove()
					preview.find('*').remove()

					var my_patt = $('<div>').appendTo(control);



					var flright = $('<div>').appendTo(preview) .css('float','left')
											// .css('padding', 10)
											.width(300)
											.height(300)
											.css('border', '1px solid black')
											.css('background',  "url(/static/images/bar-opacity.png) repeat")
					var prev = $('<div>').appendTo(preview).css('float','left')
											.width(300)
											.height(300)
											.css('border', '1px solid black')
											.css('background',  "url(/static/images/bar-opacity.png) repeat")



					var Cjq = $('<canvas>').appendTo(flright)
					var C   = Cjq[0]
					var S = $('<canvas>')[0] //.appendTo(flright)[0]
					var ctx = C.getContext('2d')


					var sctx = S.getContext('2d')
					var base = 128;
					// var WA = 0, HA = 0,
					var A  = 0;
					var GA = 1;
					//  iWA = true, iHA = true;
					var Z = 0.25 // 0.08;
					var opacity;
					self._make_pallette()

					var BG = {v:1, ix:3},//this.Site.colors.pallette[0][3]
						FG = {v:1, ix:0};// this.Site.colors.pallette[0][0]



					var result, image, buffData, library_ix = false;

					function redraw_ctx(){
						Cjq .css('margin-left', (300 - base) / 2)
							.css('margin-top', (300 - base) / 2 );
						C.width = base
						C.height = base

						var iw = image.width * Z;
						var ih = image.height * Z;

						function dr_im(x,y,bx,by){


							ctx.save()
							ctx.translate(x, y)
							ctx.scale(Z,Z)
							rad = A* (3.14/180)
							ctx.rotate(rad)
							ctx.globalAlpha = opacity / 100;
							ctx.drawImage(image, -(iw/2), -(ih/2), iw, ih)
							ctx.restore()
						}

						if (BG){
							//console.log(BG)
							if ('ix' in BG){
								c = self.get_color(BG)
							}else{
								c = BG
							}
							c.a = GA;
							ctx.fillStyle =	 hsvToRgb(c)// "rgba( 255,255, 255, 255)";
						}
						ctx.rect(0,0, C.width, C.height)
						ctx.fill()
						ctx.save()
						ctx.clip();

						dr_im(base/2, base/2)

						dr_im(0, 0)
						dr_im(0, base)
						dr_im(base, 0)
						dr_im(base, base)
						ctx.closePath();
						ctx.restore()

						var img = C.toDataURL()
						prev.css('background', 'url(' + img + ') repeat' );

					}
					make_image = function(){

						img = new Image()
						img.onload = function(){
							exc_color(img)

						}
						img.src = result
					}
					var exc_color = function (img_) {
						S.width = img_.width
						S.height = img_.height
						sctx.drawImage(img_,0,0)
						buffData = sctx.getImageData(0,0, img_.width, img_.height)
						if( 'ix' in FG){
							var c = self.get_color(FG)
						}else { var c = FG}

							//}
						FGA = hsvToRgb(c, true)
						alphas = {};
						for(x =0; x<buffData.width; x++){
							for(y=0; y <buffData.height; y++){
								ix = (x+ ( y* buffData.width ))*4
								buffData.data[ix] = FGA[0]; //red
								buffData.data[ix+1] = FGA[1]; //green
								buffData.data[ix+2] = FGA[2]; //blue
							}

						}
						console.log(alphas)
						sctx.putImageData(buffData, 0,0)
						var du = S.toDataURL();
						_I = new Image()
						_I.onload = function(){
							image = _I
							redraw_ctx();
						}
						_I.src = du;
					}


					$('<span>').text('Элемент узора').appendTo(my_patt)
					var img_cont = $('<div>').width(290).height(100).css('overflow','auto').appendTo(my_patt);

					console.log("ICONS", back_icons_urls);
					$.each(back_icons_urls, function(i,url){

						$(new Image()).one('load', function(){
							// console.log("fdfdf", this);
							var img_self = this;
							//var img = scaleImage(this, 64, 64);
							$('<div>').css('float','left').width(64).height(64)
							.css('border', '2px solid black')
							.css('background', 'url(' + this.src + ') no-repeat' )
							.css('background-size', '64px 64px')
							.css('margin', '5px')
							// .append($(img))
							.appendTo(img_cont)
							.on('mouseenter', function(){ $(this).css('border-color','black') })
							.on('mouseleave', function(){ $(this).css('border-color','grey') })

							// $(this)
							.on('click', function(){
								//console.log("CLICK", )
								exc_color( img_self );
								//redraw_ctx();
								//make_image();
							})

						}).prop('src', url);

					})


					$('<input>').prop('type', 'file').change(function(){
						fr = new FileReader()
						fr.onload = function(){
							result = this.result;
							make_image();
						}
						fr.readAsDataURL(this.files[0]);
					}).appendTo(my_patt);

					choose_bg = function(col, ix, hsva ){
						//if (col != 'clear'){
						//	BG =
						//}else{
						//	BG = false
						//}
						BG = hsva
						redraw_ctx()
					}
					choose_fg = function(col, ix, hsva ){
						//if (col != 'clear'){
						FG = hsva
						exc_color(image);

							//}else{
							//FG = false
							//}
						redraw_ctx()
					}
					ul = $('<li>').appendTo(my_patt)

					$('<button>').click(function(e){ self.draw_color_chooser( choose_bg ).appendTo(my_patt) }).appendTo(my_patt).text("Background")
					$('<button>').click(function(e){ self.draw_color_chooser( choose_fg ).appendTo(my_patt) }).appendTo(my_patt).text("Foreground")

					var li = $('<li>').appendTo(ul)
					$('<span>').text('Угол поворота узора').appendTo(li)
					$("<div>").width(250).slider({min:0, max:360,value:0, slide:function(event, ui){ A = ui.value ;redraw_ctx()}} ).appendTo(li)

					var li = $('<li>').appendTo(ul)
					$('<span>').text('Размер узора').appendTo(li)
					$("<div>").width(250).slider({min:1, max:100,value:Z*100, slide:function(event, ui){ Z = (ui.value)/100 ;redraw_ctx()}} ).appendTo(li)

					var li = $('<li>').appendTo(ul)
					$('<span>').text('Размер тайла').appendTo(li)
					$("<div>").width(250).slider({min:64, max:300,value:base, slide:function(event, ui){ base = ui.value ;redraw_ctx()}} ).appendTo(li)

					var li = $('<li>').appendTo(ul)
					$('<span>').text('Прозрачность узора').appendTo(li)
					$("<div>").width(250).slider({min:0, max:100,value:100, slide:function(event, ui){ opacity = ui.value ;redraw_ctx()}} ).appendTo(li)

					var li = $('<li>').appendTo(ul)
					$('<span>').text('Прозрачность фона').appendTo(li)
					$("<div>").width(250).slider({min:0, max:100,value:GA*100, slide:function(event, ui){ GA = ui.value/100 ;redraw_ctx()}} ).appendTo(li)






				$("<div>").appendTo(control)//.append()
				 .append($('<button>').text('Сохранить').click(function(){
					var ready_image = C.toDataURL("image/png")
					var pattern = {image:ready_image, type: 'constructor' }

					DB.save_object('generic.'+BASE_SITE, 'pattern', pattern,function(){}, function(){})

					self._show_pattern_editor(to)
				})).append($('<button>').text('Отменить').click(function(){

					self._show_pattern_editor(to)
				}))
			}


			$('<button>').appendTo(control).text('Новый').click(function(){
				control.find('*').remove()

				//var css_pattern = {gradients:[]
										  	// };
				show_control()



			})

			}`
window.Constructor._show_pattern_editor = _show_pattern_editor





_show_picture_based_background_list = `function (to){
				var self = this;
				to.find('*').remove();
				var control = $('<div>').appendTo(to).width(400).height(400).css('float','left').css('overflow','auto')
				to.height(400);
				var preview = $('<div>').appendTo(to).width(400).height(400).css('float','left')

				$('<span>').text('Мои паттерны').appendTo(control)
				var pat_cont = $('<div>').width(400).height(300).appendTo(control).css('overflow','auto')
				$.each(DB.get_objects('generic.' + BASE_SITE,'pattern',{type:'image'}).objects, function(ix, obj){
					// console.log(ix, obj)
					if (obj.image.blob){
						var url = DB.get_blob_url(obj.image)
					}else{
						var url = obj.image;
					}

					$('<div>').css('float','left')
							  .css('background', 'url(' + url +')')
							  .css('background-size', '64px 64px')
							  .css('border', '2px solid grey')
							  .width(64).height(64)
							  .css('margin', '5px').appendTo(pat_cont)
							  .css('cursor','pointer')
							  .on('mouseenter', function(){ $(this).css('border-color','black') })
							  .on('mouseleave', function(){ $(this).css('border-color','grey') })

							  .on('click', function(){
								  preview.css('background', 'url(' + obj.image+')')
							  })

				})


			 	// First - picture template based
				$('<input>').prop('type','file').change(function(){
					var fr = new FileReader()
					fr.onloadend = function(){
						"use strict";

						var result = this.result;

						control.find('*').remove()

						var C = $('<canvas>')// .appendTo(control)
						var S = $('<canvas>')// .appendTo()
						var sctx = S[0].getContext('2d')

						var img = new Image()
						img.onload = function(){
							// // // console.log (img.width, img.height);
							var canv_div = $('<div>').width(400).height(150).css('overflow','auto').appendTo(control)
							C.appendTo( canv_div )
							C[0].width = img.width;
							C[0].height = img.height;
							C.css('border', '1px solid black')
							var ctx = C[0].getContext('2d')

							var R = {left:0,top:0, width:img.width, height:img.height}

							$("<button>").appendTo(control).text("Сохранить").click(function(){
								var ready_image = S[0].toDataURL("image/png")
								var pattern = {image:ready_image, type: 'image' }
								DB.save_object('generic.' +BASE_SITE, 'pattern', pattern,function(){}, function(){})
								self._show_picture_based_background_list(to)

							})
							$("<button>").appendTo(control).text("Отменить").click(function(){
								self._show_picture_based_background_list(to)
							})

							var _fpreview =  function(){
								var ready_image = S[0].toDataURL("image/png")
								preview.css('background-image','url("' + ready_image +' ")').css('background-repeat','repeat')


							}

							function redraw(st){
								ctx.clearRect(0,0,img.width,img.height)
								ctx.drawImage(img,0,0);
								S[0].width = R.width;
								S[0].height = R.height;

								sctx.drawImage(img,-R.left,-R.top)


								ctx.strokeStyle = 'rgba(128,128,0, 1)';
								ctx.fillStyle =	 'rgba(0,0,0, 0.7)';
								ctx.lineWidth = 2;
								ctx.beginPath();
								ctx.rect(R.left, 0, img.width - R.left, R.top);
								ctx.rect(R.left+R.width, R.top, img.width-R.width-R.left, img.height -R.top);

								ctx.rect(0, (R.top+R.height), R.left + R.width, img.height -R.top -R.height);

								ctx.rect(0, 0, R.left, R.height + R.top);

								ctx.fill();
								ctx.closePath();
								if (st){
									if (st.point){
										ctx.strokeStyle = 'rgba(255,255,255, 1)';
										ctx.fillStyle =	 'rgba(0,0,0, 0.7)';
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
								_fpreview();
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
									var line_left = Math.min(line.begin.left, line.end.left)
									var line_right = Math.max(line.begin.left, line.end.left)

									return	(cx > line_left && cx < line_right) && Math.abs(line.begin.top - cy ) < thresh
								}else{
									var line_top = Math.min(line.begin.top, line.end.top)
									var line_bottom = Math.max(line.begin.top, line.end.top)
									return	(cy > line_top && cy < line_bottom) && Math.abs(line.begin.left - cx ) < thresh
								}

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
														gline.begin.left =	gline.end.left = R.width + R.left;
														redraw(gline);
														return;
													case 'b':
														R.height += diff.top;
														gline.begin.top =gline.end.top = R.height + R.top;
														redraw(gline);
														return;
													case 'l':
														R.left += diff.left;
														R.width -= diff.left;
														gline.begin.left =	gline.end.left = R.left;
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
									for(var p in points){
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

									for(var l in lines){
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
					 ext = this.files[0].type.split('/')[1]

					 if(['jpeg','png','gif'].indexOf(ext) != -1 ){
						 fr.readAsDataURL(this.files[0]);
						 $(this).remove()

					 }else{
						 alert('Принимаются только изображения')
					 }


					}).appendTo(control);






			}`
window.Constructor._show_picture_based_background_list = _show_picture_based_background_list




addPage = `function (is_removable, is_menu_item, title, name, expected_parameters){
				var amount = 0
				for (k in this.Site.pages){amount += 1};

				if (typeof name == 'undefined'){
					slug = "Untitled_page_" + (amount + 1);
					title = "Untitled page " + (amount + 1)

				}else{
					slug = name
					title = title
				}
				if (expected_parameters){
					// expected parameters
					// {parameter: default_value}
				}
				var newPage = {title: title,
								 blocks :[],
								 removable: is_removable,
								 show_in_menu: is_menu_item,
								 layout : 'same',
								 params: expected_parameters,
								 order: amount + 1}
				this.Site.pages[slug] = newPage;
				//

			}`
window.Constructor.addPage = addPage




deletePage = `function (name){
				delete this.Site.pages[name] ;
				this.redraw_cp(1);

			}`
window.Constructor.deletePage = deletePage



downPage = `function (name) {
				var ix = this.Site.pages[name].order

				this.Site.pages[name].order = ix + 1

				var subst = this.page_order_index[ix+1]
				//console.log(name, subst, this.page_order_index)
				var ix_s = this.Site.pages[subst].order
				this.Site.pages[subst].order = ix_s -1
				this._save_site();
				this.load_site()
				this.redraw_cp(1);
			}`
window.Constructor.downPage = downPage




upPage = `function (name) {
				var ix = this.Site.pages[name].order
				//new_order = ix-1
				this.Site.pages[name].order = ix-1


				var subst = this.page_order_index[ix-1]
				//console.log(name, subst, this.page_order_index)
				var ix_s = this.Site.pages[subst].order
				// new_order_subst = ix_s +1
				this.Site.pages[subst].order = ix_s +1
				this._save_site();

				this.load_site()
				this.redraw_cp(1);
			}`
window.Constructor.upPage = upPage


###
showUserScheme = `function () {
				// Сначала, мы должны отобразить всех пользователей, который авторизованы для этого сайта
				// Потом мы должны отобразить все роли, которыми располагают приложения
				// Потом мы должны создать возможность давать приглашения пользователям чтобы редактировать наш сайт

				// this._app_admin_contents = $('<div>').appendTo(this._app_admin_cont)

				var self = this;
				var dialog = $('<div>').appendTo('#controls')
				.dialog({title:'Назначение ролей другим пользователям',
						 buttons:{'Пригласить другого пользователя':function(){
							 			var invited = $('<div>').appendTo($('#controls'));
										$('<input>').addClass('email').appendTo(invited)
							 			invited.dialog({width:400, height:200, buttons:{'Пригласить': function () {
										var email = invited.find('input.email').val()
										var my_hostname = window.location.host
										var ID= DB.save_object_sync('generic.' + BASE_SITE, 'invite', {'email': email, 'to': my_hostname, is_unique:true})
										// console.log(ID);
										DB.send_email(email, 'invite to access ' + my_hostname,
															"this is invite to take part in be-web.ru project http://" + my_hostname +
															". You can create your account <a href='http://be-web.ru/register/'>here</a>" )

															self.Site.Roles.push({user: email, roles: [] })
															self._save_site()
															invited.dialog('close')
															self.showUserScheme();
															invited.dialog('close')

							 			}


						 				}
									})

							 			console.log('inviting')
									},
									'Закрыть': function(){ dialog.dialog('close') },
									'Применить': function(){
										self._save_site();
									}
					 			},

						 width:600, height:500})

				$.each( this.Site.Roles , function(ix, obj){
					var user= obj.user
					var ROLES = obj.roles

					// console.log(user, ROLES)
					var user_control = $('<div>').appendTo(dialog).css('border','1px solid black').addClass('inactive users')
					var expand = function(evt){
						if ($(this).hasClass('inactive')){
							$(this).parent().find('.users').addClass('inactive')
							$(this).removeClass('inactive')
							$(this).parent().find('inactive ul.-stops').remove()
							var ul = $('<ul>').appendTo($(this)).addClass('-stops');
							var add_group_controls=function(_ix, app ){
								log("check app_name", _ix, app)
								for (var i=0; i < app.roles.length; i++){
									var role;
									role = app.roles[i] + '#' + _ix
									// log("INSERTING ROlES",app.roles[i], app.default_role)

									if(app.roles[i] != app.default_role){
										var li = $("<li>").appendTo(ul);
										var ch = $('<input >').prop('id','id_ch_'+role)
														  .prop('type','checkbox').appendTo(li)
														  .click(function(evt){
															  var is_on = $(this).prop('checked')
															  if (is_on){
																  self.Site.Roles[ix].roles.push(role)

															  }else{
																  var ixxx = self.Site.Roles[ix].roles.indexOf(role)
																  self.Site.Roles[ix].user.splice(ixxx,1)
															  }

														  })
										var lch = $('<label>').prop('for','id_ch_'+role)
														  .prop('type','checkbox').appendTo(li).text(role)
										log("WHAT ?,", role, ROLES);
										if(ROLES.indexOf(role) != -1){
											ch.prop('checked', true)
										}

									}
								}
							}
							$.each( self.Site.Applications , add_group_controls)
						}

					}
					user_control.text(user)
					user_control.on('click', expand);

				})

			}`
###
window.Constructor.showUserScheme = ->

  # Сначала, мы должны отобразить всех пользователей, который авторизованы для этого сайта
  # Потом мы должны отобразить все роли, которыми располагают приложения
  # Потом мы должны создать возможность давать приглашения пользователям чтобы редактировать наш сайт

  # this._app_admin_contents = $('<div>').appendTo(this._app_admin_cont)
  self = this
  dialog = $("<div>").appendTo("#controls").dialog(
    title: "Назначение ролей другим пользователям"
    buttons:
      "Пригласить другого пользователя": ->
        invited = $("<div>").appendTo($("#controls"))
        $("<input>").addClass("email").appendTo invited
        invited.dialog
          width: 400
          height: 200
          buttons:
            "Пригласить": ->
              email = invited.find("input.email").val()
              my_hostname = window.location.host
              DB.save_object_sync("generic." + BASE_SITE, "invite",
                email: email
                to: my_hostname
                is_unique: true
              )

              DB.send_email email, "invite to access " + my_hostname, "this is invite to take part in be-web.ru project http://" + my_hostname + ". You can create your account <a href='http://be-web.ru/register/'>here</a>"
              self.Site.Roles.push
                user: email
                roles: []

              self._save_site()
              invited.dialog "close"
              self.showUserScheme()
              invited.dialog "close"

        # console.log "inviting"

      "Закрыть": ->
        dialog.dialog "close"

      "Применить": ->
        self._save_site()

    width: 600
    height: 500
  )
  #log "SITE ROLES", @Site.Roles
  if not  @Site.Roles?
    $("<div>").appendTo(dialog).text("Чтобы управлять пользователями надо сначала сохранить сайт хотя бы один раз")
  else
    $.each @Site.Roles, (ix, obj) ->
      user = obj.user
      ROLES = obj.roles

      # console.log(user, ROLES)
      user_control = $("<div>").appendTo(dialog).css("border", "1px solid black").addClass("inactive users")
      expand = (evt) ->
        if $(this).hasClass("inactive")
          $(this).parent().find(".users").addClass "inactive"
          $(this).removeClass "inactive"
          $(this).parent().find("inactive ul.-stops").remove()
          ul = $("<ul>").appendTo($(this)).addClass("-stops")
          add_group_controls = (_ix, app) ->
            #log "check app_name", _ix, app
            i = 0

            while i < app.roles.length
              role = undefined
              role = app.roles[i] + "#" + _ix

              # log("INSERTING ROlES",app.roles[i], app.default_role)
              unless app.roles[i] is app.default_role
                li = $("<li>").appendTo(ul)
                ch = $("<input >").prop("id", "id_ch_" + role).prop("type", "checkbox").appendTo(li).click((evt) ->
                  is_on = $(this).prop("checked")
                  if is_on
                    self.Site.Roles[ix].roles.push role
                  else
                    ixxx = self.Site.Roles[ix].roles.indexOf(role)
                    self.Site.Roles[ix].user.splice ixxx, 1
                )
                lch = $("<label>").prop("for", "id_ch_" + role).prop("type", "checkbox").appendTo(li).text(role)
                # log "WHAT ?,", role, ROLES
                ch.prop "checked", true  unless ROLES.indexOf(role) is -1
              i++

          $.each self.Site.Applications, add_group_controls

      user_control.text user
      user_control.on "click", expand


window.Constructor.showSEOScheme = ->
  self = this
  meta_yandex = undefined
  meta_google = undefined
  sname = undefined
  save_metas = ->

    # console.log('>');
    my = meta_yandex.val()
    mg = meta_google.val()
    sname_ = sname.val()
    if "seo" of self.Site
      self.Site["seo"]["metas"] =
        yandex: my
        google: mg
    else
      self.Site["seo"] = metas:
        yandex: my
        google: mg
    self.Site["seo"]["title"] = sname_

  seod = $("<div>").dialog(
    title: "Оптимизация для поисковых систем"
    width: 500
    height: 400
    buttons:
      "Сохранить": ->
        save_metas()
        self._save_site()
        self.redraw()
  )
  ul = $("<ul>").appendTo(seod)
  li = $("<li>").appendTo(ul)
  $("<span>").text("Наименование сайта (отображается в title)").appendTo li
  sname = $("<input>").appendTo(li).change(->
    save_metas()
  )
  sname.val self.Site["seo"]["title"]  if "seo" of self.Site
  li = $("<li>").appendTo(ul)
  $("<span>").text("Яндекс").appendTo li
  meta_yandex = $("<input>").appendTo(li).change(->
    save_metas()
  )
  meta_yandex.val self.Site["seo"]["metas"]["yandex"]  if "seo" of self.Site and 'metas' of self.Site.seo
  li = $("<li>").appendTo(ul)
  $("<span>").text("Google").appendTo li
  meta_google = $("<input>").appendTo(li).change(->
    save_metas()
  )
  meta_google.val self.Site["seo"]["metas"]["google"]  if "seo" of self.Site and 'metas' of self.Site.seo
  li = $("<li>").appendTo(ul)
  $("<span>").text("Кеширование содержимого - обязательно").appendTo li
  $("<input type=\"button\">").val("Запустить").button().appendTo(li).click ->
    $(this).hide()
    self.caching()
    $(this).show()


window.Constructor.showTextColorScheme = ->

  templ = "
<div>
  <ul>
  <li> Текст <div name ='text_color' style='width:30px; height:20px; background-color:{{ text_color }}; display:inline-block'></div></li>
  <li> Ссылки <div name ='link_color' style='width:30px; height:20px; background-color:{{ link_color }}; display:inline-block'></div></li>
  <li> Посещенные ссылки <div name ='visited_color' style='width:30px; height:20px; background-color:{{ visited_color }}; display:inline-block'></div></li>
  <li> Активные ссылки <div name ='active_color' style='width:30px; height:20px; background-color:{{ active_color }}; display:inline-block'></div></li>
  <li> Ссылка под курсором <div name ='hover_color' style='width:30px; height:20px; background-color:{{ hover_color }}; display:inline-block'></div></li>


</ul>
<p> Могут примениться только после перезагрузки всего сайта это требует его сохранения</p>
</div>
"

  #colors = @getTextColors()
  hsbas = {}
  if @Site.textColors?
    for attr, val of @Site.textColors
      hsbas[attr] = val
  current_cols = @getTextColors()



  ht = Mustache.render(templ, current_cols)
  cold = $("<div>").html(ht)
  cold.find('div[name]').click (e) =>
    col_type = $(e.target).attr('name')
    d =$(e.target)
    setter = (col, ix, hsba) ->
      d.css('background-color', col )
      hsbas[col_type] = {index:ix,rgb:col}
      {}

    color_chooser = @draw_color_chooser setter
    color_chooser.appendTo($('#controls')).position({of:$(e.target), my:'left top', at:'right bottom'})

  #log("SMT")
  cold.dialog(
    title: "Цвет ссылок и текста"
    width: 400
    height: 400
    buttons:
      "Сохранить и перезагрузить": =>
        #log(@)
        @Site.textColors = hsbas
        @_save_site()

        cold.dialog('close')
        window.location.reload()
      "Сохранить без перезагрузки": =>
        #log(@)
        @Site.textColors = hsbas
        @_save_site()
        @redraw()
        cold.dialog('close')

      "Отмена": =>
        @redraw()
        cold.dialog('close')

  )

window.Constructor.backgroundChooser =(type) ->
  self = this

  if @Site.backgrounds?
    old_background = $.extend(true, {}, @Site.backgrounds[type])
  else
    old_background = {}
    @Site.backgrounds = {}
    @Site.backgrounds[type] = {}

  onPattern = (patt) =>
    @Site.backgrounds[type] =
      type: "pattern"
      pattern: patt

    @redraw_background()

  onColor = (color, pal_ix, hsba) ->
    self.Site.backgrounds[type] =
      type: "color"
      color: pal_ix

    self.redraw_background()

  onCancel = ->
    self.Site.backgrounds[type] = old_background
    self.redraw_background()
    $(this).dialog "close"

  onSave = ->
    self.redraw_background()
    self._save_site()
    $(this).dialog "close"

  self.drawBackgroundSelectorDialog onPattern, onColor, onCancel, onSave


window.Constructor.getAppSource = (app_name) ->
  T = """
{
name : "{{name}}",
title:"{{title}}",
roles: {{& roles }},
default_role:'{{default_role}}',
data:{{& data}},
Main: function(constr, appid ){
	   {{& Main.body }}
	},
	getter: function(constr, appid){
	  return this.Main()
	} }
"""
  app = @getAppJson(app_name)
  #app.Main = (new Function(app.Main.attr, app.Main.body)).toString()
  # app.Main = app.Main.body
  app.data = JSON.stringify(app.data) if app.data and app.data?
  app.roles = JSON.stringify(app.roles)
  app.name = app.app_name.split('.')[0]

  result = Mustache.render(T, app)
  #log(result)
  result


window.Constructor.show_CP = (active_tab) ->
  self = this
  C = $("div#controls")
  @cp = $("<div>").appendTo(C).width(360).height(window.innerHeight).css("position", "fixed").css("top", 0).css("left", 0)
  @_app_admin_cont = $("<div>").css("position", "fixed").css("overflow", "scroll").css("top", 0).css("left", 240).width(1100).height(window.innerHeight).css("background", "white").zIndex(2000).appendTo(C).hide()
  $("<div>").css("background", "orange").width(@_app_admin_cont.width()).append($("<button>").text("HIDE").click(->
    self._app_admin_cont.hide()
  )).appendTo @_app_admin_cont
  @_app_admin_contents = $("<div>").appendTo(@_app_admin_cont)
  $("<div>").height(50).width("100%").appendTo(@cp).append $("<button>").button().text("hide").click(->
    self.cp.remove()
    self.CPmarker.show()
  )
  @cp_acc = $("<div>").appendTo(@cp)
  $("<h3>").text("Основные").appendTo @cp_acc
  d = $("<div>").appendTo(@cp_acc)
  ul = $("<ul>").appendTo(d)
  $("<li>").append($("<a>").prop("href", "#").text("Фон сайта").click(->self.backgroundChooser "body")).appendTo ul
  $("<li>").append($("<a>").prop("href", "#").text("Фон центральной части сайта").click(->self.backgroundChooser "content")).appendTo ul
  $("<li>").append($("<a>").prop("href", "#").text("Цветовая схема").click(->
    self.showColorScheme()
  )).appendTo ul
  $("<li>").append($("<a>").prop("href", "#").text("Цвет текста").click(->
    self.showTextColorScheme()
  )).appendTo ul

  $("<li>").append($("<a>").prop("href", "#").text("Создание фонов").click(->
    self.showBackgroundScheme()
  )).appendTo ul
  $("<li>").append($("<a>").prop("href", "#").text("Шрифты").click(->
    self.showFontsScheme()
  )).appendTo ul
  $("<li>").append($("<a>").prop("href", "#").text("Управление геометрией").click(->
    self.showLayoutScheme()
  )).appendTo ul
  $("<li>").append($("<a>").prop("href", "#").text("Управление доменами").click(->
    self.showDomainScheme()
  )).appendTo ul
  $("<li>").append($("<a>").prop("href", "#").text("Управление Ролями и пользователями").click(->
    self.showUserScheme()
  )).appendTo ul
  $("<li>").append($("<a>").prop("href", "#").text("Поисковые системы").click(->
    self.showSEOScheme()
  )).appendTo ul
  $("<li>").append($("<a>").prop("href", "#").text("Сохранение сайта").css("color", "red").click(->
    self._save_site true
  )).appendTo ul
  $("<h3>").text("Мои страницы").appendTo @cp_acc
  d = $("<div>").appendTo(@cp_acc)
  ul = $("<ul>").css("padding", "0").appendTo(d)
  $("<li>").append($("<a>").prop("href", "#").text("Добавить").click(->
    page = undefined
    title = undefined
    kw = undefined
    descr = undefined
    diag = $("<div>").dialog(
      title: "Опции страницы"
      width: 600
      height: 300
      buttons:
        "Сохранить": ->
          self.addPage true, true, title.val(), page.val()
          self._save_site false
          self.redraw_cp 1
          self.redraw()
          diag.dialog "close"
    )
    ul = $("<ul>").appendTo(diag)
    li = $("<li>").appendTo(ul)
    $("<span>").appendTo(li).text "Отображаемое название"
    title = $("<input>").appendTo(li).val("Новая страница")
    li = $("<li>").appendTo(ul)
    $("<span>").appendTo(li).text "slug(англ)"
    amount = 0
    for k of self.Site.pages
      amount += 1
    page = $("<input>").appendTo(li).val("untitled_page_" + amount)
  )).appendTo ul
  pages = $.extend(true, {}, @Site.pages)
  pa = []
  $.each pages, (i, p) ->
    p.slug = i
    pa.push p

  pa.sort (a, b) ->
    a.order - b.order

  $.each pa, (ix, p) ->
    i = p.slug
    li = $("<li>").appendTo(ul)
    unless p.order is 0
      li.append $("<button>").button(icons:
        primary: "ui-icon-arrowthick-1-n"
      ).width(32).height(32).css("margin-left", "5px").css("background-size", "120% 120%").click(->
        self.upPage i
        self.redraw()
      )
    unless (self.page_amount - 1) is p.order
      li.append $("<button>").button(icons:
        primary: "ui-icon-arrowthick-1-s"
      ).width(32).height(32).css("margin-left", "5px").css("background-size", "120% 120%").click(->
        self.downPage i

        #self._save_site()
        self.redraw()
      )
    a = $("<a>").prop("href", "#!" + i).text(p.title).click((e) ->
      window.location.hash = i
      e.preventDefault()
    ).appendTo(li)

    # log('descr', $(this), $(this).val());
    li.append($("<button>").button(icons:
      primary: "ui-icon-pencil"
    ).width(32).height(32).css("margin-left", "20px").css("background-size", "120% 120%").click(->
      page_slug = $("<input>").appendTo(li).val(i).keyup ->

      diag = $("<div>").dialog(
        title: "Опции страницы"
        width: 600
        height: 300
        buttons:
          "Сохранить": ->
            np = $.extend(true, {}, self.Site.pages[i])
            delete self.Site.pages[i]
            ix = page_slug.val()
            self.Site.pages[ix] = np
            self._save_site false
            self.redraw()
            self.redraw_cp 1
      )
      ul = $("<ul>").appendTo(diag)
      li = $("<li>").appendTo(ul)
      $("<span>").appendTo(li).text "Отображаемое название"
      $("<input>").appendTo(li).val(p.title).keyup ->
        self.Site.pages[i].title = $(this).val()

      li = $("<li>").appendTo(ul)
      $("<span>").appendTo(li).text "slug(англ)"
      if i isnt ""
        page_slug.appendTo(li);

      else
        $("<span>").css("color", "red").appendTo(li).text "Не изменяется для главной страницы"

      li = $("<li>").appendTo(ul)
      $("<span>").appendTo(li).text "Ключевые слова через запятую"
      kw = $("<input>").appendTo(li).val(self.Site.pages[i].keywords).keyup(->
        self.Site.pages[i].keywords = $(this).val()
        log self.Site.pages[i]


      )
      li = $("<li>").appendTo(ul)
      $("<span>").appendTo(li).text "Описание страницы"
      descr = $("<textarea>").appendTo(li).val(self.Site.pages[i].description).keyup(->
        self.Site.pages[i].description = $(this).val()
        log self.Site.pages[i]
      )
    )).css "padding-bottom", "10px"
    if self.Site.pages[i].removable
      li.append $("<button>").button(icons:
        primary: "ui-icon-closethick"
      ).width(32).height(32).css("margin-left", "5px").css("background-size", "120% 120%").click(->
        self.deletePage i
        self._save_site()
        self.redraw()
      )

# Applications 3
  app_menu_template = '
<div>
  <ul id="id_app_list">
    {{#apps}}
      <li> <a id="id_open_admin" href="#" app_name={{val.app_name}}>{{ val.title }} </a>{{#val.is_own}} <a class="remove" style="color:red;" href="#" app_name="{{ val.app_name }}" >remove</a> <a class="edit" href="#" app_name="{{ val.app_name }}" >edit</a>{{/val.is_own}}</li>
    {{/apps}}
  </ul>
</div>'
  template_create = '
  <div id = "app_dialog">
    <div id="app_tabs">
    <ul>
      <li> <a href="#source"> Sourcecode         </a></li>
      <li> <a href="#publishing"> Publishing     </a></li>
    </ul>
    <div id="publishing">
      Here is publishing utils
    </div>
    <div id=source>
        <textarea id="id_source_textarea" style="width:600px; height:700px">{{ source }}</textarea>
    </div></div></div>'
  template_searcher = "
    <div id='id_search_dialog'>
      <ul id='my_apps'>
        {{# apps }}
          <li> {{ title }} {{^in_app}} <input class='_add_button' type='button' app_name='{{ app_name }}' value='+'> {{/in_app}}</li>
        {{/apps }}

      </ul>
      <input id='id_app_search_input' />
      <div id='id_search_results'>
      </div>
    </div>
  "
  template_search_results = "
  <ul>
    {{#apps}}
      <li> {{ title }} {{^in_app}}<input class='_add_button' type='button' app_name='{{app_name}}' value='+'>{{/in_app}} </li>
    {{/apps}}
  </ul>
  "


  E = (evt) =>

    app = $(evt.target).attr 'app_name'

    if app?
        source = @getAppSource app
    else
        source = @default_app
    html = Mustache.render(template_create , {source: source } )
    @_app_admin_contents.html html
    @_app_admin_contents.find('#app_tabs').tabs()
    @_app_admin_contents.find('#app_dialog').dialog
      title : "Новое приложение"
      width: 800
      height: 900
      buttons:
        save: ->
          t = editAreaLoader.getValue("id_source_textarea")
          res = eval("(" + t + ")")
          res = JSON.stringify(res, (key, val) ->
            if typeof val is "function"
              fstr = val.toString()
              startBody = fstr.indexOf("{") + 1
              endBody = fstr.lastIndexOf("}")
              body = fstr.substring(startBody, endBody)
              {is_function: true,body: body}
            else val
          )
          #log( typeof res )
          DB.save_application res  # if "Main" of res and "getter" of res and "roles" of res and "data" of res
    editAreaLoader.init
      id: "id_source_textarea"
      syntax: "js"
      start_highlight: true
      replace_tab_by_spaces: 4
  R = (evt) =>

    app = $(evt.target).attr 'app_name'
    if app isnt "generic." + BASE_SITE
      log(@Site.Applications[app])
      if @Site.Applications[app].remove?
        @Site.Applications[app].remove()
      delete @Site.Applications[app]
      ix = @Site._Apps.indexOf(app)
      @Site._Apps.splice(ix,1)
      @_save_site();
      @redraw();
      #log(@Site._Apps)
    #else
    #  log('no delete')

  $("<h3>").text("Приложения").appendTo @cp_acc
  app_menu = $( Mustache.render(app_menu_template, {'apps':({key:k,val:v } for k,v of @Site.Applications )}) )
  @cp_acc.append app_menu
  ul = app_menu.find('#id_app_list')
  app_menu.find('a.edit').click E
  app_menu.find('a.remove').click R

  app_menu.find('a#id_open_admin').css('cursor','pointer').bind 'click', (e)=>
    app_name = $(e.target).attr('app_name')
    app = @Site.Applications[app_name]
    if app.admin_page?
      app.admin_page(self._app_admin_contents);
      self._app_admin_cont.show()



  adder = (e) =>
    app_name = $(e.target).attr 'app_name'
    if app_name not in @Site._Apps
      @Site._Apps.push app_name
      @_save_site();



  SF = (evt) =>
    $.ajax
      url: "/app/list/",
      dataType: "JSON",
      success: (js) =>
        vals = for k in js.apps
          if k.app_name in @Site._Apps
            k['in_app'] = true
          k
        dhtml = Mustache.render(template_searcher, {apps:vals})
        #log(@, @@)
        @_app_admin_contents.html dhtml
        res_cont = @_app_admin_contents.find("#id_search_results")
        @_app_admin_contents.find('._add_button').click adder

        dialog=@_app_admin_contents.find( "#id_search_dialog").dialog
          width:600
          height:600
        dialog.find('#id_app_search_input').bind 'keyup', (e)=>
          val = $(e.target).val()
          $.ajax
            url: "/app/list/"
            data:
              iname: val
            dataType: 'JSON'
            success: (js)=>
              vals = for k in js.apps
                if k.full_name in @Site._Apps
                  k['in_app'] = true
                k

              reshtml = Mustache.render(template_search_results, {apps:vals} )
              res_cont.html reshtml
              res_cont.find('._add_button').click adder



  $("<li>").appendTo(ul).append( $("<a>").prop("href", "#").text("Создать").click (E) )
  $("<li>").appendTo(ul).append( $("<a>").prop("href", "#").text("Найти и добавить").click (SF) )







  $("<h3>").text("Виджеты").appendTo @cp_acc
  d = $("<div>").appendTo(@cp_acc)
  ul = $("<ul>").appendTo(d)
  $.each @Site.Applications, (app_name, app) =>
    if app.widgets
      li = $("<li>").text(app.title).appendTo(ul)
      ul_ = $("<ul>").appendTo(li)
      $.each app.widgets, (name, w) =>
        $("<li>").text(w.title).appendTo(ul_).prop("type", name + "." + app_name).draggable
          scroll: false
          start: ->
          helper: -> $("<div>").text "drag me"
          drag: (event, ui) =>
            left = event.clientX + $(document).scrollLeft() - self._main_offset.left
            top = event.clientY + $(document).scrollTop() - self._main_offset.top
            #log(@)
            ll = @_stepping_left(left)
            tt = @_stepping_top(top)
            @widget_drag_state = {left: ll.block, top: tt.block}
            ui.position =
              top: tt.val - $(document).scrollTop() + self._main_offset.top
              left: ll.val - $(document).scrollLeft() + self._main_offset.left
          stop: (e)=>
            type = $(e.target).prop("type")
            # log("We just stopped",type, @widget_drag_state)
            @add_block @widget_drag_state.left, @widget_drag_state.top, type, w.default_size
            @redraw()




  if active_tab
    @cp_acc.accordion({active: active_tab, heightStyle: "fill"})
  else
    @cp_acc.accordion()


