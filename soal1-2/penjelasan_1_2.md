# Soal 1.2 — Penjelasan Constraint

## 1. Primary Key
- `chart_of_accounts.account_id` → kode akun unik
- `journal_headers.header_id` → ID transaksi unik (auto-increment)
- `journal_lines.line_id` → ID baris unik (auto-increment)

Primary Key menjamin setiap baris punya identitas unik dan 
mencegah duplikasi data.

## 2. Foreign Key dengan ON DELETE RESTRICT
- `journal_lines.header_id` → ke `journal_headers.header_id`
- `journal_lines.account_id` → ke `chart_of_accounts.account_id`

**Mengapa RESTRICT?** Mencegah penghapusan data master yang masih 
direferensikan oleh transaksi. Ini melindungi integritas data:
- Akun yang masih dipakai tidak bisa dihapus
- Header yang masih punya line tidak bisa dihapus

Tanpa RESTRICT, penghapusan akun bisa menyebabkan "orphan line" 
(baris jurnal tanpa akun), yang merusak laporan keuangan.

## 3. CHECK debit >= 0 dan credit >= 0
Mencegah nilai negatif. Di double-entry, nilai negatif tidak 
diperbolehkan — arah debit/kredit sudah merepresentasikan 
posisi akuntansi (bukan tanda +/-).

## 4. CHECK NOT (debit = 0 AND credit = 0)
Ini constraint paling penting. Mencegah "baris jurnal kosong" yang 
tidak punya makna akuntansi. Setiap baris jurnal HARUS punya 
nilai di salah satu sisi (debit atau kredit), tidak boleh keduanya nol.

Tanpa constraint ini, API bisa mengirim baris jurnal kosong yang 
lolos validasi frontend, menyebabkan laporan keuangan tidak balance.

## 5. CHECK pada normal_balance dan report_classification
Membatasi nilai kolom ke domain yang valid. Mencegah typo seperti 
'DEBET' (salah, harus 'DEBIT') atau 'ASSET' (salah, harus 'ASET').

## Bukti Test
Screenshot hasil test ada di folder `screenshots/`.