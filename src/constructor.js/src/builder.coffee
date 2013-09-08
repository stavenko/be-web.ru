
window.Constructor.redraw = (force_reload = false)-> # Done
        @clear();
        @draw(null,null,null,force_reload);
window.Constructor.clear = ->
  # console.log('clear')
  @page_cont.find( "*").remove()
  $("#controls>.widget-control").remove()

window.Constructor.draw= (custom_cont = @page_cont, custom_head=$('head'), custom_hash, force_reload=false) -> #Done
      #log("CH", custom_hash)
      if custom_hash
        custom_hash = custom_hash.slice(1).split('?')
      if @_init_page custom_hash, custom_head, force_reload
        @init_grid(custom_cont, custom_head)

window.Constructor._init_page = (hash_ = window.location.hash.slice(1).split('?'), head = $('head'), force_reload=false ) -> #Done
  @page_vars= {} if not @page_vars?
  page_name = hash_[0].replace('!','')
  params = if hash_[1]?
      hash_[1]
    else ""
  @current_page = page_name
  pdata = @getPageData(page_name, force_reload)
  if pdata? # We've got page Draw!
    if  pdata.params
      for p, val of pdata.params
        do (p, val) =>
          #log(@, p, val)
          @page_vars[p] = val

    t = head.find('title')
    if t.length is 0
      t = $('<title>').appendTo head
    @head_tag = head
    @_set_description  pdata.description
    @_set_keywords pdata.keywords
    if not @Site.seo.title?
      title = "Undefined"
    else title = @Site.seo.title
    if not pdata.title?
      ptitle = "Unknown page"
    else ptitle = pdata.title
    #console.log(t.text())
    doc_title = ptitle + '|' + title
    if is_ie
      document.title = doc_title
    else
      t.text (doc_title)

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
    @layout = @Site.layout
    @base_height = @layout.base_height
    @inited_blocks = []
    #log 'ok', page_name, pdata, params
    true
  else
    #log ('no ok')
    false




window.Constructor.getPageData = ( page_name, do_reload = false ) -> # DOne
  @load_site(do_reload);
  @Site.pages[page_name]


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
    xhr = $.ajax({url: window.get_application_url + name + "/",async: false, cache:true})
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
					d = $('<meta>')
					// console.log(d)
					d.appendTo(H).attr('name','description');
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







window.Constructor.get_color = (c) ->
  @_make_pallette()
  if c.v is 'C'
    console.log("FROM_PALLETTE", c.ix in  @Site.colors.custom_pallette);
    if  c.ix of @Site.colors.custom_pallette
      console.log(c.ix)
      @Site.colors.custom_pallette[c.ix]
    else
      @Site.colors.custom_pallette[ 0 ]
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
  @layout_cont = $("<div>").css("position", "absolute").css("width", @layout.width + e).css("top", @Site.layout.padding.top).css("left", left).css("height", total_height).appendTo(to)
  c_off = @layout_cont.offset()
  to.css "top", "0px"

  @_main_offset = c_off
  @redraw_background()
  @_busy_regions = []
  @_moved_block_ = []

  bw = self._block_width(1)
  bh = self._block_height(1)
  bhp = self.Site.layout.grid.hor
  bvp = self.Site.layout.grid.ver
  gw = bw + (bhp * 2)
  gh = bh + (bvp * 2)
  gp = self.Site.layout.padding.left + self.Site.layout.grid.hor

  gmp = (gp - (bhp * 2))

  if not is_safari
    grad_function = 'linear-gradient'

    $("<div>").addClass("empty-block").appendTo(@layout_cont)
    .css("position", "absolute")
    .css("background-color", "transparent")
    .css("background-image", grad_function+"(90deg, rgba(0,0,0,.5) 1px, transparent 1px)," +
                       grad_function+"(90deg, rgba(255,255,255,.5) 2px, transparent 1px)," +
                       grad_function+"(90deg, rgba(255,255,255,.5) 2px, transparent 1px)," +
                       grad_function+"(90deg, rgba(0,0,0,.5) 1px, transparent 1px)," +
                       grad_function+"(0deg, rgba(0,0,0,.5) 1px, transparent 1px)," +
                       grad_function+"(0deg, rgba(255,255,255,.5) 2px, transparent 1px)," +
                       grad_function+"(0deg, rgba(255,255,255,.5) 2px, transparent 1px)," +
                       grad_function+"(0deg, rgba(0,0,0,.5) 1px, transparent 1px)")
    .css("background-size", gw + "px 1px,  " + gw + "px 1px,  " + gw + "px 1px,  " + gw + "px 1px, 1px " + gh + "px, 1px " + gh + "px, 1px " + gh + "px, 1px " + gh + "px  ")
    .css("background-position", gp + "px 0px, " + (gp + 1) + "px 0px, " + gmp + "px 0px, " + (gmp + 1) + "px 0px, 0px 0px,0px 1px, 0px -" + (bvp * 2) + "px,0px -" + ((bvp * 2) - 1) + "px")
    .css("left", 0)
    .css("top", 0).css("width", @Site.layout.width)
    .css("height", total_height)  if @is_constructor

  @inited_blocks = [] # Предназначение - последующий анбинд события клик после даблклика - включения панели управления
  @settings_over_block = false;

  hm = []
  $.each @Site.blocks, (ix, block) =>
    if block.display_on is "all"
      return  unless block.dont_display_on.indexOf(self.current_page) is -1
    else return  unless block.display_on is self.current_page
    set = self.getBlockSettings(ix)

    bw = (if set then set.border_width else 0)
    x = block.x # Number(koords.split(':')[0]);
    y = block.y # Number(koords.split(':')[1]);
    unless set.unsnap_to_grid

      xx = self._calc_left(x + 1) - bw
      yy = self._calc_top(y) - bw
    else
      xx = x
      yy = y
    w = block.width
    h = block.height
    unless set.unsnap_to_grid
      W = self._calc_width(w)
      H = self._calc_height(h)
    else
      W = w
      H = h
    gp =
      jq: $("<div>").appendTo(self.layout_cont).css("position", "absolute").css("left", xx).css("top", yy).width(W).css("height", H)
      .css("overflow", "hidden")
      pos: ix
    bl = self.init_block block, gp
    if bl
      offs = bl.offset()
      h = bl.height()
      hm.push(offs.top + h)
      @inited_blocks.push bl;
  @layout_cont.height(Math.max.apply(Math,hm))





