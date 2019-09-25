import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sensoro_survey/generated/customCalendar/lib/controller.dart';
import 'package:sensoro_survey/net/api/app_api.dart';
import 'package:sensoro_survey/net/api/net_config.dart';
import 'package:sensoro_survey/views/survey/common/data_transfer_manager.dart';
import 'package:sensoro_survey/views/survey/commonWidegt/SearchView.dart';
import 'package:sensoro_survey/views/survey/const.dart' as prefix0;
import 'package:sensoro_survey/views/survey/sitePages/Model/SitePageModel.dart';
import 'package:sensoro_survey/views/survey/sitePages/buildinglist_page.dart';
import 'package:sensoro_survey/views/survey/sitePages/creat_site_page.dart';
import 'package:sensoro_survey/views/survey/sitePages/dynamic_creat_page.dart';
import 'package:sensoro_survey/views/survey/sitePages/sqflite_page.dart';

import '../const.dart';


class QuestionAnswerDetailPage extends StatefulWidget {
  QuestionAnswerDetailPage({Key key, this.title}) : super(key: key);


  final String title;

  @override
  _QuestionAnswerDetailPageState createState() => _QuestionAnswerDetailPageState();
}

class _QuestionAnswerDetailPageState extends State<QuestionAnswerDetailPage> {

  BasicMessageChannel  _locationBasicMessageChannel =
  BasicMessageChannel("BasicMessageChannelPluginGetCity", StandardMessageCodec());
  FocusNode blankNode = FocusNode();
  bool calendaring = false;
  String beginTimeStr = "";
  String endTimeStr = "";

  String dateFilterStr = "";
  CalendarController controller;
  String searchStr = "";
  TextEditingController searchController = TextEditingController();
  List<SitePageModel> dataList = [];

  void _startManagePage(SitePageModel data) async {
    DataTransferManager.shared.creatModel();
    final result = await Navigator.of(context, rootNavigator: true)
        .push(CupertinoPageRoute(builder: (BuildContext context) {
      return new BuildingListPage(sitePageModel: data);
    }));

    if (result != null) {
      String name = result as String;
      if (name == "refreshList") {}
      // this.name = name;
      setState(() {});
    }
  }

  void _creatSite(SitePageModel model, bool isCreat) async {
    DataTransferManager.shared.creatModel();
    final result = await Navigator.of(context, rootNavigator: true)
        .push(CupertinoPageRoute(builder: (BuildContext context) {
      return new CreatSitePage(fireModel: model, isCreatSite: isCreat);
    }));

    if (result != null) {
      getListNetCall();
    }
  }

  void _textSql()async {
    final result = await Navigator.of(context, rootNavigator: true)
        .push(CupertinoPageRoute(builder: (BuildContext context) {
      return new DynamicCreatePage();
    }));

    if (result != null) {
      String name = result as String;
      if (name == "refreshList") {}
      // this.name = name;
      setState(() {});
    }
  }



  Future getListNetCall() async {
    String urlStr = NetConfig.siteListUrl+"0"+"&keyword="+searchStr;
    Map<String, dynamic> headers = {};
    Map<String, dynamic> params = {};

    ResultData resultData = await AppApi.getInstance()
        .getListNetCall(context, true, urlStr, headers, params);
    if (resultData.isSuccess()) {
      // _stopLoading();
      dataList.clear();
      int code = resultData.response["code"].toInt();
      if (code == 200) {

        if (resultData.response["data"]["records"] is List) {
          List resultList = resultData.response["data"]["records"];
          if (resultList.length > 0) {
            for (int i = 0; i < resultList.length; i++) {
              Map json = resultList[i] as Map;
              SitePageModel model = SitePageModel.fromJson(json);
              if (model != null) {
                dataList.add(model);
              }
            }

          }
        }

      }
      setState(() {
      });
    }
  }


  _getData() {
    for (int i = 0; i < 5; i++) {
      var sitePage = new SitePageModel("","","","","","","","",0.0,"","");
      sitePage.siteName = "望京soho T1";

      dataList.add(sitePage);
    }
  }

