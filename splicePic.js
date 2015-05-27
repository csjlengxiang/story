var fs = require('fs');
var async = require("async");
var im = require('imagemagick');
var walk=require("walkdo")
var path = require("path")
//im.resize({
//  srcData: fs.readFileSync('kittens.jpg', 'binary'),
//  width:   256
//}, function(err, stdout, stderr){
//  if (err) throw err
//  fs.writeFileSync('kittens-resized.jpg', stdout, 'binary');
//  console.log('resized kittens.jpg to fit within 256x256px')
//});
var doone = function(_p,cb){
	if(path.extname(_p).toLowerCase()==".jpg"){
		im.readMetadata(_p, function(err, metadata){
		  if (err) {
			  cb(err);
			  return;
		  }
		  if(!metadata.exif){
			  cb(new Error("error"))
			  return;
		  } 
		  console.log(_p)
		  var width = metadata.exif.exifImageWidth;
		  var height = metadata.exif.exifImageLength;
		  if(width>height*1.3){
			  //分为两半
			  async.series([
				  function(_cb){
					  im.crop({
						  srcPath: _p,
						  dstPath: _p.replace(/\.jpg|\.JPG/,"001.jpg"),
						  width: width/2,
						  height: height,
						  quality: 1,
						  gravity: "SouthWest"
						}, function(err, stdout, stderr){
							
							im.resize({
							  srcPath: _p.replace(/\.jpg|\.JPG/,"001.jpg"),
							  dstPath: _p.replace(/\.jpg|\.JPG/,"001.jpg"),
							  width:   (width/2>600)?600:(width/2)
							}, function(err, stdout, stderr){
							  _cb();
							});
						});
				  },
				  function(_cb){
					  im.crop({
						  srcPath: _p,
						  dstPath: _p.replace(/\.jpg|\.JPG/,"002.jpg"),
						  width: width/2,
						  height: height,
						  quality: 1,
						  gravity: "SouthEast"
						}, function(err, stdout, stderr){
						  im.resize({
							  srcPath: _p.replace(/\.jpg|\.JPG/,"002.jpg"),
							  dstPath: _p.replace(/\.jpg|\.JPG/,"002.jpg"),
							  width:   (width/2>600)?600:(width/2)
							}, function(err, stdout, stderr){
							  _cb();
							});
						});
				  }
			  ],function(){
				  fs.unlinkSync(_p)
				  cb()
			  })
			  
				
		  }else{
			 fs.renameSync(_p,_p.replace(/\.jpg|\.JPG/,"000.jpg"))
			 im.resize({
			  srcPath: _p.replace(/\.jpg|\.JPG/,"000.jpg"),
			  dstPath: _p.replace(/\.jpg|\.JPG/,"000.jpg"),
			  width:   (width>600)?600:(width)
			}, function(err, stdout, stderr){
			  cb();
			});
			 
		  }
		  
		});
	}else{
		cb()
	}
}
var source = './../巴特恩的裁缝梦/';
//同步深度遍历文件夹
walk(source,function(list,next,context){
	doone(path.join(__dirname,list),function(){
		next.call(context)
	})
},function(){
    console.log("all finish!")
	var paths = fs.readdirSync(source);
	var result_paths = []
    paths.forEach(function (_p) {
		if(path.extname(_p)==".jpg"){
			result_paths.push(path.join(source,_p));
		}
    });
	result_paths.sort(function(r1,r2){
		if(path.basename(r1,'.jpg').replace(/[^0-9]/g,'')*1>path.basename(r2,'.jpg').replace(/[^0-9]/g,'')*1){
			return 1;
		}else if(path.basename(r1,'.jpg').replace(/[^0-9]/g,'')*1<path.basename(r2,'.jpg').replace(/[^0-9]/g,'')*1){
			return -1;
		}else{
			return 0;
		}
	});
	result_paths.forEach(function(r,i){
		fs.renameSync(r,path.join(path.dirname(r),i+".jpg"))
	})
	console.log(result_paths)
})