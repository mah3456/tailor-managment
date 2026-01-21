import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailor/FingPrint/AuthView.dart';
import 'app/theme/theme_data.dart';


late  SharedPreferences shared;
var first = shared.getBool('firstTime');
var isdark = shared.getBool('isDarkMod')?? true;


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  shared = await SharedPreferences.getInstance();


  await Supabase.initialize(
    url: 'https://qlxdanglhagvjhjiiowt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFseGRhbmdsaGFndmpoamlpb3d0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgyMDc2NTYsImV4cCI6MjA4Mzc4MzY1Nn0.mBvNPdBvVxwum9wZVgt_iAaaEx6ystVuoagIkA7NVRU',
  );

  runApp(GetMaterialApp(
        locale: Locale('ar' ,'YE'),
        themeMode: ThemeMode.system, // سيتم التحكم به عبر الـ controller
        theme: ThemeData(
          fontFamily: 'cairo',
          useMaterial3: true,
          colorScheme: AppColors.lightScheme,
          scaffoldBackgroundColor: AppColors.lightScheme.background,
        ),
        darkTheme: ThemeData(
          fontFamily: 'cairo',
          useMaterial3: true,
          colorScheme: AppColors.darkScheme,
          scaffoldBackgroundColor: AppColors.darkScheme.background,
        ),
        // إزالة default transition
        defaultTransition: Transition.noTransition,



        home: FingerprintAuthView(),
        debugShowCheckedModeBanner: false,

        onInit: () async{


          shared.setBool('firstTime', false);
          if(first != null && first == false){
            shared.setBool('isDarkMod', true);
          }
        },
      )
  );
}




