




caching = `function (){
				var _current_page = this.current_page;
				var hashes = {};
				var self = this;
				var active_renderers = {}
				var is_saved =false

				var body_style = $('body').prop('style')



				var perform_caching = function(){
					if (is_saved){return} // просто выходим - сохранили
					var is_done = true;

					for( i in active_renderers ){
						is_d = !active_renderers[i]
						is_done = is_done && is_d;
					}
					if( is_done ){ // все процессы отработали
						DB.save_cache(hashes)
						is_saved = true
					}else{
						setTimeout(perform_caching, 1000);
					}

				}

				var render_page = function(hash){
					if(hash in hashes){ return }

					active_renderers[hash] = true;
					var custom_cont = $('<div>');
					var custom_head = $('<div>');
					var content, head_content;
					try{
						self.is_constructor = false;
						self.draw(custom_cont, custom_head, hash)
						self.is_constructor = true;
					}finally{
						self.is_constructor = true
						// throw
					}




					setTimeout(function(){
						var content = custom_cont.html();
						var head_content = custom_head.html();
						var link_list = [];
						var as = custom_cont.find('a');
						$.each(as, function(ix, a){
							 var h = "#" + $(a).prop('href').split('#')[1]
							 if(typeof h == 'undefined' || h == 'undefined'){
							 }
							 render_page(h);
						})
						custom_cont.remove();
						var h = $('<html>')
						var b = $('<body>')
						.prop('style', body_style.cssText)
						.html(content).appendTo(h)

						hashes[hash] = {'body':h.html(), head:head_content}
						active_renderers[hash] = false;
					}, 5000)
				}

				render_page("#!");
				perform_caching();



			}`
window.Constructor.caching = caching






_make_pallette = `function (){
				var h =	 this.Site.colors.base,
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
				sat_koef = [0.89, 0.5, 0.5, 0.01];
				br_koef	 = [0.05, 0.05, 0.45 ,0.3];

				colors = [h,a,s,A];

				var greys = new Array();
				am = 5
				for(c =0; c <= am; c++){
					_c = {h:0,s:0, b: c * (100/am),a:1 }
					greys.push(_c)
				}
				this.Site.colors.pallette[0]= greys

				for( col in colors){
					var color = colors[col];
					var vars = [{h:color,s:saturation,b:brightness}];

					if (color){
						for (i in sat_koef){
							ds = saturation * sat_koef[i]
							db = brightness * br_koef[i]

							if (i < 2){ // lights
								dsat = ds * lights /100
								dbri = db* lights /100

							}else{// shadows
								dsat = ds * shadows /100
								dbri = db* shadows /100

							}
								sat = saturation - dsat;
								bri = brightness - dbri;

							vars[Number(i)+1] = {h:color,s:sat, b:bri, a:1}
						}
						this.Site.colors.pallette.push( vars)

					}else{
						this.Site.colors.pallette.push(false) ;
					}
				}
			}`
window.Constructor._make_pallette = _make_pallette
###

_draw_css_background = `function (to, css_pattern) {
				// var preview = to
				var sizes = [];
				var poss  = [];
				var grads = [];
				$.each(css_pattern.gradients, function(ix, grad){
					var stops = [];

					if(grad.stops.length <2){
						// need two color stops at least
						return;
					}
					$.each(grad.stops, function(ix, st){
						var rgba = hsvToRgb(st.col)
						var s = rgba + ' ' + st.size.v + st.size.m;
						stops.push(s);

					})

					if(grad.type == 'linear'){
						var gr = 'linear-gradient('+grad.deg+'deg, ' + stops.join(', ') +')'
					}else{
						var position = grad.rad_w.v + grad.rad_w.m + ' ' + grad.rad_h.v + grad.rad_h.m;
						var size = 'circle at '+grad.rad_l.v + grad.rad_l.m + ' ' + grad.rad_t.v + grad.rad_t.m;
						var gr = 'radial-gradient('+ size+', '+ stops.join(', ') +') 	' + position
					}
					grads.push(gr)
					poss.push(grad.pos[0].v + grad.pos[0].m +' ' + grad.pos[1].v + grad.pos[1].m)
					sizes.push(grad.size[0].v + grad.size[0].m +' ' + grad.size[1].v + grad.size[1].m)
				})

				to.css({
					'background-image': grads.join(',') ,
					'background-size': sizes.join(', '),
					'background-position':poss.join(', ')

				})
			 }`
