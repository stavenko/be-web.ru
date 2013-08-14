
window.Constructor.redraw = -> # Done
        @clear();
        @draw();
window.Constructor.clear = ->
        @page_cont.find( "*").remove()
        $("#controls>.widget-control").remove()

window.Constructor.draw= (custom_cont = @page_cont, custom_head=$('head'), custom_hash) -> #Done
      #log("CH", custom_hash)
      if custom_hash
        @_init_page custom_hash.slice(1), custom_head
      else
        @_init_page()
      @init_grid(custom_cont, custom_head)

window.Constructor._init_page = (hash_ = window.location.hash.slice(1).split('?'), head = $('head') ) -> #Done
  @page_vars= {} if not @page_vars?
  page_name = hash_[0].replace('!','')
  params = if hash_[1]?
      hash_[1]
    else ""
  @current_page = page_name
  pdata = @getPageData(page_name)
  #log(pdata)
  if  pdata.params
    for p, val of pdata.params
      do (p, val) =>
        #log(@, p, val)
        @page_vars[p] = val

  #log('c')
  t = head.find('title')
  if not t.length
    t = $('<title>').appendTo head
  @head_tag = head
  # log (@head_tag)
  @_set_description  pdata.description
  @_set_keywords pdata.keywords
  t.text (pdata.title + '|' + @Site.seo.title)
  head.append(@Site.seo.metas.yandex) if @Site.seo.metas? and @Site.seo.metas.yandex?
  head.append(@Site.seo.metas.google) if @Site.seo.metas? and @Site.seo.metas.google?
  if params
    a = params.split('&')
    for p in a
      do (p) =>
        #log(p)
        _p = p.split('=')
        name = _p[0]
        val =  _p[1]
        if name and val
          @page_vars[name] = val
  # log("FFF", @page_vars)
  @layout = @Site.layout
  @base_height = @layout.base_height
  @inited_blocks = []



window.Constructor.getPageData = ( page_name ) -> # DOne
  @load_site();
  # log(page_name,this.Site.pages[page_name]);
  @Site.pages[page_name]
  #log(@Site.pages, page_name)


window.Constructor.load_site = (do_reload = false ) -> #done
  #log( not @Site? or  do_reload )

  if   not @Site? or do_reload
    S = DB.get_objects("generic." + BASE_SITE, this._site_type, {} )
    if S.total_amount isnt 0
      @Site = S.objects[0];
      if not @Site.layout.grid?
        @Site.layout.grid = this.Site.layout.padding
        @Site.layout.padding = {top:50, left:10}
    else
      @Site = default_site

    apps_ = {}
    for app_name in @Site._Apps
      do (app_name) =>
        app = @getApp(app_name)
        if app
          apps_[app_name] = app

    #log(apps_);
    @Site['Applications'] = apps_;

    delete @Site.version
    @page_order_index = {};
    @page_amount = 0
    for i,page in @Site.pages
      @page_order_index[page.order] = i
      @page_amount +=1




window.Constructor.getAppJson = (name) ->
    xhr = $.ajax({url: window.get_application_url + name + "/",async: false})
    #log(xhr.status)
    if xhr.status is 200
      JSON.parse(xhr.responseText)
    else
      ix = @Site._Apps.indexOf(name)
      @Site._Apps.splice ix, 1
      false



window.Constructor.getApp = (name) ->
  app_egg = @getAppJson name
  if app_egg
    #app_egg = JSON.parse(scr)
    app_egg.Main = new Function(app_egg.Main.attr, app_egg.Main.body)
    app_egg.getter = new Function(app_egg.getter.attr, app_egg.getter.body)
    App = app_egg.getter(this, name)
    App.roles = app_egg.roles
    App.default_role = app_egg.default_role
    App.app_name = app_egg.app_name
    App.title = app_egg.title
    App.is_own = app_egg.is_own
    App
  else false





window.Constructor.set_app_cache = (n,v)->
  if @_app_cache?
    @_app_cache[n]=v
  else
    @_app_cache = {}
    @_app_cache[n] = v


window.Constructor.get_app_cache = (n)->
  if @_app_cache? and @_app_cache[n]?
      @_app_cache[n]
  else{}





window.Constructor.get_block = (ix) -> @Site.blocks[ix]


