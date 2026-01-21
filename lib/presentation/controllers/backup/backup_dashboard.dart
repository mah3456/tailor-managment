import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailor/data/services/supabase_service.dart';
import 'package:tailor/presentation/controllers/customer_controller.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class BackupController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();
  final CustomerController customerController = Get.find<CustomerController>();

  // إزالة Connectivity واستبداله بـ InternetConnectionChecker
  late InternetConnectionChecker _connectionChecker;

  // حالة التحميل
  final RxBool _isExportingCustomers = false.obs;
  final RxBool _isExportingPieces = false.obs;
  final RxBool _isImportingCustomers = false.obs;
  final RxBool _isImportingPieces = false.obs;
  final RxBool _isExportingAll = false.obs;
  final RxBool _isImportingAll = false.obs;

  // التواريخ والإحصائيات
  final RxMap<String, DateTime?> _lastBackupDates = <String, DateTime?>{}.obs;
  final RxMap<String, dynamic> _backupStats = <String, dynamic>{}.obs;

  // إحصائيات البيانات المحلية
  final RxInt _localCustomersCount = 0.obs;
  final RxInt _localPiecesCount = 0.obs;

  // حالة الاتصال
  final RxBool _isConnected = false.obs;
  final RxBool _isCheckingConnection = false.obs;
  final RxString _connectionMessage = 'جاري التحقق...'.obs;
  final RxString _connectionType = 'غير معروف'.obs;
  final RxBool _hasNetworkAccess = false.obs;

  // Getters
  bool get isExportingCustomers => _isExportingCustomers.value;
  bool get isExportingPieces => _isExportingPieces.value;
  bool get isImportingCustomers => _isImportingCustomers.value;
  bool get isImportingPieces => _isImportingPieces.value;
  bool get isExportingAll => _isExportingAll.value;
  bool get isImportingAll => _isImportingAll.value;

  Map<String, DateTime?> get lastBackupDates => _lastBackupDates;
  Map<String, dynamic> get backupStats => _backupStats;

  int get localCustomersCount => _localCustomersCount.value;
  int get localPiecesCount => _localPiecesCount.value;

  bool get isConnected => _isConnected.value;
  bool get isCheckingConnection => _isCheckingConnection.value;
  String get connectionMessage => _connectionMessage.value;
  String get connectionType => _connectionType.value;
  bool get hasNetworkAccess => _hasNetworkAccess.value;

  StreamSubscription<InternetConnectionStatus>? _connectionSubscription;
  Timer? _internetCheckTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeConnectionChecker();
    loadBackupData();
    loadLocalData();
    loadBackupState();
    _initializeConnection();
  }

  @override
  void onClose() {
    _connectionSubscription?.cancel();
    _internetCheckTimer?.cancel();
    super.onClose();
  }

  // تهيئة InternetConnectionChecker
  void _initializeConnectionChecker() {
    _connectionChecker = InternetConnectionChecker.instance;

    // بدء مراقبة تغييرات الاتصال
    startConnectionMonitoring();
  }

  // بدء مراقبة تغييرات الاتصال
  void startConnectionMonitoring() {
    _connectionSubscription = _connectionChecker.onStatusChange.listen(
          (InternetConnectionStatus status) {
        _updateConnectivityStatus(status);
      },
    );
  }

  // تحديث حالة الاتصال
  void _updateConnectivityStatus(InternetConnectionStatus status) {
    print('📡 حالة الاتصال: $status');

    switch (status) {
      case InternetConnectionStatus.connected:
        _isConnected.value = true;
        _hasNetworkAccess.value = true;
        _connectionType.value = _getConnectionType();
        _connectionMessage.value = 'متصل بالإنترنت عبر ${_connectionType.value}';
        print('✅ متصل بالإنترنت');
        break;
      case InternetConnectionStatus.disconnected:
        _isConnected.value = false;
        _hasNetworkAccess.value = false;
        _connectionType.value = 'لا يوجد اتصال';
        _connectionMessage.value = 'غير متصل بالإنترنت';
        print('❌ غير متصل بالإنترنت');
        break;
      case InternetConnectionStatus.slow:
        throw UnimplementedError();
    }
  }

  // تخمين نوع الاتصال (يمكن تحسينه إذا احتجت)
  String _getConnectionType() {
    if (Platform.isAndroid || Platform.isIOS) {
      return 'بيانات الجوال/Wi-Fi';
    } else {
      return 'Wi-Fi/Ethernet';
    }
  }

  // تهيئة الاتصال
  Future<void> _initializeConnection() async {
    await _checkConnectionImmediately();
    _startPeriodicInternetCheck();
  }

  // التحقق الفوري من الاتصال
  Future<void> _checkConnectionImmediately() async {
    _isCheckingConnection.value = true;
    _connectionMessage.value = 'جاري التحقق من الاتصال...';

    try {
      final isConnected = await _connectionChecker.hasConnection;

      if (isConnected) {
        _isConnected.value = true;
        _hasNetworkAccess.value = true;
        _connectionType.value = _getConnectionType();
        _connectionMessage.value = 'متصل بالإنترنت عبر ${_connectionType.value}';
        print('✅ التحقق الفوري: متصل بالإنترنت');
      } else {
        _isConnected.value = false;
        _hasNetworkAccess.value = false;
        _connectionType.value = 'لا يوجد اتصال';
        _connectionMessage.value = 'غير متصل بالإنترنت';
        print('❌ التحقق الفوري: غير متصل');
      }
    } catch (e) {
      print('⚠️ خطأ في التحقق الفوري: $e');
      _isConnected.value = false;
      _hasNetworkAccess.value = false;
      _connectionMessage.value = 'خطأ في التحقق من الاتصال';
    } finally {
      _isCheckingConnection.value = false;
    }
  }

  // بدء التحقق الدوري من الإنترنت
  void _startPeriodicInternetCheck() {
    _internetCheckTimer?.cancel();
    _internetCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
          (timer) {
        _checkConnectionImmediately();
      },
    );
  }

  // التحقق من الاتصال يدوياً
  Future<void> checkConnection() async {
    print('🔄 المستخدم طلب التحقق من الاتصال يدوياً');
    await _checkConnectionImmediately();
  }

  // اختبار اتصال Supabase (يبقى كما هو)
  Future<bool> checkSupabaseConnection() async {
    if (!_isConnected.value || !_hasNetworkAccess.value) {
      print('لا يوجد اتصال بالإنترنت');
      return false;
    }

    try {
      final stopwatch = Stopwatch()..start();

      await Supabase.instance.client
          .from('customers')
          .select('id')
          .limit(1)
          .maybeSingle()
          .timeout(const Duration(seconds: 3));

      stopwatch.stop();
      print('✅ اتصال Supabase ناجح خلال ${stopwatch.elapsedMilliseconds}ms');
      return true;

    } on TimeoutException catch (e) {
      print('⏰ انتهت مهلة الاتصال: $e');
      return false;
    } on SocketException catch (e) {
      print('🔌 خطأ في مقبس الشبكة: $e');
      return false;
    } on PostgrestException catch (e) {
      print('⚠️ Supabase استجاب: ${e.message}');
      return true;
    } catch (e) {
      print('❌ خطأ غير معروف: $e');
      return false;
    }
  }

  // تحميل البيانات المحلية
  Future<void> loadLocalData() async {
    try {
      final customers = await _supabaseService.getLocalCustomers();
      final pieces = await _supabaseService.getLocalPieces();
      _localCustomersCount.value = customers.length;
      _localPiecesCount.value = pieces.length;
      print('📊 البيانات المحلية: ${customers.length} عميل، ${pieces.length} قطعة');
    } catch (e) {
      print('❌ خطأ في تحميل البيانات المحلية: $e');
    }
  }

  // تحميل حالة النسخ الاحتياطي
  Future<void> loadBackupState() async {
    try {
      final stats = await _supabaseService.getBackupStats();
      _backupStats.value = stats;
      print('📊 حالة النسخ الاحتياطي: $stats');
    } catch (e) {
      print('❌ خطأ في تحميل حالة النسخ الاحتياطي: $e');
    }
  }

  // تحميل بيانات النسخ الاحتياطي
  Future<void> loadBackupData() async {
    try {
      final dates = await _supabaseService.getLastBackupDates();
      _lastBackupDates.value = dates;
      print('📅 تواريخ النسخ الاحتياطي: $dates');
    } catch (e) {
      print('❌ خطأ في تحميل تواريخ النسخ الاحتياطي: $e');
    }
  }

  // التحقق من الاتصال قبل العمليات
  Future<bool> checkConnectionBeforeOperation(String operation) async {
    print('🔍 التحقق من الاتصال قبل العملية: $operation');

    await checkConnection();

    if (!_isConnected.value) {
      print('❌ لا يوجد اتصال للإنترنت');
      final bool? retry = await Get.defaultDialog(
        title: 'مشكلة في الاتصال',
        middleText: 'يتطلب $operation اتصالاً فعالاً بالإنترنت.\n\n'
            'حالة الاتصال: ${_connectionMessage.value}\n\n'
            'حلول مقترحة:\n'
            '• تأكد من تشغيل Wi-Fi أو بيانات الهاتف\n'
            '• إعادة تشغيل الجهاز\n'
            '• الاتصال بشبكة أخرى',
        textConfirm: 'إعادة المحاولة',
        textCancel: 'إلغاء',
        confirmTextColor: Colors.white,
        cancelTextColor: Colors.grey,
        onConfirm: () => Get.back(result: true),
        onCancel: () => Get.back(result: false),
        buttonColor: Colors.blue,
      );

      if (retry == true) {
        await checkConnection();
        return _isConnected.value && _hasNetworkAccess.value;
      }
      return false;
    }

    if (!_hasNetworkAccess.value) {
      print('⚠️ اتصال بدون إنترنت');
      Get.snackbar(
        'اتصال بدون إنترنت',
        'يجب أن يكون لديك اتصال إنترنت نشط لإجراء $operation',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    }

    print('🔄 جاري التحقق من اتصال Supabase...');
    Get.snackbar(
      'جاري التحقق',
      'جاري التحقق من اتصال الخدمة السحابية...',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    final hasSupabaseConnection = await checkSupabaseConnection();
    if (!hasSupabaseConnection) {
      print('❌ فشل اتصال Supabase');
      Get.snackbar(
        'خطأ في الخدمة السحابية',
        'لا يمكن الوصول إلى خدمة النسخ الاحتياطي',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    }

    print('✅ الاتصال جاهز للعملية: $operation');
    return true;
  }

  // باقي الدوال تبقى كما هي بدون تغيير...
  // تصدير العملاء، استيراد العملاء، إلخ...

  // تنسيق التاريخ
  String formatDate(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.day}/${date.month}/${date.year}';
  }

  // تحديث جميع البيانات
  Future<void> refreshAllData() async {
    print('🔄 تحديث جميع البيانات...');
    await loadLocalData();
    await loadBackupData();
    await loadBackupState();
    print('✅ تم تحديث جميع البيانات');
  }

  // الحصول على حالة الاتصال بشكل مفصل
  Map<String, dynamic> getDetailedConnectionStatus() {
    return {
      'isConnected': _isConnected.value,
      'hasNetworkAccess': _hasNetworkAccess.value,
      'connectionType': _connectionType.value,
      'message': _connectionMessage.value,
      'isChecking': _isCheckingConnection.value,
    };
  }

  // تصدير العملاء
  Future<void> exportCustomers() async {
    print('🚀 بدء تصدير العملاء...');
    if (!await checkConnectionBeforeOperation('تصدير العملاء')) return;

    _isExportingCustomers.value = true;

    try {
      final success = await _supabaseService.exportCustomers();

      if (success) {
        await loadBackupData();
        await loadBackupState();
        Get.snackbar(
          'نجاح',
          'تم تصدير العملاء بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        print('✅ تم تصدير العملاء بنجاح');
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في تصدير العملاء',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print('❌ فشل في تصدير العملاء');
      }
    } catch (e) {
      Get.snackbar(
        'خطأ غير متوقع',
        'حدث خطأ أثناء التصدير',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('❌ خطأ غير متوقع: $e');
    } finally {
      _isExportingCustomers.value = false;
    }
  }

  // تصدير القطع
  Future<void> exportPieces() async {
    print('🚀 بدء تصدير القطع...');
    if (!await checkConnectionBeforeOperation('تصدير القطع')) return;

    _isExportingPieces.value = true;

    try {
      final success = await _supabaseService.exportPieces();

      if (success) {
        await loadBackupState();
        await loadBackupData();
        Get.snackbar(
          'نجاح',
          'تم تصدير القطع بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        print('✅ تم تصدير القطع بنجاح');
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في تصدير القطع',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print('❌ فشل في تصدير القطع');
      }
    } catch (e) {
      Get.snackbar(
        'خطأ غير متوقع',
        'حدث خطأ أثناء التصدير',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('❌ خطأ غير متوقع: $e');
    } finally {
      _isExportingPieces.value = false;
    }
  }

  // تصدير الكل
  Future<void> exportAll() async {
    print('🚀 بدء تصدير جميع البيانات...');
    if (!await checkConnectionBeforeOperation('تصدير جميع البيانات')) return;

    _isExportingAll.value = true;

    try {
      final success = await _supabaseService.exportAll();

      if (success) {
        await loadBackupData();
        await loadBackupState();
        Get.snackbar(
          'نجاح',
          'تم تصدير جميع البيانات بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        print('✅ تم تصدير جميع البيانات بنجاح');
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في تصدير البيانات',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print('❌ فشل في تصدير جميع البيانات');
      }
    } catch (e) {
      Get.snackbar(
        'خطأ غير متوقع',
        'حدث خطأ أثناء التصدير',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('❌ خطأ غير متوقع: $e');
    } finally {
      _isExportingAll.value = false;
    }
  }

  // استيراد العملاء
  Future<void> importCustomers() async {
    print('🚀 بدء استيراد العملاء...');
    if (!await checkConnectionBeforeOperation('استيراد العملاء')) return;

    bool? confirm = await Get.defaultDialog<bool>(
      title: 'تأكيد استيراد العملاء',
      middleText:
      'سيتم حذف جميع العملاء المحليين واستبدالهم بالبيانات من السحابة. هل تريد المتابعة؟',
      textConfirm: 'متابعة',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.grey,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
      buttonColor: Colors.green,
    );

    if (confirm != true) return;

    _isImportingCustomers.value = true;

    try {
      final db = await _supabaseService.dbHelper.database;
      await db.delete('customers');

      final success = await _supabaseService.importCustomers();

      if (success) {
        await loadLocalData();
        await loadBackupState();
        customerController.getAllUsers();
        Get.snackbar(
          'نجاح',
          'تم استيراد العملاء بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        print('✅ تم استيراد العملاء بنجاح');
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في استيراد العملاء',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print('❌ فشل في استيراد العملاء');
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء الاستيراد: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('❌ خطأ في استيراد العملاء: $e');
    } finally {
      _isImportingCustomers.value = false;
    }
  }

  // استيراد القطع
  Future<void> importPieces() async {
    print('🚀 بدء استيراد القطع...');
    if (!await checkConnectionBeforeOperation('استيراد القطع')) return;

    bool? confirm = await Get.defaultDialog<bool>(
      title: 'تحذير',
      middleText:
      'القطع مرتبطة بالعملاء. تأكد من أن العملاء المستوردين موجودين في السحابة ويتطابقون مع العملاء المحليين. هل تريد المتابعة؟',
      textConfirm: 'متابعة',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.grey,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
      buttonColor: Colors.green,
    );

    if (confirm != true) return;

    _isImportingPieces.value = true;

    try {
      final db = await _supabaseService.dbHelper.database;
      await db.delete('pieces');

      final success = await _supabaseService.importPieces();

      if (success) {
        await loadLocalData();
        await loadBackupState();
        Get.snackbar(
          'نجاح',
          'تم استيراد القطع بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        print('✅ تم استيراد القطع بنجاح');
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في استيراد القطع',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print('❌ فشل في استيراد القطع');
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء الاستيراد: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('❌ خطأ في استيراد القطع: $e');
    } finally {
      _isImportingPieces.value = false;
    }
  }

  // استيراد الكل
  Future<void> importAll() async {
    print('🚀 بدء استيراد جميع البيانات...');
    if (!await checkConnectionBeforeOperation('استيراد جميع البيانات')) return;

    bool? confirm = await Get.defaultDialog<bool>(
      title: 'تحذير!',
      middleText:
      'سيتم حذف جميع البيانات المحلية واستبدالها بالبيانات من السحابة. هذه العملية لا يمكن التراجع عنها. هل تريد المتابعة؟',
      textConfirm: 'نعم، متابعة',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.grey,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
      buttonColor: Colors.red,
    );

    if (confirm != true) return;

    _isImportingAll.value = true;

    try {
      final success = await _supabaseService.importAll();

      if (success) {
        await loadLocalData();
        await loadBackupState();
        Get.snackbar(
          'نجاح',
          'تم استيراد جميع البيانات بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        print('✅ تم استيراد جميع البيانات بنجاح');
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في استيراد البيانات',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print('❌ فشل في استيراد جميع البيانات');
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء الاستيراد: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('❌ خطأ في استيراد جميع البيانات: $e');
    } finally {
      _isImportingAll.value = false;
    }
  }
}