###
window.Constructor._draw_css_background =(to, css_pattern) ->

  # var preview = to
  sizes = []
  poss = []
  grads = []
  $.each css_pattern.gradients, (ix, grad) ->
    stops = []

    # need two color stops at least
    return  if grad.stops.length < 2
    $.each grad.stops, (ix, st) ->
      rgba = hsvToRgb(st.col)
      s = rgba + " " + st.size.v + st.size.m
      stops.push s

    if grad.type is "linear"
      gr = "linear-gradient(" + grad.deg + "deg, " + stops.join(", ") + ")"
    else
      position = grad.rad_w.v + grad.rad_w.m + " " + grad.rad_h.v + grad.rad_h.m
      size = "circle at " + grad.rad_l.v + grad.rad_l.m + " " + grad.rad_t.v + grad.rad_t.m
      gr = "radial-gradient(" + size + ", " + stops.join(", ") + ") \t" + position
    grads.push gr
    poss.push grad.pos[0].v + grad.pos[0].m + " " + grad.pos[1].v + grad.pos[1].m
    sizes.push grad.size[0].v + grad.size[0].m + " " + grad.size[1].v + grad.size[1].m

  to.css
    "background-image": grads.join(",")
    "background-size": sizes.join(", ")
    "background-position": poss.join(", ")



###
redraw_background = `function (){
				var self = this;
				$.each(this.Site.backgrounds, function(name, imgo){
					if (name == 'body'){
						var C = $('body')
						c = C[0];


					}else if (name == 'content'){
						var C = self.layout_cont;
					}
					if (imgo.type == 'pattern'){
						if( typeof imgo.pattern  == 'undefined'){
							C.css('background-image', '' );
							return
						}
						if (['image','constructor'].indexOf(imgo.pattern.type) != -1){
							var pat = imgo.pattern.image;
							C.css('background', 'url("' + pat +'") repeat' );
						}
						else{
							var pat = imgo.pattern.image
							self._draw_css_background(C, pat);
						}
					}else if(imgo.type == 'color'){
						var c = self.get_color(imgo.color);
						C.css('background', hsvToRgb(c))

					}else if(imgo.type == 'none'){
						C.css('background', '' );
					}

				})
			}`
###
window.Constructor.redraw_background = ->

  log( "BGs", @Site.backgrounds )
  if @Site.backgrounds?
    log("DOne")
    $.each @Site.backgrounds, (name, imgo) =>
      if name is "body"
        C = $("body")
        #c = C[0]
      else C = @layout_cont  if name is "content"
      if imgo.type is "pattern"
        if typeof imgo.pattern is "undefined"
          C.css "background-image", ""
          return
        unless ["image", "constructor"].indexOf(imgo.pattern.type) is -1
          pat = imgo.pattern.image
          C.css "background", "url(\"" + pat + "\") repeat"
        else
          pat = imgo.pattern.image
          @_draw_css_background C, pat
      else if imgo.type is "color"
        c = @get_color(imgo.color)
        C.css "background", hsvToRgb(c)
      else C.css "background", ""  if imgo.type is "none"


###