getBlockSettings = `function (pos){
				if (this.Site.default_block_settings){
					set = clone(this.Site.default_block_settings)
				}else{
					set = {border_width:0,
							 background:{type:'none'}}
				}

				if ( this.Site.blocks[pos].settings ){
					for (k in this.Site.blocks[pos].settings){
						set[k] = this.Site.blocks[pos].settings[k]
					}
					// set = self.Site.blocks[pos].settings
				}
					return set

			}`
window.Constructor.getBlockSettings = getBlockSettings




rect = `function (x,y,w,h){
			return {left:x, top:y, width:w, height:h}	 ;
			}`
window.Constructor.rect = rect





getWidgetData = `function (pos, def){
				var self = this;
				return (function(i){
					 var d = self.Site.blocks[pos].widget.data;
					if (d){
						return d
					}
					return def;

				})(pos)


			}`
window.Constructor.getWidgetData = getWidgetData






_add_title = `function (title) {
				var t = this.head_tag.find('title');
				var text = t.text()
				t.text(title +'|' + text);
			}`
window.Constructor._add_title = _add_title




_set_keywords = `function (kw){
				var H  = this.head_tag;
				var d = H.find('meta[name=keywords]');
				if(d.length){
				}else{
					d = $('<meta>').appendTo(H).attr('name','keywords');
				}
				if(kw){
					if(typeof kw == 'string'){
						d.attr('content', kw )
					}else{
						d.attr('content', kw.join(', ') )
					}
				}else{
					d.attr('content', '' )
				}
			}`
window.Constructor._set_keywords = _set_keywords




_set_description = `function (description){
				var H  = this.head_tag;
				var d = H.find('meta[name=description]');

				if(d.length){
				}else{
					d = $('<meta>').appendTo(H).attr('name','description');
				}
				d.attr('content', description)


			}`
window.Constructor._set_description = _set_description




_set_page_var = `function (name, val){
				this.page_vars[name] = val
			}`
window.Constructor._set_page_var = _set_page_var




_get_page_var = `function (name){
				return this.page_vars[name];
			}`
window.Constructor._get_page_var = _get_page_var








get_color = `function (c){
				this._make_pallette()
				if (c.v == 'C') {// color from custom palette
					return this.Site.colors.custom_pallette[c.ix]

				}else{
					return this.Site.colors.pallette[c.v][c.ix]
				}


			}`
window.Constructor.get_color = (c) ->
  @_make_pallette()
  if c.v is 'C'
    @Site.colors.custom_pallette[c.ix]
  else
    v = @Site.colors.pallette[c.v]
    if v
      v[c.ix]
    else
      v = @Site.colors.pallette[c.v - 1]
      if v
        v[c.ix]
      else
        v = @Site.colors.pallette[c.v - 2]
        if v
          v[c.ix]
        else
          @Site.colors.pallette[c.v - 3][c.ix]



window.Constructor.getTextColors = ->
  colors = if not @Site.textColors? then {} else @Site.textColors
  defaults =
    text_color : "rgb(0,0,0)"
    link_color : "#0000ff"
    visited_color : "#800080"
    active_color : "#ff0000"
    hover_color  : "#0000ff"
  lc = {}
  #log('W', @Site.textColors, colors)
  for k in ["text_color", "link_color", "visited_color", "active_color", 'hover_color']

    if colors[k]? and colors[k].index?
      lc[k] = hsvToRgb(@get_color(colors[k].index))
    else
      lc[k] = defaults[k]
  #log("FINAL", lc)
  lc

