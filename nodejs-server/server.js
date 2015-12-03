var images_path     = "./upload/"
var express         =       require("express");
var multer          =       require('multer');
var app             =       express();
var upload = multer({ dest: images_path});

app.use(multer({ dest: images_path,
    rename: function (fieldname, filename, req, res) {
        console.log('Rename is called');
        return filename+Date.now();
    },
    onFileUploadStart: function (file) {
        file.fieldname = file.originalname;
        console.log(file.originalname + ' is starting ...');
    },
    onFileUploadComplete: function (file) {
        console.log(file.fieldname + ' uploaded to  ' + file.path)
    }
}));

// app.get('/',function(req,res){
//       res.sendFile(__dirname + "/index.html");
// });

app.post('/lmp/image/upload',function(req,res){
    upload(req,res,function(err) {
        if(err) {
            return res.end("Error uploading file.");
        }
        res.end("File is uploaded");
    });
});

app.listen(9292,function(){
    console.log("Working on port 9292");
});
