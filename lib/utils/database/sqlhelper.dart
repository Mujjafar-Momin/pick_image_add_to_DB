import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SqlHelper{

  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE images(
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
  imageName TEXT,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
)
""");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase('my_dataBase.db', version: 1,
       onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

static Future<void> insertImage(String imageBase64) async{
   final db = await SqlHelper.db();
 await db.insert('images', {'imageName':imageBase64});
}
static Future getImage(String imageBase64)async{
 final db = await SqlHelper.db();
 final result=await db.query('images',where: 'imageName?',limit: 1,whereArgs: [imageBase64]);
debugPrint(result.toString());
}
 
}