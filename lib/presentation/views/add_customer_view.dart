import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tailor/functions.dart';

import '../../data/models/customer_model.dart';
import '../../main.dart';
import '../controllers/customer_controller.dart';

class AddCustomerPage extends StatefulWidget {
  const AddCustomerPage({super.key});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final CustomerController customerController = Get.find<CustomerController>();

  var isdark = false;

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    final dh = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        elevation: 0,
        centerTitle: true,

        title: Text(
          'إضافة عميل جديد',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة معلومات العميل
              SizedBox(
                width: dw,
                height: dh * 0.60,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // العنوان
                          Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person_add_alt_1,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'بيانات العميل الجديد',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          // حقل الاسم
                          _buildFormField(
                            label: '',
                            hintText: 'أدخل الاسم الكامل للعميل',
                            controller: _nameController,
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال الاسم';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 30),
                          _buildFormField(
                            label: '',
                            hintText: 'أدخل هاتف العميل',
                            controller: _phoneController,
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال الرقم';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 30),
                          // حقل الموقع
                          _buildFormField(
                            label: '',
                            hintText: 'أدخل موقع العميل',
                            controller: _locationController,
                            icon: Icons.location_on_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال الموقع';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              // أزرار الحفظ والإلغاء
              Row(
                children: [
                  SizedBox(width: 16),
                  // زر الحفظ
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final newCustomer = CustomerModel(
                              name: _nameController.text,
                              phone: _phoneController.text,
                              location: _locationController.text,
                            );

                            var response = await customerController.addCustomer(customer: newCustomer);



                            if (response > 0) {
                              _nameController.clear();
                              _phoneController.clear();
                              _locationController.clear();

                              helpers.customSnackBar(
                                title: 'نجاح',
                                message: 'تم إضافة العميل بنجاح',
                                background: CupertinoColors.systemGreen,

                              );

                            } else {

                              helpers.customSnackBar(
                                  title: '!خطا',
                                  message: 'فشل إضافة العميل',
                                  background:CupertinoColors.systemGreen
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save, size: 20 , color: Colors.white,),
                            SizedBox(width: 8),
                            Text(
                              'حفظ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textAlign: TextAlign.right,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                width: 2,
                color: CupertinoColors.systemGreen,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: isdark! ? Colors.transparent : Colors.transparent,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: Icon(icon, color: Colors.grey[600]),
          ),
          style: TextStyle(fontSize: 16),
          validator: validator,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}