draw_color_chooser = `function (onSelectColor){
				color_chooser = $('<div>')
				.css('position','absolute')
				.css('background-color','white')
				.css('border', '1px solid black')
				.css('padding', '10px')
				.width(400)
				.zIndex(10000)
				.draggable({scroll:false})
				var self = this;


				this._make_pallette();
				$.each(this.Site.colors.pallette , function(l, vars){
					var b, main
					if (l == 0){
						//console.log(l, vars)
						$.each ( vars, function(i, col_){
							if(typeof col_.a  == 'undefined'){col_.a = 1}
							var col = hsvToRgb(col_);

							 if(i == 0){

								b = $('<div>').css('float','left').width(100).height(100).appendTo(color_chooser)
							}

							$('<button>').css('padding','0').css('border','0').css('display','block').css('background-color', col).css('float','left').width(100).height(100/6).appendTo(b)
							.click(function(evt){
								onSelectColor(col, {v:l, ix:i}, col_ )
								evt.preventDefault(), evt.stopPropagation()
								color_chooser.remove();
							})

						})
					}
					else{
						// console.log(l, vars)
						 $.each ( vars, function(i, col_){
 							if(typeof col_.a  == 'undefined'){col_.a = 1}

							var col = hsvToRgb(col_);
							if(i == 0){
								b = $('<div>').css('float','left').width(100).height(100).appendTo(color_chooser)
								main = $('<button>').css('padding','0').css('border','0').css('display','block').css('background-color', col).css('float','left').width(100).height(50)
								.click(function(evt){
									onSelectColor(col, {v:l, ix:i}, col_ )
									color_chooser.remove();
									evt.preventDefault(), evt.stopPropagation()})
							 }else{
								if(i == 3){
									main.appendTo(b);
								}
								$('<button>').css('padding','0').css('border','0').css('display','block').css('background-color', col).css('float','left').width(50).height(25).appendTo(b)
								.click(function(evt){	// console.log(col);
									onSelectColor(col,{v:l, ix:i}, col_);
									evt.preventDefault(), evt.stopPropagation()
									color_chooser.remove();
								})
							}
						})
					}
				})
				var customs = $('<div>').css('float','left').width(200).height(200).appendTo(color_chooser);
				$('<div>').text('Custom colors').width(200).height(25).appendTo(customs)
				$.each(this.Site.colors.custom_pallette , function(l, vars){
					if(typeof vars.a  == 'undefined'){vars.a = 1}

					var col = hsvToRgb(vars);
					var tr = $("<div>").css('background', "url(/static/images/bar-opacity.png) repeat" )
					.width(25).height(25).css('float','left').appendTo(customs)

					$('<button>').css('padding','0').css('border','0')
					.css('display','block')
					.css('background-color', col)
					.width(25).height(25).appendTo(tr)
					.click(function(evt){	// console.log(col);
						onSelectColor(col, {v:'C', ix:l }, vars );
						evt.preventDefault(), evt.stopPropagation()
						color_chooser.remove();
					})
				})

				$('<div>').css('clear','both').appendTo(color_chooser)
				var butts = $('<div>').appendTo(color_chooser).css('border-top', '1px solid black')
				.css('margin-top', '20px')
				$('<input>').attr('value','Закрыть').button().appendTo(butts).click(function(){
					color_chooser.remove()
				})

				//$('<input>').attr('value','Прозрачный').button().appendTo(butts).click(function(){
				//	onSelectColor("clear");
				//	color_chooser.remove()

				//})
				$('<input>').button().text('Другой цвет').appendTo(butts).attr('value','Выбрать другой цвет').button()
					.colorpicker({inline:false, alpha:true, colorFormat:'RGBA', ok: function(evt, color){
						var hsv = color.hsv
						hsv.s = hsv.s * 100;
						hsv.b = hsv.v * 100;
						hsv.h = hsv.h * 360;
						hsv.a = color.a
						delete hsv.v
						console.log(hsv)
						self.Site.colors.custom_pallette.push(hsv)
						var ix = self.Site.colors.custom_pallette.length - 1
						color_chooser.remove()
						onSelectColor(color.formatted, {v:'C', ix: ix }, hsv)

					}})
				return color_chooser;
			}`


