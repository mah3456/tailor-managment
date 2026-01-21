import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/piece_model.dart';
import '../../../functions.dart';
import '../../controllers/backup/backup_dashboard.dart';
import '../../controllers/backup/pieces_backup_data.dart';

class PiecesScreen extends StatelessWidget {
  PiecesScreen({super.key});

  final piecesDataController controller = Get.put(piecesDataController());
  final currencyFormat = NumberFormat.currency(locale: 'ar_SA', symbol: 'ر.ي');
  final BackupController dashboard = Get.put(BackupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('القطع في السحابه'),
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

          // قائمة القطع
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: TextButton(
                        onPressed: () {
                          _showDeleteDialog(
                            context: context,
                            isAll: true,
                            piece: PieceModel(
                              customerPhone: 'customerPhone',
                              name: '',
                              type: '',
                              price: 0,
                              length: 0,
                              width: 0,
                              notes: '',
                              paidAmount: 0,
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
                    ),
                  ],
                ),

                Obx(() {
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
                            onPressed: () => controller.fetchPieces(),
                            child: const Text('إعادة المحاولة' , style: TextStyle(color: Colors.grey),),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.filteredPieces.isEmpty) {
                    return const Center(child: Text('لا توجد قطع'));
                  }

                  return _buildPiecesList();
                }),
              ],
            ),
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
              hintText: 'ابحث عن قطعة...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: controller.onSearchChanged,
          ),

          const SizedBox(height: 8),

          // صف الفلاتر
          Obx(() {
            return Column(
              children: [
                // فلتر حسب النوع
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: controller.types.map((type) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(type),
                          selected: controller.selectedType.value == type,
                          onSelected: (_) => controller.onTypeChanged(type),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 4),

                // فلتر حسب العميل
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: controller.customerNames.map((customer) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(customer),
                          selected:
                              controller.selectedCustomer.value == customer,
                          onSelected: (_) =>
                              controller.onCustomerChanged(customer),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // قائمة القطع
  Widget _buildPiecesList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: controller.filteredPieces.length,
      itemBuilder: (context, index) {
        final piece = controller.filteredPieces[index];
        final dw = MediaQuery.of(context).size.width;

        return SizedBox(
          width: dw * 0.95,
          child: Card(
            child: ListTile(
              leading: _buildPieceIcon(piece.type),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          piece.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        currencyFormat.format(piece.price),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),
                  Text(
                    'رقم العميل | ${piece.customerPhone.toString()}',
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                  if (piece.type.isNotEmpty)
                    Text(
                      'نوع: ${piece.type}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  if (piece.notes?.isNotEmpty ?? false)
                    Text(
                      'ملاحظات: ${piece.notes}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                ],
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مدفوع: ${currencyFormat.format(piece.paidAmount)}',
                        style: const TextStyle(fontSize: 10),
                      ),

                      Text(
                        'متبقي: ${currencyFormat.format(piece.price - piece.paidAmount)}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // القياسات
                  if (piece.length > 0 || piece.width > 0)
                    Text(
                      'القياسات: ${piece.length} × ${piece.width}',
                      style: const TextStyle(fontSize: 12),
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
                        Text('استيراد'),
                      ],
                    ),
                  ),

                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20),
                        SizedBox(width: 8),
                        Text('حذف'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'import') {
                    _showImportDialog(
                      context: context,
                      piece: controller,
                      pieces: piece,
                    );
                  } else if (value == 'delete') {
                    _showDeleteDialog(
                      context: context,
                      piece: piece,
                      isAll: false,
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPieceIcon(String type) {
    IconData icon;
    Color color;

    switch (type.toLowerCase()) {
      case 'قميص':
        icon = Icons.checkroom;
        color = Colors.blue;
        break;
      case 'بنطال':
        icon = Icons.work_outline;
        color = Colors.brown;
        break;
      case 'بدلة':
        icon = Icons.business_center;
        color = Colors.black;
        break;
      default:
        icon = Icons.inventory_2;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, color: color),
    );
  }

  void _showDeleteDialog({
    required BuildContext context,
    required PieceModel piece,
    required bool isAll,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تأكيد الحذف'),
          content: Text(
            locale: Locale('AR'),
            !isAll
                ? 'هل أنت متأكد من حذف قطعة "${piece.name}"؟'
                : 'سيتم حذف كل القطع من السحابه',
          ),
          actions: [
            TextButton(
              style: ButtonStyle(elevation: WidgetStatePropertyAll(0)),
              onPressed: () => Get.back(),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (isAll) {
                  var res = await controller.deleteAllPieces();

                  if (res) {
                    await controller.fetchPieces();
                    await dashboard.loadLocalData();
                    await dashboard.loadBackupState();
                    Navigator.of(context).pop();

                    helpers.customSnackBar(
                      title: 'نجاح',
                      message: 'تم حذف كل القطع من السحابه',
                      background: CupertinoColors.systemGreen,
                    );
                  }
                } else {
                  var res = await controller.deletePiece(piece.id.toString());
                  if (res) {
                    await controller.fetchPieces();
                    helpers.customSnackBar(
                      title: 'نجاح',
                      message: 'تم الحذف من السحابه',
                      background: CupertinoColors.systemGreen,
                    );
                  }
                  Get.back();
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
    required piecesDataController piece,
    required PieceModel pieces,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تأكيد الاستيراد'),
          content: Text('هل أنت متأكد من القطعه "${pieces.name}" ؟'),
          actions: [
            TextButton(
              style: ButtonStyle(elevation: WidgetStatePropertyAll(0)),
              onPressed: () => Get.back(),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final pieceData = PieceModel(
                  name: pieces.name,
                  type: pieces.type,
                  customerPhone: pieces.customerPhone,
                  length: pieces.length,
                  width: pieces.width,
                  notes: pieces.notes,
                  price: pieces.price,
                  paidAmount: pieces.paidAmount,
                  createdAt: pieces.createdAt,
                ).toMap();

                var res = await piece.importPiece(pieceData: pieceData);

                if (res > 0) {
                  await controller.fetchPieces();
                  Get.back();
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
              child: const Text(
                'استيراد',
                style: TextStyle(color: CupertinoColors.systemGreen),
              ),
            ),
          ],
        );
      },
    );
  }
}
