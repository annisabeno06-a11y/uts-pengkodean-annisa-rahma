# Soal 1.3 — Analisis Audit & Keamanan Finansial

## Pendahuluan

Dalam perancangan basis data akuntansi, pemilihan model skema tabel
sangat menentukan kualitas jejak audit (audit trail) dan kepatuhan
terhadap normalisasi data. Terdapat dua pendekatan umum: **model
tabel tunggal (flat journal table)** dan **model Header-Line**
yang memisahkan metadata transaksi dari detail akuntansi.

Analisis berikut menjelaskan mengapa model Header-Line lebih andal
dibandingkan model flat, ditinjau dari dua sudut pandang: jejak
audit dan bentuk normal ketiga (3NF).

---

## A. Sudut Pandang Jejak Audit (Audit Trail)

### 1. Pemisahan Metadata dari Detail

Pada model Header-Line, metadata transaksi (tanggal, nomor bukti,
deskripsi, status posting) disimpan **sekali** di tabel
`journal_headers`. Sedangkan detail akuntansi (akun, debit, kredit)
disimpan di `journal_lines`.

Keunggulan untuk audit:
- **Satu baris header = satu jejak transaksi.** Auditor dapat
  dengan mudah menghitung berapa banyak transaksi terjadi dalam
  periode tertentu.
- **Status posting terpusat di header.** Ketika transaksi
  di-posting (POSTED), status berubah di satu tempat. Tidak ada
  risiko satu baris sudah POSTED sementara baris lain masih DRAFT.
- **Nomor bukti unik di level transaksi.** Mencegah duplikasi
  nomor bukti yang sering terjadi di model flat.

### 2. Imutabilitas Transaksi POSTED

Model Header-Line memungkinkan penegakan aturan **immutability**
(ketidakberubahan) di level header. Ketika `status_posting = 'POSTED'`,
seluruh baris di `journal_lines` yang merujuk ke header tersebut
otomatis terkunci. Tidak ada baris yang bisa diubah tanpa mengubah
status header.

Di model flat, aturan ini sulit ditegakkan karena status tersebar
di setiap baris. Bisa terjadi inkonsistensi: sebagian baris POSTED,
sebagian masih DRAFT.

### 3. Kemudahan Rekonsiliasi

Auditor dapat dengan cepat memverifikasi keseimbangan
(double-entry) per transaksi:

```sql
SELECT h.header_id, h.reference_no,
       SUM(l.debit) AS total_debit,
       SUM(l.credit) AS total_credit
FROM journal_headers h
JOIN journal_lines l ON l.header_id = h.header_id
GROUP BY h.header_id, h.reference_no
HAVING SUM(l.debit) <> SUM(l.credit);