window.Constructor.init_grid = (to, head) ->

  # log(to,head);
  block_width = @_block_width()
  base_height = @layout.base_height
  self = this
  if @layout.fixed
    e = "px"
  else
    e = "%"
  $("body").css "margin", 0
  total_height = @Site.layout.drawen_lines * (@Site.layout.base_height + 2 * (@Site.layout.grid.ver))
  window_width = window.innerWidth
  width = @Site.layout.width
  w_left = window_width - width
  left = w_left / 2
  #log "TOTAL", @Site

  # .css('margin-left','auto')

  # .css('margin-right','auto')
  @layout_cont = $("<div>").css("position", "absolute").css("width", @layout.width + e).css("top", @Site.layout.padding.top).css("left", left).css("height", total_height).appendTo(to)
  c_off = @layout_cont.offset()
  to.css "top", "0px"

  # console.log("OFFSET", c_off)
  @_main_offset = c_off
  @redraw_background()
  @_busy_regions = []
  @_moved_block_ = []

  #console.log(this.Site.blocks)
  bw = self._block_width(1)
  bh = self._block_height(1)
  bhp = self.Site.layout.grid.hor
  bvp = self.Site.layout.grid.ver
  gw = bw + (bhp * 2)
  gh = bh + (bvp * 2)
  gp = self.Site.layout.padding.left + self.Site.layout.grid.hor

  gmp = (gp - (bhp * 2))
  # log(bw, gw, bhp )

  gridd = $("<div>").addClass("empty-block").appendTo(@layout_cont)
  .css("position", "absolute")
  .css("background-color", "white")
  .css("background", "linear-gradient(90deg, rgba(0,0,0,.5) 1px, transparent 1px)," + "linear-gradient(90deg, rgba(255,255,255,.5) 2px, transparent 1px)," + "linear-gradient(90deg, rgba(255,255,255,.5) 2px, transparent 1px)," + "linear-gradient(90deg, rgba(0,0,0,.5) 1px, transparent 1px)," + "linear-gradient(rgba(0,0,0,.5) 1px, transparent 1px)," + "linear-gradient(rgba(255,255,255,.5) 2px, transparent 1px)," + "linear-gradient(rgba(255,255,255,.5) 2px, transparent 1px)," + "linear-gradient(rgba(0,0,0,.5) 1px, transparent 1px)")
  .css("background-size", gw + "px 1px,  " + gw + "px 1px,  " + gw + "px 1px,  " + gw + "px 1px, 1px " + gh + "px, 1px " + gh + "px, 1px " + gh + "px, 1px " + gh + "px  ")
  .css("background-position", gp + "px 0px, " + (gp + 1) + "px 0px, " + gmp + "px 0px, " + (gmp + 1) + "px 0px, 0px 0px,0px 1px, 0px -" + (bvp * 2) + "px,0px -" + ((bvp * 2) - 1) + "px")
  .css("left", 0)
  .css("top", 0).css("width", @Site.layout.width)
  .css("height", total_height)  if @is_constructor

  #.zIndex(-100)
  @inited_blocks = [] # Предназначение - последующий анбинд события клик после даблклика - включения панели управления
  @settings_over_block = false;

  hm = []
  $.each @Site.blocks, (ix, block) =>
    if block.display_on is "all"

      #console.log(block.dont_display_on , self.current_page)

      #console.log('do not display it', ix)
      return  unless block.dont_display_on.indexOf(self.current_page) is -1
    else return  unless block.display_on is self.current_page
    set = self.getBlockSettings(ix)

    #console.log("IG",set)
    bw = (if set then set.border_width else 0)
    x = block.x #Number(koords.split(':')[0]);
    y = block.y # Number(koords.split(':')[1]);
    unless set.unsnap_to_grid

      #console.log('orig', x,y)
      xx = self._calc_left(x + 1) - bw
      yy = self._calc_top(y) - bw
    else

      #self.move_block(ix, 0, 0)
      #consmoveole.log('my', x,y)
      xx = x
      yy = y

    #console.log("XX", xx,yy, self._calc_left(2), self._calc_top(5) )
    w = block.width
    h = block.height
    unless set.unsnap_to_grid
      W = self._calc_width(w)
      H = self._calc_height(h)
    else
      W = w
      H = h

    # console.log(W,H)

    # console.log(block_list);
    gp =
      jq: $("<div>").appendTo(self.layout_cont).css("position", "absolute").css("left", xx).css("top", yy).width(W).css("height", H)
      .css("overflow", "visible")
      pos: ix


    bl = self.init_block block, gp
    offs = bl.offset()
    h = bl.height()
    hm.push(offs.top + h)
    #log(hm)
    @inited_blocks.push bl;
  @layout_cont.height(Math.max.apply(Math,hm))






