import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UpdateAddress extends StatefulWidget {
  const UpdateAddress({super.key});

  @override
  State<UpdateAddress> createState() => _UpdateAddressState();
}

class _UpdateAddressState extends State<UpdateAddress> {
// ------------------------- Property ------------------------------- //
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController relationController = TextEditingController();

  var value = Get.arguments ?? "__";

  XFile? imageFile;
  final ImagePicker picker = ImagePicker();

  // ImagePicker 에서 선택된 filename
  String filename = ""; 

  // Gallery 를 선택 했는지 확인하기 위한 변수
  int firstDisp = 0;
// ------------------------------------------------------------------ //
@override
  void initState() {
    super.initState();
    nameController.text = value[1];
    phoneController.text = value[2];
    addressController.text = value[3];
    relationController.text = value[4];
  }
// ------------------------------------------------------------------ //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("주소록 수정"),
      ),
      body: Center(
        child: Column(
          children: [
            _buildTextField(nameController, "이름을 수정 하세요", false),
            _buildTextField(phoneController, "전화번호를 수정 하세요", false),
            _buildTextField(addressController, "주소를 수정 하세요", false),
            _buildTextField(relationController, "관계를 수정 하세요", false),
            ElevatedButton(
              onPressed: () => getImageFromGallery(ImageSource.gallery), 
              child: Text('이미지 가져오기')
            ),
            // 이미지를 변경하기 전에 기존의 이미지를 보여주기 위해!
            firstDisp == 0
            ? Container(
              width: MediaQuery.of(context).size.width,
              height: 200,
              color: Colors.grey,
              child: Center(
                child: Image.network(
                  "http://127.0.0.1:8000/view/${value[0]}?t=${DateTime.now().microsecondsSinceEpoch}"
                )
              ),
            )
            // 이미지를 새로 불러온 경우 바뀐 이미지로 보여준다.
            : Container(
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
              onPressed: () => updateAction(), 
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
  firstDisp += 1;
  setState(() {});
}
// ------------------------------------------------------------------- //
// multipart 는 큰 데이터를 사용 할 때 사용하며 퍼포먼스가 좋다!
// String 과 image 를 함께 보내기 때문에 MultipartRequest 를 사용한다!
// image 의 변경 여부를 판별하여 다르게 update 해주어야 한다.
updateAction()async{
  final uri = firstDisp != 0
  ? Uri.parse("http://127.0.0.1:8000/update_with_image")
  : Uri.parse("http://127.0.0.1:8000/update");
  var request = http.MultipartRequest(
    "POST",      // get 방식 이라면 get 이 쓰인다.
    uri
  );
  request.fields['seq'] = (value[0]).toString();
  request.fields['name'] = nameController.text;
  request.fields['phone'] = phoneController.text;
  request.fields['address'] = addressController.text;
  request.fields['relation'] = relationController.text;

  if(firstDisp != 0 && imageFile != null){
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
    title: "수정 결과",
    middleText: "수정이 완료 되었습니다.",
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
    '수정 시 문제가 발생 했습니다.',
    duration: Duration(seconds: 2)
  );
}
// ------------------------------------------------------------------- //
}// class