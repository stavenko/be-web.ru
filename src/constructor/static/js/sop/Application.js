var init_db = function(csrf_token){
    var cs_name = $(csrf_token).prop('name');
    var cs_val  = $(csrf_token).val()
    var a = {
		__query_cache : {}, // Refresh every F5 data
        save_object: function(appid, type, obj, progress, complete){
            var data = {'object':obj,
                            'type' : type+ "@" + appid};
            //data[cs_name] = cs_val;
            var xhr = new XMLHttpRequest()
            var fd = new FormData();
            for (i in obj.images){
            }
            function loadend() {
                
                complete(this )
            };

            if (obj.is_unique){
                fd.append('is_unique', true)
            };

            fd.append('x-data', JSON.stringify(data))
            fd.append(cs_name, cs_val)
            xhr.open("POST", "/_/data/", true)
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
            xhr.open("POST", "/_/site_cache/", false)
            
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
            xhr.open("POST", "/_/email/", false)
            
            xhr.send(fd)
		},
		save_application: function(app){
            var xhr = new XMLHttpRequest()
            var fd = new FormData();
            fd.append('x-data', app)
            fd.append(cs_name, cs_val)
            xhr.open("POST", "/_/app/add/", true)
            xhr.send(fd)
		},
        save_object_sync:function(appid, type, obj, progress, complete){
            var data = {'object':obj,
                'type' : type+ "@" + appid };
            var xhr = new XMLHttpRequest()
            var fd = new FormData();
            for (i in obj.images){
            }
            function loadend(){
				if (complete){complete(this)}
            }
            fd.append('x-data', JSON.stringify(data))
			if(obj.is_unique){
				fd.append('is_unique', true)
			}
            fd.append(cs_name, cs_val)
            xhr.open("POST", "/_/data/", false)
            xhr.upload.progress = progress
            xhr.onloadend = loadend
            
            xhr.send(fd)
			return JSON.parse(xhr.responseText)
        },
		remove_object:function(appid, type, query, complete){
			var o = {}
			o.q = query
			d={o : JSON.stringify(o), type:type+ "@" + appid}
			d[cs_name] = cs_val;
            var success = function(js){
                if (complete != null){
                  complete(js);

                }
            };
			$.ajax({
				url:'/_/data/delete/',
				data: d,
				dataType:'json',
				type:'POST',
                success: success
				
			})
			
		},
		get_blob_url:function(blob){
			// console.log(">>", blob);
			
			if(blob.blob){
				if('file_id' in blob){
					// console.log('new_style')
					return "/_/blob/" + blob.file_id['$oid'] + '/'
				}else{
				    return "/_/blob/"+ blob._id['$oid'] + '/'
				}
			}else{
				return blob;
			}
		},
		remove_blob:function(blob){
			console.log("BLOB REMOVE");
			if(blob.blob){
				if('file_id' in blob){
					d = {};
					d[cs_name] = cs_val;
					$.ajax({
						url: "/_/del_blob/" + blob._id['$oid'] + '/',
						data : d,
						type:'post'
					})
					
				}else{
				    console.log("NO REMOVE")
				}
			}
			
			
		},
		get_objects_async: function(appid, type, query, paging, view, sort, callback){
			// console.log(type, appid);
            var d = {type: type + "@" + appid }
            var o = {}
            if (query){o['q'] =query}
            if (view){o['v']=view}
            if (sort){o['o'] = sort}
            if (paging){o['p'] = paging}
            d['o'] = JSON.stringify(o)
            //var data = [];
            $.ajax({url:'/_/data/',
                    data: d,
                    dataType:'json',
					cache:false,
                    success: function(js){callback(js)}
				})
            //return data
        	
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
            $.ajax({url:'/_/data/',
                    data: d,
                    dataType:'json',
                    success: function(js){data = js},
                    async:false} 
                    )
            return data
        }
    }
    return a;
}