###

window.Constructor.draw_color_chooser = (onSelectColor) ->
  color_chooser = $("<div>").css("position", "absolute").css("background-color", "white").css("border", "1px solid black").css("padding", "10px").width(400).zIndex(10000).draggable(scroll: false)
  self = this
  @_make_pallette()
  $.each @Site.colors.pallette, (l, vars) ->
    b = undefined
    main = undefined
    if l is 0

      #console.log(l, vars)
      $.each vars, (i, col_) ->
        col_.a = 1  if typeof col_.a is "undefined"
        col = hsvToRgb(col_)
        b = $("<div>").css("float", "left").width(100).height(100).appendTo(color_chooser)  if i is 0
        $("<button>").css("padding", "0").css("border", "0").css("display", "block").css("background-color", col).css("float", "left").width(100).height(100 / 6).appendTo(b).click (evt) ->
          onSelectColor col,
            v: l
            ix: i
          , col_
          evt.preventDefault()
          evt.stopPropagation()

          color_chooser.remove()


    else

      # console.log(l, vars)
      $.each vars, (i, col_) ->
        col_.a = 1  if typeof col_.a is "undefined"
        col = hsvToRgb(col_)
        if i is 0
          b = $("<div>").css("float", "left").width(100).height(100).appendTo(color_chooser)
          main = $("<button>").css("padding", "0").css("border", "0").css("display", "block").css("background-color", col).css("float", "left").width(100).height(50).click((evt) ->
            onSelectColor col,
              v: l
              ix: i
            , col_
            color_chooser.remove()
            evt.preventDefault()
            evt.stopPropagation()
          )
        else
          main.appendTo b  if i is 3
          $("<button>").css("padding", "0").css("border", "0").css("display", "block").css("background-color", col).css("float", "left").width(50).height(25).appendTo(b).click (evt) -> # console.log(col);
            onSelectColor col,
              v: l
              ix: i
            , col_
            evt.preventDefault()
            evt.stopPropagation()

            color_chooser.remove()



  customs = $("<div>").css("float", "left").width(200).height(200).appendTo(color_chooser)
  $("<div>").text("Custom colors").width(200).height(25).appendTo customs
  if @Site.colors.custom_pallette?
    $.each @Site.colors.custom_pallette, (l, vars) ->
      vars.a = 1  if typeof vars.a is "undefined"
      col = hsvToRgb(vars)
      tr = $("<div>").css("background", "url(/static/images/bar-opacity.png) repeat").width(25).height(25).css("float", "left").appendTo(customs)
      $("<button>").css("padding", "0").css("border", "0").css("display", "block").css("background-color", col).width(25).height(25).appendTo(tr).click (evt) -> # console.log(col);
        onSelectColor col,
          v: "C"
          ix: l
        , vars
        evt.preventDefault()
        evt.stopPropagation()

        color_chooser.remove()


  $("<div>").css("clear", "both").appendTo color_chooser
  butts = $("<div>").appendTo(color_chooser).css("border-top", "1px solid black").css("margin-top", "20px")
  $("<input>").attr("value", "Закрыть").button().appendTo(butts).click ->
    color_chooser.remove()

  $("<input>").button().text("Другой цвет").appendTo(butts).attr("value", "Выбрать другой цвет").button().colorpicker
    inline: false
    alpha: true
    colorFormat: "RGBA"
    ok: (evt, color) ->
      hsv = color.hsv
      hsv.s = hsv.s * 100
      hsv.b = hsv.v * 100
      hsv.h = hsv.h * 360
      hsv.a = color.a
      delete hsv.v

      console.log hsv
      self.Site.colors.custom_pallette.push hsv
      ix = self.Site.colors.custom_pallette.length - 1
      color_chooser.remove()
      onSelectColor color.formatted,
        v: "C"
        ix: ix
      , hsv

  color_chooser