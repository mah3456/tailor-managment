import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailor/data/models/piece_model.dart';
import 'package:tailor/data/models/customer_model.dart';
import 'package:tailor/data/services/supabase_service.dart';

import '../../../data/services/database_helper.dart';

class piecesDataController extends GetxController {
  final supabase = Supabase.instance.client;
  final supabaseService = SupabaseService();
  
  RxList<PieceModel> pieces = <PieceModel>[].obs;
  RxList<PieceModel> filteredPieces = <PieceModel>[].obs;
  RxList<CustomerModel> customers = <CustomerModel>[].obs;
  final DatabaseHelper dbHelper = DatabaseHelper();

  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  // للبحث والتصفية
  RxString searchQuery = ''.obs;
  RxString selectedType = 'الكل'.obs;
  RxString selectedCustomer = 'الكل'.obs;
  RxList<String> types = <String>[].obs;
  RxList<String> customerNames = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPieces();
    fetchCustomers();
  }

  Future<int> importPiece({required  Map<String, dynamic> pieceData}) async {
    return  await dbHelper.insertPiece(row: pieceData);
  }


  // جلب القطع من Supabase
  Future<void> fetchPieces() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';



      final response = await supabase
          .from('pieces')
          .select('*')
          .order('created_at', ascending: false);

      

      if (response != null && response is List) {
        pieces.value = response.map((data) {
          return PieceModel(
            id: data['id'] ?? '',
            customerPhone: data['customer_phone'].toString() ?? '',
            name: data['name'] ?? '',
            type: data['type'] ?? '',
            price: data['price']?.toDouble() ?? 0.0,
            length: data['length']?.toDouble() ?? 0.0,
            width: data['width']?.toDouble() ?? 0.0,
            notes: data['notes'] ?? '',
            paidAmount: data['paid_amount']?.toDouble() ?? 0.0
          );
        }).toList();

        filteredPieces.value = List.from(pieces);

        // استخراج الأنواع الفريدة للتصفية
        _extractTypes();
      }
    } catch (e) {
      errorMessage.value = 'فشل في تحميل القطع';
      print('Error fetching pieces: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // جلب العملاء من Supabase
  Future<void> fetchCustomers() async {
    try {
      final response = await supabase
          .from('customers')
          .select('id, name')
          .order('name');

      if (response != null && response is List) {
        customers.value = response.map((data) {
          return CustomerModel(
            id: data['id'] ?? '',
            name: data['name'] ?? '',
            phone: '',
            location: '',
          );
        }).toList();

        customerNames.value = ['الكل', ...customers.map((c) => c.name).toList()];
      }
    } catch (e) {
      print('Error fetching customers for filter: $e');
    }
  }

  // استخراج الأنواع الفريدة
  void _extractTypes() {
    final allTypes = pieces
        .map((piece) => piece.type)
        .where((type) => type != null && type.isNotEmpty)
        .toSet()
        .toList();

    types.value = ['الكل', ...allTypes];
  }

  // البحث والتصفية
  void filterPieces() {
    if (searchQuery.isEmpty && selectedType.value == 'الكل' && selectedCustomer.value == 'الكل') {
      filteredPieces.value = List.from(pieces);
      return;
    }

    filteredPieces.value = pieces.where((piece) {
      // التصفية حسب النوع
      final typeMatch = selectedType.value == 'الكل' ||
          piece.type == selectedType.value;

      // التصفية حسب العميل
      final customerMatch = selectedCustomer.value == 'الكل' ||
          piece.customerPhone == selectedCustomer.value;

      // البحث حسب الاسم أو الملاحظات
      final searchMatch = searchQuery.isEmpty ||
          piece.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (piece.notes?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);

      return typeMatch && customerMatch && searchMatch;
    }).toList();
  }

  // تحديث البحث
  void onSearchChanged(String query) {
    searchQuery.value = query;
    filterPieces();
  }

  // تغيير النوع المحدد
  void onTypeChanged(String type) {
    selectedType.value = type;
    filterPieces();
  }

  // تغيير العميل المحدد
  void onCustomerChanged(String customer) {
    selectedCustomer.value = customer;
    filterPieces();
  }

  // جلب قطعة بواسطة ID
  Future<PieceModel?> getPieceById(String id) async {
    try {
      final response = await supabase
          .from('pieces')
          .select('*, customers!inner(name)')
          .eq('id', id)
          .single();

      if (response != null) {
        return PieceModel(
          id: response['id'] ?? '',
          customerPhone: response['customer_phone'].toString() ?? '',
          name: response['name'] ?? '',
          type: response['type'] ?? '',
          price: response['price']?.toDouble() ?? 0.0,
          length: response['length']?.toDouble() ?? 0.0,
          width: response['width']?.toDouble() ?? 0.0,
          notes: response['notes'] ?? '',
          paidAmount: response['paid_amount']?.toDouble() ?? 0.0,
          createdAt: response['date'] != null
              ? DateTime.parse(response['date'])
              : DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      print('Error getting piece by id: $e');
      return null;
    }
  }

  // تحديث قطعة
  Future<bool> updatePiece(PieceModel piece) async {
    try {
      await supabase.from('pieces').update({
        'name': piece.name,
        'type': piece.type,
        'price': piece.price,
        'length': piece.length,
        'width': piece.width,
        'notes': piece.notes,
        'paid_amount': piece.paidAmount,
        'date': piece.createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', piece.id!);

      // تحديث القائمة المحلية
      final index = pieces.indexWhere((p) => p.id == piece.id);
      if (index != -1) {
        pieces[index] = piece;
        filterPieces();
      }

      return true;
    } catch (e) {
      errorMessage.value = 'فشل في تحديث القطعة: $e';
      return false;
    }
  }

  Future<bool> deleteAllPieces() async {
   return SupabaseService().deleteAllData(table: 'pieces');
  }


  // حذف قطعة
  Future<bool> deletePiece(String id) async {
    try {
      await supabase.from('pieces').delete().eq('id', id);

      // إزالة من القائمة المحلية
      pieces.removeWhere((piece) => piece.id == int.parse(id));
      filterPieces();

      return true;
    } catch (e) {
      errorMessage.value = 'فشل في حذف القطعة: $e';
      return false;
    }
  }

  // حساب الإجمالي
  double get totalAmount {
    return filteredPieces.fold(0, (sum, piece) => sum + piece.price);
  }

  // حساب المدفوع
  double get totalPaid {
    return filteredPieces.fold(0, (sum, piece) => sum + piece.paidAmount);
  }

  // حساب المتبقي
  double get remainingAmount {
    return totalAmount - totalPaid;
  }

  // تجديد البيانات
  Future<void> refreshData() async {
    await fetchPieces();
    await fetchCustomers();
  }
}