window.Constructor.reapply_block_settings = (obj, widget)->
  sett = @getBlockSettings(obj.pos)
  @apply_block_settings(obj, sett, widget)

window.Constructor.apply_block_settings = (obj, settings, widget) ->
  if not widget.has_own_settings

    w = obj.jq #.children(":first")
    bl = @get_block(obj.pos)
    if widget.disobey.indexOf("border_color") is -1
      if typeof settings.border_color is "string"
        w.css "border-color", settings.border_color
      else
        if typeof settings.border_color is "undefined"
          settings.border_color =
            v: 0
            ix: 0
        color = @get_color(settings.border_color)
        c = hsvToRgb(color)
        w.css "border-color", c
    w.css "opacity", settings.bg_opacity  if widget.disobey.indexOf("bg_opacity") is -1
    if "border_radius" not  in widget.disobey
      w.css "-moz-border-radius" , settings.border_radius + "px"
      w.css "-webkit-border-radius" , settings.border_radius + "px"
      w.css "border-radius" , settings.border_radius + "px"


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
      if patt.type is "image"

        w.css "background", "url(" + patt.image + " ) repeat"
      else if patt.type is 'constructor'
        @renderPattern w, patt

      else
        @_draw_css_background w, patt.image
    if widget.depends_on_settings?
      widget.draw(settings)






