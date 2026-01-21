import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tailor/data/services/database_helper.dart';
import '../../../data/models/piece_model.dart';
import '../../../data/services/supabase_service.dart';
import '../../../functions.dart';

class PieceController extends GetxController {
  var pieces = <PieceModel>[].obs;
  var filteredPieces = <PieceModel>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  final DatabaseHelper _database = DatabaseHelper();
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void onInit() {
    super.onInit();
    fetchPieces();
  }

  // جلب جميع القطع
  Future<void> fetchPieces() async {
    try {
      isLoading.value = true;
      final List<PieceModel> allPieces = await _database.getAllPieces();
      pieces.value = allPieces;
      filteredPieces.value = allPieces;
    } catch (e) {
      print('Error fetching pieces: $e');
      Get.snackbar(
        'خطأ',
        'فشل في تحميل البيانات',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<int> deleteAll(){
    return DatabaseHelper().deleteAllData(table: 'pieces');
  }



  // البحث عن قطع
  Future<void> search(String query) async {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredPieces.value = pieces;
      return;
    }

    try {
      isLoading.value = true;
      final List<PieceModel> results = await _database.searchPieces(query);
      filteredPieces.value = results;
    } catch (e) {
      print('Error searching: $e');
    } finally {
      isLoading.value = false;
    }
  }


  Future<bool> uploadPiece({required PieceModel piece}){
    return _supabaseService.exportSinglePieces(piece: piece);
  }

  // حذف قطعة
  Future<void> deletePiece(int id, BuildContext context) async {
    try {
      await _database.deletePiece(id: id);

      // تحديث القوائم بعد الحذف
      pieces.removeWhere((piece) => piece.id == id);
      filteredPieces.removeWhere((piece) => piece.id == id);

      // عرض رسالة نجاح
      helpers.customSnackBar(
        title: 'نجاح',
        message: 'تم حذف القطعة بنجاح',
        background: CupertinoColors.systemGreen
      );
    } catch (e) {
      print('Error deleting piece: $e');
      helpers.customSnackBar(
          title:'!خطا',
          message: 'فشل في حذف القطعة',
          background: CupertinoColors.systemRed
      );
    }
  }


}