(function() {
  var BASE_SITE, Constructor, DEBUG, Site, WI, back_icons_urls, caching, clone, default_app, default_site, getBlockSettings, getWidgetData, hsvToHex, hsvToRgb, is_ie, is_ie9, is_linux, is_safari, is_webkit, log, port, rect, rgb2hsv, scaleImage, test_block_content, _add_title, _block_height, _block_left, _block_width, _calc_height, _calc_left, _calc_top, _calc_width, _get_page_var, _make_pallette, _set_description, _set_keywords, _set_page_var, _stepping_height, _stepping_left, _stepping_top, _stepping_width, _uncalc_left, _uncalc_top,
    _this = this,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  log = function(){
			if (DEBUG){
				args =[];
				var E = new Error();
				if (E.stack != null){
					var f = E.stack.split('\n')[2].split('@')[0];
					var a = E.stack.split('\n')[2].split(':');

					var ln = parseInt(a[a.length-1])
					args.push('[' +f +':'+ln +']');
				}
				for (var i =0; i< arguments.length; i++){
					args.push(arguments[i]);
				}


				console.log.apply(console, args);
			}

		};

  scaleImage = function(img, maxWidth, maxHeight, useMax) {
    var h, height, scale, w, width;
    if (useMax == null) {
      useMax = false;
    }
    w = img.width;
    h = img.height;
    width = img.width;
    height = img.height;
    if (useMax) {
      scale = Math.max(maxWidth / width, maxHeight / height);
    } else {
      scale = Math.min(maxWidth / width, maxHeight / height);
    }
    width = parseInt(width * scale, 10);
    height = parseInt(height * scale, 10);
    img.width = width;
    img.height = height;
    return img;
  };

  if (window.location.port === '8000') {
    BASE_SITE = "test.be-test.com:8000";
  } else {
    BASE_SITE = 'www.be-web.ru';
  }

  DEBUG = true;

  clone = function clone(obj) {
			// Handle the 3 simple types, and null or undefined
			if (null == obj || "object" != typeof obj) return obj;

			// Handle Date
			if (obj instanceof Date) {
				 var copy = new Date();
				 copy.setTime(obj.getTime());
				 return copy;
			}

			// Handle Array
			if (obj instanceof Array) {
				 var copy = [];
				 for (var i = 0, len = obj.length; i < len; i++) {
					 copy[i] = clone(obj[i]);
				 }
				 return copy;
			}

			// Handle Object
			if (obj instanceof Object) {
				 var copy = {};
				 for (var attr in obj) {
					 if (obj.hasOwnProperty(attr)) copy[attr] = clone(obj[attr]);
				 }
				 return copy;
			}

			throw new Error("Unable to copy obj! Its type isn't supported.");
			};

  rgb2hsv = function rgb2hsv () {
				 var rr, gg, bb,
				r = arguments[0] / 255,
				g = arguments[1] / 255,
				b = arguments[2] / 255,
				h, s,
				v = Math.max(r, g, b),
				diff = v - Math.min(r, g, b),
				diffc = function(c){
					return (v - c) / 6 / diff + 1 / 2;
				};

				 if (diff == 0) {
				h = s = 0;
				 } else {
				s = diff / v;
				rr = diffc(r);
				gg = diffc(g);
				bb = diffc(b);

				if (r === v) {
					h = bb - gg;
				}else if (g === v) {
					h = (1 / 3) + rr - bb;
				}else if (b === v) {
					h = (2 / 3) + gg - rr;
				}
				if (h < 0) {
					h += 1;
				}else if (h > 1) {
					h -= 1;
				}
				 }
				 return {
				h: Math.round(h * 360),
				s: Math.round(s * 100),
				b: Math.round(v * 100)
				 };
		}
		;

  hsvToRgb = function(o, as_array, no_opacity) {
    var a, b, bb, f, g, gg, h, i, p, q, r, rr, s, t, v;
    if (as_array == null) {
      as_array = false;
    }
    if (no_opacity == null) {
      no_opacity = false;
    }
    h = Math.max(0, Math.min(360, o.h));
    s = Math.max(0, Math.min(100, o.s));
    v = Math.max(0, Math.min(100, o.b));
    v = o.b != null ? o.b : o.v;
    s /= 100;
    v /= 100;
    if (s === 0) {
      r = g = b = v;
    } else {
      h /= 60;
      i = Math.floor(h);
      f = h - i;
      p = v * (1 - s);
      q = v * (1 - s * f);
      t = v * (1 - s * (1 - f));
      switch (i) {
        case 0:
          r = v;
          g = t;
          b = p;
          break;
        case 1:
          r = q;
          g = v;
          b = p;
          break;
        case 2:
          r = p;
          g = v;
          b = t;
          break;
        case 3:
          r = p;
          g = q;
          b = v;
          break;
        case 4:
          r = t;
          g = p;
          b = v;
          break;
        default:
          r = v;
          g = p;
          b = q;
      }
    }
    if (as_array) {
      return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255), Math.round(o.a * 255)];
    } else {
      rr = Math.round(r * 255);
      gg = Math.round(g * 255);
      bb = Math.round(b * 255);
      if (typeof o.a !== "undefined") {
        a = o.a;
      } else {
        a = 1;
      }
      if (no_opacity || !isOpacitySupported()) {
        return "rgb(" + rr + "," + gg + "," + bb + ")";
      } else {
        return "rgba(" + rr + "," + gg + "," + bb + "," + a + ")";
      }
    }
  };

  hsvToHex = function(o) {
    var a, componentToHex;
    componentToHex = function(c) {
      var hex;
      hex = c.toString(16);
      if (hex.length === 1) {
        return "0" + hex;
      } else {
        return hex;
      }
    };
    a = hsvToRgb(o, true);
    return "#" + componentToHex(a[0]) + componentToHex(a[1]) + componentToHex(a[2]);
  };

  window.base64_encode = function  (data) {
  // http://kevin.vanzonneveld.net
  // +   original by: Tyler Akins (http://rumkin.com)
  // +   improved by: Bayron Guevara
  // +   improved by: Thunder.m
  // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
  // +   bugfixed by: Pellentesque Malesuada
  // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
  // +   improved by: Rafał Kukawski (http://kukawski.pl)
  // *     example 1: base64_encode('Kevin van Zonneveld');
  // *     returns 1: 'S2V2aW4gdmFuIFpvbm5ldmVsZA=='
  // mozilla has this native
  // - but breaks in 2.0.0.12!
  //if (typeof this.window['btoa'] === 'function') {
  //    return btoa(data);
  //}
  var b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
  var o1, o2, o3, h1, h2, h3, h4, bits, i = 0,
    ac = 0,
    enc = "",
    tmp_arr = [];

  if (!data) {
    return data;
  }

  do { // pack three octets into four hexets
    o1 = data.charCodeAt(i++);
    o2 = data.charCodeAt(i++);
    o3 = data.charCodeAt(i++);

    bits = o1 << 16 | o2 << 8 | o3;

    h1 = bits >> 18 & 0x3f;
    h2 = bits >> 12 & 0x3f;
    h3 = bits >> 6 & 0x3f;
    h4 = bits & 0x3f;

    // use hexets to index into b64, and append result to encoded string
    tmp_arr[ac++] = b64.charAt(h1) + b64.charAt(h2) + b64.charAt(h3) + b64.charAt(h4);
  } while (i < data.length);

  enc = tmp_arr.join('');

  var r = data.length % 3;

  return (r ? enc.slice(0, r - 3) : enc) + '==='.slice(r || 3);

}
;

  window.hsvToRgb = hsvToRgb;

  window.hsvToHex = hsvToHex;

  default_site = {
    _Apps: ['generic.' + BASE_SITE],
    layout: {
      cols: 12,
      fixed: true,
      grid: {
        hor: 10,
        ver: 5
      },
      padding: {
        left: 10,
        top: 10
      },
      width: 960,
      drawen_lines: 30,
      base_height: 50
    },
    colors: {
      type: 'mono',
      base: 120,
      brightness: 100,
      lights: 50,
      saturation: 100,
      shadows: 50
    },
    patterns: [],
    blocks: [
      {
        x: 0,
        y: 0,
        width: 3,
        height: 3,
        widget: {
          name: 'text.generic.' + BASE_SITE,
          data: test_block_content
        },
        display_on: 'all',
        dont_display_on: []
      }, {
        x: 3,
        y: 0,
        width: 4,
        height: 2,
        widget: {
          name: 'text.generic.' + BASE_SITE,
          data: test_block_content
        },
        display_on: '',
        dont_display_on: []
      }, {
        x: 7,
        y: 0,
        width: 5,
        height: 2,
        widget: {
          name: 'image.generic.' + BASE_SITE,
          data: {}
        },
        display_on: 'about',
        dont_display_on: []
      }
    ],
    default_block_settings: false,
    seo: {
      title: 'Unknown site'
    },
    pages: {
      "": {
        layout: "same",
        title: "Main",
        show_in_menu: true,
        removable: true
      },
      "about": {
        layout: 'same',
        title: "About",
        removable: true,
        show_in_menu: true
      }
    }
  };

  default_app = "{name:'MyApplication',\ntitle:\"My application\",\nroles:['client','manager'],\ndefault_role:'client',\ndata:{product:{view:['client','manager'],\n 			add:['manager'],\n		del:['manager'] } },\n	Main: function(){\n		 // put here some code\n		 var obj = { title : 'new application',\n		 admin_page: function(to){}, /* page shown in admin interface */\n		 widgets: {widget_name:'',\n					 title:'', // Title diaplaed on admin page in `widgets menu.\n					 default_size: [3,1], // default size, when placed on grid\n					 init:function(my_cont,	constructor_inst, pos, cp){\n						//my_cont - is container div of widget - place to draw data\n						// constructor_inst - global pointer to constracting javascript object\n						// pos - index of a block in the blocks array\n						// cp - control page div - designed to place specific content in settings div, if needed\n					var o = {\n		 				disobey:['padding_left_right', 'padding_top'], // settings field, that sholdn't be applied to this widget\n						draw : function(){}, // function to draw widget on the page\n						settings: function(){}, // function called, when edit functions activated\n						save : function(){}, //save widget on the page\n						cancel : function(){}, // cancel edits\n						jq:{} // MUST be created - root element of this widget\n						}\n					return o\n\n\n				 }\n			 } // widgets, that culd be placed on pages\n		 };\n		 return obj\n	},\n	getter: function(){\n		return this.Main()\n	} }";

  test_block_content = "Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt, explicabo. Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos, qui ratione voluptatem sequi nesciunt, neque porro quisquam est, qui dolorem ipsum, quia dolor sit, amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt, ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit, qui in ea voluptate velit esse, quam nihil molestiae consequatur, vel illum, qui dolorem eum fugiat, quo voluptas nulla pariatur? At vero eos et accusamus et iusto odio dignissimos ducimus, qui blanditiis praesentium voluptatum deleniti atque corrupti, quos dolores et quas molestias excepturi sint, obcaecati cupiditate non provident, similique sunt in culpa, qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio, cumque nihil impedit, quo minus id, quod maxime placeat, facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet, ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.";

  Site = false;

  port = window.location.port;

  back_icons_urls = ['/static/images/back_constr/fg/icons_02.png', '/static/images/back_constr/fg/icons_06.png', '/static/images/back_constr/fg/icons_10.png', '/static/images/back_constr/fg/icons_12.png', '/static/images/back_constr/fg/icons_15.png', '/static/images/back_constr/fg/icons_16.png', '/static/images/back_constr/fg/icons_18.png', '/static/images/back_constr/fg/icons_20.png', '/static/images/back_constr/fg/icons_22.png', '/static/images/back_constr/fg/icons_28.png', '/static/images/back_constr/fg/icons_29.png', '/static/images/back_constr/fg/icons_31.png', '/static/images/back_constr/fg/icons_32.png', '/static/images/back_constr/fg/icons_33.png', '/static/images/back_constr/fg/icons_41.png', '/static/images/back_constr/fg/icons_45.png', '/static/images/back_constr/fg/icons_47.png', '/static/images/back_constr/fg/icons_52.png', '/static/images/back_constr/fg/icons_54.png', '/static/images/back_constr/fg/icons_58.png', '/static/images/back_constr/fg/icons_62.png', '/static/images/back_constr/fg/icons_65.png', '/static/images/back_constr/fg/icons_70.png', '/static/images/back_constr/fg/icons_73.png', '/static/images/back_constr/fg/icons_76.png', '/static/images/back_constr/fg/icons_81.png'];

  is_safari = /Safari/.test(navigator.userAgent) && !/Chrome/.test(navigator.userAgent);

  is_webkit = /WebKit/.test(navigator.userAgent);

  is_ie = /MSIE/.test(navigator.userAgent);

  is_ie9 = /MSIE 9.0/.test(navigator.userAgent);

  is_linux = /Linux/.test(navigator.userAgent);

  window.isCanvasSupported = function() {
    var el;
    el = document.createElement('canvas');
    return (el.getContext != null) && ((el.getContext('2d')) != null);
  };

  window.isOpacitySupported = function() {
    return $('body')[0].style.opacity != null;
  };

  window.initArray = function(){
	if (!Array.prototype.indexOf)
	{
		Array.prototype.indexOf = function(elt /*, from*/)
		{
			var len = this.length >>> 0;

			var from = Number(arguments[1]) || 0;
			from = (from < 0)
					 ? Math.ceil(from)
					 : Math.floor(from);
			if (from < 0)
				from += len;

			for (; from < len; from++)
			{
				if (from in this &&
						this[from] === elt)
					return from;
			}
			return -1;
		};
	}
};

  Constructor = (function() {
    function Constructor() {
      this.init = function(do_constr, site_id) {
        var _this = this;
        if (do_constr == null) {
          do_constr = false;
        }
        window.DB = init_db(window.csrf);
        window.initArray();
        this.site_id = site_id;
        this._site_type = "sites";
        this.is_constructor = do_constr;
        this.page_cont = $('#id-top-cont');
        this.default_app = default_app;
        $(window).bind('resize', function() {
          return _this.redraw();
        });
        if (window.PATTERNS_REPR != null) {
          window.PATTERNS = JSON.parse(window.PATTERNS_REPR);
        }
        if (window.APP_EGGS_REPR != null) {
          window.APP_EGGS = JSON.parse(window.APP_EGGS_REPR);
        }
        window.onhashchange = function() {
          _this._init_page();
          return _this.redraw();
        };
        if (this.is_constructor) {
          this.init_cp_marker();
        }
        return this.redraw();
      };
    }

    return Constructor;

  })();

  window.Constructor = new Constructor();

  $(document).bind("ready", function(e) {
    return window.Constructor.init(window.is_constructor, window.site_id);
  });

  window.setFont = function(jq, fontfamily) {
    return jq.css('font-family', fontfamily);
  };

  window.WidgetIniter = function() {
    this.default_size = [3, 1];
    this.disobey = [];
    this.redraw = function() {
      this.my_cont.find("*").remove();
      return this.draw();
    };
    this.__remove_blob = function(id) {
      return DB.remove_blob(id);
    };
    this._data = function() {
      if (this.data) {
        if (typeof this.data === 'object') {
          return jQuery.extend(true, {}, this.data);
        } else {
          return this.data;
        }
      } else {
        return this._def_data;
      }
    };
    this.init = function(my_cont, constructor_inst, pos, cp) {
      this.set = constructor_inst.getBlockSettings(pos);
      this.data = constructor_inst.getWidgetData(pos);
      this.my_cont = my_cont;
      this.pos = pos;
      this.constructor_inst = constructor_inst;
      this.C = constructor_inst;
      return this;
    };
    this.draw = function() {
      this.apply_block_settings(false);
      return this._draw();
    };
    this.save = function() {
      if (this._save) {
        this._save();
      }
      this.C.setWidgetData(this.pos, this.data);
      return this.C.setBlockSettings(this.pos, this.set);
    };
    this.remove = function() {
      if (this._remove) {
        return this._remove();
      }
    };
    this.cancel = function() {
      if (this._cancel) {
        this._cancel();
      }
      return this.redraw.apply(this, []);
    };
    this.settings = function(cp) {
      this._init_block_cp(cp);
      if (this._settings != null) {
        this._settings(cp);
      }
      return cp.show();
    };
    this._init_block_cp = function(to) {
      var cb, cl, lhs, li, m, o, old_settings, onCancel, onColorChoice, onPatternChoice, onSave, plr, pt, self, settings, ul, vf, w;
      cb = void 0;
      cl = void 0;
      lhs = void 0;
      li = void 0;
      m = void 0;
      o = void 0;
      old_settings = void 0;
      onCancel = void 0;
      onColorChoice = void 0;
      onPatternChoice = void 0;
      onSave = void 0;
      plr = void 0;
      pt = void 0;
      self = void 0;
      settings = void 0;
      ul = void 0;
      vf = void 0;
      w = void 0;
      m = $("<div>").appendTo(to);
      self = this;
      old_settings = $.extend(true, {}, this.set);
      onPatternChoice = function(pattern) {
        self.set.background = {
          type: "pattern",
          pattern: pattern
        };
        return self.apply_block_settings();
      };
      onColorChoice = function(color, pal_ix, hsba) {
        if (color === "clear") {
          self.set.background = {
            type: "none"
          };
        } else {
          self.set.background = {
            type: "color",
            color: pal_ix
          };
        }
        return self.apply_block_settings();
      };
      onCancel = function() {
        this.set = old_settings;
        self.apply_block_settings();
        return $(this).dialog("close");
      };
      onSave = function() {
        return $(this).dialog("close");
      };
      cl = $("<button>").button().text("Выбор фона").click(function() {
        return self.C.drawBackgroundSelectorDialog(onPatternChoice, onColorChoice, onCancel, onSave);
      }).appendTo(m);
      cl = $("<button>").button().text("выбрать цвет рамки").click(function() {
        var cc;
        cb = void 0;
        cc = void 0;
        cb = function(col, ix) {
          if (col !== "clear") {
            self.set.border_color = ix;
            return self.apply_block_settings();
          }
        };
        cc = self.C.draw_color_chooser(cb);
        return cc.appendTo(to).position({
          of: this,
          my: "left top",
          at: "left top"
        });
      }).appendTo(m);
      cl = $("<button>").button().text("выбрать цвет текста").click(function() {
        var cc;
        cb = void 0;
        cc = void 0;
        cb = function(col, ix) {
          if (col !== "clear") {
            self.set.text_color = ix;
            return self.apply_block_settings();
          }
        };
        cc = self.C.draw_color_chooser(cb);
        return cc.appendTo(to).position({
          of: this,
          my: "left top",
          at: "left top"
        });
      }).appendTo(m);
      vf = function(a, d) {
        if (typeof a === "undefined") {
          return d;
        } else {
          return a;
        }
      };
      ul = $("<ul>").appendTo(m).addClass("cp-ul");
      li = $("<li>").appendTo(ul);
      $("<span>").text("Прозрачность блока").appendTo(li);
      $("<div>").width(250).slider({
        min: 0,
        max: 100,
        value: vf(self.set.bg_opacity, 100) * 100,
        slide: function(event, ui) {
          self.set.bg_opacity = ui.value / 100;
          return self.apply_block_settings();
        }
      }).appendTo(li);
      li = $("<li>").appendTo(ul);
      $("<span>").text("Радиус границы").appendTo(li);
      $("<div>").width(250).slider({
        min: 0,
        max: 100,
        value: vf(self.set.border_radius, 0),
        slide: function(event, ui) {
          self.set.border_radius = ui.value;
          return self.apply_block_settings();
        }
      }).appendTo(li);
      li = $("<li>").appendTo(ul);
      $("<span>").text("Ширина границы").appendTo(li);
      $("<div>").width(250).slider({
        min: 0,
        max: 100,
        value: vf(self.set.border_width, 0) * 10,
        slide: function(event, ui) {
          self.set.border_width = ui.value / 10;
          return self.apply_block_settings();
        }
      }).appendTo(li);
      li = $("<li>").appendTo(ul);
      $("<span>").text("Межстрочный интервал").appendTo(li);
      lhs = $("<div>").width(250).slider({
        min: 0,
        max: 300,
        value: vf(self.set.line_height, 1) * 10,
        slide: function(event, ui) {
          self.set.line_height = ui.value / 10;
          return self.apply_block_settings();
        }
      }).appendTo(li);
      li = $("<li>").appendTo(ul);
      $("<span>").text("Размер шрифта").appendTo(li);
      $("<div>").width(250).slider({
        min: 0,
        max: 300,
        value: vf(self.set.font_size, 10) * 10,
        slide: function(event, ui) {
          self.set.font_size = ui.value / 10;
          return self.apply_block_settings();
        }
      }).appendTo(li);
      li = $("<li>").appendTo(ul);
      $("<span>").text("отступ сверху").appendTo(li);
      pt = (self.set.padding_top ? self.set.padding_top * 10 : 0);
      $("<div>").width(250).slider({
        min: 0,
        max: 300,
        value: pt,
        slide: function(event, ui) {
          self.set.padding_top = ui.value / 10;
          return self.apply_block_settings();
        }
      }).appendTo(li);
      li = $("<li>").appendTo(ul);
      $("<span>").text("Отступ слева-справа").appendTo(li);
      plr = (self.set.padding_left_right ? self.set.padding_left_right * 10 : 0);
      $("<div>").width(250).slider({
        min: 0,
        max: 300,
        value: plr,
        slide: function(event, ui) {
          self.set.padding_left_right = ui.value / 10;
          return self.apply_block_settings();
        }
      }).appendTo(li);
      $("<label for='available_all_pages'>").appendTo(m).append("Показывать на всех страницах");
      cb = $("<input type='checkbox' id='available_all_pages'>").appendTo(m).click(function() {
        if (self.C.Site.blocks[self.pos].display_on === "all") {
          return self.C.Site.blocks[self.pos].display_on = self.current_page;
        } else {
          return self.C.Site.blocks[self.pos].display_on = "all";
        }
      });
      cb.prop("checked", self.C.Site.blocks[self.pos].display_on === "all");
      $("<br>").appendTo(m);
      $("<label for='unsnap_to_grid'>").appendTo(m).append("Свободный блок");
      cb = $("<input type='checkbox' id='unsnap_to_grid'>").appendTo(m).click(function() {
        var bl;
        self.set.unsnap_to_grid = this.checked;
        bl = self.C.get_block(self.pos);
        if (this.checked) {
          self.C.move_block(self.pos, self.C._calc_left(bl.x + 1) + self.set.border_width, self.C._calc_top(bl.y) + self.set.border_width, true);
          self.C.Site.blocks[self.pos].width = self.C._calc_width(bl.width);
          return self.C.Site.blocks[self.pos].height = self.C._calc_height(bl.height);
        } else {
          self.C.move_block(self.pos, Math.round(self.C._uncalc_left(bl.x) + self.set.border_width), Math.round(self.C._uncalc_top(bl.y) + self.set.border_width), true);
          self.C.Site.blocks[self.pos].width = Math.round(self.C.Site.blocks[self.pos].width / self.C._block_width());
          return self.C.Site.blocks[self.pos].height = Math.round(self.C.Site.blocks[self.pos].height / self.C._block_height());
        }
      });
      cb.prop("checked", self.set.unsnap_to_grid);
      $("<br>").appendTo(m);
      cl = $("<button>").button().text("Применить для всех новых блоков").click(function() {
        self.C.Site.default_block_settings = self.set;
        self.C.redraw();
        return m.remove();
      }).css("display", "block").css("padding", "5px").css("margin-bottom", "10px").appendTo(m);
      cl = $("<button>").button().text("Применить для всех имеющихся блоков").click(function() {
        self.C.Site.default_block_settings = self.set;
        $.each(self.C.Site.blocks, function(i, bl) {
          return delete bl["settings"];
        });
        self.C.redraw();
        return to.remove();
      }).appendTo(m).css("display", "block").css("padding", "5px").css("margin-bottom", "10px");
      o = {
        save: function() {
          return self.C.setBlockSettings(obj.pos, self.set);
        },
        cancel: function() {}
      };
      return o;
    };
    return this.apply_block_settings = function(follow) {
      var C, appl, background, border_color, border_radius, border_width, f, font_size, k, line_height, opacity, padding_left_right, padding_top, text_color;
      if (follow == null) {
        follow = true;
      }
      C = this.my_cont.parent();
      border_color = function() {
        var c, color;
        if (this.set.border_color != null) {
          if (typeof this.set.border_color === "string") {
            return C.css("border-color", this.set.border_color);
          } else {
            color = this.C.get_color(this.set.border_color);
            c = hsvToRgb(color);
            return C.css("border-color", c);
          }
        }
      };
      opacity = function() {
        if (isOpacitySupported()) {
          return this.my_cont.css("opacity", this.set.bg_opacity);
        }
      };
      border_radius = function() {
        C.css("-moz-border-radius", this.set.border_radius + "px");
        C.css("-webkit-border-radius", this.set.border_radius + "px");
        return C.css("border-radius", this.set.border_radius + "px");
      };
      border_width = function() {
        var bl, xx, yy;
        bl = this.C.get_block(this.pos);
        if (!this.set.unsnap_to_grid) {
          xx = this.C._calc_left(bl.x + 1) - this.set.border_width;
          yy = this.C._calc_top(bl.y) - this.set.border_width;
        } else {
          xx = bl.x;
          yy = bl.y;
        }
        C.css("border-width", this.set.border_width + "px");
        C.css("left", xx);
        C.css("top", yy);
        return C.css("border-style", "solid");
      };
      line_height = function() {
        return C.css("line-height", this.set.line_height + "px");
      };
      font_size = function() {
        return C.css("font-size", this.set.font_size + "px");
      };
      padding_left_right = function() {
        var W;
        W = C.width();
        C.children().eq(0).css("margin-left", this.set.padding_left_right + "px");
        C.children().eq(0).css("margin-right", this.set.padding_left_right + "px");
        return C.children().eq(0).width(W - this.set.padding_left_right * 2);
      };
      padding_top = function() {
        return C.children().eq(0).css("padding-top", this.set.padding_top + "px");
      };
      background = function() {
        var c, color, patt;
        if (this.set.background.type === "color") {
          if (typeof this.set.background.color === "string") {
            return C.css("background", this.set.background.color);
          } else {
            color = this.C.get_color(this.set.background.color);
            c = hsvToRgb(color);
            return C.css("background", c);
          }
        } else if (this.set.background.type === "none") {
          return C.css("background", "");
        } else if (this.set.background.type === "pattern") {
          patt = this.set.background.pattern;
          if (patt.type === "image") {
            return C.css("background", "url(" + patt.image + " ) repeat");
          } else if (patt.type === "constructor") {
            return this.C.renderPattern(C, patt);
          } else {
            return this.C._draw_css_background(C, patt.image);
          }
        }
      };
      text_color = function() {
        if (this.set.text_color) {
          return C.css("color", hsvToRgb(this.C.get_color(this.set.text_color)));
        }
      };
      appl = {
        border_color: border_color,
        opacity: opacity,
        border_radius: border_radius,
        border_width: border_width,
        padding_top: padding_top,
        padding_left_right: padding_left_right,
        background: background,
        font_size: font_size,
        line_height: line_height,
        text_color: text_color
      };
      for (k in appl) {
        f = appl[k];
        if (this.do_not_apply != null) {
          if (this.do_not_apply.indexOf(k) === -1) {
            f.apply(this);
          }
        } else {
          f.apply(this);
        }
      }
      if (this.need_redraw && follow) {
        return this._draw();
      }
    };
  };

  WI = function WidgetIniter(){
		this.default_size = [3,1];
		this.disobey = [];
		this.redraw = function(){
				this.my_cont.find('*').remove()
				this.draw();
		};
		this._data = function(){
				//console.log(">>>>",this.data);
				return this.data?this.data:this._def_data}

		this.init = function(my_cont, constructor_inst, pos, cp){
				this.set = constructor_inst.getBlockSettings(pos)
				this.data		 = constructor_inst.getWidgetData(pos)
				this.my_cont = my_cont;
				this.pos = pos;
				this.constructor_inst = constructor_inst;
				this.C = constructor_inst;
				return this;
		}
		this.draw = function(){
				// console.log('fdfdf')
				this.apply_block_settings()
				this._draw()


		}
		this.save = function(){
				if (this._save)this._save();

				this.C.setWidgetData(this.pos, this.data)
				this.C.setBlockSettings(this.pos, this.set);
		};
		this.cancel = function(){if (this._cancel)this._cancel();};
	
		this.settings = function( cp ){ 
		this._init_block_cp( cp );
				if (this._settings != null ) {this._settings(cp);}
		cp.show();
		};
	
		this._init_block_cp = function(to) {
			var cb, cl, lhs, li, m, o, old_settings, onCancel, onColorChoice, onPatternChoice, onSave, plr, pt, self, settings, ul, vf, w;
			m = $("<div>").appendTo(to);
			self = this;
			old_settings = $.extend(true, {}, this.set);

			onPatternChoice = function(pattern) {
				self.set.background = {
					type: "pattern",
					pattern: pattern
				};
				return self.apply_block_settings();
			};

			onColorChoice = function(color, pal_ix, hsba) {
				if (color === "clear") {
					self.set.background = {
						type: "none"
					};
				} else {
					self.set.background = {
						type: "color",
						color: pal_ix
					};
				}
				return self.apply_block_settings();
			};
			onCancel = function() {
				this.set = old_settings;
				self.apply_block_settings();
				return $(this).dialog("close");
			};
			onSave = function() {
				return $(this).dialog("close");
			};

				cl = $("<button>").button().text("Выбор фона").click(function() {
					return self.C.drawBackgroundSelectorDialog(onPatternChoice, onColorChoice, onCancel, onSave);
				}).appendTo(m);

				cl = $("<button>").button().text("выбрать цвет рамки").click(function() {
					var cb, cc;
					cb = function(col, ix) {
						if (col !== "clear") {
							self.set.border_color = ix;
							return self.apply_block_settings();
						}
					};
					cc = self.C.draw_color_chooser(cb);
					return cc.appendTo(to).position({
						of: this,
						my: "left top",
						at: "left top"
					});
				}).appendTo(m);
				cl = $("<button>").button().text("выбрать цвет текста").click(function() {
					var cb, cc;
					cb = function(col, ix) {
						if (col !== "clear") {
							self.set.text_color = ix;
							return self.apply_block_settings();
						}
					};
					cc = self.C.draw_color_chooser(cb);
					return cc.appendTo(to).position({
						of: this,
						my: "left top",
						at: "left top"
					});
				}).appendTo(m);


			vf = function(a, d) {
				if (typeof a === "undefined") {
					return d;
				} else {
					return a;
				}
			};


			ul = $("<ul>").appendTo(m).addClass("cp-ul");

				li = $("<li>").appendTo(ul);
				$("<span>").text("Прозрачность блока").appendTo(li);
				$("<div>").width(250).slider({
					min: 0,
					max: 100,
					value: vf(self.set.bg_opacity, 100) * 100,
					slide: function(event, ui) {
						self.set.bg_opacity = ui.value / 100;
						return self.apply_block_settings();
					}
				}).appendTo(li);

				li = $("<li>").appendTo(ul);
				$("<span>").text("Радиус границы").appendTo(li);
				$("<div>").width(250).slider({
					min: 0,
					max: 100,
					value: vf(self.set.border_radius, 0),
					slide: function(event, ui) {
						self.set.border_radius = ui.value;
						return self.apply_block_settings();
					}
				}).appendTo(li);
				li = $("<li>").appendTo(ul);
				$("<span>").text("Ширина границы").appendTo(li);
				$("<div>").width(250).slider({
					min: 0,
					max: 100,
					value: vf(self.set.border_width, 0) * 10,
					slide: function(event, ui) {
						self.set.border_width = ui.value / 10;
						return self.apply_block_settings();
					}
				}).appendTo(li);
				li = $("<li>").appendTo(ul);
				$("<span>").text("Межстрочный интервал").appendTo(li);
				lhs = $("<div>").width(250).slider({
					min: 0,
					max: 300,
					value: self.set.line_height,
					slide: function(event, ui) {
						self.set.line_height = ui.value / 10;
						return self.apply_block_settings();
					}
				}).appendTo(li);
				li = $("<li>").appendTo(ul);
				$("<span>").text("Размер шрифта").appendTo(li);
				$("<div>").width(250).slider({
					min: 0,
					max: 300,
					value: self.set.font_size,
					slide: function(event, ui) {
						self.set.font_size = ui.value / 10;
						return self.apply_block_settings();
					}
				}).appendTo(li);
				li = $("<li>").appendTo(ul);
				$("<span>").text("отступ сверху").appendTo(li);
				pt = (self.set.padding_top ? self.set.padding_top * 10 : 0);
				$("<div>").width(250).slider({
					min: 0,
					max: 300,
					value: pt,
					slide: function(event, ui) {
						self.set.padding_top = ui.value / 10;
						return self.apply_block_settings();
					}
				}).appendTo(li);
				li = $("<li>").appendTo(ul);
				$("<span>").text("Отступ слева-справа").appendTo(li);
				plr = (self.set.padding_left_right ? self.set.padding_left_right * 10 : 0);
				$("<div>").width(250).slider({
					min: 0,
					max: 300,
					value: plr,
					slide: function(event, ui) {
						self.set.padding_left_right = ui.value / 10;
						return self.apply_block_settings();
					}
				}).appendTo(li);

			$("<label for='available_all_pages'>").appendTo(m).append("Показывать на всех страницах");
			cb = $("<input type='checkbox' id='available_all_pages'>").appendTo(m).click(function() {
				if (self.C.Site.blocks[self.pos].display_on === "all") {
					return self.C.Site.blocks[self.pos].display_on = self.current_page;
				} else {
					return self.C.Site.blocks[self.pos].display_on = "all";
				}
			});

			cb.prop("checked", self.C.Site.blocks[self.pos].display_on === "all");
			$("<br>").appendTo(m);
			$("<label for='unsnap_to_grid'>").appendTo(m).append("Свободный блок");
			cb = $("<input type='checkbox' id='unsnap_to_grid'>").appendTo(m).click(function() {
				self.set.unsnap_to_grid = this.checked;
				var bl = self.C.get_block(self.pos);
				if (this.checked) {
						self.C.move_block(self.pos, self.C._calc_left(bl.x + 1) + self.set.border_width, self.C._calc_top(bl.y ) + self.set.border_width, true);

						self.C.Site.blocks[self.pos].width = self.C._calc_width(bl.width);
						self.C.Site.blocks[self.pos].height = self.C._calc_height(bl.height);
				} else {
					self.C.move_block(self.pos, Math.round(self.C._uncalc_left(bl.x) + self.set.border_width), Math.round(self.C._uncalc_top(bl.y) + self.set.border_width), true);
					self.C.Site.blocks[self.pos].width = Math.round(self.C.Site.blocks[self.pos].width / self.C._block_width())
					self.C.Site.blocks[self.pos].height = Math.round(self.C.Site.blocks[self.pos].height	/ self.C._block_height())
				}
			});
			cb.prop("checked", self.set.unsnap_to_grid);
			$("<br>").appendTo(m);
			cl = $("<button>").button().text("Применить для всех новых блоков").click(function() {
				self.C.Site.default_block_settings = self.set;
				self.C.redraw();
				return m.remove();
			}).css("display", "block").css("padding", "5px").css("margin-bottom", "10px").appendTo(m);
			cl = $("<button>").button().text("Применить для всех имеющихся блоков").click(function() {
				self.C.Site.default_block_settings = self.set;
				$.each(self.C.Site.blocks, function(i, bl) {
					return delete bl["settings"];
				});
				self.C.redraw();
				return to.remove();
			}).appendTo(m).css("display", "block").css("padding", "5px").css("margin-bottom", "10px");
			o = {
				save: function() {
					//console.log('save')
					return self.C.setBlockSettings(obj.pos, self.set);
				},
				cancel: function() {}
			};
			return o;
		};

		this.apply_block_settings = function(){
				var C = this.my_cont.parent();
				var border_color = function(){
						if (this.set.border_color != null) {
								//console.log(this.set.border_color)
								if (typeof this.set.border_color === 'string'){
										C.css('border-color', this.set.border_color);
								}else{

										var color = this.C.get_color(this.set.border_color);
										c = hsvToRgb(color);
										C.css("border-color", c );
								}
						}
				}
				var opacity = function(){
						this.my_cont.css("opacity", this.set.bg_opacity);
				}
				var	border_radius = function(){
						C.css("-moz-border-radius", this.set.border_radius + "px");
						C.css("-webkit-border-radius", this.set.border_radius + "px");
						C.css("border-radius", this.set.border_radius + "px");
				}

				var border_width = function(){
									 bl = this.C.get_block(this.pos);
									if (!this.set.unsnap_to_grid) {
										xx = this.C._calc_left(bl.x + 1) - this.set.border_width;
										yy = this.C._calc_top(bl.y) - this.set.border_width;
									} else {
										xx = bl.x;
										yy = bl.y;
									}
									C.css("border-width", this.set.border_width + "px");
									C.css("left", xx);
									C.css("top", yy);
									C.css("border-style", "solid");
				}
				var line_height = function(){
						C.css("line-height", this.set.line_height + "px");

				}
				var font_size = function(){
						 C.css("font-size", this.set.font_size + "px");

				}
				var padding_left_right = function(){
						//C = w.children().eq(0);
						var W = C.width();
						C.children().eq(0).css("margin-left", this.set.padding_left_right + "px");
						C.children().eq(0).css("margin-right", this.set.padding_left_right + "px");
						C.children().eq(0).width(W - this.set.padding_left_right * 2);

				}
				var padding_top = function(){
						C.children().eq(0).css("padding-top", this.set.padding_top + "px");
				}
				var background = function(){
						if (this.set.background.type === "color") {

								if (typeof this.set.background.color === "string") {
									C.css("background", this.set.background.color);
								} else {
									color = this.C.get_color(this.set.background.color);
									c = hsvToRgb(color);
									C.css("background", c);
								}

						} else if (this.set.background.type === "none") {
								C.css("background", "");
						} else if (this.set.background.type === "pattern") {
							patt = this.set.background.pattern;
							if (patt.type === "image") {
								C.css("background", "url(" + patt.image + " ) repeat");
							} else if (patt.type === 'constructor') {
								this.C.renderPattern(C, patt);
							} else {
								this.C._draw_css_background(C, patt.image);
							}
						}
				}


				var text_color = function(){
						if (this.set.text_color ){
								C.css('color', hsvToRgb(this.C.get_color( this.set.text_color ) ) )
						}
				}
				var appl = {border_color:border_color,
								opacity:opacity,
								border_radius:border_radius,
								border_width: border_width,
								padding_top: padding_top,
								padding_left_right: padding_left_right,
								background:background,
								font_size:font_size,
								line_height:line_height,
								text_color:text_color

						}
				// console.log(this.set);
				for (k in appl){
						f = appl[k]
						// console.log(k)
						if (this.do_not_apply != null){
								if (this.do_not_apply.indexOf(k) === -1)
									 f.apply(this)

						}else {f.apply(this)}
				}
				if (this.need_redraw){
						this._draw();
				}




		}
		// return this;
}

