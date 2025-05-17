import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mysql_image_app/view/inser_address.dart';
import 'package:mysql_image_app/view/update_address.dart';

class QueryAddress extends StatefulWidget {
  const QueryAddress({super.key});

  @override
  State<QueryAddress> createState() => _QueryAddressState();
}

class _QueryAddressState extends State<QueryAddress> {
  List data = [];

  @override
  void initState() {
    super.initState();
    getJSONData();
  }
// ---------------------------- Functions ------------------------- //
getJSONData()async{
  var response = await http.get(Uri.parse("http://127.0.0.1:8000/select"));
  data.clear();
  data.addAll(json.decode(utf8.decode(response.bodyBytes))['results']);
  setState(() {});
  // print(data);
}
// ---------------------------------------------------------------- //
// ---------------------------- Body ------------------------------ //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("주소록 검색"),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(InserAddress())!.then((value) => getJSONData());
            }, 
            icon: Icon(Icons.add_outlined)
          )
        ],
      ),
      body: Center(
        child: data.isEmpty
        ? Text('데이터가 없습니다.', textAlign: TextAlign.center,)
        :ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Get.to(UpdateAddress(),
                arguments: [
                  // image 는 size 가 너무 크기 때문에 update 화면에서 따로 불러온다!
                  data[index]['seq'],
                  data[index]['name'],
                  data[index]['phone'],
                  data[index]['address'],
                  data[index]['relation'],
                ]
                )!.then((value) => getJSONData());
              },
              child: Slidable(
                endActionPane: ActionPane(
                  motion: BehindMotion(), 
                  children: [
                    SlidableAction(
                      icon: Icons.delete,
                      backgroundColor: Colors.red,
                      label: "삭제",
                      onPressed: (context) => deleteAction(data[index]['seq']),
                    )
                  ],
                ),
                child: Card(
                  child: Row(
                    children: [
                      // server 에서 cache 를 막아놔도 network 에서도 cache 가 있기 때문에 설정을 한번 더 해줘야 한다.
                      // ?t=${DateTime.now().microsecondsSinceEpoch 부분을 추가 해준다.
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network("http://127.0.0.1:8000/view/${data[index]['seq']}?t=${DateTime.now().microsecondsSinceEpoch}",
                        width: 100,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("이름       : ${data[index]['name']}"),
                          Text("전화번호 : ${data[index]['phone']}"),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }// build
// ------------------------- Functions ---------------------------- //
deleteAction(int seq){
  getJSONDataDelete(seq);
  getJSONData();
  setState(() {});
}
// ---------------------------------------------------------------- //
getJSONDataDelete(int seq)async{
  var response = await http.delete(Uri.parse("http://127.0.0.1:8000/delete/$seq"));
  var result = json.decode(utf8.decode(response.bodyBytes))['result'];
  if (result != "OK"){
    errorSnackBar();
  }
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