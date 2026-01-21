import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tailor/data/models/piece_model.dart';
import 'package:tailor/presentation/controllers/piece_controller.dart';
import '../../functions.dart';
import 'package:flutter/cupertino.dart';

class AddPiecePage extends StatefulWidget {
  final String customerPhone;
  final PieceModel? piece;

  const AddPiecePage({required this.customerPhone, this.piece});

  @override
  _AddPiecePageState createState() => _AddPiecePageState();
}

class _AddPiecePageState extends State<AddPiecePage> {
  final _formKey = GlobalKey<FormState>();
  final PieceController pieceController = Get.put(PieceController());

  TextEditingController nameController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController lengthController = TextEditingController();
  TextEditingController widthController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.piece == null) {
      print('null');
    } else {
      nameController.text = widget.piece!.name;
      typeController.text = widget.piece!.type;
      priceController.text = widget.piece!.price.toString();
      lengthController.text = widget.piece!.length.toString();
      widthController.text = widget.piece!.width.toString();
      notesController.text = widget.piece!.notes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.piece.isNull ? 'إضافة قطعة جديدة'  :'تعديل قطعة'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                textInputAction: TextInputAction.next,
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'اسم القطعة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم القطعة';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                textInputAction: TextInputAction.next,
                controller: typeController,
                decoration: InputDecoration(
                  labelText: 'نوع القطعة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال نوع القطعة';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                textInputAction: TextInputAction.next,
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'السعر (ريال)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال السعر';
                  }
                  if (double.tryParse(value) == null) {
                    return 'الرجاء إدخال رقم صحيح';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: lengthController,
                      decoration: InputDecoration(
                        labelText: 'الطول',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال الطول';
                        }
                        if (double.tryParse(value) == null) {
                          return 'الرجاء إدخال رقم صحيح';
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: widthController,
                      decoration: InputDecoration(
                        labelText: 'العرض',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال العرض';
                        }
                        if (double.tryParse(value) == null) {
                          return 'الرجاء إدخال رقم صحيح';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                textInputAction: TextInputAction.next,
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'ملاحظات',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {

                    // اضافة القطعه

                    if (widget.piece == null) {
                      PieceModel newPiece = PieceModel(
                        customerPhone: widget.customerPhone,
                        name: nameController.text,
                        type: typeController.text,
                        price: double.parse(priceController.text),
                        length: double.parse(lengthController.text),
                        width: double.parse(widthController.text),
                        notes: notesController.text,
                        paidAmount: 0.0,
                      );

                      var res = await pieceController.addPiece(
                        newPiece: newPiece,
                      );

                      print(res);

                      if (res > 0) {
                        nameController.clear();
                        typeController.clear();
                        priceController.clear();
                        lengthController.clear();
                        widthController.clear();
                        notesController.clear();
                        pieceController.update();
                        helpers.customSnackBar(
                          title: 'نجاح',
                          message: 'تم إضافة القطعه بنجاح',
                          background: CupertinoColors.systemGreen
                        );
                      } else{
                        helpers.customSnackBar(
                            title: '!خطا',
                            message: 'فشل الاضافه',
                            background: CupertinoColors.systemGreen
                        );
                      }


                    } else {

                      // تحديث القطعه
                      PieceModel newPiece = PieceModel(
                        id: widget.piece?.id!,
                        customerPhone: widget.customerPhone,
                        name: nameController.text,
                        type: typeController.text,
                        price: double.parse(priceController.text),
                        length: double.parse(lengthController.text),
                        width: double.parse(widthController.text),
                        notes: notesController.text,
                        paidAmount: widget.piece!.paidAmount,
                      );

                      Map<String, dynamic> data = {
                        'name': newPiece.name,
                        'type': newPiece.type,
                        'price': newPiece.price,
                        'notes': newPiece.notes,
                        'width': newPiece.width,
                        'length': newPiece.length,
                        'paid_amount': newPiece.paidAmount,
                      };

                      var res = await pieceController.updatePieces(
                        id: newPiece.id!,
                        values: data,
                      );

                      if (res > 0) {
                        nameController.clear();
                        typeController.clear();
                        priceController.clear();
                        lengthController.clear();
                        widthController.clear();
                        notesController.clear();
                        pieceController.update();

                        helpers.customSnackBar(
                          title: 'نجاح',
                          message: 'تم التحديث بنجاح',
                          background: CupertinoColors.systemGreen
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'حفظ القطعة',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
