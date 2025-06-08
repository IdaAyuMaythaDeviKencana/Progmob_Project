import 'package:dio/dio.dart';

import 'package:demo_savitrishop/utils/token_helper.dart';
import 'package:demo_savitrishop/models/status_register.dart';
import 'package:demo_savitrishop/models/login_models.dart';
import 'package:demo_savitrishop/models/jenis_transaksi.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://mobileapis.manpits.xyz/api';

  // Link Api Login
  Future<Login?> loginUser(String email, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/login',
        data: {'email': email, 'password': password},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return Login.fromJson(response.data);
      } else {
        print('Login gagal: ${response.data['message']}');
        return null;
      }
    } catch (e) {
      print('Error login: $e');
      return null;
    }
  }

  //Link Api Register
  Future<StatusRegister> registerUser(String email, String name, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('Response: ${response.data}');
      return StatusRegister.fromJson(response.data);
    } on DioException catch (e) {
      print('Dio Error: ${e.message}');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      return StatusRegister(
        status: false,
        message: 'Gagal koneksi: ${e.message}',
      );
    } catch (e) {
      print('Error lain: $e');
      return StatusRegister(
        status: false,
        message: 'Terjadi kesalahan tak terduga',
      );
    }
  }

  // Link API untuk AddMember dan Edit Member
  Future<Response?> addOrUpdateMember({
    required Map<String, dynamic> data,
    String? memberId,
  }) async {
    final token = await TokenHelper.getToken();
    if (token == null) throw Exception('Token tidak ditemukan.');

    final String url = memberId != null ? '$_baseUrl/anggota/$memberId' : '$_baseUrl/anggota';
    final String method = memberId != null ? 'PATCH' : 'POST';

    try {
      return await _dio.request(
        url,
        data: data,
        options: Options(
          method: method,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
    } catch (e) {
      print('Error addOrUpdateMember: $e');
      return null;
    }
  }

  //link api untuk lihat list member 
  Future<Response?> getMembers() async {
    final token = await TokenHelper.getToken();
    if (token == null) throw Exception('Token tidak ditemukan.');

    try {
      return await _dio.get(
        '$_baseUrl/anggota',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error getMembers: $e');
      return null;
    }
  }

  // API untuk Delete Anggota 
  Future<Response?> deleteMember(String id) async {
    final token = await TokenHelper.getToken();
    if (token == null) throw Exception('Token tidak ditemukan.');

    try {
      return await _dio.delete(
        '$_baseUrl/anggota/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error deleteMember: $e');
      return null;
    }
  }

  // API untuk LOGOUT
  Future<Response?> logout() async {
    final token = await TokenHelper.getToken();
    if (token == null) throw Exception('Token tidak ditemukan.');

    try {
      return await _dio.get(
        '$_baseUrl/logout',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error logout: $e');
      return null;
    }
  }

  // mendapatkan API untuk Jenis Transaksi
  Future<List<JenisTransaksi>> getJenisTransaksi() async {
    final token = await TokenHelper.getToken();
    if (token == null) throw Exception('Token tidak ditemukan.');

    try {
      final response = await _dio.get(
        '$_baseUrl/jenistransaksi',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List list = response.data['data']['jenistransaksi'];
        return list.map((e) => JenisTransaksi.fromJson(e)).toList();
      } else {
        throw Exception('Gagal ambil jenis transaksi: ${response.data['message']}');
      }
    } catch (e) {
      print('Error getJenisTransaksi: $e');
      rethrow;
    }
  }

  // Menambahkan transaksi tabungan
  Future<bool> addTransaksiTabungan({
    required int anggotaId,
    required String tanggal,
    required int trxId,
    required String nominal,
  }) async {
    final token = await TokenHelper.getToken();
    if (token == null) throw Exception('Token tidak ditemukan.');

    try {
      final response = await _dio.post(
        '$_baseUrl/tabungan',
        data: {
          'anggota_id': anggotaId.toString(),
          'trx_tanggal': tanggal,
          'trx_id': trxId.toString(),
          'trx_nominal': nominal,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

       // Tampilkan response lengkap dan pesan dari server
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('Pesan dari Server: ${response.data['message']}');

      return response.statusCode == 200 || response.statusCode == 201
          ? response.data['success'] == true
          : false;
    } catch (e) {
      print('Error addTransaksiTabungan: $e');
      return false;
    }
  }

  // API untuk Mendapat Nama Anggota
  Future<String?> getNamaAnggotaById(int id) async {
    final token = await TokenHelper.getToken();
    if (token == null) throw Exception('Token tidak ditemukan.');

    try {
      final response = await _dio.get(
        '$_baseUrl/anggota',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      final anggotaList = response.data['data']['anggotas'];
      if (anggotaList == null || anggotaList is! List) {
        print('Data anggota tidak dalam bentuk list.');
        return null;
      }

      final anggota = anggotaList.firstWhere(
        (a) => a['id'] == id,
        orElse: () => null,
      );

      if (anggota != null) {
        return anggota['nama']; // Key 'nama' sesuai dengan JSON kamu
      } else {
        print('Anggota dengan ID $id tidak ditemukan.');
        return null;
      }
    } catch (e) {
      print('Error getNamaAnggotaById: $e');
      return null;
    }
  }

  // untuk Mendapatkan saldo tabungan tiap anggota
  Future<int> getSaldoByAnggotaId(int anggotaId) async {
    final token = await TokenHelper.getToken();
    if (token == null) throw Exception('Token tidak ditemukan.');

    try {
      final response = await _dio.get(
        '$_baseUrl/saldo/$anggotaId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      print('Response data saldo: ${response.data}');  // Debug

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null && data['saldo'] != null) {
          return data['saldo'] as int;
        } else {
          throw Exception('Data saldo tidak ditemukan di response.');
        }
      } else {
        throw Exception('Gagal mengambil saldo, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getSaldoByAnggotaId: $e');
      throw Exception('Terjadi kesalahan saat mengambil saldo.');
    }
  }

  // API mendapatkan transaksi yang dilakukan tiap Anggota
  Future<List<Map<String, dynamic>>>  getTransaksiByAnggotaId(int anggotaId) async {
    final token = await TokenHelper.getToken();
    if (token == null) throw Exception('Token tidak ditemukan.');

    try {
      final response = await _dio.get(
        '$_baseUrl/tabungan/$anggotaId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null && data['tabungan'] != null) {
          final List<dynamic> tabunganJson = data['tabungan'];
          return tabunganJson.cast<Map<String, dynamic>>();
        } else {
          return [];
        }
      } else {
        throw Exception('Gagal mengambil data transaksi');
      }
    } catch (e) {
      print('Error getTransaksiByAnggotaId: $e');
      throw Exception('Terjadi kesalahan saat mengambil data transaksi.');
    }
  }


}
