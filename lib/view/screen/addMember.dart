import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:demo_savitrishop/models/member.dart';
import 'package:demo_savitrishop/utils/api_service.dart';

class AddMemberPage extends StatefulWidget {
  final Member? member; //Tambahkan parameter member

  const AddMemberPage({Key? key, this.member}) : super(key: key);

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nomorIndukController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController tanggalLahirController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      nomorIndukController.text = widget.member!.nomorInduk; // sesuaikan kalau ada field khusus
      namaController.text = widget.member!.nama;
      teleponController.text = widget.member!.telepon;
      alamatController.text = widget.member!.alamat;
      tanggalLahirController.text = widget.member!.tglLahir;
    }
  }

  Future<void> submitMember() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService().addOrUpdateMember(
        memberId: widget.member?.id.toString(),
        data: {
          'nomor_induk': nomorIndukController.text,
          'nama': namaController.text,
          'alamat': alamatController.text,
          'tgl_lahir': tanggalLahirController.text,
          'telepon': teleponController.text,
        },
      );

      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          errorMessage = 'Gagal menyimpan data. Coba lagi.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    nomorIndukController.dispose();
    namaController.dispose();
    alamatController.dispose();
    tanggalLahirController.dispose();
    teleponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.member != null ? 'Edit Member' : 'Tambah Member')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    buildTextField(
                      label: 'Nomor Induk',
                      controller: nomorIndukController,
                      keyboardType: TextInputType.number,
                      validatorText: 'Nomor Induk wajib diisi',
                      icon: Icons.badge,
                    ),
                    buildTextField(
                      label: 'Nama',
                      controller: namaController,
                      validatorText: 'Nama wajib diisi',
                      icon: Icons.person,
                    ),
                    buildTextField(
                      label: 'Alamat',
                      controller: alamatController,
                      validatorText: 'Alamat wajib diisi',
                      icon: Icons.location_city,
                    ),
                    buildTextField(
                      label: 'Tanggal Lahir (YYYY-MM-DD)',
                      controller: tanggalLahirController,
                      validatorText: 'Tanggal lahir wajib diisi',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.datetime,
                    ),
                    buildTextField(
                      label: 'Telepon',
                      controller: teleponController,
                      keyboardType: TextInputType.phone,
                      validatorText: 'Telepon wajib diisi',
                      icon: Icons.phone,
                    ),
                    if (errorMessage != null) ...[
                      SizedBox(height: 10),
                      Text(errorMessage!, style: TextStyle(color: Colors.red)),
                    ],
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          submitMember();
                        }
                      },
                      child: Text('Simpan'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required String validatorText,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validatorText;
          }
          if (label.contains('Tanggal Lahir')) {
            try {
              DateFormat('yyyy-MM-dd').parseStrict(value);
            } catch (_) {
              return 'Format tanggal tidak valid (YYYY-MM-DD)';
            }
          }
          return null;
        },
      ),
    );
  }
}
