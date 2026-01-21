import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tailor/data/models/customer_model.dart';
import '../../functions.dart';
import '../../presentation/controllers/customer_controller.dart';

class EditClientDialog extends StatefulWidget {
  final CustomerModel customerData;

  const EditClientDialog({super.key, required this.customerData});

  @override
  State<EditClientDialog> createState() => _EditClientDialogState();
}

class _EditClientDialogState extends State<EditClientDialog> {
  final _formKey = GlobalKey<FormState>();

  final CustomerController customer = Get.put(CustomerController());

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.customerData.name ?? '';
    _phoneController.text = widget.customerData.phone ?? '';
    _locationController.text = widget.customerData.location ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Color(0xff1e1e1e) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'تعديل معلومات العميل',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // حقل الاسم
                _buildTextField(
                  label: 'الاسم الكامل',
                  controller: _nameController,
                  icon: Icons.person,
                  isDark: isDark,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16),

                // حقل الهاتف
                _buildTextField(
                  label: 'رقم الهاتف',
                  controller: _phoneController,
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  isDark: isDark,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم الهاتف';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16),

                _buildTextField(
                  label: 'الموقع',
                  controller: _locationController,
                  icon: Icons.location_on,
                  keyboardType: TextInputType.emailAddress,
                  isDark: isDark,
                ),

                SizedBox(height: 24),

                // أزرار الحفظ والإلغاء
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                        ),
                        child: Text('إلغاء'),
                      ),
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {

                            Map<String, dynamic> data = {
                              'name': _nameController.text,
                              'phone': _phoneController.text,
                              'location': _locationController.text,
                            };

                            var res = await customer.updateUserInfo(
                              cutomerId: widget.customerData.id!,
                              values: data,
                            );

                            if (res > 0) {
                             await customer.getAllUsers();
                             await customer.loadCustomers();
                              Get.forceAppUpdate();
                              Get.appUpdate();
                              helpers.customSnackBar(
                                title: 'نجاح',
                                message: 'تم تحديث  معلومات المستخدم ',
                                background: CupertinoColors.systemGreen,
                              );
                            } else{
                              helpers.customSnackBar(
                                  title:'!خطا',
                                  message: 'لم يتم التحديث ',
                                  background: CupertinoColors.systemGreen,
                              );
                            }

                            Get.forceAppUpdate();
                            customer.update();
                            customer.getAllUsers();
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CupertinoColors.systemGreen,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'حفظ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isDark = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      readOnly: onTap != null,
      onTap: onTap,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: CupertinoColors.systemBlue, width: 2),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
        prefixIcon: Icon(
          icon,
          color: isDark ? Colors.grey[400] : Colors.grey[500],
        ),
      ),
      validator: validator,
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
