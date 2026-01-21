import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:tailor/data/models/customer_model.dart';
import 'package:tailor/presentation/controllers/piece_controller.dart';
import 'package:tailor/presentation/views/payment_view.dart';
import 'package:tailor/widgets/pieces/pay_button.dart';
import '../../data/models/piece_model.dart';
import '../../functions.dart';
import '../../presentation/views/add_piece_view.dart';

class Showpieces extends StatelessWidget {
  const Showpieces({super.key, required this.user});

  final CustomerModel user;

  @override
  Widget build(BuildContext context) {

    final PieceController pieceController = Get.put(PieceController());
    final dw = MediaQuery.of(context).size.width;
    final dh = MediaQuery.of(context).size.height;
    var isDark = true;



    // دالة حذف قطعة
    void _deletePiece(PieceModel piece, BuildContext context) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('حذف القطعة'),
          content: Text('هل أنت متأكد من حذف "${piece.name}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء' , style: TextStyle(color: Colors.grey),),
            ),
            TextButton(
              onPressed: () async {
                // حذف القطعة
                var res = await pieceController.delete(id: piece.id!);

                print(res);
                if (res > 0) {
                  helpers.customSnackBar(
                    title: 'نجاح',
                    message: 'تم الحذف بنجاح',
                    background: CupertinoColors.systemGreen,
                  );
                  pieceController.update();
                } else {
                  helpers.customSnackBar(
                    title:'!خطا',
                    message: 'لم يتم الحذف',
                    background: CupertinoColors.systemRed,
                  );
                }
                Navigator.pop(context);
                pieceController.update();
                pieceController.getUserPieces(phone: user.phone);

              },
              child: Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

    Widget _buildPieceItem(PieceModel piece, BuildContext context) {
      return GetBuilder<PieceController>(
        init: PieceController(),
        builder: (controller) {
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              // border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 20,
                      ),
                      onPressed: () {
                        Get.to(AddPiecePage(customerPhone: user.phone, piece: piece));
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        size: 20,
                        color: CupertinoColors.systemRed,
                      ),
                      onPressed: () {
                        _deletePiece(piece, context);
                      },
                    ),
                  ],
                ),

                SizedBox(height: 10,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // اسم القطعة والسعر
                    Column(
                      children: [
                        Text(piece.name),
                        SizedBox(height: 15),

                        Row(
                          children: [

                            Text('السعر  |' , style: TextStyle(fontWeight: FontWeight.bold)),

                            Text(

                              ' ${piece.price} ريال',

                            ),
                          ],
                        ),


                        SizedBox(height: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          textDirection: TextDirection.ltr,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('  المدفوع  |' , style: TextStyle(fontWeight: FontWeight.bold)),

                                Text(
                                   ' ${piece.paidAmount} ريال',
                                    style: TextStyle(
                                      color: piece.paidAmount > 0 ? Colors.orange : Colors.red,
                                    ),

                                ),
                              ],
                            ),

                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text('المتبقي  |', style: TextStyle(fontWeight: FontWeight.bold)) ,

                                Text(
                                  '  ${piece.remainingAmount} ريال',
                                  style: TextStyle(
                                    color: piece.remainingAmount > 0 ? Colors.orange : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: dh * 0.04),

                // نوع القطعة وتاريخ الإضافة
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 100 * 0.75,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                              color: isDark ? Colors.green.withOpacity(0.1) : null

                          ),

                          child: Text(
                            'النوع',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    SizedBox(
                      width: dw,
                      child: Row(
                        spacing: 10,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            spacing: 5,
                            children: [
                              Container(
                                width: 100 * 0.75,
                                height: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                    color: Colors.purple.withOpacity(0.1)

                                ),
                                child: Center(
                                  child: Text(
                                    piece.type.toString(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: dh * 0.04),

                // المقاسات
                if (piece.width != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 100 * 0.75,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                                color: isDark ? Colors.green.withOpacity(0.1) : null

                            ),

                            child: Text(
                              'المقاسات',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,

                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),

                      SizedBox(
                        width: dw,
                        child: Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('العرض'),
                                Container(
                                  width: 100 * 0.75,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    // color: Colors.purple.withOpacity(0.1),
                                      color: isDark ? Colors.purple.withOpacity(0.1) : null

                                  ),
                                  child: Center(
                                    child: Text(
                                      'سم ${piece.width.toString()}',
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              spacing: 5,
                              children: [
                                Text('الطول'),
                                Container(
                                  width: 100 * 0.75,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                      color: isDark ? Colors.purple.withOpacity(0.1) : null

                                  ),
                                  child: Center(
                                    child: Text(
                                      'سم ${piece.length.toString()}',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: dh * 0.03),

                // وصف القطعة
                if (piece.notes != null && piece.notes!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            width: 100 * 0.75,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                                color: isDark ? Colors.green.withOpacity(0.1): null

                            ),
                            child: Center(
                              child: Text(
                                'ملاحظات',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),

                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 5),

                      Container(
                        height: 70,
                        alignment: Alignment.center,
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          piece.notes ?? '',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),

                      SizedBox(height: 35),

                    ],
                  ),
                paybutton(
                    click: () {
                      Get.to(PaymentPage(piece: piece));
                    }
                )
              ],
            ),
          );
        },
      );
    }

    return GetBuilder<PieceController>(
      init: PieceController(),
      builder: (controller) {
        final PieceController customer = Get.put(PieceController());

        return FutureBuilder<List<PieceModel>>(
          future:customer.getUserPieces(phone: user.phone),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('حدث خطأ: ${snapshot.error}'));
            }

            if (snapshot.hasData) {

              var items = snapshot.data!;

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // عنوان القسم مع عدد القطع
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    color: Colors.purple,
                                    size: 22,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'القطع المضافة',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${items.length} قطعة',
                                style: TextStyle(
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // قائمة القطع
                        Container(

                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.70,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return _buildPieceItem(items[index], context);
                            },
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              );
            }

            return Container();
          },
        );
      },
    );
  }
}