apply_block_settings = `function (obj, settings, widget){
				var w = obj.jq,
				bl = this.get_block(obj.pos);
				if(widget.disobey.indexOf('border_color') == -1){
					if(typeof settings.border_color == 'string'){
						w.css('border-color', settings.border_color);
					}else{
						if (typeof settings.border_color == 'undefined'){
							settings.border_color = {v:0, ix:0}
						}
						var color = this.get_color(settings.border_color)
						var c = hsvToRgb(color);
						w.css('border-color', c);
					}

				}

				if(widget.disobey.indexOf('bg_opacity') == -1)w.css('opacity', settings.bg_opacity);
				if(widget.disobey.indexOf('border_radius')== -1 )w.css('border-radius', settings.border_radius +'px')
				if(widget.disobey.indexOf('border_width') == -1){
					if(!(settings.unsnap_to_grid)){
						var xx = this._calc_left(bl.x+1) - settings.border_width
						var yy = this._calc_top(bl.y) - settings.border_width
					}else{
						var xx = bl.x
						var yy = bl.y

					}
					w.css('border-width', settings.border_width +'px')
					w.css('left',  xx)
					w.css('top',  yy)
					w.css('border-style','solid')

				}

				if(widget.disobey.indexOf('line_height') == -1)w.css('line-height', settings.line_height +'px')
				if(widget.disobey.indexOf('font_size') == -1)w.css('font-size', settings.font_size +'px')

				if(widget.disobey.indexOf('padding_left_right') == -1){
					C = w.children().eq(0);
					W = w.width();

					C.css('margin-left',settings.padding_left_right +'px')
					C.css('margin-right',settings.padding_left_right +'px')
					C.width( W - settings.padding_left_right * 2)
				}

				if(widget.disobey.indexOf('padding_top') == -1)C.css('padding-top',settings.padding_top +'px')
				if (settings.background.type == 'color'){
					if(widget.disobey.indexOf('background_color') == -1){
						if(typeof settings.background.color == 'string'){
							w.css('background' , settings.background.color );
						}else{
							var color = this.get_color(settings.background.color)
							var c = hsvToRgb(color);
							w.css('background', c);
						}
					}
				}else if(settings.background.type == 'none'){
							w.css('background', '');
				} else if(settings.background.type == 'pattern'){
					patt = settings.background.pattern
					if (['image', 'constructor'].indexOf(patt.type ) != -1){
						w.css('background', 'url(' + patt.image +' ) repeat' )
					}else{
						this._draw_css_background(w, patt.image);
					}

				}

			}`


window.Constructor.reapply_block_settings = (obj, widget)->
  sett = @getBlockSettings(obj.pos)
  @apply_block_settings(obj, sett, widget)

window.Constructor.apply_block_settings = (obj, settings, widget) ->

  #console.log("HHHHH", obj)
  w = obj.jq#.children(":first")
  bl = @get_block(obj.pos)
  if widget.disobey.indexOf("border_color") is -1
    if typeof settings.border_color is "string"
      w.css "border-color", settings.border_color
    else
      if typeof settings.border_color is "undefined"
        settings.border_color =
          v: 0
          ix: 0

      # console.log('border-color', settings.border_color)
      color = @get_color(settings.border_color)
      c = hsvToRgb(color)
      w.css "border-color", c
  w.css "opacity", settings.bg_opacity  if widget.disobey.indexOf("bg_opacity") is -1
  #log( widget.disobey)
  if "border_radius" not  in widget.disobey
    #log('Broder radius')
    w.css "-moz-border-radius" , settings.border_radius + "px"
    w.css "-webkit-border-radius" , settings.border_radius + "px"
    w.css "border-radius" , settings.border_radius + "px"

  #if widget.disobey.indexOf("border_radius") is -1

  if widget.disobey.indexOf("border_width") is -1
    unless settings.unsnap_to_grid
      xx = @_calc_left(bl.x + 1) - settings.border_width
      yy = @_calc_top(bl.y) - settings.border_width
    else
      xx = bl.x
      yy = bl.y
    w.css "border-width", settings.border_width + "px"
    w.css "left", xx
    w.css "top", yy
    w.css "border-style", "solid"
  w.css "line-height", settings.line_height + "px"  if widget.disobey.indexOf("line_height") is -1
  w.css "font-size", settings.font_size + "px"  if widget.disobey.indexOf("font_size") is -1
  if widget.disobey.indexOf("padding_left_right") is -1
    C = w.children().eq(0)
    W = w.width()
    C.css "margin-left", settings.padding_left_right + "px"
    C.css "margin-right", settings.padding_left_right + "px"
    C.width W - settings.padding_left_right * 2
  C.css "padding-top", settings.padding_top + "px"  if widget.disobey.indexOf("padding_top") is -1
  if settings.background.type is "color"
    if widget.disobey.indexOf("background_color") is -1
      if typeof settings.background.color is "string"
        w.css "background", settings.background.color
      else
        color = @get_color(settings.background.color)
        c = hsvToRgb(color)
        w.css "background", c
  else if settings.background.type is "none"
    w.css "background", ""
  else if settings.background.type is "pattern"
    patt = settings.background.pattern
    unless ["image", "constructor"].indexOf(patt.type) is -1
      w.css "background", "url(" + patt.image + " ) repeat"
    else
      @_draw_css_background w, patt.image
  if widget.depends_on_settings?
    #log( "WIDGET", widget )
    widget.draw(settings)







