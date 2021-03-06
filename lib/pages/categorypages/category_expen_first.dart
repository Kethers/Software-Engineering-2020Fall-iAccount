import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:i_account/bill/models/category_model.dart';
import 'package:i_account/db/db_helper.dart';
import 'package:i_account/router_jump.dart';
import 'package:i_account/pages/categorypages/category_expen_second.dart';
import 'package:i_account/widgets/input_textview_dialog_category.dart';

class CategoryExpenFirstPage extends StatefulWidget {
  @override
  _CategoryExpenFirstPageState createState() => _CategoryExpenFirstPageState();
}

class _CategoryExpenFirstPageState extends State<CategoryExpenFirstPage> {
  List categoryNames = new List();

  Future<List> _loadCategoryNames() async {
    List list = await dbHelp.getCategories(1);
    return list;
  }

  @override
  void initState() {
    _loadCategoryNames().then((value) => setState(() {
          categoryNames = value;
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          "一级支出分类",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, item) {
            return buildListData(
              context,
              categoryNames[item],
            );
          },
          separatorBuilder: (BuildContext context, int index) => Divider(),
          itemCount: (categoryNames.length == null) ? 0 : categoryNames.length,
        ),
      ),
    );
  }

  Widget buildListData(BuildContext context, String titleItem) {
    return new ListTile(
      onTap: () {
        if (titleItem != '其他支出') {
          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
            return CategoryExpenSecondPage(titleItem);
          }));
        }
      },
      onLongPress: () async {
        if (titleItem == '其他支出') {
          showDialog<Null>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("提示"),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[Text("该分类不能删除或编辑！")],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: Text("确定"),
                  ),
                ],
              );
            },
          ).then((val) {
            print(val);
          });
        } else {
          showDialog<Null>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("提示"),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text("请选择删除或编辑该分类。\n删除分类的同时也会删除相应的流水信息。")
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: Text("取消"),
                  ),
                  FlatButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return TextViewDialogCategory(
                              confirm: (text) async {
                                CategoryItem preCategory =
                                    await dbHelp.getCategoryid1(titleItem, 1);
                                await dbHelp.updateCategoryBills(
                                    preCategory, text, 1);
                                await dbHelp.insertCategory(
                                    preCategory, 1, text);
                              },
                            );
                          });
                    },
                    child: Text("编辑"),
                  ),
                  FlatButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      CategoryItem category = new CategoryItem(titleItem);
                      dbHelp.deleteCategoryBills(category, 1);
                      dbHelp.deleteCategory(category, 1);
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => RouterJump()),
                          ModalRoute.withName('/'));
                      showDialog<Null>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("提示"),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[Text("已经删除该分类！")],
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                },
                                child: Text("确定"),
                              ),
                            ],
                          );
                        },
                      ).then((val) {
                        print(val);
                      });
                    },
                    child: Text("确定"),
                  ),
                ],
              );
            },
          ).then((val) {
            print(val);
          });
        }
      },
      leading: Icon(Icons.category),
      title: new Text(
        titleItem,
        style: TextStyle(fontSize: 18),
      ),
      trailing: new Icon(Icons.keyboard_arrow_right),
    );
  }
}