;

  window.Constructor.redraw = function(force_reload) {
    if (force_reload == null) {
      force_reload = false;
    }
    this.clear();
    return this.draw(null, null, null, force_reload);
  };

  window.Constructor.clear = function() {
    this.page_cont.find("*").remove();
    return $("#controls>.widget-control").remove();
  };

  window.Constructor.draw = function(custom_cont, custom_head, custom_hash, force_reload) {
    if (custom_cont == null) {
      custom_cont = this.page_cont;
    }
    if (custom_head == null) {
      custom_head = $('head');
    }
    if (force_reload == null) {
      force_reload = false;
    }
    if (custom_hash) {
      custom_hash = custom_hash.slice(1).split('?');
    }
    if (this._init_page(custom_hash, custom_head, force_reload)) {
      return this.init_grid(custom_cont, custom_head);
    }
  };

  window.Constructor._init_page = function(hash_, head, force_reload) {
    var a, doc_title, p, page_name, params, pdata, ptitle, t, title, val, _fn, _fn1, _i, _len, _ref,
      _this = this;
    if (hash_ == null) {
      hash_ = window.location.hash.slice(1).split('?');
    }
    if (head == null) {
      head = $('head');
    }
    if (force_reload == null) {
      force_reload = false;
    }
    if (this.page_vars == null) {
      this.page_vars = {};
    }
    page_name = hash_[0].replace('!', '');
    params = hash_[1] != null ? hash_[1] : "";
    this.current_page = page_name;
    pdata = this.getPageData(page_name, force_reload);
    if (pdata != null) {
      if (pdata.params) {
        _ref = pdata.params;
        _fn = function(p, val) {
          return _this.page_vars[p] = val;
        };
        for (p in _ref) {
          val = _ref[p];
          _fn(p, val);
        }
      }
      t = head.find('title');
      if (t.length === 0) {
        t = $('<title>').appendTo(head);
      }
      this.head_tag = head;
      this._set_description(pdata.description);
      this._set_keywords(pdata.keywords);
      if (this.Site.seo.title == null) {
        title = "Undefined";
      } else {
        title = this.Site.seo.title;
      }
      if (pdata.title == null) {
        ptitle = "Unknown page";
      } else {
        ptitle = pdata.title;
      }
      doc_title = ptitle + '|' + title;
      if (is_ie) {
        document.title = doc_title;
      } else {
        t.text(doc_title);
      }
      if ((this.Site.seo.metas != null) && (this.Site.seo.metas.yandex != null)) {
        head.append(this.Site.seo.metas.yandex);
      }
      if ((this.Site.seo.metas != null) && (this.Site.seo.metas.google != null)) {
        head.append(this.Site.seo.metas.google);
      }
      if (params) {
        a = params.split('&');
        _fn1 = function(p) {
          var name, _p;
          _p = p.split('=');
          name = _p[0];
          val = _p[1];
          if (name && val) {
            return _this.page_vars[name] = val;
          }
        };
        for (_i = 0, _len = a.length; _i < _len; _i++) {
          p = a[_i];
          _fn1(p);
        }
      }
      this.layout = this.Site.layout;
      this.base_height = this.layout.base_height;
      this.inited_blocks = [];
      return true;
    } else {
      return false;
    }
  };

  window.Constructor.getPageData = function(page_name, do_reload) {
    if (do_reload == null) {
      do_reload = false;
    }
    this.load_site(do_reload);
    return this.Site.pages[page_name];
  };

  window.Constructor.load_site = function(do_reload) {
    var S, app_name, apps_, i, page, _fn, _i, _j, _len, _len1, _ref, _ref1, _results,
      _this = this;
    if (do_reload == null) {
      do_reload = false;
    }
    if (window.SITE_OBJECT_REPR != null) {
      this.Site = JSON.parse(window.SITE_OBJECT_REPR);
      window.SITE_OBJECT_REPR = void 0;
    }
    if ((this.Site == null) || do_reload) {
      S = DB.get_objects("generic." + BASE_SITE, this._site_type, {});
      if (S.total_amount !== 0) {
        this.Site = S.objects[0];
        if (this.Site.layout.grid == null) {
          this.Site.layout.grid = this.Site.layout.padding;
          this.Site.layout.padding = {
            top: 50,
            left: 10
          };
        }
      } else {
        this.Site = default_site;
      }
    } else {

    }
    if (this.Site.Applications == null) {
      apps_ = {};
      _ref = this.Site._Apps;
      _fn = function(app_name) {
        var app;
        app = _this.getApp(app_name);
        if (app) {
          return apps_[app_name] = app;
        }
      };
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        app_name = _ref[_i];
        _fn(app_name);
      }
      this.Site['Applications'] = apps_;
      delete this.Site.version;
      this.page_order_index = {};
      this.page_amount = 0;
      _ref1 = this.Site.pages;
      _results = [];
      for (page = _j = 0, _len1 = _ref1.length; _j < _len1; page = ++_j) {
        i = _ref1[page];
        this.page_order_index[page.order] = i;
        _results.push(this.page_amount += 1);
      }
      return _results;
    }
  };

  window.Constructor.getAppJson = function(name) {
    var ix, xhr;
    if ((window.APP_EGGS != null) && name in window.APP_EGGS) {
      return window.APP_EGGS[name];
    } else {
      xhr = $.ajax({
        url: window.get_application_url + name + "/",
        async: false,
        cache: true
      });
      if (xhr.status === 200) {
        return JSON.parse(xhr.responseText);
      } else {
        ix = this.Site._Apps.indexOf(name);
        this.Site._Apps.splice(ix, 1);
        return false;
      }
    }
  };

  window.Constructor.getApp = function(name) {
    var App, app_egg;
    app_egg = this.getAppJson(name);
    if (app_egg) {
      app_egg.Main = new Function(app_egg.Main.attr, app_egg.Main.body);
      app_egg.getter = new Function(app_egg.getter.attr, app_egg.getter.body);
      App = app_egg.getter(this, name);
      App.roles = app_egg.roles;
      App.default_role = app_egg.default_role;
      App.app_name = app_egg.app_name;
      App.title = app_egg.title;
      App.is_own = app_egg.is_own;
      return App;
    } else {
      return false;
    }
  };

  window.Constructor.set_app_cache = function(n, v) {
    if (this._app_cache != null) {
      return this._app_cache[n] = v;
    } else {
      this._app_cache = {};
      return this._app_cache[n] = v;
    }
  };

  window.Constructor.get_app_cache = function(n) {
    if ((this._app_cache != null) && (this._app_cache[n] != null)) {
      return this._app_cache[n];
    } else {
      return {};
    }
  };

  window.Constructor.get_block = function(ix) {
    return this.Site.blocks[ix];
  };

  getBlockSettings = function (pos){
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

			};

  window.Constructor.getBlockSettings = function(pos) {
    var k, set;
    if (this.Site.default_block_settings) {
      set = clone(this.Site.default_block_settings);
    } else {
      set = {
        border_width: 0,
        background: {
          type: "none"
        }
      };
    }
    if (this.Site.blocks[pos].settings) {
      for (k in this.Site.blocks[pos].settings) {
        set[k] = this.Site.blocks[pos].settings[k];
      }
    }
    return set;
  };

  rect = function (x,y,w,h){
			return {left:x, top:y, width:w, height:h}	 ;
			};

  window.Constructor.rect = rect;

  getWidgetData = function (pos, def){
				var self = this;
				return (function(i){
					 var d = self.Site.blocks[pos].widget.data;
					if (d){
						return d
					}
					return def;

				})(pos)


			};

  window.Constructor.getWidgetData = getWidgetData;

  _add_title = function (title) {
				var t = this.head_tag.find('title');
				var text = t.text()
				t.text(title +'|' + text);
			};

  window.Constructor._add_title = _add_title;

  _set_keywords = function (kw){
				var H	= this.head_tag;
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
			};

  window.Constructor._set_keywords = _set_keywords;

  _set_description = function (description){
				var H	= this.head_tag;
				var d = H.find('meta[name=description]');

				if(d.length){
				}else{
					d = $('<meta>')
					// console.log(d)
					d.appendTo(H).attr('name','description');
				}
				d.attr('content', description)


			};

  window.Constructor._set_description = _set_description;

  _set_page_var = function (name, val){
				this.page_vars[name] = val
			};

  window.Constructor._set_page_var = _set_page_var;

  _get_page_var = function (name){
				return this.page_vars[name];
			};

  window.Constructor._get_page_var = _get_page_var;

  window.Constructor.get_color = function(c) {
    var v;
    this._make_pallette();
    if (c.v === 'C') {
      if (c.ix in this.Site.colors.custom_pallette) {
        return this.Site.colors.custom_pallette[c.ix];
      } else {
        return this.Site.colors.custom_pallette[0];
      }
    } else {
      v = this.Site.colors.pallette[c.v];
      if (v) {
        return v[c.ix];
      } else {
        v = this.Site.colors.pallette[c.v - 1];
        if (v) {
          return v[c.ix];
        } else {
          v = this.Site.colors.pallette[c.v - 2];
          if (v) {
            return v[c.ix];
          } else {
            return this.Site.colors.pallette[c.v - 3][c.ix];
          }
        }
      }
    }
  };

  window.Constructor.getTextColors = function() {
    var colors, defaults, k, lc, _i, _len, _ref;
    colors = this.Site.textColors == null ? {} : this.Site.textColors;
    defaults = {
      text_color: "rgb(0,0,0)",
      link_color: "#0000ff",
      visited_color: "#800080",
      active_color: "#ff0000",
      hover_color: "#0000ff"
    };
    lc = {};
    _ref = ["text_color", "link_color", "visited_color", "active_color", 'hover_color'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      k = _ref[_i];
      if ((colors[k] != null) && (colors[k].index != null)) {
        lc[k] = hsvToRgb(this.get_color(colors[k].index));
      } else {
        lc[k] = defaults[k];
      }
    }
    return lc;
  };

  window.Constructor.init_grid = function(to, head) {
    var base_height, bh, bhp, block_width, bvp, bw, c_off, e, gh, gmp, gp, grad_function, gw, hm, left, self, total_height, w_left, width, window_width,
      _this = this;
    block_width = this._block_width();
    base_height = this.layout.base_height;
    self = this;
    if (this.layout.fixed) {
      e = "px";
    } else {
      e = "%";
    }
    $("body").css("margin", 0);
    total_height = this.Site.layout.drawen_lines * (this.Site.layout.base_height + 2 * this.Site.layout.grid.ver);
    window_width = window.innerWidth;
    width = this.Site.layout.width;
    w_left = window_width - width;
    left = w_left / 2;
    this.layout_cont = $("<div>").css("position", "absolute").css("width", this.layout.width + e).css("top", this.Site.layout.padding.top).css("left", left).css("height", total_height).appendTo(to);
    c_off = this.layout_cont.offset();
    to.css("top", "0px");
    this._main_offset = c_off;
    this.redraw_background();
    this._busy_regions = [];
    this._moved_block_ = [];
    bw = self._block_width(1);
    bh = self._block_height(1);
    bhp = self.Site.layout.grid.hor;
    bvp = self.Site.layout.grid.ver;
    gw = bw + (bhp * 2);
    gh = bh + (bvp * 2);
    gp = self.Site.layout.padding.left + self.Site.layout.grid.hor;
    gmp = gp - (bhp * 2);
    if (!is_safari) {
      grad_function = 'linear-gradient';
      if (this.is_constructor) {
        $("<div>").addClass("empty-block").appendTo(this.layout_cont).css("position", "absolute").css("background-color", "transparent").css("background-image", grad_function + "(90deg, rgba(0,0,0,.5) 1px, transparent 1px)," + grad_function + "(90deg, rgba(255,255,255,.5) 2px, transparent 1px)," + grad_function + "(90deg, rgba(255,255,255,.5) 2px, transparent 1px)," + grad_function + "(90deg, rgba(0,0,0,.5) 1px, transparent 1px)," + grad_function + "(0deg, rgba(0,0,0,.5) 1px, transparent 1px)," + grad_function + "(0deg, rgba(255,255,255,.5) 2px, transparent 1px)," + grad_function + "(0deg, rgba(255,255,255,.5) 2px, transparent 1px)," + grad_function + "(0deg, rgba(0,0,0,.5) 1px, transparent 1px)").css("background-size", gw + "px 1px,	" + gw + "px 1px,	" + gw + "px 1px,	" + gw + "px 1px, 1px " + gh + "px, 1px " + gh + "px, 1px " + gh + "px, 1px " + gh + "px	").css("background-position", gp + "px 0px, " + (gp + 1) + "px 0px, " + gmp + "px 0px, " + (gmp + 1) + "px 0px, 0px 0px,0px 1px, 0px -" + (bvp * 2) + "px,0px -" + ((bvp * 2) - 1) + "px").css("left", 0).css("top", 0).css("width", this.Site.layout.width).css("height", total_height);
      }
    }
    this.inited_blocks = [];
    this.settings_over_block = false;
    hm = [];
    $.each(this.Site.blocks, function(ix, block) {
      var H, W, bl, h, offs, set, w, x, xx, y, yy;
      if (block.display_on === "all") {
        if (block.dont_display_on.indexOf(self.current_page) !== -1) {
          return;
        }
      } else {
        if (block.display_on !== self.current_page) {
          return;
        }
      }
      set = self.getBlockSettings(ix);
      bw = (set ? set.border_width : 0);
      x = block.x;
      y = block.y;
      if (!set.unsnap_to_grid) {
        xx = self._calc_left(x + 1) - bw;
        yy = self._calc_top(y) - bw;
      } else {
        xx = x;
        yy = y;
      }
      w = block.width;
      h = block.height;
      if (!set.unsnap_to_grid) {
        W = self._calc_width(w);
        H = self._calc_height(h);
      } else {
        W = w;
        H = h;
      }
      gp = {
        jq: $("<div>").appendTo(self.layout_cont).css("position", "absolute").css("left", xx).css("top", yy).width(W).css("height", H).css("overflow", "hidden"),
        pos: ix
      };
      bl = self.init_block(block, gp);
      if (bl) {
        offs = bl.offset();
        h = bl.height();
        hm.push(offs.top + h);
        return _this.inited_blocks.push(bl);
      }
    });
    return this.layout_cont.height(Math.max.apply(Math, hm));
  };

  window.Constructor.reapply_block_settings = function(obj, widget) {
    var sett;
    sett = this.getBlockSettings(obj.pos);
    return this.apply_block_settings(obj, sett, widget);
  };

  window.Constructor.apply_block_settings = function(obj, settings, widget) {
    var C, W, bl, c, color, patt, w, xx, yy;
    if (!widget.has_own_settings) {
      w = obj.jq;
      bl = this.get_block(obj.pos);
      if (widget.disobey.indexOf("border_color") === -1) {
        if (typeof settings.border_color === "string") {
          w.css("border-color", settings.border_color);
        } else {
          if (typeof settings.border_color === "undefined") {
            settings.border_color = {
              v: 0,
              ix: 0
            };
          }
          color = this.get_color(settings.border_color);
          c = hsvToRgb(color);
          w.css("border-color", c);
        }
      }
      if (widget.disobey.indexOf("bg_opacity") === -1) {
        w.css("opacity", settings.bg_opacity);
      }
      if (__indexOf.call(widget.disobey, "border_radius") < 0) {
        w.css("-moz-border-radius", settings.border_radius + "px");
        w.css("-webkit-border-radius", settings.border_radius + "px");
        w.css("border-radius", settings.border_radius + "px");
      }
      if (widget.disobey.indexOf("border_width") === -1) {
        if (!settings.unsnap_to_grid) {
          xx = this._calc_left(bl.x + 1) - settings.border_width;
          yy = this._calc_top(bl.y) - settings.border_width;
        } else {
          xx = bl.x;
          yy = bl.y;
        }
        w.css("border-width", settings.border_width + "px");
        w.css("left", xx);
        w.css("top", yy);
        w.css("border-style", "solid");
      }
      if (widget.disobey.indexOf("line_height") === -1) {
        w.css("line-height", settings.line_height + "px");
      }
      if (widget.disobey.indexOf("font_size") === -1) {
        w.css("font-size", settings.font_size + "px");
      }
      if (widget.disobey.indexOf("padding_left_right") === -1) {
        C = w.children().eq(0);
        W = w.width();
        C.css("margin-left", settings.padding_left_right + "px");
        C.css("margin-right", settings.padding_left_right + "px");
        C.width(W - settings.padding_left_right * 2);
      }
      if (widget.disobey.indexOf("padding_top") === -1) {
        C.css("padding-top", settings.padding_top + "px");
      }
      if (settings.background.type === "color") {
        if (widget.disobey.indexOf("background_color") === -1) {
          if (typeof settings.background.color === "string") {
            w.css("background", settings.background.color);
          } else {
            color = this.get_color(settings.background.color);
            c = hsvToRgb(color);
            w.css("background", c);
          }
        }
      } else if (settings.background.type === "none") {
        w.css("background", "");
      } else if (settings.background.type === "pattern") {
        patt = settings.background.pattern;
        if (patt.type === "image") {
          w.css("background", "url(" + patt.image + " ) repeat");
        } else if (patt.type === 'constructor') {
          this.renderPattern(w, patt);
        } else {
          this._draw_css_background(w, patt.image);
        }
      }
      if (widget.depends_on_settings != null) {
        return widget.draw(settings);
      }
    }
  };

  window.Constructor.init_block = function(bl, to) {
    var H, W, Widget, app_name, clc, delete_marker, draga, h, he, init_resizer, l, make_draggable, mh, mouseHeight, mouseWidth, mw, newWidget, o, po, r, resize_marker, self, start_x, start_y, w, wdata, wi, widget_name, widget_str,
      _this = this;
    init_resizer = function() {};
    newWidget = function(c, t, p, cp) {
      var A, W, wi;
      A = t.Site.Applications[app_name];
      if ((A != null) && (A.widgets[widget_name] != null)) {
        W = A.widgets[widget_name];
        wi = (function() {
          return new W();
        })();
        wi.init(c, t, p, cp);
        return wi;
      } else {
        return false;
      }
    };
    r = bl.top;
    l = bl.left;
    w = bl.width;
    h = bl.height;
    self = this;
    W = this._calc_width(w);
    H = this._calc_height(h);
    widget_str = bl.widget.name.split(".");
    widget_name = widget_str[0];
    widget_str.splice(0, 1);
    app_name = widget_str.join(".");
    wdata = bl.widget.data;
    w = $("<div>").css('overflow', 'hidden').css("width", to.jq.width()).css("height", to.jq.height()).appendTo(to.jq).addClass("draggable-module");
    draga = void 0;
    Widget = newWidget(w, this, to.pos);
    if (!Widget) {
      return false;
    }
    Widget.draw();
    if (Widget.set.unsnap_to_grid) {
      W = bl.width;
      H = bl.height;
    }
    make_draggable = function(to) {
      return to.jq.draggable({
        scroll: false,
        zIndex: 100,
        cancel: ".resize-marker",
        start: function(event, ui) {
          var i, regs;
          regs = [];
          w = bl.x;
          while (w < bl.x + bl.width) {
            h = bl.y;
            while (h < bl.y + bl.height) {
              regs.push(w + ":" + h);
              h++;
            }
            w++;
          }
          for (i in self.inited_blocks) {
            self.inited_blocks[i].unbind("mouseenter");
          }
          to.jq.unbind("mouseleave");
          return self._moved_block_ = regs;
        },
        drag: function(event, ui) {
          var ll, tt;
          if (!Widget.set.unsnap_to_grid) {
            ll = self._stepping_left(ui.position.left);
            tt = self._stepping_top(ui.position.top);
            draga = {
              left: ll.block,
              top: tt.block
            };
            return ui.position = {
              top: tt.val,
              left: ll.val
            };
          } else {
            return draga = {
              left: ui.position.left,
              top: ui.position.top
            };
          }
        },
        stop: function() {
          self._moved_block = false;
          self.move_block(to.pos, draga.left, draga.top);
          return self.redraw();
        }
      });
    };
    if (this.is_constructor) {
      make_draggable(to);
    }
    if (this.is_constructor) {
      to.jq.dblclick(function() {
        var control_panel, _i, _len, _ref;
        control_panel = $("<div>").addClass('widget-control').appendTo($("#controls"));
        _ref = _this.inited_blocks;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          bl = _ref[_i];
          bl.unbind("click dblclick");
          bl.draggable('destroy');
        }
        $("#controls>.widget-control").hide();
        control_panel.css("position", "absolute").position({
          of: w,
          my: "left top",
          at: "right top",
          collision: "none none"
        }).css("border", "2px solid black").css("background-color", "white").draggable({
          scroll: false
        }).css("padding", "10");
        if (Widget.settings) {
          Widget.settings(control_panel);
        }
        $("<div>").css("background-color", "green").appendTo(to.jq.parent()).css("position", "absolute").position({
          of: to.jq,
          my: "left top",
          at: "left-20 top",
          collision: "none none"
        }).addClass("ui-icon ui-icon-gripsmall-diagonal-se").width(20).height(20).click(function() {
          if (Widget.save) {
            Widget.save();
          }
          _this._save_site();
          control_panel.remove();
          return self.redraw();
        });
        return $("<div>").css("background-color", "red").appendTo(to.jq.parent()).css("position", "absolute").position({
          of: to.jq,
          my: "left top",
          at: "left-20 top+30",
          collision: "none none"
        }).addClass("ui-icon ui-icon-gripsmall-diagonal-se").width(20).height(20).click(function() {
          control_panel.remove();
          Widget.cancel();
          return self.redraw();
        });
      });
      mouseWidth = W;
      mouseHeight = H;
      start_x = void 0;
      start_y = void 0;
      delete_marker = $("<div>").appendTo($("#controls")).css("position", "absolute").addClass("delete-marker widget-control").css("background-color", "blue").css("border-radius", "5px").css("border", "1px solid black").addClass("ui-icon ui-icon-closethick").width("20px").height("20px").hide().click(function() {
        Widget.remove();
        self.delete_block(to.pos);
        return self.redraw.apply(self, []);
      });
      resize_marker = $("<div>").appendTo($("#controls")).css("position", "absolute").addClass("ui-icon ui-icon-grip-diagonal-se").width("32px").height("32px").hide().addClass("resize-marker widget-control").css("background-color", "blue").css("cursor", "se-resize").css("border-radius", "5px").css("border", "1px solid black").mouseenter(function() {}).mouseup(function(evt) {
        return self.resize_frame = false;
      }).mousedown(function(evt) {
        start_x = evt.clientX;
        start_y = evt.clientY;
        self.resize_frame = $("<div>").css("position", "absolute").css("border", "1px solid black").appendTo(to.jq.parent()).width(W).height(H).position({
          of: to.jq,
          my: "left top",
          at: "left top"
        });
        mouseWidth = bl.width;
        mouseHeight = bl.height;
        to.jq.parent().unbind("mouseup");
        to.jq.parent().unbind("mousemove");
        to.jq.parent().mouseup(function() {
          if (self.resize_frame) {
            self.resize_frame.remove();
            self.resize_frame = false;
            self.Site.blocks[to.pos].width = mouseWidth;
            self.Site.blocks[to.pos].height = mouseHeight;
            return self.redraw.apply(self, []);
          }
        });
        to.jq.parent().mousemove(function(evt) {
          var fr, height_step, nh, nw, width_step;
          fr = self.resize_frame;
          if (fr) {
            if (fr.size()) {
              nh = evt.clientY - start_y + H;
              nw = evt.clientX - start_x + W;
              if (!Widget.set.unsnap_to_grid) {
                width_step = self._stepping_width(nw);
                height_step = self._stepping_height(nh);
                fr.width(width_step.val);
                fr.height(height_step.val);
                mouseWidth = width_step.block;
                mouseHeight = height_step.block;
              } else {
                fr.width(nw);
                fr.height(nh);
                mouseWidth = nw;
                mouseHeight = nh;
              }
            }
          }
          return evt.preventDefault();
        }).css("cursor", "se-resize");
        return $(this).hide();
      });
      po = to.jq.position();
      wi = to.jq.width();
      he = to.jq.height();
      mw = resize_marker.width();
      mh = resize_marker.height();
      o = this._main_offset;
      resize_marker.css("top", po.top + o.top + he - mh);
      resize_marker.css("left", po.left + o.left + wi - mw);
      delete_marker.css("top", po.top);
      delete_marker.css("left", po.left + o.left + wi - mw);
      clc = function(e) {
        $("#controls>.widget-control").hide();
        delete_marker.show().zIndex(1000);
        return resize_marker.show().zIndex(1000);
      };
      (function() {
        return to.jq.on('click', clc);
      })();
    }
    return to.jq;
  };

  window.Constructor.registerEvent = function(e, f) {
    if (this.events != null) {
      if (this.events[e]) {
        this.events[e].push(f);
      }
      return {
        "else": this.events[e] = [f]
      };
    } else {
      this.events = {};
      return this.events[e] = [f];
    }
  };

  window.Constructor.fireEvent = function(e) {
    var f, _i, _len, _ref, _results;
    if ((this.events != null) && this.events[e]) {
      _ref = this.events[e];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        f = _ref[_i];
        _results.push(f());
      }
      return _results;
    }
  };

  window.Constructor.renderPattern = function(to, pattern) {
    var A, BG, C, Cjq, FG, GA, S, Z, base, ctx, exc_color, image_obj, img_src, opacity, redraw_ctx, sctx,
      _this = this;
    redraw_ctx = function(image_obj) {
      var c, dr_im, ih, img, iw;
      dr_im = function(x, y, bx, by_) {
        var rad;
        ctx.save();
        ctx.translate(x, y);
        ctx.scale(Z, Z);
        rad = A * (3.14 / 180);
        ctx.rotate(rad);
        ctx.globalAlpha = opacity / 100;
        ctx.drawImage(image_obj, -(iw / 2), -(ih / 2), iw, ih);
        return ctx.restore();
      };
      Cjq.css("margin-left", (300 - base) / 2).css("margin-top", (300 - base) / 2);
      C.width = base;
      C.height = base;
      iw = image_obj.width * Z;
      ih = image_obj.height * Z;
      if (BG) {
        if ("ix" in BG) {
          c = _this.get_color(BG);
        } else {
          c = BG;
        }
        c.a = GA;
        ctx.fillStyle = hsvToRgb(c);
      }
      ctx.rect(0, 0, C.width, C.height);
      ctx.fill();
      ctx.save();
      ctx.clip();
      dr_im(base / 2, base / 2);
      dr_im(0, 0);
      dr_im(0, base);
      dr_im(base, 0);
      dr_im(base, base);
      ctx.closePath();
      ctx.restore();
      img = C.toDataURL();
      return to.css("background", "url(" + img + ") repeat");
    };
    exc_color = function(img_) {
      var FGA, buffData, c, du, ix, x, y, _I;
      S.width = img_.width;
      S.height = img_.height;
      sctx.drawImage(img_, 0, 0);
      buffData = sctx.getImageData(0, 0, img_.width, img_.height);
      if ("ix" in FG) {
        c = _this.get_color(FG);
      } else {
        c = FG;
      }
      FGA = hsvToRgb(c, true);
      x = 0;
      while (x < buffData.width) {
        y = 0;
        while (y < buffData.height) {
          ix = (x + (y * buffData.width)) * 4;
          buffData.data[ix] = FGA[0];
          buffData.data[ix + 1] = FGA[1];
          buffData.data[ix + 2] = FGA[2];
          y++;
        }
        x++;
      }
      sctx.putImageData(buffData, 0, 0);
      du = S.toDataURL();
      _I = new Image();
      _I.onload = function() {
        return redraw_ctx(_I);
      };
      return _I.src = du;
    };
    if (pattern.base_image != null) {
      img_src = pattern.base_image;
      FG = pattern.FG;
      BG = pattern.BG;
      A = pattern.A;
      Z = pattern.Z;
      GA = pattern.GA;
      base = pattern.base;
      opacity = pattern.opacity;
      Cjq = $('<canvas>');
      C = Cjq[0];
      S = $('<canvas>')[0];
      ctx = C.getContext('2d');
      sctx = S.getContext('2d');
      image_obj = $(new Image());
      image_obj.one('load', function(e) {
        return exc_color(e.delegateTarget);
      });
      return image_obj.prop('src', img_src);
    } else {
      return to.css("background", "url(" + pattern.image + ") repeat");
    }
  };

  caching = function (){
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



			};

  window.Constructor.caching = caching;

  _make_pallette = function (){

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
			};

  window.Constructor._make_pallette = function() {
    var A, a, am, br_koef, bri, brightness, c, col, color, colors, db, dbri, ds, dsat, greys, h, i, lights, s, sat, sat_koef, saturation, shadows, vars, _c, _results;
    h = this.Site.colors.base;
    lights = this.Site.colors.lights;
    shadows = this.Site.colors.shadows;
    brightness = this.Site.colors.brightness;
    saturation = this.Site.colors.saturation;
    i = this.Site.colors.type;
    this.Site.colors.pallette = [];
    s = void 0;
    a = void 0;
    A = void 0;
    switch (i) {
      case "mono":
        s = a = A = false;
        break;
      case "complement":
        s = (h + 180) % 360;
        a = A = false;
        break;
      case "triada":
        s = (h + 120) % 360;
        a = (h + (360 - 120)) % 360;
        A = false;
        break;
      case "split-trio":
        s = (h + 150) % 360;
        a = (h + (360 - 150)) % 360;
        A = false;
        break;
      case "analogous":
        s = (h + 30) % 360;
        a = (h + (360 - 30)) % 360;
        A = false;
        break;
      case "accent":
        s = (h + 30) % 360;
        a = (h + (360 - 30)) % 360;
        A = (h + 180) % 360;
    }
    sat_koef = [0.89, 0.5, 0.5, 0.01];
    br_koef = [0.05, 0.05, 0.45, 0.3];
    colors = [h, s, a, A];
    greys = new Array();
    am = 5;
    c = 0;
    while (c <= am) {
      _c = {
        h: 0,
        s: 0,
        b: c * (100 / am),
        a: 1
      };
      greys.push(_c);
      c++;
    }
    this.Site.colors.pallette[0] = greys;
    _results = [];
    for (col in colors) {
      color = colors[col];
      vars = [
        {
          h: color,
          s: saturation,
          b: brightness
        }
      ];
      if (color) {
        for (i in sat_koef) {
          ds = saturation * sat_koef[i];
          db = brightness * br_koef[i];
          if (i < 2) {
            dsat = ds * lights / 100;
            dbri = db * lights / 100;
          } else {
            dsat = ds * shadows / 100;
            dbri = db * shadows / 100;
          }
          sat = saturation - dsat;
          bri = brightness - dbri;
          vars[Number(i) + 1] = {
            h: color,
            s: sat,
            b: bri,
            a: 1
          };
        }
        _results.push(this.Site.colors.pallette.push(vars));
      } else {
        _results.push(this.Site.colors.pallette.push(false));
      }
    }
    return _results;
  };

  window.Constructor._draw_css_background = function(to, css_pattern) {
    var grads, poss, sizes,
      _this = this;
    sizes = [];
    poss = [];
    grads = [];
    $.each(css_pattern.gradients, function(ix, grad) {
      var deg, gr, is_mobile, position, size, stops;
      stops = [];
      if (grad.stops.length < 2) {
        return;
      }
      $.each(grad.stops, function(ix, st) {
        var hsva, rgba, s;
        if (st.col_ix == null) {
          rgba = hsvToRgb(st.col);
        }
        if (st.col_ix != null) {
          hsva = _this.get_color(st.col_ix);
          hsva.a = st.a;
          rgba = hsvToRgb(hsva);
        }
        s = rgba + " " + st.size.v + st.size.m;
        return stops.push(s);
      });
      if (grad.type === "linear") {
        is_safari = /Safari/.test(navigator.userAgent) && !/Chrome/.test(navigator.userAgent);
        is_mobile = /Mobile/.test(navigator.userAgent);
        if (is_safari || is_mobile) {
          deg = (360 - (grad.deg - 90)) % 360;
          gr = "-webkit-linear-gradient(" + deg + "deg, " + stops.join(", ") + ")";
        } else {
          gr = "linear-gradient(" + grad.deg + "deg, " + stops.join(", ") + ")";
        }
      } else {
        position = grad.rad_w.v + grad.rad_w.m + " " + grad.rad_h.v + grad.rad_h.m;
        size = "circle at " + grad.rad_l.v + grad.rad_l.m + " " + grad.rad_t.v + grad.rad_t.m;
        gr = "radial-gradient(" + size + ", " + stops.join(", ") + ") \t" + position;
      }
      grads.push(gr);
      poss.push(grad.pos[0].v + grad.pos[0].m + " " + grad.pos[1].v + grad.pos[1].m);
      return sizes.push(grad.size[0].v + grad.size[0].m + " " + grad.size[1].v + grad.size[1].m);
    });
    return to.css({
      "background": grads.join(","),
      "background-size": sizes.join(", "),
      "background-position": poss.join(", ")
    });
  };

  window.Constructor.redraw_background = function() {
    var _this = this;
    if (this.Site.backgrounds != null) {
      return $.each(this.Site.backgrounds, function(name, imgo) {
        var C, c, pat, patt;
        if (name === "body") {
          C = $("body");
        } else {
          if (name === "content") {
            C = _this.layout_cont;
          }
        }
        if (imgo.type === "pattern") {
          if ((window.PATTERNS != null) && imgo.pattern in window.PATTERNS) {
            patt = window.PATTERNS[imgo.pattern];
          } else {
            patt = DB.get_objects('generic.' + BASE_SITE, 'pattern', {
              '_id': {
                '$oid': imgo.pattern
              }
            }).objects[0];
          }
          if (typeof patt === "undefined") {
            C.css("background-image", "");
            return;
          }
          if (patt.type === "image") {
            pat = patt.image;
            return C.css("background", "url(\"" + pat + "\") repeat");
          } else if (patt.type === "constructor") {
            if (!isCanvasSupported()) {
              return C.css("background", "url(\"" + patt.image + "\") repeat");
            } else {
              return _this.renderPattern(C, patt);
            }
          } else {
            pat = patt.image;
            return _this._draw_css_background(C, pat);
          }
        } else if (imgo.type === "color") {
          c = _this.get_color(imgo.color);
          return C.css("background", hsvToRgb(c));
        } else {
          if (imgo.type === "none") {
            return C.css("background", "");
          }
        }
      });
    }
  };

  window.Constructor.draw_color_chooser = function(onSelectColor) {
    var butts, color_chooser, customs, self;
    color_chooser = $("<div>").css("position", "absolute").css("background-color", "white").css("border", "1px solid black").css("padding", "10px").width(500).zIndex(10000).draggable({
      scroll: false
    });
    self = this;
    this._make_pallette();
    $.each(this.Site.colors.pallette, function(l, vars) {
      var b;
      b = void 0;
      if (l === 0) {
        return $.each(vars, function(i, col_) {
          var col;
          if (typeof col_.a === "undefined") {
            col_.a = 1;
          }
          col = hsvToRgb(col_);
          if (i === 0) {
            self.__b = $("<div>").css("float", "left").width(100).height(100).appendTo(color_chooser);
          }
          return $("<button>").css("padding", "0").css("border", "0").css("display", "block").css("background-color", col).css("float", "left").width(100).height(100 / 6).appendTo(self.__b).click(function(evt) {
            color_chooser.remove();
            onSelectColor(col, {
              v: l,
              ix: i
            }, col_);
            evt.preventDefault();
            return evt.stopPropagation();
          });
        });
      } else {
        return $.each(vars, function(i, col_) {
          var col;
          if (typeof col_.a === "undefined") {
            col_.a = 1;
          }
          col = hsvToRgb(col_);
          if (i === 0) {
            self.__b = $("<div>").css("float", "left").width(100).height(100).appendTo(color_chooser);
            return self.__main = $("<button>").css("padding", "0").css("border", "0").css("display", "block").css("background-color", col).css("float", "left").width(100).height(50).click(function(evt) {
              color_chooser.remove();
              onSelectColor(col, {
                v: l,
                ix: i
              }, col_);
              evt.preventDefault();
              return evt.stopPropagation();
            });
          } else {
            if (i === 3) {
              self.__main.appendTo(self.__b);
            }
            return $("<button>").css("padding", "0").css("border", "0").css("display", "block").css("background-color", col).css("float", "left").width(50).height(25).appendTo(self.__b).click(function(evt) {
              onSelectColor(col, {
                v: l,
                ix: i
              }, col_);
              evt.preventDefault();
              evt.stopPropagation();
              return color_chooser.remove();
            });
          }
        });
      }
    });
    $('<div>').css('clear', 'both').css('display', 'block').appendTo(color_chooser);
    customs = $("<div>").css("float", "left").width(200).height(200).appendTo(color_chooser);
    $("<div>").text("Custom colors").width(200).height(25).appendTo(customs);
    if (this.Site.colors.custom_pallette != null) {
      $.each(this.Site.colors.custom_pallette, function(l, vars) {
        var col, tr;
        if (typeof vars.a === "undefined") {
          vars.a = 1;
        }
        col = hsvToRgb(vars);
        tr = $("<div>").css("background", "url(/static/images/bar-opacity.png) repeat").width(25).height(25).css("float", "left").appendTo(customs);
        return $("<button>").css("padding", "0").css("border", "0").css("display", "block").css("background-color", col).width(25).height(25).appendTo(tr).click(function(evt) {
          onSelectColor(col, {
            v: "C",
            ix: l
          }, vars);
          evt.preventDefault();
          evt.stopPropagation();
          return color_chooser.remove();
        });
      });
    }
    $("<div>").css("clear", "both").appendTo(color_chooser);
    butts = $("<div>").appendTo(color_chooser).css("border-top", "1px solid black").css("margin-top", "20px");
    $("<input>").attr("value", "Закрыть").button().appendTo(butts).click(function() {
      return color_chooser.remove();
    });
    $("<input>").button().text("Другой цвет").appendTo(butts).attr("value", "Выбрать другой цвет").button().colorpicker({
      inline: false,
      alpha: true,
      colorFormat: "RGBA",
      ok: function(evt, color) {
        var hsv, ix;
        hsv = color.hsv;
        hsv.s = hsv.s * 100;
        hsv.b = hsv.v * 100;
        hsv.h = hsv.h * 360;
        hsv.a = color.a;
        delete hsv.v;
        if (self.Site.colors.custom_pallette != null) {
          self.Site.colors.custom_pallette.push(hsv);
        } else {
          self.Site.colors.custom_pallette = [hsv];
        }
        ix = self.Site.colors.custom_pallette.length - 1;
        color_chooser.remove();
        return onSelectColor(color.formatted, {
          v: "C",
          ix: ix
        }, hsv);
      }
    });
    return color_chooser;
  };

  _stepping_left = function (left){
				// // // console.log(
				var sm = 10000000,
					ls = {};
				for(var i =0; i< this.layout.cols; i++){
					var ll	 = this._calc_left(i+1);
					var d	 = Math.abs(left - ll);
					if (d < sm){
						sm = d;
					}
					ls[d] = {val:ll, block:i }
				}
				//// // console.log("LEFT", left, ls[sm] );
				return ls[sm];
			};

  window.Constructor._stepping_left = _stepping_left;

  _stepping_top = function (w){
				var ws = {},
					sm= 1000000;
				for (var i =0; i < this.Site.layout.drawen_lines; i++){

					var ww = this._calc_top(i)
					var d = Math.abs(w-ww)
					if (d< sm){
						sm = d;
					}
					ws[d] = {val:ww,block:i}
				}
				return ws[sm]
			};

  window.Constructor._stepping_top = _stepping_top;

  _stepping_height = function (w){
				var ws = {},
					sm= 1000000;
				for (var i =0; i < this.Site.layout.drawen_lines; i++){

					var ww = this._calc_height(i+1)
					var d = Math.abs(w-ww)
					if (d< sm){
						sm = d;
					}
					ws[d] = {val:ww,block:i+1}
				}
				return ws[sm]


			};

  window.Constructor._stepping_height = _stepping_height;

  _stepping_width = function (w){
				var ws = {},
					sm= 1000000;
				for (var i =0; i< this.layout.cols; i++){

					var ww = this._calc_width(i+1)
					var d = Math.abs(w-ww)
					if (d< sm){
						sm = d;
					}
					ws[d] =	 {val:ww,block:i+1}
				}
				return ws[sm]


			};

  window.Constructor._stepping_width = _stepping_width;

  _block_width = function (){
				var base_width =  ((this.layout.width - ( 2 * this.layout.padding.left) ) / this.layout.cols)
				var block_width = (base_width - ( 2 * this.layout.grid.hor ) )

				return block_width

			};

  window.Constructor._block_width = _block_width;

  _block_left = function (){

			};

  window.Constructor._block_left = _block_left;

  _block_height = function (){
				block_height = this.layout.base_height;
				return block_height;

			};

  window.Constructor._block_height = _block_height;

  _uncalc_top = function (T) {
				return  T  / this._block_height();

			};

  window.Constructor._uncalc_top = _uncalc_top;

  _uncalc_left = function (L){
				return L / this._block_width();
			};

  window.Constructor._uncalc_left = _uncalc_left;

  _calc_top = function (t){
				var h = (this._calc_height(t))
				if (h == 0){ var P =0} else {var P = 2}
				return (h + P*this.layout.grid.ver) ;// + this._main_offset.top;
			};

  window.Constructor._calc_top = _calc_top;

  _calc_left = function (l){
				var w = (this._calc_width (l-1) )
				if (l > 1){var P =2 }else{var P=0}
				return (this.layout.padding.left + this.layout.grid.hor  + w + P*this.layout.grid.hor) // + this._main_offset.left;

				// console.log('LL', l)
				//var w = this._calc_width( l-1 ) // Ширина блока учитывается при значениях больше 1 (0,1)
				//return (this.layout.padding.left + w +(this.layout.grid.hor * (l-1)*2))
			};

  window.Constructor._calc_left = _calc_left;

  _calc_height = function (h){
				if (this._c_bh){
					cbh = this._c_bh
				}
				else{
					this._c_bh = this._block_height()
					cbh = this._c_bh
				}
				return (cbh * h) + (this.layout.grid.ver *2 * (h-1));


			};

  window.Constructor._calc_height = _calc_height;

  _calc_width = function (w){
				if (w <= 0) return 0;
				this._c_bw = this._block_width()
				cbw = this._c_bw
				return (cbw * w) + (this.layout.grid.hor *2 * (w-1) )


			};

  window.Constructor._calc_width = _calc_width;

}).call(this);

/*
//@ sourceMappingURL=displayer.js.map
*/