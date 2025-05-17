import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class InserAddress extends StatefulWidget {
  const InserAddress({super.key});

  @override
  State<InserAddress> createState() => _InserAddressState();
}

class _InserAddressState extends State<InserAddress> {
// ------------------------- Property ------------------------------- //
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController relationController = TextEditingController();

  XFile? imageFile;
  final ImagePicker picker = ImagePicker();

  String filename = ""; // ImagePicker 에서 선택된 filename
// ------------------------------------------------------------------ //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("주소록 추가"),
      ),
      body: Center(
        child: Column(
          children: [
            _buildTextField(nameController, "이름을 입력 하세요", false),
            _buildTextField(phoneController, "전화번호를 입력 하세요", false),
            _buildTextField(addressController, "주소를 입력 하세요", false),
            _buildTextField(relationController, "관계를 입력 하세요", false),
            ElevatedButton(
              onPressed: () => getImageFromGallery(ImageSource.gallery), 
              child: Text('이미지 가져오기')
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 200,
              color: Colors.grey,
              child: Center(
                child: imageFile == null
                ? Text('이미지가 선택되지 않았습니다.')
                : Image.file(File(imageFile!.path)),
              ),
            ),
            ElevatedButton(
              onPressed: () => insertAction(), 
              child: Text('입력')
            ),
          ],
        ),
      ),
    );
  }// build
// -------------------------- Widgets -------------------------------- //
Widget _buildTextField(TextEditingController conrtoller, String labelText, bool readOnly){
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextField(
      controller: conrtoller,
      decoration: InputDecoration(
        labelText: labelText
      ),
      keyboardType: TextInputType.text,
      readOnly: readOnly,
    ),
  );
}
// ------------------------------------------------------------------- //
// -------------------------- Functions ------------------------------ //
getImageFromGallery(ImageSource imageSource)async{
  final XFile? pickedFile = await picker.pickImage(source: imageSource);
  imageFile = XFile(pickedFile!.path); // 선택된 이미지의 경로를 가져온다
  setState(() {});
}
// ------------------------------------------------------------------- //
// multipart 는 큰 데이터를 사용 할 때 사용하며 퍼포먼스가 좋다!
// String 과 image 를 함께 보내기 때문에 MultipartRequest 를 사용한다!
insertAction()async{
  var request = http.MultipartRequest(
    "POST",      // get 방식 이라면 get 이 쓰인다.
    Uri.parse("http://127.0.0.1:8000/insert")
  );
  request.fields['name'] = nameController.text;
  request.fields['phone'] = phoneController.text;
  request.fields['address'] = addressController.text;
  request.fields['relation'] = relationController.text;
  if(imageFile != null){
    request.files.add(await http.MultipartFile.fromPath('file', imageFile!.path));
  }
  var res = await request.send();
  if(res.statusCode == 200){
    _showDialog();
  } else{
    errorSnackBar();
  }
}
// ------------------------------------------------------------------- //
_showDialog(){
  Get.defaultDialog(
    title: "입력 결과",
    middleText: "입력이 완료 되었습니다.",
    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    barrierDismissible: false,
    actions: [
      TextButton(
        onPressed: () {
          Get.back();
          Get.back();
        }, 
        child: Text('OK')
      ),
    ]
  );
}
// ------------------------------------------------------------------- //
errorSnackBar(){
  Get.snackbar(
    'Error', 
    '입력시 문제가 발생 했습니다.',
    duration: Duration(seconds: 2)
  );
}
// ------------------------------------------------------------------- //
}// class