import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tailor/data/models/customer_model.dart';
import '../../widgets/customer/edit_client.dart';
import '../../widgets/customer/info_header.dart';
import '../../widgets/pieces/show_pieces.dart';
import '../controllers/piece_controller.dart';
import 'add_piece_view.dart';
import 'package:flutter/cupertino.dart';


class CustomerDetailsPage extends StatelessWidget {
  final CustomerModel customer;
  final PieceController pieceController = Get.put(PieceController());

  CustomerDetailsPage({required this.customer});

  @override
  Widget build(BuildContext context) {
    pieceController.loadPiecesByCustomerId(phone: customer.phone);
    final dw = MediaQuery.of(context).size.width;
    final dh = MediaQuery.of(context).size.height;


    void _editClientInfo(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) {
          return EditClientDialog(
            customerData: customer,
          );
        },
      );
    }
    

    return Scaffold(

      floatingActionButton: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        onPressed: () {
          Get.to(() => AddPiecePage(customerPhone: customer.phone));
        },


        label: Row(
          children: [
            Icon(CupertinoIcons.add, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              ' إضافة قطعه',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                // fontSize: 16,
              ),
            ),
          ],
        ),
      ),


      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _editClientInfo(context),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // معلومات العميل
            infoCard(customerData: customer),

            SizedBox(
              width: dw * 0.99,
              height: dh,
              child: SingleChildScrollView(child: Showpieces(user: customer)),
            ),
          ],
        ),
      ),
    );
  }
}