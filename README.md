# This project shows how to send Formdata requests to Express+Apollo server using Dio in flutter.

!! Don't forget to include the <code>apollo-require-preflight: true</code> header in the request from flutter.

- The steps involve:

1. Use Image_Picker instance to pick an array of images.
2. Create a corresponing array with `null` entries for each image picked.
3. Create a `Map<String, dynamic> mapData` Object with properties for operations and map.
4. Initialize an empty `Formdata` Instance using the `Dio` library.
5. Use the `.fromMap()` method to convert the `mapData` into Formdata.
6. The Files selected will be added individually in the FormData instance.
7. Send the Formdata as data using Dio.post method.

---

**The Code Looks as follows:**

```dart
void _chooseMultiple() async {
   _images = await picker.pickMultiImage();
   if (_images.isEmpty) return;

   List correspondingNullImageArray = [];
   for (var element in _images) {
     correspondingNullImageArray.add(null);
   }

   Map<String, dynamic> map = {};
   map["operations"] = json.encode({
     "query":
         "mutation MultipleUpload(\$files:[Upload!]){multipleUpload(files:\$files)}",
     "variables": {"files": correspondingNullImageArray}
   });

   Map<String, dynamic> mapField = {};
   for (var i = 0; i < _images.length; i++) {
     mapField["$i"] = ["variables.files.$i"];
   }
   map["map"] = json.encode(mapField);

   FormData data = FormData.fromMap(map);
   for (var i = 0; i < _images.length; i++) {
     data.files
         .add(MapEntry("$i", MultipartFile.fromFileSync(_images[i]!.path)));
   }

   Dio dio = new Dio();
   Response res = await dio.post("http://192.168.43.17:8084/graphql",
       data: data,
       options: Options(headers: {"apollo-require-preflight": true}));
   print(res);
 }
```

