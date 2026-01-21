import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailor/data/models/customer_model.dart';
import '../../../data/services/database_helper.dart';
import '../../../data/services/supabase_service.dart';



class customersBackupController extends GetxController {
  final supabase = Supabase.instance.client;
  final supabaseService = SupabaseService();

  RxList<CustomerModel> customers = <CustomerModel>[].obs;
  RxList<CustomerModel> filteredCustomers = <CustomerModel>[].obs;
  final DatabaseHelper dbHelper = DatabaseHelper();

  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  // للبحث والتصفية
  RxString searchQuery = ''.obs;
  RxString selectedLocation = 'الكل'.obs;
  RxList<String> locations = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetch_customers();
  }


  Future<int> importCustomer({required  Map<String, dynamic> customerData}) async {
       try{
         return await dbHelper.insertCustomer({
           'name': customerData['name'],
           'phone': customerData['phone'].toString(),
           'location': customerData['location'],
         });
       } on DatabaseException catch (e){
         if(e.isUniqueConstraintError()){
           Get.snackbar(
               '!خطا',
               'هاتف موجود مسبقا',
               backgroundColor: Colors.red,
               colorText: Colors.white
           );
         }
         rethrow;
       }
  }

  // جلب العملاء من Supabase
  Future<void> fetch_customers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await supabase
          .from('customers')
          .select('*')
          .order('created_at', ascending: false);

      if (response != null && response is List) {
        customers.value = response.map((data) {
          return CustomerModel(
            id: data['id'] ?? '',
            name: data['name'] ?? '',
            phone: data['phone'].toString() ?? '',
            location: data['location'] ?? ''
          );
        }).toList();

        filteredCustomers.value = List.from(customers);

        _extractLocations();
      }
    } on PostgrestException catch (e) {
      errorMessage.value = 'فشل في تحميل العملاء: ${e.code}';
      print('Error fetching customers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // استخراج المواقع الفريدة
  void _extractLocations() {
    final allLocations = customers
        .map((customer) => customer.location)
        .where((location) => location != null && location.isNotEmpty)
        .toSet()
        .toList();

    locations.value = ['الكل', ...allLocations];
  }

  // البحث والتصفية
  void filterCustomers() {
    if (searchQuery.isEmpty && selectedLocation.value == 'الكل') {
      filteredCustomers.value = List.from(customers);
      return;
    }

    filteredCustomers.value = customers.where((customer) {
      // التصفية حسب الموقع
      final locationMatch = selectedLocation.value == 'الكل' ||
          customer.location == selectedLocation.value;

      // البحث حسب الاسم أو الهاتف
      final searchMatch = searchQuery.isEmpty ||
          customer.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          customer.phone.contains(searchQuery);

      return locationMatch && searchMatch;
    }).toList();
  }

  // تحديث البحث
  void onSearchChanged(String query) {
    searchQuery.value = query;
    filterCustomers();
  }

  // تغيير الموقع المحدد
  void onLocationChanged(String location) {
    selectedLocation.value = location;
    filterCustomers();
  }

  // جلب عميل بواسطة ID
  Future<CustomerModel?> getCustomerById(String id) async {
    try {
      final response = await supabase
          .from('customers')
          .select('*')
          .eq('id', id)
          .single();

      if (response != null) {
        return CustomerModel(
          id: response['id'] ?? 0,
          name: response['name'] ?? '',
          phone: response['phone'].toString() ?? '',
          location: response['location'] ?? '',
        );
      }
      return null;
    } catch (e) {
      print('Error getting customer by id: $e');
      return null;
    }
  }

  // تحديث عميل
  Future<bool> updateCustomer(CustomerModel customer) async {
    try {
      await supabase.from('customers').update({
        'name': customer.name,
        'phone': customer.phone.toString(),
        'location': customer.location,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', customer.id!);

      // تحديث القائمة المحلية
      final index = customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        customers[index] = customer;
        filterCustomers();
      }

      return true;
    } catch (e) {
      errorMessage.value = 'فشل في تحديث العميل: $e';
      return false;
    }
  }

  // حذف عميل
  Future<bool> deleteCustomer({required String name}) async {
    try {
      await supabase.from('customers').delete().eq('name', name);

      // إزالة من القائمة المحلية
      // customers.removeWhere((customer) => customer.id == id);
      filterCustomers();

      return true;
    } catch (e) {
      errorMessage.value = 'فشل في حذف العميل: $e';
      return false;
    }
  }


  Future<bool> deleteAllCustomers() async {
    return SupabaseService().deleteAllData(table: 'customers');

  }

  // تجديد البيانات
  Future<void> refreshData() async {
    await fetch_customers();
  }
}