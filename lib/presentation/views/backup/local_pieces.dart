import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tailor/functions.dart';
import '../../../data/models/piece_model.dart';
import '../../controllers/backup/Local_pieces.dart';
import '../../controllers/backup/backup_dashboard.dart';


class LocalPiecesScreen extends StatelessWidget {

  final PieceController controller = Get.put(PieceController());
  final BackupController dashBoard = Get.put(BackupController());

  final TextEditingController searchController = TextEditingController();

  LocalPiecesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة القطع المحليه'),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: controller.search,
              decoration: InputDecoration(
                hintText: 'بحث بالاسم أو النوع  ...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    controller.search('');
                  },
                ),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: TextButton(
                  onPressed: () {
                    _showDeleteDialog(
                      context: context,
                      isALl: true,
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
                  child: Text('حذف الكل', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),

          // مؤشر التحميل
          Obx(
            () => controller.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  )
                : const SizedBox.shrink(),
          ),

          // قائمة القطع
          Expanded(
            child: Obx(() {
              if (controller.filteredPieces.isEmpty) {
                return Center(
                  child: Text(
                    controller.searchQuery.value.isEmpty
                        ? 'لا توجد قطع'
                        : 'لا توجد نتائج',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.filteredPieces.length,
                itemBuilder: (context, index) {
                  final piece = controller.filteredPieces[index];
                  return _buildPieceCard(context, piece);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // بطاقة العرض للقطعة
  Widget _buildPieceCard(BuildContext context, PieceModel piece) {
    final currencyFormat = NumberFormat('#,##0.00', 'ar_SA');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان والمعلومات الأساسية
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            piece.customerPhone.toString(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('| رقم العميل '),
                        ],
                      ),
                      Text(
                        piece.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        piece.type,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // أزرار التحكم
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
                          _showExportDialog(context, piece);
                        });
                      },
                    ),

                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('حذف'),
                        ],
                      ),
                      onTap: () {
                        Future.delayed(Duration.zero, () {
                          _showDeleteDialog(
                            context: context,
                            piece: piece,
                            isALl: false,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // معلومات القطعة
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildInfoItem(
                  'السعر',
                  '${currencyFormat.format(piece.price)} ر.ي',
                ),
                _buildInfoItem(
                  'المدفوع',
                  '${currencyFormat.format(piece.paidAmount)} ر.ي',
                ),
                _buildInfoItem(
                  'المتبقي',
                  '${currencyFormat.format(piece.remainingAmount)} ر.ي',
                ),
                _buildInfoItem('المقاسات', '${piece.length} × ${piece.width}'),
              ],
            ),

            // الملاحظات
            if (piece.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        piece.notes,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // التاريخ ومعلومات إضافية
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تاريخ الإضافة: ${piece.createdAt}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  'ID: ${piece.id}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // عنصر عرض المعلومات
  Widget _buildInfoItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  // حوار الحذف
  void _showDeleteDialog({
    required BuildContext context,
    PieceModel? piece,
    required bool isALl,
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
          !isALl
              ? 'هل أنت متأكد من حذف القطعة "${piece!.name}"؟'
              : 'سيتم حذف كل القطع المحليه ',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (isALl) {
                var res = await controller.deleteAll();

                if (res > 0) {
                  await controller.fetchPieces();
                  await dashBoard.loadLocalData();
                  Navigator.of(context).pop();

                  helpers.customSnackBar(
                    title: 'نجاح',
                    message: 'تم حذف كل القطع',
                    background: CupertinoColors.systemGreen,
                  );
                }
              } else {
                Navigator.of(context).pop();
                await dashBoard.loadLocalData();
                await controller.fetchPieces();
                await controller.deletePiece(piece!.id!, context);
              }
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
                backgroundColor: Colors.transparent

            ),
            child: const Text('حذف' , style: TextStyle(color: Colors.red),),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, PieceModel piece) {
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
        content: Text(
          'هل أنت متأكد من تصدير القطعة  "${piece.name}" الى السحابه؟',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء' , style: TextStyle(color: Colors.grey),),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              var res = await controller.uploadPiece(piece: piece);
              await dashBoard.loadBackupState();
              print(piece.customerPhone);
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
              foregroundColor: Colors.white,
                backgroundColor: Colors.transparent

            ),
            child: const Text('تصدير' , style: TextStyle(color: CupertinoColors.systemGreen),),
          ),
        ],
      ),
    );
  }
}
