import 'package:get/get.dart';
import 'package:tailor/data/models/piece_model.dart';
import 'package:tailor/data/services/database_helper.dart';

class PieceController extends GetxController {
  var pieces = <PieceModel>[].obs;
  var isLoading = false.obs;

  Future<void> loadPiecesByCustomerId({required String phone}) async {
    try {
      isLoading(true);
      var pieceMaps = await DatabaseHelper().queryPiecesByCustomerId(phone: phone);
      pieces.assignAll(
        pieceMaps.map((e) => PieceModel.fromMap(e)).toList(),
      );
    } finally {
      isLoading(false);
    }
  }

  Future<List<PieceModel>> getUserPieces({required String phone}) async {
    List<Map<String,dynamic>> data = await DatabaseHelper().queryPiecesByCustomerId(phone: phone );
    return data.map((e) => PieceModel.fromMap(e)).toList();
  }

  Future<int> addPiece({required PieceModel newPiece}){
    var response = DatabaseHelper().insertPiece(row: newPiece.toMap());
    return response;
  }

  Future<int> updatePieces({required int id , required Map<String, dynamic> values}) async {
    return await DatabaseHelper().updatePiece(row: values, id: id);
  }


  Future<void> updatePiece({required PieceModel piece , required int id}) async {
    await DatabaseHelper().updatePiece(row: piece.toMap() , id: id);
    int index = pieces.indexWhere((p) => p.id == piece.id);
    if (index != -1) {
      pieces[index] = piece;
    }

  }

  Future<void> deletePiece(int id) async {
    await DatabaseHelper().deletePiece(id: id);
    pieces.removeWhere((piece) => piece.id == id);
  }

  Future<int> delete({required int id}) async {
    return await DatabaseHelper().deletePiece(id: id);
  }

  Future<int> payItem({required int id, required Map<String, dynamic> values}) async {
      return await DatabaseHelper().updatePiece(row: values ,id: id);
  }


  Future<void> addPayment(int pieceId, double amount) async {
    PieceModel piece = pieces.firstWhere((p) => p.id == pieceId);
    piece.paidAmount += amount;
    await updatePiece(piece: piece ,id: pieceId);
  }
}