window.Constructor.init_block = (bl, to) ->

  # console.log (bl)

  # console.log(W,H)
  init_resizer = ->
  newWidget = (c, t, p, cp) ->

    #log("New widget", t.Site.Applications, widget_name,app_name );
    t.Site.Applications[app_name].widgets[widget_name].init c, t, p, cp
  r = bl.top
  l = bl.left
  w = bl.width
  h = bl.height
  self = this
  W = @_calc_width(w)
  H = @_calc_height(h)
  widget_str = bl.widget.name.split(".")
  widget_name = widget_str[0]
  widget_str.splice 0, 1
  app_name = widget_str.join(".")
  wdata = bl.widget.data
  w = $("<div>").css('overflow','hidden').css("width", to.jq.width()).css("height", to.jq.height()).appendTo(to.jq).addClass("draggable-module")
  draga = undefined
  Widget = newWidget(w, this, to.pos)
  #log( widget_name, app_name)
  Widget.draw()
  settings = self.getBlockSettings(to.pos)

  #console.log("B", w.width() )
  self.apply_block_settings to, settings, Widget
  if settings.unsnap_to_grid
    W = bl.width
    H = bl.height

  # console.log("WH", W,H)
  make_draggable = (to)=>
    to.jq.draggable
      scroll: false
      zIndex: 100
      cancel: ".resize-marker"
      start: (event, ui) ->
        regs = []
        w = bl.x
        while w < bl.x + bl.width
          h = bl.y
          while h < bl.y + bl.height
            regs.push w + ":" + h
            h++
          w++
        for i of self.inited_blocks
          self.inited_blocks[i].unbind "mouseenter"
        to.jq.unbind "mouseleave" # , 'mouseenter')
        self._moved_block_ = regs

      drag: (event, ui) ->

        # // // console.log(ui)
        # var C = ui.helper;
        #console.log(settings)
        unless settings.unsnap_to_grid
          ll = self._stepping_left(ui.position.left)
          tt = self._stepping_top(ui.position.top)
          draga =
            left: ll.block
            top: tt.block

          ui.position =
            top: tt.val
            left: ll.val
        else
          draga =
            left: ui.position.left
            top: ui.position.top

      stop: ->
        self._moved_block = false
        self.move_block to.pos, draga.left, draga.top
        self.redraw()

  if @is_constructor
    make_draggable(to);


  #console.log("A", w.width() )

  if @is_constructor
    to.jq.dblclick =>
      control_panel = $("<div>").appendTo($("#controls"))
      wco = self.init_block_cp(to, control_panel, Widget)
      saving_data = (evt) =>
        Widget.save()  if Widget.save
        wco.save()

        @settings_over_block = false
        control_panel.remove()
        @redraw.apply self, []

      if   @settings_over_block isnt false

        @settings_over_block.saving()
      else
        @settings_over_block = {to:to, Widget:Widget, saving: saving_data }

        for bl in @inited_blocks
          bl.unbind "click dblclick"
          bl.draggable('destroy')
        log("after loop",  to.jq.attr('class'))

        $("#controls>.widget-control").hide()
        control_panel.css("position", "absolute").position(
          of: w
          my: "left top"
          at: "right top"
          collision: "none none"
        ).css("border", "2px solid black").css("background-color", "white").draggable(scroll: false).css "padding", "10"


        Widget.settings control_panel  if Widget.settings
        $("<div>").css("background-color", "orange").appendTo(to.jq).css("position", "absolute").position(
          of: to.jq
          my: "left top"
          at: "right top"
          collision: "none"
        ).addClass("ui-icon ui-icon-gripsmall-diagonal-se").width(20).height 20
        $("<div>").css("background-color", "green").appendTo(to.jq.parent()).css("position", "absolute").position(
          of: to.jq
          my: "left top"
          at: "left-20 top"
          collision: "none none"
        ).addClass("ui-icon ui-icon-gripsmall-diagonal-se").width(20).height(20).click =>
          saving_data()
          @_save_site();

        $("<div>").css("background-color", "red").appendTo(to.jq.parent()).css("position", "absolute").position(
          of: to.jq
          my: "left top"
          at: "left-20 top+30"
          collision: "none none"
        ).addClass("ui-icon ui-icon-gripsmall-diagonal-se").width(20).height(20).click ->
          Widget.cancel()  if Widget.cancel

          control_panel.remove()
          @settings_over_block = false
          self.redraw.apply self, []


    mouseWidth = W
    mouseHeight = H
    start_x = undefined
    start_y = undefined

    # .css('cursor', 'se-resize')

    #.position({of:to.jq, my:"right top", at:"right-20 top"})
    delete_marker = $("<div>").appendTo($("#controls")).css("position", "absolute").addClass("delete-marker widget-control").css("background-color", "blue").css("border-radius", "5px").css("border", "1px solid black").addClass("ui-icon ui-icon-closethick").width("20px").height("20px").hide().click(->
      self.delete_block to.pos
      self.redraw.apply self, []
    )

    resize_marker = $("<div>").appendTo($("#controls")).css("position", "absolute").addClass("ui-icon ui-icon-grip-diagonal-se").width("32px").height("32px").hide().addClass("resize-marker widget-control").css("background-color", "blue").css("cursor", "se-resize").css("border-radius", "5px").css("border", "1px solid black").mouseenter(->
    ).mouseup((evt) ->
      self.resize_frame = false
    ).mousedown((evt) ->
      start_x = evt.clientX
      start_y = evt.clientY
      self.resize_frame = $("<div>").css("position", "absolute").css("border", "1px solid black").appendTo(to.jq.parent()).width(W).height(H).position(
        of: to.jq
        my: "left top"
        at: "left top"
      )
      mouseWidth = bl.width
      mouseHeight = bl.height
      to.jq.parent().unbind "mouseup"
      to.jq.parent().unbind "mousemove"
      to.jq.parent().mouseup ->

        #console.log("FFF")
        if self.resize_frame
          self.resize_frame.remove()
          self.resize_frame = false
          self.Site.blocks[to.pos].width = mouseWidth
          self.Site.blocks[to.pos].height = mouseHeight

          #console.log('redraw')
          self.redraw.apply self, []


      #console.log('move evtnt')
      to.jq.parent().mousemove((evt) ->
        fr = self.resize_frame
        if fr
          if fr.size()
            nh = evt.clientY - start_y + H
            nw = evt.clientX - start_x + W
            unless settings.unsnap_to_grid
              width_step = self._stepping_width(nw)
              height_step = self._stepping_height(nh)
              fr.width width_step.val
              fr.height height_step.val
              mouseWidth = width_step.block
              mouseHeight = height_step.block
            else
              fr.width nw
              fr.height nh
              mouseWidth = nw
              mouseHeight = nh
        evt.preventDefault()
      ).css "cursor", "se-resize"
      $(this).hide()
    )
    po = to.jq.position()
    wi = to.jq.width()
    he = to.jq.height()
    mw = resize_marker.width()
    mh = resize_marker.height()
    o = @_main_offset

    #console.log("top", p , h , mh, "left",	w , mw)
    resize_marker.css "top", po.top + o.top + he - mh
    resize_marker.css "left", po.left + o.left + wi - mw
    delete_marker.css "top", po.top
    delete_marker.css "left", po.left + o.left + wi - mw
    to.jq.click (e) ->
      $("#controls>.widget-control").hide()

      delete_marker.show().zIndex 1000
      resize_marker.show().zIndex 1000

  to.jq


window.Constructor.registerEvent = (e, f)->
  if @events?
    if @events[e]
      @events[e].push(f)
    else:
      @events[e] = [f]
  else
    @events = {}
    @events[e] = [f]

window.Constructor.fireEvent = (e)->
  if @events? and @events[e]
    for f in @events[e]
      do f