  void _createDynamic() async {
    final result = await Navigator.of(context, rootNavigator: true)
        .push(CupertinoPageRoute(builder: (BuildContext context) {
      return new DynamicCreatePage();
    }));

    if (result != null) {
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _locationBasicMessageChannel.setMessageHandler((message) => Future<String>(() {
      print(message);
      //message为native传递的数据
      //给Android端的返回值
      return "========================收到Native消息：" + message;
    }));


    getListNetCall();
  }

  @override
  Widget build(BuildContext context) {


    Widget navBar = AppBar(
      elevation: 1.0,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      centerTitle: true,
      // title: Text(
      //   "项目列表",
      //   style: TextStyle(
      //       color: BLACK_TEXT_COLOR, fontWeight: FontWeight.bold, fontSize: 16),
      // ),
      title: Text("建筑风险比例"),
      actions: <Widget>[

        Container(
          padding: new EdgeInsets.fromLTRB(0, 0, 0, 0),
          alignment: Alignment.center,
          child: GestureDetector(
              onTap: () {
                // 点击空白页面关闭键盘
                _textSql();
              },
              child: Padding(
                padding: new EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Text(
                  "保存",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              )
          ),
        ),
      ],
    );




    Widget myListView = new ListView.builder(
        physics: new AlwaysScrollableScrollPhysics()
            .applyTo(new BouncingScrollPhysics()), // 这个是用来控制能否在不屏的状态下滚动的属性
        itemCount: dataList.length == 0 ? 1 : dataList.length,
        // separatorBuilder: (BuildContext context, int index) =>
        // Divider(height: 1.0, color: Colors.grey, indent: 20), // 添加分割线
        itemBuilder: (BuildContext context, int index) {
          // print("rebuild index =$index");
          if (dataList.length == 0) {
            return new Container(
              padding: const EdgeInsets.only(
                  top: 150.0, bottom: 0, left: 0, right: 0),
              child: new Column(children: <Widget>[
                new Image(
                  image: new AssetImage("assets/images/nocontent.png"),
                  width: 120,
                  height: 120,
                  // fit: BoxFit.fitWidth,
                ),
                Text("暂无场所",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: prefix0.LIGHT_TEXT_COLOR,
                        fontWeight: FontWeight.normal,
                        fontSize: 17)),
              ]),
            );
          }

          return Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            child: new Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.only(top: 0.0, bottom: 0, left: 0, right: 0),
              child: new Column(

                  //这行决定了对齐
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      color: LIGHT_LINE_COLOR,
                      height: 12,
                      width: prefix0.screen_width,
                    ),

                    GestureDetector(
                      onTap: () {
                        _startManagePage(dataList[index]);
                      },
                      child: Container(
                        height: 80,
                        color: Colors.white,
                        padding: const EdgeInsets.only(
                            top: 0.0, bottom: 0, left: 20, right: 20),
                        child: Row(
                            //Row 中mainAxisAlignment是水平的，Column中是垂直的
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //表示所有的子件都是从左到顺序排列，这是默认值
                            textDirection: TextDirection.ltr,
                            children: <Widget>[
                              //这决定了左对齐
                             
                            ]),
                      ),
                    ),

                    //分割线
                    Container(
                        alignment: Alignment.center,
                        width: prefix0.screen_width,
                        height: 1.0,
                        color: FENGE_LINE_COLOR),
                  ]),
            ),
            secondaryActions: <Widget>[
            ],
          );
        });

    _searchAction(String text) {
      searchStr = text;
      getListNetCall();
      print("........................." + text);
    }


    Widget reflust = new  RefreshIndicator(
      displacement: 10.0,
      child: myListView,
      onRefresh: getListNetCall

    );


    Widget bodyContiner = new Container(
      color: Colors.white,
      // height: 140, //高度不填会自适应
      padding: const EdgeInsets.only(top: 0.0, bottom: 120, left: 0, right: 0),
      child: Column(
        //这行决定了左对齐
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          //分割线
          Container(
              width: prefix0.screen_width,
              height: 1.0,
              color: FENGE_LINE_COLOR),
          Expanded(
            child: reflust,
          ),
          // bottomButton,
        ],
      ),
    );


    return new Scaffold(
      appBar: navBar,
      body: GestureDetector(
        onTap: () {
          // 点击空白页面关闭键盘
          FocusScope.of(context).requestFocus(blankNode);
        },
        child: bodyContiner,
      ),
    );
  }
}