
_stepping_left = `function (left){
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
			}`
window.Constructor._stepping_left = _stepping_left




_stepping_top = `function (w){
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
			}`
window.Constructor._stepping_top = _stepping_top




_stepping_height = `function (w){
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


			}`
window.Constructor._stepping_height = _stepping_height




_stepping_width = `function (w){
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


			}`
window.Constructor._stepping_width = _stepping_width




_block_width = `function (){
				var base_width =  ((this.layout.width - ( 2 * this.layout.padding.left) ) / this.layout.cols)
				var block_width = (base_width - ( 2 * this.layout.grid.hor ) )
				//console.log(base_width, block_width)

				return block_width

			}`
window.Constructor._block_width = _block_width




_block_left = `function (){

			}`
window.Constructor._block_left = _block_left




_block_height = `function (){
				block_height = this.layout.base_height;
				return block_height;

			}`
window.Constructor._block_height = _block_height




_uncalc_top = `function (T) {
				return  T  / this._block_height();

			}`
window.Constructor._uncalc_top = _uncalc_top




_uncalc_left = `function (L){
				return L / this._block_width();
			}`
window.Constructor._uncalc_left = _uncalc_left




_calc_top = `function (t){
				var h = (this._calc_height(t))
				if (h == 0){ var P =0} else {var P = 2}
				return (h + P*this.layout.grid.ver) ;// + this._main_offset.top;
			}`
window.Constructor._calc_top = _calc_top




_calc_left = `function (l){
				var w = (this._calc_width (l-1) )
				if (l > 1){var P =2 }else{var P=0}
				return (this.layout.padding.left + this.layout.grid.hor  + w + P*this.layout.grid.hor) // + this._main_offset.left;

				// console.log('LL', l)
				//var w = this._calc_width( l-1 ) // Ширина блока учитывается при значениях больше 1 (0,1)
				//return (this.layout.padding.left + w +(this.layout.grid.hor * (l-1)*2))
			}`
window.Constructor._calc_left = _calc_left




_calc_height = `function (h){
				if (this._c_bh){
					cbh = this._c_bh
				}
				else{
					this._c_bh = this._block_height()
					cbh = this._c_bh
				}
				return (cbh * h) + (this.layout.grid.ver *2 * (h-1));


			}`
window.Constructor._calc_height = _calc_height




_calc_width = `function (w){
				if (w <= 0) return 0;
				this._c_bw = this._block_width()
				cbw = this._c_bw
				return (cbw * w) + (this.layout.grid.hor *2 * (w-1) )


			}`
window.Constructor._calc_width = _calc_width

