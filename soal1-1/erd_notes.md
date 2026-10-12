# Soal 1.1 — Catatan Desain ERD

## Keputusan Desain

### 1. account_id pakai VARCHAR(10), bukan SERIAL
Kode akun di akuntansi bersifat semantik (punya makna):
- '101' = Kas
- '101.1' = Kas Kecil
- '1-1000' = Aset Lancar

Kalau pakai SERIAL (angka auto-increment), kode akun kehilangan makna
dan sulit dibaca auditor. Ini praktik standar di sistem akuntansi.

### 2. Pemisahan Header-Line
- journal_headers menyimpan metadata transaksi (tanggal, referensi, status)
- journal_lines menyimpan detail akuntansi (akun, debit, kredit)
- Pemisahan ini memenuhi 3NF dan memudahkan audit trail.

### 3. journal_lines sebagai Junction Table
journal_lines punya 2 Foreign Key:
- header_id → journal_headers
- account_id → chart_of_accounts

Ini yang menghubungkan transaksi dengan akun.

### 4. Tidak Ada Kolom Total di Header
Total debit/kredit dihitung dari SUM di journal_lines.
Menyimpan total di header melanggar 3NF dan rawan inkonsistensi.

### 5. status_posting sebagai Kunci Audit Trail
Nilai 'POSTED' menandakan transaksi sudah final dan tidak boleh diubah.
Ini yang akan diimplementasikan di Soal 3.2 (immutability).

## Kardinalitas

| Relasi | Kardinalitas | Penjelasan |
|---|---|---|
| chart_of_accounts → journal_lines | 1 : N | 1 akun muncul di banyak baris jurnal |
| journal_headers → journal_lines | 1 : N | 1 transaksi punya banyak baris (min 2) |
| chart_of_accounts ↔ journal_headers | Tidak langsung | Terhubung via journal_lines |