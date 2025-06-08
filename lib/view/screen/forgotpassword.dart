import 'package:flutter/material.dart';

// Palet warna
const primarycolors = Color(0xFF6D2932);
const lightbackground = Color(0xFFFFFFFF);

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  String? emailError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightbackground,
      appBar: AppBar(
        title: const Text("Reset Password"),
        backgroundColor: primarycolors,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Enter your email to reset your password",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.mail),
                errorText: emailError,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    emailError = emailController.text.isEmpty ? 'Email belum diisi' : null;
                  });

                  if (emailError == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Link reset telah dikirim ke email kamu")),
                    );
                    Navigator.pop(context); // kembali ke login
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primarycolors,
                ),
                child: const Text("Kirim Link Reset", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
