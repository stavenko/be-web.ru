




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
					// log(is_done, active_renderers)
					if( is_done ){ // все процессы отработали
						DB.save_cache(hashes)
						is_saved = true
					}else{
						setTimeout(perform_caching, 1000);
					}

				}

				var render_page = function(hash){
				  // hash = hash.replace("#", "")

					if(hash in hashes){ return }

					active_renderers[hash] = true;
					var custom_cont = $('<div>');
					var custom_head = $('<div>');
					var content, head_content;
					try{
						self.is_constructor = false;
						self.draw(custom_cont, custom_head, hash)
						self.is_constructor = true;

						setTimeout(function(){
              var content = custom_cont.html();
              var head_content = custom_head.html();
              var link_list = [];
              var as = custom_cont.find('a');
              $.each(as, function(ix, a){
                 var h = "#" + $(a).prop('href').split('#')[1]
                 if(h != null){
                  render_page(h);
                 }
              })
              custom_cont.remove();
              var h = $('<html>')
              var b = $('<body>')
              .prop('style', body_style.cssText)
              .html(content).appendTo(h)
              hashes[hash] = {'cont':b.html(), head:head_content}
              active_renderers[hash] = false;
            }, 5000)
					}finally{
						self.is_constructor = true
						// throw
					}





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
        console.log("Hues", colors)
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
window.Constructor._make_pallette =->
  h = @Site.colors.base
  lights = @Site.colors.lights
  shadows = @Site.colors.shadows
  brightness = @Site.colors.brightness
  saturation = @Site.colors.saturation
  i = @Site.colors.type
  @Site.colors.pallette = []
  s = undefined
  a = undefined
  A = undefined

  # // // // console.log(i,h,s,a,A, this.Site.colors)
  switch i
    when "mono"
      s = a = A = false
    when "complement"
      s = (h + 180) % 360
      a = A = false

    #return hsvToRgb(a,100,100)
    when "triada"
      s = (h + 120) % 360
      a = (h + (360 - 120)) % 360
      A = false
    when "split-trio"
      s = (h + 150) % 360
      a = (h + (360 - 150)) % 360
      A = false
    # return hsvToRgb(a,100,100)
    when "analogous"
      s = (h + 30) % 360
      a = (h + (360 - 30)) % 360
      A = false
    # return hsvToRgb(a,100,100)
    when "accent"
      s = (h + 30) % 360
      a = (h + (360 - 30)) % 360
      A = (h + 180) % 360
  # return hsvToRgb(a,100,100)
  sat_koef = [0.89, 0.5, 0.5, 0.01]
  br_koef = [0.05, 0.05, 0.45, 0.3]
  colors = [h, s, a, A]
  # console.log("COLORS", colors)
  greys = new Array()
  am = 5
  c = 0
  while c <= am
    _c =
      h: 0
      s: 0
      b: c * (100 / am)
      a: 1

    greys.push _c
    c++
  @Site.colors.pallette[0] = greys
  #log("LOGGIN COLOR", colors)

  for col of colors
    color = colors[col]
    vars = [
      h: color
      s: saturation
      b: brightness
    ]

    if color
      for i of sat_koef
        ds = saturation * sat_koef[i]
        db = brightness * br_koef[i]
        if i < 2 # lights
          dsat = ds * lights / 100
          dbri = db * lights / 100
        else # shadows
          dsat = ds * shadows / 100
          dbri = db * shadows / 100
        sat = saturation - dsat
        bri = brightness - dbri
        vars[Number(i) + 1] =
          h: color
          s: sat
          b: bri
          a: 1
      @Site.colors.pallette.push vars
    else
      @Site.colors.pallette.push false

window.Constructor._draw_css_background =(to, css_pattern) ->

  # var preview = to
  sizes = []
  poss = []
  grads = []
  $.each css_pattern.gradients, (ix, grad) =>
    stops = []

    # need two color stops at least
    return  if grad.stops.length < 2
    $.each grad.stops, (ix, st) =>
      # log(st)
      rgba = hsvToRgb(st.col) unless st.col_ix?
      if st.col_ix?
        hsva = @get_color(st.col_ix)
        hsva.a = st.a
        rgba = hsvToRgb(hsva)
      s = rgba + " " + st.size.v + st.size.m
      stops.push s

    if grad.type is "linear"
      is_safari = /Safari/.test( navigator.userAgent ) and not /Chrome/.test(navigator.userAgent)
      is_mobile = /Mobile/.test(navigator.userAgent)
      if is_safari or is_mobile
        deg = (360 - (grad.deg - 90)) % 360
        gr = "-webkit-linear-gradient(" + deg + "deg, " + stops.join(", ") + ")"
      else
        gr = "linear-gradient(" + grad.deg + "deg, " + stops.join(", ") + ")"
    else
      position = grad.rad_w.v + grad.rad_w.m + " " + grad.rad_h.v + grad.rad_h.m
      size = "circle at " + grad.rad_l.v + grad.rad_l.m + " " + grad.rad_t.v + grad.rad_t.m
      gr = "radial-gradient(" + size + ", " + stops.join(", ") + ") \t" + position
    grads.push gr
    poss.push grad.pos[0].v + grad.pos[0].m + " " + grad.pos[1].v + grad.pos[1].m
    sizes.push grad.size[0].v + grad.size[0].m + " " + grad.size[1].v + grad.size[1].m

  to.css

    "background": grads.join(",")
    "background-size": sizes.join(", ")
    "background-position": poss.join(", ")



window.Constructor.redraw_background = ->

  #log( "BGs", @Site.backgrounds )
	if @Site.backgrounds?
		$.each @Site.backgrounds, (name, imgo) =>
			if name is "body"
				C = $("body")
			else C = @layout_cont  if name is "content"
			if imgo.type is "pattern"
				#console.log window.PATTERNS? , imgo.pattern of window.PATTERNS
				if window.PATTERNS? and imgo.pattern of window.PATTERNS
					patt = window.PATTERNS[imgo.pattern]
				else
					patt = DB.get_objects('generic.' + BASE_SITE , 'pattern', {'_id': {'$oid':imgo.pattern }}).objects[0]
				if typeof patt is "undefined"
					C.css "background-image", ""
					return
				if patt.type is "image"
					pat = patt.image
					C.css "background", "url(\"" + pat + "\") repeat"

				else if patt.type is "constructor"
					if not isCanvasSupported()
						C.css "background", "url(\"" + patt.image + "\") repeat"
					else
						@renderPattern C, patt
				else
					pat = patt.image
					@_draw_css_background C, pat
			else if imgo.type is "color"
				c = @get_color(imgo.color)
				
				C.css "background", hsvToRgb(c)
			else C.css "background", ""  if imgo.type is "none"


window.Constructor.draw_color_chooser = (onSelectColor) ->
  color_chooser = $("<div>").css("position", "absolute").css("background-color", "white").css("border", "1px solid black")
  .css("padding", "10px")
  .width(500).zIndex(10000).draggable(scroll: false)
  self = this
  @_make_pallette()
  $.each @Site.colors.pallette, (l, vars) ->
    b = undefined
    if l is 0

      # Сначала серые - 6 градаций черный - (4 серых) - белый
      $.each vars, (i, col_) ->
        col_.a = 1  if typeof col_.a is "undefined"
        col = hsvToRgb(col_)
        self.__b = $("<div>").css("float", "left").width(100).height(100).appendTo(color_chooser)  if i is 0
        $("<button>").css("padding", "0").css("border", "0").css("display", "block").css("background-color", col).css("float", "left").width(100).height(100 / 6).appendTo(self.__b).click (evt) ->
          color_chooser.remove()
          onSelectColor col,
            v: l
            ix: i
          , col_

          evt.preventDefault()
          evt.stopPropagation()


    else
      $.each vars, (i, col_) ->
        col_.a = 1  if typeof col_.a is "undefined"
        col = hsvToRgb(col_)
        if i is 0
          self.__b = $("<div>").css("float", "left").width(100).height(100).appendTo(color_chooser)
          self.__main = $("<button>").css("padding", "0").css("border", "0").css("display", "block").css("background-color", col).css("float", "left").width(100).height(50).click((evt) ->
            color_chooser.remove()
            onSelectColor col,
              v: l
              ix: i
            , col_

            evt.preventDefault()
            evt.stopPropagation()
          )
        else
          self.__main.appendTo self.__b  if i is 3
          $("<button>").css("padding", "0").css("border", "0").css("display", "block").css("background-color", col).css("float", "left").width(50).height(25).appendTo(self.__b).click (evt) -> # console.log(col);
            onSelectColor col,
              v: l
              ix: i
            , col_
            evt.preventDefault()
            evt.stopPropagation()

            color_chooser.remove()

  $('<div>').css('clear','both').css('display','block').appendTo color_chooser
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

      #console.log hsv
      #console.log("BEFORE", self.Site.colors.custom_pallette)
      if self.Site.colors.custom_pallette?
        self.Site.colors.custom_pallette.push hsv
      else
        self.Site.colors.custom_pallette = [hsv]
      #console.log("AFTER", self.Site.colors.custom_pallette)
      ix = self.Site.colors.custom_pallette.length - 1
      color_chooser.remove()
      #console.log( "Index", ix )
      onSelectColor color.formatted,
        v: "C"
        ix: ix
      , hsv

  color_chooser