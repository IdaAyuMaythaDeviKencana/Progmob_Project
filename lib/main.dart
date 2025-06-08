import 'package:demo_savitrishop/view/screen/home_page.dart';
import 'package:flutter/material.dart';
import 'package:demo_savitrishop/view/screen/login.dart';
import 'package:demo_savitrishop/view/screen/register.dart';
import 'package:demo_savitrishop/view/screen/memberList.dart';
import 'package:demo_savitrishop/view/screen/addMember.dart';


void main() {
  runApp(const MyApp()); //untuk menjalankan aplikasi dengan menampilkan widget utama dari aplikasi
}


class MyApp extends StatelessWidget {
  const MyApp({super.key}); // mendefinisikan kelas MyApp sebagai StatelessWidget
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(), //menentukan halaman awalyg muncul
      routes: { //rute untuk navigasi antar halaman
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/members': (context) => const MemberListPage(),
        '/add-member': (context) => const AddMemberPage(),
      },
    );
  }
}

