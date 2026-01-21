import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tailor/data/models/customer_model.dart';
import 'package:tailor/main.dart';

class infoCard extends StatelessWidget {
  const infoCard({super.key, required this.customerData});

  final CustomerModel customerData;

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    var isDark = shared.getBool('isDarkMod');

    return Container(
      width: dw * 0.95,
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark!
              ? [CupertinoColors.systemGreen.withValues(alpha: 0.9), Color(0xff32b764),] :
          [CupertinoColors.systemGreen.withValues(alpha: 0.9), Color(0xff474747),],

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? CupertinoColors.systemGreen : Colors.transparent,
            blurRadius: 15,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Icon(
              Icons.content_cut,
              size: 150,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                // الصورة أو الأيقونة
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Icon(
                      color: isDark ? Colors.white : null,
                      Icons.person,
                      size: 40,
                    ),
                  ),
                ),

                SizedBox(width: 120),

                // معلومات العميل الرئيسية
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerData.name ?? 'عميل',
                        style: TextStyle(
                          color: isDark ? Colors.white : null,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 8),

                      Text(
                        'رقم العميل: ${customerData.id ?? 'غير محدد'}',
                        style: TextStyle(
                          color: isDark ? Colors.white : null,
                          fontSize: 16,
                        ),
                      ),

                      SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: isDark ? Colors.white : null,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              customerData.location ?? 'رقم غير محدد',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 16,
                            color: isDark ? Colors.white : null,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              customerData.phone ?? 'رقم غير محدد',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
