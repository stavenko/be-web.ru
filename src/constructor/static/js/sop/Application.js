var init_db = function(csrf_token){
    var cs_name = $(csrf_token).prop('name');
    var cs_val  = $(csrf_token).val()
    var a = {
        save_object: function(appid, type, obj, progress, complete){
            var data = {'object':obj,
                            'type' : type+ "@" + appid,
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
			if(obj.is_unique){
				fd.append('is_unique', true)
			}
			
            fd.append('x-data', JSON.stringify(data))
            fd.append(cs_name, cs_val)
            xhr.open("POST", "/data/", true)
            xhr.upload.progress = progress
            xhr.onloadend = loadend
            xhr.send(fd)


        },
		save_cache: function(cache){
			var str_cache = JSON.stringify(cache);
            var xhr = new XMLHttpRequest()
			var fd = new FormData();
            fd.append('page_cache', str_cache)
            fd.append(cs_name, cs_val)
            xhr.open("POST", "/site_cache/", false)
            
            xhr.send(fd)
		},
		send_email: function(to, subj, body){
            //var data = {'object':obj,
             //   'type' : type,
            //};
            // data[cs_name] = cs_val;
            var xhr = new XMLHttpRequest()
            var fd = new FormData();
            //for (i in obj.images){
                // console.log( obj.images[i].length )
				//}
            fd.append('subject', subj)
            fd.append('body', body)
            fd.append('to', to)
            fd.append(cs_name, cs_val)
            xhr.open("POST", "/email/", false)
            
            xhr.send(fd)
		},
		save_application: function(app){
            //var data = {'object':obj,
            //           'type' : type };
            //data[cs_name] = cs_val;
            var xhr = new XMLHttpRequest()
            var fd = new FormData();
            //for (i in obj.images){
                //console.log( obj.images[i].length )
            //}
            //function loadend(){
                
                // complete(this)
            //}
            fd.append('x-data', app)
            fd.append(cs_name, cs_val)
            xhr.open("POST", "/app/add/", true)
            // xhr.upload.progress = progress
            // xhr.onloadend = loadend
            
            xhr.send(fd)
		},
		
        save_object_sync:function(appid, type, obj, progress, complete){
            var data = {'object':obj,
                'type' : type+ "@" + appid,
            };
			
            // data[cs_name] = cs_val;
            var xhr = new XMLHttpRequest()
            var fd = new FormData();
            for (i in obj.images){
                // console.log( obj.images[i].length )
            }
            function loadend(){
				if (complete)
                
                {complete(this)}
            }
            fd.append('x-data', JSON.stringify(data))
			if(obj.is_unique){
				fd.append('is_unique', true)
			}
            fd.append(cs_name, cs_val)
            xhr.open("POST", "/data/", false)
            xhr.upload.progress = progress
            xhr.onloadend = loadend
            
            xhr.send(fd)
			return JSON.parse(xhr.responseText)
        },
		remove_object:function(appid, type, query){
			var o = {}
			o.q = query
			d={o : JSON.stringify(o), type:type+ "@" + appid}
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
        get_objects: function(appid, type, query, paging, view, sort){
			// console.log(type, appid);
            var d = {type: type + "@" + appid }
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