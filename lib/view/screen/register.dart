import 'package:flutter/material.dart';
import 'package:demo_savitrishop/view/screen/login.dart';
import 'package:demo_savitrishop/utils/api_service.dart';
import 'package:demo_savitrishop/models/status_register.dart';

// Pallate Warna
const primarycolors = Color(0xFF6D2932);
const lightbackground = Color(0xFFFFFFFF);

//statefulwidget = biar bisa simpan dan edit data selama halaman aktif
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // global key untuk validator date of birth
  final _formKey = GlobalKey<FormState>();

  // mengontrol dan menyimpan inputan text dari textfield
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerNameController = TextEditingController();
  final TextEditingController registerPasswordController = TextEditingController();

  // untuk lihat password
  bool isPasswordVisible = false;

  // untuk validasi inputan user
  String? emailError;
  String? nameError;
  String? passwordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,//agar tidak ada tanda back
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 20,
      ),
      body: Center(
          child: Container(
            padding: const EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min, //agar column tidak mengambil ruang yg diperlukan teks 
                children: [
                  const SizedBox(height: 5),
                  const Text(
                    "Make an Account",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: Colors.black
                    ),
                    textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Register your identify",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                        color: Colors.black
                      ),
                    textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: registerEmailController, //inputan user disimpan di controller ini
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.mail),
                        prefixIconConstraints: BoxConstraints(minHeight: 10, minWidth: 40),
                      ),
                      validator: (value) { //apakah user sudah menginputkan teks
                        if (value == null || value.trim().isEmpty) { //jika hasil kosong dan controller kosong
                          return 'Email belum terisi'; //mengirimkan pesan ini
                        }
                        return null; 
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: registerNameController, //simpan inputan user
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                        prefixIconConstraints: BoxConstraints(minHeight: 10, minWidth: 40),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama belum terisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: registerPasswordController,
                      obscureText: !isPasswordVisible,  //awalnya teks tidak terlihat
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        prefixIconConstraints: const BoxConstraints(minHeight: 10, minWidth: 40),
                        suffixIcon: IconButton(
                          icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () { //jika ikon ditekan, maka teks akan ditampilkan
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) { //validasi agar password tidak kosong
                        if (value == null || value.trim().isEmpty) {
                          return 'Password belum terisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // button register
                    SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: ElevatedButton( //tombol yang menonjol dari background
                        onPressed: () async {
                          // Validasi jika field belum diisi
                          setState(() {
                            //pesan error akan ditampilkan jika inputan user itu kosong
                            emailError = registerEmailController.text.trim().isEmpty ? 'Email belum terisi' : null;
                            nameError = registerNameController.text.trim().isEmpty ? 'Nama belum terisi' : null;
                            passwordError = registerPasswordController.text.trim().isEmpty ? 'Password belum terisi' : null;
                          });

                          //jika GlobalKey tidak bisa mengakses status terkini dari form, maka validator tidak dijalankan
                          if (!_formKey.currentState!.validate()) {
                            return; // Hentikan proses jika form tidak valid
                          }

                          // Panggil API
                          try {
                            StatusRegister register = await ApiService().registerUser(
                              registerEmailController.text.trim(),
                              registerNameController.text.trim(),
                              registerPasswordController.text.trim(),
                            );

                            if (!context.mounted) return;

                            if (register.status == true) {
                              // Pop-up berhasil registrasi
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Registrasi Berhasil'),
                                  content: const Text('Silakan login untuk melanjutkan'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context); // Tutup dialog
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const LoginPage()),
                                        );
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // Pop-up gagal registrasi
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Gagal Registrasi'),
                                  content: Text(register.message),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Error"),
                                content: Text("Terjadi kesalahan: $e"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primarycolors,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Register',
                        style: TextStyle(fontSize: 14.0, color: Colors.white)), // Tambahkan child
                      ),
                    ),
                    const SizedBox(height: 15),

                    // perpindahan page
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(fontSize: 12),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                              ); //mengarahkan ke login page
                          },
                          child: const Text(
                            "LOGIN",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primarycolors,
                            ),
                          ),
                        ),
                      ],
                    ),
                ]
              ),
            ),
          ),
        ),
      );
  }
}