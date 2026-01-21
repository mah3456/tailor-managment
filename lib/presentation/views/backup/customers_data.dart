import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tailor/data/models/customer_model.dart';
import '../../../functions.dart';
import '../../controllers/backup/backup_dashboard.dart';
import '../../controllers/backup/customers_controller.dart';
import '../../controllers/customer_controller.dart';

class CustomersScreen extends StatelessWidget {
  CustomersScreen({super.key});

  final customersBackupController controller = Get.put(
    customersBackupController(),
  );
  final CustomerController customers = Get.put(CustomerController());
  final BackupController dashboard = Get.put(BackupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('العملاء في السحابه'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshData(),
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث والتصفية
          _buildSearchFilterBar(),

          // الإحصائيات
          _buildStatsBar(context: context),

          // قائمة العملاء
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(controller.errorMessage.value),

                      SizedBox(height: 16),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.transparent
                        ),
                        onPressed: () => controller.fetch_customers(),
                        child: const Text('إعادة المحاولة' ,style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                );
              }

              if (controller.filteredCustomers.isEmpty) {
                return const Center(child: Text('لا يوجد عملاء'));
              }

              return _buildCustomersList();
            }),
          ),
        ],
      ),
    );
  }

  // شريط البحث والتصفية
  Widget _buildSearchFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          // حقل البحث
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'ابحث عن عميل...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: controller.onSearchChanged,
          ),

          const SizedBox(height: 8),

          // قائمة التصفية حسب الموقع
          Obx(() {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: controller.locations.map((location) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(location),
                      selected: controller.selectedLocation.value == location,
                      onSelected: (_) => controller.onLocationChanged(location),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  // شريط الإحصائيات
  Widget _buildStatsBar({required BuildContext context}) {
    return Obx(() {
      return Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '${controller.filteredCustomers.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('العملاء'),
                ],
              ),

              SizedBox(width: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _showDeleteDialog(
                        context: context,
                        isAll: true,
                        customer: CustomerModel(
                          name: 'name',
                          phone: 'phone',
                          location: '',
                        ),
                      );
                    },
                    style: ButtonStyle(
                      overlayColor: WidgetStateColor.transparent,
                    ),
                    child: Text(
                      'حذف الكل',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  // قائمة العملاء
  Widget _buildCustomersList() {
    return ListView.builder(
      itemCount: controller.filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = controller.filteredCustomers[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(
                customer.name[0].toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              customer.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.phone),
                if (customer.location.isNotEmpty)
                  Text(
                    customer.location,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'import',
                  child: Row(
                    children: [
                      Icon(Icons.save, size: 20),
                      SizedBox(width: 8),
                      Text('حفظ'),
                    ],
                  ),
                ),

                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('حذف', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'import') {
                  _showImportDialog(
                    context: context,
                    customer: customer,
                    customers: customers,
                  );
                } else if (value == 'delete') {
                  _showDeleteDialog(
                    context: context,
                    customer: customer,
                    isAll: false,
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  // حوار تأكيد الحذف
  void _showDeleteDialog({
    required BuildContext context,
    required CustomerModel customer,
    required bool isAll,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
              textDirection: TextDirection.rtl,
              'تأكيد الحذف'),
          content: Text(
              textDirection: TextDirection.rtl,
              !isAll ? 'هل أنت متأكد من حذف ${customer.name}؟' : 'سيتم حذف كل المستخدمين من السحابه'),
          actions: [
            TextButton(
              style: ButtonStyle(elevation: WidgetStatePropertyAll(0)),
              onPressed: () => Get.back(),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),

            ElevatedButton(
              onPressed: () async {
                if (isAll) {
                  var res = await controller.deleteAllCustomers();

                  if (res) {
                    await controller.fetch_customers();
                    await dashboard.loadLocalData();
                    await dashboard.loadBackupState();
                    Navigator.of(context).pop();

                    helpers.customSnackBar(
                      title: 'نجاح',
                      message: 'تم حذف كل العملا من السحابه',
                      background: CupertinoColors.systemGreen,
                    );
                  }
                } else {

                  var res = await controller.deleteCustomer(name: customer.name);

                  if (res) {
                    await controller.fetch_customers();
                    helpers.customSnackBar(
                        title: 'نجاح',
                        message: 'تم الحذف من السحابه',
                        background: CupertinoColors.systemGreen
                    );
                    Get.back();
                  }

                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0),
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showImportDialog({
    required BuildContext context,
    required CustomerController customers,
    required CustomerModel customer,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تأكيد الاستيراد'),
          content: Text('هل أنت متأكد من استيراد "${customer.name}" ؟'),
          actions: [
            TextButton(
              style: ButtonStyle(elevation: WidgetStatePropertyAll(0)),
              onPressed: () => Get.back(),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final customerData = CustomerModel(
                  name: customer.name,
                  phone: customer.phone.toString(),
                  location: customer.location,
                ).toMap();

                var res = await controller.importCustomer(
                  customerData: customerData,
                );

                if (res > 0) {
                  await customers.getAllUsers();
                  customers.update();
                  Get.back();
                  await customers.loadCustomers();
                  helpers.customSnackBar(
                    title: 'نجاح',
                    message: 'تم الاستيراد بنجاح',
                    background: CupertinoColors.systemGreen,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0),
              child: const Text('استيراد',
                style: TextStyle(color: CupertinoColors.systemGreen),
              ),
            ),
          ],
        );
      },
    );
  }

}
