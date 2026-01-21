import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailor/data/models/customer_model.dart';
import 'package:tailor/data/models/piece_model.dart';
import 'database_helper.dart';



class SupabaseService {

  final supabase = Supabase.instance.client;
  final DatabaseHelper dbHelper = DatabaseHelper();

  // جلب جميع العملاء من SQLite
  Future<List<CustomerModel>> getLocalCustomers() async {
    var customerMaps = await dbHelper.queryAllCustomers();
    return customerMaps.map((e) => CustomerModel.fromMap(e)).toList();
  }

  // جلب جميع القطع من SQLite
  Future<List<PieceModel>> getLocalPieces() async {
    final db = await dbHelper.database;
    var pieceMaps = await db.query('pieces');
    return pieceMaps.map((e) => PieceModel.fromMap(e)).toList();
  }

  // تصدير العملاء فقط إلى Supabase
  Future<bool> exportCustomers() async {
    try {
      final customers = await getLocalCustomers();
      int exportedCount = 0;

      for (var customer in customers) {
        await supabase.from('customers').upsert({
          'id': customer.id,
          'name': customer.name,
          'phone': int.parse(customer.phone),
          'location': customer.location,
        });
        exportedCount++;
      }

      await logBackup(
        type: 'export_customers',
        recordCount: exportedCount,
        details: 'تم تصدير $exportedCount عميل',
      );

      return true;
    } on DatabaseException catch (e){
      if(e.isUniqueConstraintError()){
        Get.snackbar(
            '!خطا',
            'رقم هاتف موجود مسبقا',
            backgroundColor: Colors.red,
            colorText: Colors.white
        );
      }
      rethrow;
    }
  }

  // تصدير القطع فقط إلى Supabase
  Future<bool> exportPieces() async {
    try {
      final pieces = await getLocalPieces();
      int exportedCount = 0;

      for (var piece in pieces) {
        await supabase.from('pieces').upsert({
          'id': piece.id,
          'customer_phone': int.parse(piece.customerPhone!),
          'name': piece.name,
          'type': piece.type,
          'price': piece.price,
          'length': piece.length,
          'width': piece.width,
          'notes': piece.notes,
          'paid_amount': piece.paidAmount,
          'created_at': piece.createdAt.toIso8601String(),
        });
        exportedCount++;
      }

      await logBackup(
        type: 'export_pieces',
        recordCount: exportedCount,
        details: 'تم تصدير $exportedCount قطعة',
      );

      return true;
    } catch (e) {
      print('Export pieces error: $e');
      return false;
    }
  }


  Future<bool> exportSinglePieces({required PieceModel piece}) async {
    try {

        await supabase.from('pieces').upsert(piece.toMap());
        await logBackup(
          type: 'export_pieces',
          recordCount: 1,
          details: 'تم تصدير 1 قطعة',
        );

      return true;
    } on PostgrestException catch(e) {
      print('Export pieces error: ${e.message}');
      return false;
    }
  }

  Future<bool> exportSingleCustomer({required CustomerModel customer}) async {
    try {

      await supabase.from('customers').upsert(customer.toMap());
      await logBackup(
        type: 'export_customers',
        recordCount: 1,
        details: 'تم تصدير 1 قطعة',
      );

      return true;
    } on DatabaseException catch (e){
      if(e.isUniqueConstraintError()){
        Get.snackbar(
            '!خطا',
            'رقم الهاتف موجود مسبقا',
            backgroundColor: Colors.red,
            colorText: Colors.white
        );
      }
      rethrow;
    }
  }


  // تصدير كل شيء
  Future<bool> exportAll() async {
    try {
      final customersSuccess = await exportCustomers();
      final piecesSuccess = await exportPieces();
      return customersSuccess && piecesSuccess;
    } on DatabaseException catch (e){
      if(e.isUniqueConstraintError()){
        Get.snackbar(
            '!خطا',
            'رقم هاتف موجود مسبقا',
            backgroundColor: Colors.red,
            colorText: Colors.white
        );
      }
      rethrow;
    }
  }

  // استيراد العملاء فقط من Supabase
  Future<bool> importCustomers() async {
    try {
      // استيراد العملاء
      final customersResponse = await supabase
          .from('customers')
          .select()
          .order('created_at', ascending: false);

      int importedCount = 0;
      for (var customerData in customersResponse) {
        await dbHelper.insertCustomer({
          'name': customerData['name'],
          'phone': customerData['phone'].toString(),
          'location': customerData['location'],
          // 'created_at': customerData['created_at'],
        });
        importedCount++;
      }

      await logBackup(
        type: 'import_customers',
        recordCount: importedCount,
        details: 'تم استيراد $importedCount عميل',
      );

      return true;
    } on DatabaseException catch (e){
      if(e.isUniqueConstraintError()){
        Get.snackbar(
            '!خطا',
            'رقم الهاتف موجود مسبقا',
            backgroundColor: Colors.red,
            colorText: Colors.white
        );
      }
      rethrow;
    }
  }

