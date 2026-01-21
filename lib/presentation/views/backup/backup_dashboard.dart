import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tailor/presentation/views/backup/backup_pieces_data.dart';
import '../../controllers/backup/backup_dashboard.dart';
import 'Local_pieces.dart';
import 'customers_data.dart';

class BackupView extends StatelessWidget {
  const BackupView({super.key});

  BackupController get controller => Get.put(BackupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('النسخ الاحتياطي'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: GestureDetector(
              onTap: controller.checkConnection,
              child: Row(
                children: [
                  Obx(() => controller.isCheckingConnection
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Icon(
                    controller.isConnected ? Icons.wifi : Icons.wifi_off,
                    color: controller.isConnected ? Colors.green : Colors.red,
                    size: 22,
                  )),
                  const SizedBox(width: 4),
                  Obx(() => Text(
                    controller.isConnected ? 'متصل' : 'غير متصل',
                    style: TextStyle(
                      fontSize: 14,
                      color: controller.isConnected ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // مؤشر حالة الاتصال المميز
            Obx(() => _buildConnectionStatusCard()),
            const SizedBox(height: 20),

            // ملخص البيانات المحلية
            Obx(() => _buildLocalDataCard()),
            const SizedBox(height: 20),

            // ملخص البيانات السحابية
            Obx(() => _buildCloudDataCard()),
            const SizedBox(height: 30),

            // قسم تصدير البيانات
            _buildExportSection(),
            const SizedBox(height: 30),

            // قسم استيراد البيانات
            _buildImportSection(),
            const SizedBox(height: 30),

            // تلميحات وإرشادات
            _buildTipsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatusCard() {
    return Card(
      color: controller.isConnected ? Colors.green[50] : Colors.red[50],
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: controller.isConnected ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: controller.isConnected ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: controller.isCheckingConnection
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.green,
                ),
              )
                  : Icon(
                controller.isConnected ? Icons.wifi : Icons.wifi_off,
                color: controller.isConnected ? Colors.green : Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.connectionMessage,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: controller.isConnected ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.isConnected
                        ? 'يمكنك إجراء عمليات النسخ الاحتياطي'
                        : 'يجب الاتصال بالإنترنت للاستمرار',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: controller.isConnected ? Colors.green : Colors.red),
              onPressed: controller.checkConnection,
              tooltip: 'إعادة التحقق من الاتصال',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalDataCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: 'البيانات المحلية',
              icon: Icons.storage,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildStatItem(
                  'العملاء',
                  controller.localCustomersCount.toString(),
                  Icons.people,
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () => Get.to(() => LocalPiecesScreen()),
                  child: _buildStatItem(
                    'القطع',
                    controller.localPiecesCount.toString(),
                    Icons.inventory,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudDataCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: 'البيانات السحابية',
              icon: Icons.cloud,
              color: controller.isConnected ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                InkWell(
                  onTap: () => Get.to(() => CustomersScreen()),
                  child: _buildStatItem(
                    'العملاء',
                    '${controller.backupStats['customers_count'] ?? 0}',
                    Icons.people,
                    subText: controller.lastBackupDates['customers'] != null
                        ? 'آخر تحديث: ${controller.formatDate(controller.lastBackupDates['customers']!)}'
                        : 'لم يتم التصدير بعد',
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () => Get.to(() => PiecesScreen()),
                  child: _buildStatItem(
                    'القطع',
                    '${controller.backupStats['pieces_count'] ?? 0}',
                    Icons.inventory,
                    subText: controller.lastBackupDates['pieces'] != null
                        ? 'آخر تحديث: ${controller.formatDate(controller.lastBackupDates['pieces']!)}'
                        : 'لم يتم التصدير بعد',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'تصدير إلى السحابة',
          icon: Icons.cloud_upload,
          color: controller.isConnected ? Colors.green : Colors.grey,
        ),
        const SizedBox(height: 12),
        Obx(() => _buildActionButton(
          icon: Icons.people,
          text: 'تصدير العملاء',
          isLoading: controller.isExportingCustomers,
          onPressed: controller.isConnected && !controller.isExportingCustomers
              ? controller.exportCustomers
              : null,
          color: controller.isConnected ? Colors.green : Colors.grey,
        )),
        const SizedBox(height: 12),
        Obx(() => _buildActionButton(
          icon: Icons.inventory,
          text: 'تصدير القطع',
          isLoading: controller.isExportingPieces,
          onPressed: controller.isConnected && !controller.isExportingPieces
              ? controller.exportPieces
              : null,
          color: controller.isConnected ? Colors.green : Colors.grey,
        )),
        const SizedBox(height: 12),
        Obx(() => _buildActionButton(
          icon: Icons.cloud_upload,
          text: 'تصدير الكل',
          isLoading: controller.isExportingAll,
          onPressed: controller.isConnected && !controller.isExportingAll
              ? controller.exportAll
              : null,
          color: controller.isConnected ? Colors.deepPurple : Colors.grey,
        )),
      ],
    );
  }

  Widget _buildImportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.cloud_download,
                color: controller.isConnected ? Colors.blue : Colors.grey),
            const SizedBox(width: 8),
            const Text(
              'استيراد من السحابة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Icons.warning, color: Colors.orange, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() => _buildActionButton(
          icon: Icons.people,
          text: 'استيراد العملاء',
          isLoading: controller.isImportingCustomers,
          onPressed: controller.isConnected && !controller.isImportingCustomers
              ? controller.importCustomers
              : null,
          color: controller.isConnected ? Colors.blue : Colors.grey,
          warning: true,
        )),
        const SizedBox(height: 12),
        Obx(() => _buildActionButton(
          icon: Icons.inventory,
          text: 'استيراد القطع',
          isLoading: controller.isImportingPieces,
          onPressed: controller.isConnected && !controller.isImportingPieces
              ? controller.importPieces
              : null,
          color: controller.isConnected ? Colors.blue : Colors.grey,
          warning: true,
        )),
        const SizedBox(height: 12),
        Obx(() => _buildActionButton(
          icon: Icons.cloud_download,
          text: 'استيراد الكل',
          isLoading: controller.isImportingAll,
          onPressed: controller.isConnected && !controller.isImportingAll
              ? controller.importAll
              : null,
          color: controller.isConnected ? Colors.red : Colors.grey,
          warning: true,
        )),
      ],
    );
  }

  Widget _buildTipsCard() {
    return Card(
      color: Colors.amber[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber[800]),
                const SizedBox(width: 8),
                Text(
                  'نصائح وإرشادات',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.amber[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTipItem('1. انقر على أيقونة الاتصال لإعادة التحقق من الاتصال'),
            _buildTipItem('2. يجب أن تكون متصلاً بالإنترنت لعمليات النسخ الاحتياطي'),
            _buildTipItem('3. تصدير العملاء أولاً قبل القطع للحفاظ على العلاقات'),
            _buildTipItem('4. استيراد العملاء قبل القطع لتجنب الأخطاء'),
            _buildTipItem('5. النسخ الاحتياطي المنتظم يضمن عدم فقدان البيانات'),
            _buildTipItem('6. الاتصال بالواي فاي أفضل للعمليات الكبيرة'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {String? subText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                if (subText != null)
                  Text(
                    subText,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required bool isLoading,
    required VoidCallback? onPressed,
    required Color color,
    bool warning = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: warning ? const BorderSide(color: Colors.orange, width: 2) : null,
        ),
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: Colors.amber[800]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}