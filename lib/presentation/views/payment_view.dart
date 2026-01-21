import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:tailor/data/models/piece_model.dart';
import '../../functions.dart';
import '../controllers/piece_controller.dart';
import 'package:flutter/cupertino.dart';

class PaymentPage extends StatefulWidget {
  final PieceModel piece;

  PaymentPage({required this.piece});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final PieceController pieceController = Get.put(PieceController());
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    amountController.text = widget.piece.remainingAmount.toString();
  }

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    final dh = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text('تسديد قيمة القطعة'), centerTitle: true),
      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.piece.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('النوع: ${widget.piece.type}'),
                      Divider(),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('السعر الإجمالي:'),
                          Text(
                            '${widget.piece.price} ريال',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('المدفوع مسبقاً:'),
                          Text(
                            '${widget.piece.paidAmount} ريال',
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('المتبقي:'),
                          Text(
                            '${widget.piece.remainingAmount} ريال',
                            style: TextStyle(
                              color: widget.piece.remainingAmount > 0
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                child: TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'المبلغ المطلوب تسديده (ريال)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
        
              SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: dw * 0.70,
                  child: ElevatedButton(
                    onPressed: () async {
                      double amount =
                          double.tryParse(amountController.text) ?? 0.0;
                      double netAmount =
                          double.tryParse(amountController.text)! +
                          widget.piece.paidAmount;
        
                      if (amount <= 0) {
                        helpers.customSnackBar(
                          title:'!خطا',
                          message: 'الرجاء إدخال مبلغ صحيح',
                          background: Colors.red,
        
                        );
                        return;
                      }
        
                      if (amount > widget.piece.remainingAmount) {
                        helpers.customSnackBar(
                          title:'!خطا',
                          message: 'المبلغ المدخل أكبر من المبلغ المتبقي',
                          background: Colors.red,
                        );
                        return;
                      }
        
                      Map<String, dynamic> values = {
                        'name': widget.piece.name,
                        'type': widget.piece.type,
                        'price': widget.piece.price,
                        'notes': widget.piece.notes,
                        'width': widget.piece.width,
                        'length': widget.piece.length,
                        'paid_amount': netAmount,
                      };
        
                      var res = await pieceController.payItem(
                        id: widget.piece.id!,
                        values: values,
                      );
        
                      print(res);
        
                      if (res > 0) {
                        helpers.customSnackBar(
                          title: 'نجاح',
                          message: 'تم التسديد بنجاح',
                          background: CupertinoColors.systemGreen
                        );
                        pieceController.update();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CupertinoColors.systemGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10),
                      ),
                    ),
                    child: Text(
                      'تسديد المبلغ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
