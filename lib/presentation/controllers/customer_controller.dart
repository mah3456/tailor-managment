import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tailor/data/models/customer_model.dart';
import 'package:tailor/data/services/database_helper.dart';

import '../../data/services/supabase_service.dart';

class phone implements Exception{
    final String message = 'رقم الهاتف هذا موجود';

    @override
  String toString() => message;
}

class CustomerController extends GetxController {
  var customers = <CustomerModel>[].obs;
  var searchResults = <CustomerModel>[].obs;
  var filteredCustomers = <CustomerModel>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  final SupabaseService _supabaseService = SupabaseService();


  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  Future<List<CustomerModel>> getAllUsers() async {

    List<Map<String,dynamic>> data = await DatabaseHelper().queryAllCustomers();

    return data.map((e) => CustomerModel.fromMap(e)).toList();
  }

  Future<void> loadCustomers() async {
    try {
      isLoading(true);
      var customerMaps = await DatabaseHelper().queryAllCustomers();
      customers.assignAll(
        customerMaps.map((e) => CustomerModel.fromMap(e)).toList(),
      );
      filteredCustomers.assignAll(customers);
    } finally {
      isLoading(false);
    }
  }

  void searchCustomers(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredCustomers.assignAll(customers);
    } else {
      filteredCustomers.assignAll(
        customers.where((customer) =>
        customer.name.toLowerCase().contains(query.toLowerCase()) ||
            customer.phone.contains(query)
        ).toList(),
      );
    }
  }

  updateUserInfo({required int cutomerId ,required  Map<String, dynamic> values}) async {
    return DatabaseHelper().updateCustomer(id: cutomerId , row: values);
  }


  Future<int> addCustomer({required CustomerModel customer}) async {
     try{
       int id = await DatabaseHelper().insertCustomer(customer.toMap());
       customer.id = id;
       customers.insert(0, customer);
       searchCustomers(searchQuery.value);
       return id;
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

  Future<int> deleteAll(){
    return DatabaseHelper().deleteAllData(table: 'customers');
  }


  Future<bool> uploadCustomer({required CustomerModel customer}){
    return _supabaseService.exportSingleCustomer(customer: customer);
  }


  Future<void> updateCustomer({required CustomerModel customer , required int id}) async {
    await DatabaseHelper().updateCustomer(id: id, row: customer.toMap());
    int index = customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      customers[index] = customer;
      searchCustomers(searchQuery.value);
    }
  }

  Future<int> deleteUser({required int id}) async {
    return await DatabaseHelper().deleteCustomer(id: id);
  }


  Future<void> deleteCustomer({required int id}) async {
    await DatabaseHelper().deleteCustomer(id: id);
    customers.removeWhere((customer) => customer.id == id);
    searchCustomers(searchQuery.value);
  }


  Future<void> searchItems({required String search}) async {
    try {
      isLoading(true);
      searchResults.value = await DatabaseHelper().search(search: search);
      isLoading(false);
    } catch (e) {
      isLoading(false);
      print('Search by name error: $e');
    }
  }

}