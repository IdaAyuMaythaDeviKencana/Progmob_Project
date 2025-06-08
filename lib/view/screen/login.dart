import 'package:flutter/material.dart';

import 'package:demo_savitrishop/view/screen/register.dart';
import 'package:demo_savitrishop/view/screen/forgotpassword.dart';
import 'package:demo_savitrishop/view/screen/home_page.dart';
import 'package:demo_savitrishop/utils/api_service.dart';
import 'package:demo_savitrishop/utils/token_helper.dart';

// Warna utama
const primarycolors = Color(0xFF6D2932);

//deklarasi widget LoginPage sebagai StatefulWidget karena ada perubahan UI (loading dan visibilitas password)
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //deklarasi variable untuk membaca dan mengontrol input dari TextField
  final TextEditingController loginemailController = TextEditingController();
  final TextEditingController loginpasswordController = TextEditingController();

  //simpan error teks dan status tampilan password serta status loading
  String? emailError;
  String? passwordError;
  bool isPasswordVisible = false;
  bool isLoading = false; // untuk loading saat login

  //buat objek untuk mengaksses fungsi API login
  final ApiService apiService = ApiService();

  //untuk fungsi login
  Future<void> _handleLogin() async {
    setState(() {
      //validasi jika kosong fieldnya maka diset error message
      emailError = loginemailController.text.trim().isEmpty ? 'Email belum terisi' : null;
      passwordError = loginpasswordController.text.trim().isEmpty ? 'Password belum terisi' : null;
    });

    //jika tidak ada error, lanjut proses login dan tampilkan loading
    if (emailError == null && passwordError == null) { //jika emailerror dan password itu tidak ada
      setState(() {
        isLoading = true; // tampilkan loading
      });

      //ambil inputan user dan bersihkan spasi
      String email = loginemailController.text.trim();
      String password = loginpasswordController.text.trim();

      try {
        //kirim data login ke API dan menunggu hasilnya
        final login = await apiService.loginUser(email, password);

        if (login != null) { //jika berhasil login, token disimpan ke storage dan dicetak ke console
          await TokenHelper.saveToken(login.token); //simpan token ke storage flutter
          print('Token dari server: ${login.token}'); //tampilkan pesan di debug console

          //mengecek apakah widget masih/tidak terpasang di tree (hierarki widget)
          if (!mounted) return; //kalau widget sudah tidak ada di layar(sudah di-unmount), stop eksekusi kode berikutnya
          Navigator.pushReplacement( //widget ada? lanjut navigasi ke homepage jika widget masih aktif
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else { //kalau datalogin tidak valid, tampilkan dialog error
          _showDialog('Login Gagal', 'Email atau password salah.');
        }
      } catch (e) { //menangani error
        _showDialog('Error', 'Terjadi kesalahan saat login. Silakan coba lagi.');
        print('Error saat login: $e');
      } finally { //selalu dijalankan untuk mengatur ulang status UI
        if (mounted) { //widget masih aktif/tidak?
          setState(() { //widgetnya aktif, maka loading diganti false
            isLoading = false; //untuk mengembalikan fungsi tombol login dan load spinner ilang
          });
        }
      }
    }
  }


  //untuk kotak pesan (alert) dan menerima 2 parameter title dan message
  void _showDialog(String title, String message) {
    showDialog( //untuk memunculkan kotak dialog
      context: context, //tentukan posisi widget dalam UI tree
      builder: (_) => AlertDialog( //membangun tmapilan dialog dengan jenis kotak standar
        title: Text(title), //menampilkan teks dari parameter yang dikirim saat panggil _showDialog
        content: Text(message),
        actions: [ //tombol dibawah dialog
          TextButton( //menutup dialog dengan navigator.of(context).pop()
            onPressed: () => Navigator.of(context).pop(), //untuk nutup dialog
            child: const Text('Tutup'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() { //bawaan SatefulWidget untuk hapus halaman
    loginemailController.dispose(); //membersihkan controller dari textfield
    loginpasswordController.dispose();
    super.dispose(); //panggil dispose dari kelas parent untuk selesaikan proses bersih-bersih dengan benar
  }

  @override
  Widget build(BuildContext context) { //fungsi untuk menampikan halaman
    return Scaffold( //kerangka dasar halaman flutter 
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 20,
      ),
      body: SingleChildScrollView( //agar halaman bisa di scroll untuk layar kecil
        child: Center(
          child: Padding( //setting padding
            padding: const EdgeInsets.fromLTRB(30, 5, 30, 30),
            child: Column( //menyusun widget secara vertikal
              mainAxisSize: MainAxisSize.min, //tinggi kolom menyesuaikan isi
              children: [
                Image.asset('assets/image/Savitri.jpg', height: 150, width: 150),
                const SizedBox(height: 5),
                const Text(
                  "Let's Start",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: Colors.black),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Login into your account",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 20),
                TextField( //isiian user 
                  controller: loginemailController, //simpan teks isian user
                  keyboardType: TextInputType.emailAddress, //tampilkan keyboard khusus email
                  decoration: InputDecoration( //mengatur tampilan field
                    labelText: 'Email',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.mail),
                    errorText: emailError, //jika tidak ada null, akan tampil error(saat email kosong)
                  ),
                ),
                const SizedBox(height: 15),
                TextField( //isian user
                  controller: loginpasswordController, //disimpan
                  obscureText: !isPasswordVisible, //awalnya password disembunyikan
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    errorText: passwordError, //validasi error password
                    suffixIcon: IconButton( //tombol mata password
                      //jika isPasswordVisible itu true maka ikon terbuka, jika tidak ikon tertutup
                      icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() { //merubah tampilan saat isPasswordVisible berubah
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                Align( //untuk lupa password
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () { //jika ditekan akan mengarahkan ke halaman lupa password
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
                      );
                    },
                    child: const Text('Forgot Password?', style: TextStyle(color: primarycolors, fontSize: 12)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin, //jika isLoading true, maka tombol tidak aktif (null)
                    style: ElevatedButton.styleFrom( //kalau tidak loading, teombol panggil _handleLogin
                      backgroundColor: primarycolors,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    //jika isLoading true, maka tampilkan spinner. kalau gak, tampilin tulisan
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Login',
                            style: TextStyle(fontSize: 14.0, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 15),
                Row( //pindah ke halaman register
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(fontSize: 12)),
                    GestureDetector( //karna bukan button
                      onTap: () { //jadi pakai ini untuk menangkap ketukan dan pindah ke halaman selanjutnya
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterPage()),
                        );
                      },
                      child: const Text(
                        "REGISTER",
                        style: TextStyle(
                          fontSize: 12,
                          color: primarycolors,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
