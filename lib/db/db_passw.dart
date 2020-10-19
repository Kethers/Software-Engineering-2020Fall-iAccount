import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String tablePassword = 'Password';
final String columnpassword = '_password';
final String columnauthentication = '_authentication';

class Password {
  String password;
  bool authentication;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnpassword: password,
      columnauthentication: authentication
    };
    if (password != null) {
      map[columnpassword] = password;
    }
    return map;
  }

  Password([String password, bool authentication = false]) {
    this.password = password;
    this.authentication = authentication;
  }

  Password.fromMap(Map<String, dynamic> map) {
    password = map[columnpassword];
    authentication = map[columnauthentication];
  }
}

class PWSqlite {
  Database db;

  openSqlite() async {
    // 获取数据库文件的存储路径
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'PW.db');

//根据数据库文件路径和数据库版本号创建数据库表
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
          CREATE TABLE $tablePassword (
            $columnpassword STRING PRIMARY KEY, 
            $columnauthentication BOOL PRIMARY, )
          ''');
    });
  }

  // 插入新密码
  Future<Password> insert(Password pw) async {
    pw.password = (await db.insert(tablePassword, pw.toMap())) as String;
    return pw;
  }

  // 读取密码
  Future<Password> loadPassword() async {
    List<Map> maps = await db
        .query(tablePassword, columns: [columnpassword, columnauthentication]);

    if (maps == null || maps.length == 0) {
      return null;
    }

    List<Password> pw = [];
    pw.add(Password.fromMap(maps[0]));
    return pw[0];
  }

// 读取密码认证状态
  Future<Password> loadAuthentication() async {
    List<Map> maps = await db
        .query(tablePassword, columns: [columnpassword, columnauthentication]);

    if (maps == null || maps.length == 0) {
      return null;
    }

    List<Password> pw = [];
    pw.add(Password.fromMap(maps[0]));
    return pw[1];
  }

  // 更新密码
  Future<int> updatePW(Password pw, String key) async {
    return await db.update(tablePassword, pw.toMap(),
        where: '$columnpassword = ?', whereArgs: [key]);
  }

  //更新密码认证状态
  Future<int> updateAT(Password pw, bool at) async {
    return await db.update(tablePassword, pw.toMap(),
        where: '$columnauthentication = ?', whereArgs: [at]);
  }

  // 记得及时关闭数据库，防止内存泄漏
  close() async {
    await db.close();
  }
}
