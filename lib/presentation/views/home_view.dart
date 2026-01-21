import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tailor/data/models/customer_model.dart';
import '../../app/theme/theme.dart';
import '../../functions.dart';
import '../controllers/customer_controller.dart';
import 'add_customer_view.dart';
import 'backup/backup_dashboard.dart';
import 'customer_details_page.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatelessWidget {
  final CustomerController customerController = Get.put(CustomerController());
  final TextEditingController searchController = TextEditingController();
  final themecont theme = Get.put(themecont());

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    final dh = MediaQuery.of(context).size.height;
    final or = MediaQuery.of(context).orientation;

    return RefreshIndicator(
      color: CupertinoColors.systemGreen,
      onRefresh: () async {
        await customerController.getAllUsers();
        await customerController.loadCustomers();
      },

      child: WillPopScope(
        onWillPop: () {
          return helpers.message(context);
        },
        child: Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            onPressed: () async {
              Get.to(
                () => AddCustomerPage(),
                transition: Transition.circularReveal,
                duration: Duration(milliseconds: 700),
              );
            },
            label: Row(
              children: [
                Icon(CupertinoIcons.add, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'إضافة',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: false,
            toolbarHeight: dh * 0.09,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: IconButton(
              icon: Icon(Icons.backup_outlined),
              onPressed: () {
                Get.to(BackupView());
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Obx(
                  () => Switch(
                    value: theme.isDarkMode,
                    onChanged: (value) => theme.toggleTheme(),
                    activeThumbColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),

          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 8),
              Container(
                width: dw * 0.95,
                height: or == Orientation.landscape ? null : dh * 0.22,
                alignment: Alignment.center,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        TextFormField(
                          autofocus: false,
                          controller: searchController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.transparent,
                            hintText: 'ابحث عن عميل بالاسم أو الهاتف',
                            hintStyle: TextStyle(fontSize: 13),
                            prefixIcon: Icon(Icons.search),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      searchController.clear();
                                      customerController.searchCustomers('');
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            customerController.searchCustomers(value);
                          },
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),

              // Card السفلي لعرض العملاء
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 5,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [

                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: TextButton(
                              onPressed: () {
                                if (customerController.filteredCustomers.isEmpty) {

                                  helpers.customSnackBar(
                                      title: 'خطا',
                                      message: 'لا يوجد مستخدمين',
                                      background: CupertinoColors.systemRed
                                  );

                                } else {
                                  Future.delayed(Duration.zero, () {
                                    _showDeleteDialog(
                                      context: context,
                                      isAll: true,
                                    );
                                  });
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  Colors.transparent,
                                ),
                                overlayColor: WidgetStatePropertyAll(
                                  Colors.transparent,
                                ),
                              ),
                              child: Text(
                                'حذف الكل',
                                style: TextStyle(fontSize: 15, color: customerController.filteredCustomers.isEmpty ?Colors.grey :Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ),


                      Obx(() {
                        if (customerController.isLoading.value) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final filteredCustomers = customerController.filteredCustomers;

                        if (filteredCustomers.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 80,
                                  color: Colors.grey[300],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  customerController.searchQuery.value.isEmpty
                                      ? 'لا يوجد عملاء'
                                      : 'لم يتم العثور على نتائج "${searchController.text}"',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (searchController.text.isEmpty) {
                          return SizedBox(
                            // height: dh * 0.5,
                            child: GetBuilder<CustomerController>(
                              init: CustomerController(),
                              builder: (controller) {
                                return FutureBuilder<List<CustomerModel>>(
                                  future: controller.getAllUsers(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.blue,
                                        ),
                                      );
                                    }

                                    if (snapshot.hasError) {
                                      return Center(
                                        child: Text('حدث خطأ: ${snapshot.error}'),
                                      );
                                    }

                                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                      return const Center(
                                        child: Text('لا يوجد بيانات'),
                                      );
                                    }

                                    // الآن snapshot.data هو List<CustomersModel>
                                    List<CustomerModel> customers = snapshot.data!;

                                    return ListView.separated(
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.all(18),
                                      itemCount: customers.length,
                                      separatorBuilder: (context, index) =>
                                          SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final user = customers[index];

                                        return _buildClientItem(
                                          context: context,
                                          controller: controller,
                                          customer: user,
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        } else {
                          return SizedBox(
                            height: dh * 0.5,
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(18),
                              itemCount: filteredCustomers.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final customer = filteredCustomers[index];
                                return _buildClientItem(
                                  context: context,
                                  controller: customerController,
                                  customer: customer,
                                );
                              },
                            ),
                          );
                        }
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClientItem({
    required CustomerModel customer,
    required BuildContext context,
    required CustomerController controller,
  }) {
    final dw = MediaQuery.of(context).size.width;
    final dh = MediaQuery.of(context).size.height;

    return Container(
      width: dw * 0.90,
      alignment: Alignment.center,
      child: Card(
        child: ListTile(
          onTap: () => Get.to(
            () => CustomerDetailsPage(customer: customer),
            transition: Transition.circularReveal,
            duration: Duration(milliseconds: 700),
          ),
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Icon(Icons.person),
              ),
            ],
          ),
          title: Text(
            customer.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(customer.phone),
              Text(
                customer.location,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: Column(
            children: [
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.cloud_upload, size: 20),
                        SizedBox(width: 8),
                        Text('تصدير'),
                      ],
                    ),
                    onTap: () {
                      Future.delayed(Duration.zero, () {
                        _showExportDialog(context: context, customer: customer);
                      });
                    },
                  ),

                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('حذف', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    onTap: () {
                      Future.delayed(Duration.zero, () {
                        _showDeleteDialog(
                          context: context,
                          customer: customer,
                          isAll: false,
                        );
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog({
    required BuildContext context,
    CustomerModel? customer,
    required bool isAll,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Text('تأكيد الحذف'),
          ],
        ),
        content: Text(
          textDirection: TextDirection.rtl,
          isAll
              ? 'سيتم حذف جميع المستخدمين'
              : 'هل أنت متأكد من حذف "${customer?.name ?? ''}"؟',
        ),
        actions: [
          TextButton(
            style: ButtonStyle(elevation: WidgetStatePropertyAll(0)),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (isAll) {
                var res = await customerController.deleteAll();

                if (res > 0) {
                  Navigator.of(context).pop();
                  await customerController.getAllUsers();
                  await customerController.loadCustomers();
                  helpers.customSnackBar(
                    title: 'نجاح',
                    message: 'تم حذف كل المستخدمين',
                    background: CupertinoColors.systemGreen,
                  );
                }
              } else {
                var res = await customerController.deleteUser(
                  id: customer?.id! ?? 0,
                );

                if (res > 0) {
                  Navigator.of(context).pop();
                  await customerController.getAllUsers();
                  await customerController.loadCustomers();
                  helpers.customSnackBar(
                    title: 'نجاح',
                    message: 'تم الحذف',
                    background: CupertinoColors.systemGreen,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.transparent

            ),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showExportDialog({
    required BuildContext context,
    required CustomerModel customer,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Text('تأكيد التصدير'),
          ],
        ),
        content: Text('هل أنت متأكد من تصدير العميل "${customer.name}"؟' ,textDirection: TextDirection.rtl,),
        actions: [
          TextButton(
            style: ButtonStyle(elevation: WidgetStatePropertyAll(0)),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              var res = await customerController.uploadCustomer(
                customer: customer,
              );

              if (res) {
                Get.snackbar(
                  'نجاح',
                  'تم الرفع بنجاح',
                  backgroundColor: CupertinoColors.systemGreen,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'فشل',
                  'فشل الرفع ',
                  backgroundColor: CupertinoColors.destructiveRed,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.transparent
            ),
            child: const Text('تصدير',
              style: TextStyle(color: CupertinoColors.systemGreen),
            ),
          ),
        ],
      ),
    );
  }
}
