var init_db = function(csrf_token){
    var cs_name = $(csrf_token).prop('name');
    var cs_val  = $(csrf_token).val()
    console.log(cs_name, cs_val, $(csrf_token) )
    // Available base types:
    // 
    // 1. basic
    // 2. blob
    // 
    // 
    var a = {
        save_object: function(type, obj, progress, complete){
            var data = {'object':obj,
                            'type' : type,
                        };
            //data[cs_name] = cs_val;
            var xhr = new XMLHttpRequest()
            var fd = new FormData();
            for (i in obj.images){
                //console.log( obj.images[i].length )
            }
            function loadend(){
                
                complete(this)
            }
            fd.append('x-data', JSON.stringify(data))
            fd.append(cs_name, cs_val)
            xhr.open("POST", "/data/", true)
            xhr.upload.progress = progress
            xhr.onloadend = loadend
            
            xhr.send(fd)


        },
		
        save_object_sync:function(type, obj, progress, complete){
            var data = {'object':obj,
                'type' : type,
            };
            // data[cs_name] = cs_val;
            var xhr = new XMLHttpRequest()
            var fd = new FormData();
            for (i in obj.images){
                // console.log( obj.images[i].length )
            }
            function loadend(){
                
                complete(this)
            }
            fd.append('x-data', JSON.stringify(data))
            fd.append(cs_name, cs_val)
            xhr.open("POST", "/data/", false)
            xhr.upload.progress = progress
            xhr.onloadend = loadend
            
            xhr.send(fd)
        },
		remove_object:function(type, query){
			var o = {}
			o.q = query
			d={o : JSON.stringify(o), type:type}
			d[cs_name] = cs_val;
			$.ajax({
				url:'/data/delete/',
				data: d,
				dataType:'json',
				type:'POST',
				
			})
			
		},
		get_blob_url:function(blob){
			return "/blob/"+ blob._id['$oid'] + '/' 
			
		},
        get_objects: function(type, query, paging, view, sort){
            var d = {type:type}
            var o = {}
            if (query){o['q'] =query}
            if (view){o['v']=view}
            if (sort){o['o'] = sort}
            if (paging){o['p'] = paging}
            d['o'] = JSON.stringify(o)

			//console.log("Ha")
            var data = [];
            $.ajax({url:'/data/',
                    data: d,
                    dataType:'json',
                    success: function(js){data = js},
                    async:false} 
                    )
            return data
        },
        
        
    }
    return a;
}