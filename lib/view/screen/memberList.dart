import 'package:flutter/material.dart';

import 'package:demo_savitrishop/models/member.dart';
import 'package:demo_savitrishop/utils/api_service.dart';
import 'package:demo_savitrishop/utils/token_helper.dart';
import 'package:demo_savitrishop/view/screen/addMember.dart';

class MemberListPage extends StatefulWidget {
  const MemberListPage({Key? key}) : super(key: key);

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  final ApiService apiService = ApiService();  //objek untuk akses API
  List<Member> memberList = [];                //Menyimpan daftar anggota
  bool isLoading = false;                      //Status loading
  String? errorMessage;                        //Menyimpan pesan error

  @override
  void initState() {
    super.initState();
    fetchMembers();  //panggil saat halaman pertama kali dibuat
  }

  Future<void> fetchMembers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final token = await TokenHelper.getToken();

      if (token == null) {   //jika token tidak ada
        setState(() {
          errorMessage = 'Token tidak ditemukan. Silakan login ulang.';
          isLoading = false;
        });
        return;
      }

      final response = await apiService.getMembers();  //panggil API ambil data member

      if (response == null) { //jika tidak ada respon API
        setState(() {
          errorMessage = 'Gagal memuat data anggota.';
          isLoading = false;
        });
        return;
      }

      if (response.statusCode == 200) {  //jika status OK, ambil data anggotas
        final List<dynamic> membersJson = response.data['data']['anggotas']; //ambil data anggotas
        final List<Member> loadedMembers =
            membersJson.map((json) => Member.fromJson(json)).toList(); //konversi ke list member dengan fromjson

        setState(() {
          memberList = loadedMembers;  //simpan data ke memberList
          isLoading = false;
        });
      } else {  //jika tidak ada respon API
        setState(() {
          errorMessage = 'Status error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {  //jika error saat panggil API
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _deleteMember(String id) async {  //hapus anggota
    setState(() {  //saat mulai menghapus, tampilkan login
      isLoading = true;
    });

    try {
      final response = await apiService.deleteMember(id);  //panggil API

      if (response != null && response.statusCode == 200) {  //jika response tidak null dan statusCOdenya 200 (permintaan berhasil)
        await fetchMembers();  //panggil untuk perbarui daftar anggota
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Anggota berhasil dihapus')),  //menampilkan
        );
      } else {  //jika permintaan ditolak server
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus anggota')),
        );
      }
    } catch (e) {  //menangkap semua kesalahan dari try
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kesalahan: $e')),
      );
    } finally {  //bagian ini selalu jalan
      setState(() {
        isLoading = false; //agar yang muncul saat loading menghilang
      });
    }
  }

  void _confirmDelete(BuildContext context, String id) {  //context itu untuk menunjukkan posisi widget
    showDialog(  //nampilin popup dialog dilayar 
      context: context,
      builder: (ctx) => AlertDialog(  //untuk buat tampilan dialognya
        title: Text('Hapus Anggota'),
        content: Text('Yakin ingin menghapus anggota ini?'),
        actions: [  //tombol yang dibagian bawah
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),  //untuk tutup dialog tapi anggota ga terhapus
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();  //dialog ditutup 
              _deleteMember(id); //menjalankan hapus anggota
            },
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, //untuk tidak balik ke halaman sebelumnya
        title: Text('Member'),
        actions: [  //untuk tombol refresh
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchMembers,  //kalo di klik, fetchmember dipanggil untuk memuat ulang daftar anggota
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(  //untuk addmember
        child: Icon(Icons.add),
        onPressed: () {  //jika ditekan, maka akan pindah ke halaman berikutnya
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMemberPage()),
          ).then((value) {  //setelah kembali
            if (value == true) {  //data akan dimuat ulang jika true
              fetchMembers();
            }
          });
        },
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())  //kalo true, menampilkan loading spinner di tengah layar
          : errorMessage != null
              ? Center(child: Text(errorMessage!))  //kalo ada error message, tampilkan teks error ditengah
              : memberList.isEmpty
                  ? Center(child: Text('Belum ada member.')) //kalo list member kosong, tampilkan pesan
                  : ListView.builder(  //kalo ada, data ditampilin pake list view builder
                      itemCount: memberList.length,  //jumlah anggota
                      itemBuilder: (context, index) { //buat tampilan setiap item berdasar index
                        final member = memberList[index];
                        return ListTile(  //isi dari tiap member
                          title: Text(member.nama),
                          subtitle: Text(member.telepon),
                          trailing: Row( //bagian kanan dari ListTile
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton( //tombol edit
                                icon: Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'Edit',
                                onPressed: () { //saat ditekan akan berpindah halaman
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddMemberPage(member: member),
                                    ),
                                  ).then((value) {  //saat kembali dengan value true
                                    if (value == true) {
                                      fetchMembers();  //data anggota dimuat ulang
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Hapus',
                                onPressed: () {  //jika diklik akan memanggil prosedur diatas
                                  _confirmDelete(context, member.id.toString());
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