  Future<int> importCustomer({required  Map<String, dynamic> customerData}) async {
    try {
      return await dbHelper.insertCustomer({
        'name': customerData['name'],
        'phone': customerData['phone'].toString(),
        'location': customerData['location'],
      });
    } on DatabaseException catch (e){
      if(e.isUniqueConstraintError()){
        Get.snackbar(
            '!خطا',
            'رقم الهاتف موجود مسبقا',
            backgroundColor: Colors.red,
            colorText: Colors.white
        );
      }
      rethrow;
    }
  }


  // استيراد القطع فقط من Supabase
  Future<bool> importPieces() async {
    try {
      // استيراد القطع
      final piecesResponse = await supabase
          .from('pieces')
          .select()
          .order('created_at', ascending: false);

      int importedCount = 0;
      for (var pieceData in piecesResponse) {
        await dbHelper.insertPiece(row: {
          'customer_phone': pieceData['customer_phone'].toString(),
          'name': pieceData['name'],
          'type': pieceData['type'],
          'price': pieceData['price'],
          'length': pieceData['length'],
          'width': pieceData['width'],
          'notes': pieceData['notes'],
          'paid_amount': pieceData['paid_amount'],
          'created_at': pieceData['created_at'],
        });
        importedCount++;
      }

      await logBackup(
        type: 'import_pieces',
        recordCount: importedCount,
        details: 'تم استيراد $importedCount قطعة',
      );

      return true;
    } catch (e) {
      print('Import pieces error: $e');
      return false;
    }
  }

  // استيراد كل شيء
  Future<bool> importAll() async {
    try {
      // مسح البيانات المحلية أولاً
      final db = await dbHelper.database;
      await db.delete('customers');
      await db.delete('pieces');

      final customersSuccess = await importCustomers();
      final piecesSuccess = await importPieces();
      return customersSuccess && piecesSuccess;
    } on DatabaseException catch (e){
      if(e.isUniqueConstraintError()){
        Get.snackbar(
            '!خطا',
            'رقم الهاتف موجود مسبقا',
            backgroundColor: Colors.red,
            colorText: Colors.white
        );
      }
      rethrow;
    }
  }

  // الحصول على إحصائيات منفصلة
  Future<Map<String, dynamic>> getBackupStats() async {
    try {
      final customersCount = await supabase
          .from('customers')
          .select('id').count(CountOption.exact);

      final piecesCount = await supabase
          .from('pieces')
          .select('id').count(CountOption.exact);

      return {
        'customers_count': customersCount.count,
        'pieces_count': piecesCount.count,
      };
    } catch (e) {
      return {'customers_count': 0, 'pieces_count': 0};
    }
  }


  // الحصول على تاريخ آخر نسخة احتياطية لكل نوع
  Future<Map<String, DateTime?>> getLastBackupDates() async {
    try {
      final customersResponse = await supabase
          .from('backup_logs')
          .select('created_at')
          .eq('type', 'export_customers')
          .order('created_at', ascending: false)
          .limit(1);

      final piecesResponse = await supabase
          .from('backup_logs')
          .select('created_at')
          .eq('type', 'export_pieces')
          .order('created_at', ascending: false)
          .limit(1);

      DateTime? customersDate = customersResponse.isNotEmpty && customersResponse[0]['created_at'] != null
          ? DateTime.parse(customersResponse[0]['created_at'])
          : null;

      DateTime? piecesDate = piecesResponse.isNotEmpty && piecesResponse[0]['created_at'] != null
          ? DateTime.parse(piecesResponse[0]['created_at'])
          : null;

      return {
        'customers': customersDate,
        'pieces': piecesDate,
      };
    } catch (e) {
      return {'customers': null, 'pieces': null};
    }
  }


  Future<bool> deleteAllData({required String table}) async {
    try {

      await supabase
          .from(table)
          .delete()
          .gte('id', 0); // شرط يحذف كل شيء

      return true;
    } on PostgrestException catch(e) {
      Get.snackbar('خطأ', e.message.toString());
      rethrow;
    }
  }



  // تسجيل عملية النسخ الاحتياطي مع تفاصيل
  Future<void> logBackup({
    required String type,
    required int recordCount,
    String details = '',
  }) async {
    try {
      await supabase.from('backup_logs').insert({
        'type': type,
        'record_count': recordCount,
        'details': details,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Log backup error: $e');
    }
  }
}