window.Constructor.init_block = (bl, to) ->

  init_resizer = ->
  newWidget = (c, t, p, cp) ->
    A = t.Site.Applications[app_name]
    if A? and A.widgets[widget_name]?

      W = A.widgets[widget_name];
      wi = (->new W())();
      wi.init c, t, p, cp
      #console.log(c,t,p,cp)
      return wi
    else
      false
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
  unless Widget
    return false
  #log( widget_name, app_name)
  Widget.draw()
  # console.log("Widget test", bl.x, bl.y, bl.width, bl.height, app_name, widget_name, Widget.data);
  # settings = self.getBlockSettings(to.pos)
  #console.log("B", w.width() )
  # self.apply_block_settings to, settings, Widget
  if Widget.set.unsnap_to_grid
    W = bl.width
    H = bl.height

  # console.log("WH", W,H)

  make_draggable = (to)=>
    #console.log(to.jq)
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
        unless Widget.set.unsnap_to_grid
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
      control_panel = $("<div>").addClass('widget-control') .appendTo($("#controls"))
      #wco = self.init_block_cp(to, control_panel, Widget)
      #saving_data = (evt) =>
      #  Widget.save()  if Widget.save
      #  wco.save()
      #
      #
      #  @settings_over_block = false
      #  control_panel.remove()
      #  @redraw.apply self, []

      #if   @settings_over_block isnt false

      #  @settings_over_block.saving()
      #else
      #  @settings_over_block = {to:to, Widget:Widget, saving: saving_data }

      for bl in @inited_blocks
        bl.unbind "click dblclick"
        bl.draggable('destroy')
      #log("after loop",  to.jq.attr('class'))

      $("#controls>.widget-control").hide()
      control_panel.css("position", "absolute").position(
        of: w
        my: "left top"
        at: "right top"
        collision: "none none"
      ).css("border", "2px solid black").css("background-color", "white").draggable(scroll: false).css "padding", "10"


      Widget.settings control_panel  if Widget.settings

      #$("<div>").css("background-color", "orange").appendTo(to.jq).css("position", "absolute").position(
      #  of: to.jq
      #  my: "left top"
      #  at: "right top"
      #  collision: "none"
      #).addClass("ui-icon ui-icon-gripsmall-diagonal-se").width(20).height 20
      console.log(to.jq.parent());
      $("<div>").css("background-color", "green").appendTo(to.jq.parent()).css("position", "absolute").position(
        of: to.jq
        my: "left top"
        at: "left-20 top"
        collision: "none none"
      ).addClass("ui-icon ui-icon-gripsmall-diagonal-se").width(20).height(20).click =>
        Widget.save() if Widget.save #saving_data()
        @_save_site();
        control_panel.remove()
        self.redraw();

      $("<div>").css("background-color", "red").appendTo(to.jq.parent()).css("position", "absolute").position(
        of: to.jq
        my: "left top"
        at: "left-20 top+30"
        collision: "none none"
      ).addClass("ui-icon ui-icon-gripsmall-diagonal-se").width(20).height(20).click ->
        Widget.cancel()  if Widget.cancel

        control_panel.remove()
        # @settings_over_block = false
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
            unless Widget.set.unsnap_to_grid
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
    #console.log(to.jq)
    clc = (e) =>
      #console.log('silent click');

      $("#controls>.widget-control").hide()
      delete_marker.show().zIndex 1000
      resize_marker.show().zIndex 1000
    (->to.jq.on('click', clc))()
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


window.Constructor.renderPattern = (to, pattern)->
  # log(pattern)
  redraw_ctx = (image_obj) =>
    dr_im = (x, y, bx, by_) ->
      ctx.save()
      ctx.translate x, y
      ctx.scale Z, Z
      rad = A * (3.14 / 180)
      ctx.rotate rad
      ctx.globalAlpha = opacity / 100
      ctx.drawImage image_obj, -(iw / 2), -(ih / 2), iw, ih
      ctx.restore()
    Cjq.css("margin-left", (300 - base) / 2).css "margin-top", (300 - base) / 2
    C.width = base
    C.height = base
    iw = image_obj.width * Z
    ih = image_obj.height * Z
    if BG
      if "ix" of BG
        c = @get_color(BG)
      else
        c = BG
      c.a = GA
      ctx.fillStyle = hsvToRgb(c) # "rgba( 255,255, 255, 255)";
    ctx.rect 0, 0, C.width, C.height
    ctx.fill()
    ctx.save()
    ctx.clip()
    dr_im base / 2, base / 2
    dr_im 0, 0
    dr_im 0, base
    dr_im base, 0
    dr_im base, base
    ctx.closePath()
    ctx.restore()
    img = C.toDataURL()
    to.css "background", "url(" + img + ") repeat"


  exc_color = (img_) =>
    S.width = img_.width
    S.height = img_.height
    sctx.drawImage img_, 0, 0
    buffData = sctx.getImageData(0, 0, img_.width, img_.height)
    if "ix" of FG
      c = @get_color(FG)
    else
      c = FG
    FGA = hsvToRgb(c, true)
    x = 0
    while x < buffData.width
      y = 0
      while y < buffData.height
        ix = (x + (y * buffData.width)) * 4
        buffData.data[ix] = FGA[0] #red
        buffData.data[ix + 1] = FGA[1] #green
        buffData.data[ix + 2] = FGA[2] #blue
        y++
      x++
    sctx.putImageData buffData, 0, 0
    du = S.toDataURL()
    _I = new Image()
    _I.onload = -> redraw_ctx(_I)
    _I.src = du
  if pattern.base_image?
    img_src = pattern.base_image
    FG = pattern.FG
    BG = pattern.BG
    A = pattern.A
    Z = pattern.Z
    GA=pattern.GA
    base = pattern.base
    opacity = pattern.opacity
    Cjq = $('<canvas>') #.appendTo(flright)
    C   = Cjq[0]
    S = $('<canvas>')[0] #.appendTo(flright)[0]
    ctx = C.getContext('2d')
    sctx = S.getContext('2d')
    image_obj = $(new Image()).one('load', (e)=>
      exc_color(e.target)
    ).prop('src', img_src)

  else
     to.css "background", "url(" + pattern.image + ") repeat"
