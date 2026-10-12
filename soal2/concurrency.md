# Soal 2.2 — Penanganan Concurrency (Race Condition)

## A. Identifikasi Masalah

Race condition terjadi ketika dua atau lebih transaksi database
mengakses data yang sama secara bersamaan tanpa mekanisme penguncian
yang memadai. Pada kasus inventory, ini bisa menyebabkan **overselling**
— stok terjual melebihi jumlah yang tersedia.

Skenario:
- Stok BRG001 = 1 unit
- Kasir A dan Kasir B menjual 1 unit BRG001 secara bersamaan
- Tanpa proteksi, keduanya lolos validasi stok
- Hasil: 2 unit terjual, stok jadi negatif

## B. Teknik Penanganan Concurrency

### 1. SELECT ... FOR UPDATE (Pessimistic Locking)

Teknik ini mengunci baris yang sedang dibaca sampai transaksi selesai.
Transaksi lain yang mencoba membaca baris yang sama akan **menunggu**
sampai lock dilepas.

**Kelebihan:**
- Menjamin konsistensi data
- Cocok untuk transaksi yang sering konflik

**Kekurangan:**
- Bisa menyebabkan deadlock kalau tidak hati-hati
- Menurunkan throughput (transaksi antre)

### 2. Isolasi Transaksi Serializable

Level isolasi tertinggi di PostgreSQL. Transaksi dijamin berjalan
seolah-olah dieksekusi secara berurutan (serial).

**Kelebihan:**
- Menjamin konsistensi penuh
- Tidak perlu eksplisit lock

**Kekurangan:**
- Paling lambat
- Bisa sering mengalami serialization failure (harus retry)

### 3. Optimistic Locking (Versioning)

Tambahkan kolom `version` di tabel. Setiap UPDATE harus menyertakan
versi yang sesuai. Kalau versi sudah berubah, transaksi gagal.

## C. Rekomendasi untuk Kasus Ini

Untuk kasus inventory dengan risiko overselling, saya merekomendasikan
**SELECT ... FOR UPDATE** karena:

1. Sederhana dan mudah dipahami
2. Menjamin konsistensi di level baris
3. Cocok untuk transaksi yang melibatkan stok
4. Tidak perlu mengubah skema tabel

## D. Cuplikan Kode

```sql
CREATE OR REPLACE FUNCTION trg_update_stock_and_journal()
RETURNS TRIGGER AS $$
DECLARE
    v_stock_qty INT;
BEGIN
    -- Kunci baris inventory_items
    SELECT stock_qty INTO v_stock_qty
    FROM inventory_items
    WHERE item_id = NEW.item_id
    FOR UPDATE;
    
    -- Cek stok untuk SALE
    IF NEW.trx_type = 'SALE' AND v_stock_qty < NEW.qty THEN
        RAISE EXCEPTION 'Stok tidak mencukupi untuk item %. Stok: %, diminta: %',
            NEW.item_id, v_stock_qty, NEW.qty;
    END IF;
    
    -- Update stok
    IF NEW.trx_type = 'PURCHASE' THEN
        UPDATE inventory_items
        SET stock_qty = stock_qty + NEW.qty
        WHERE item_id = NEW.item_id;
    ELSIF NEW.trx_type = 'SALE' THEN
        UPDATE inventory_items
        SET stock_qty = stock_qty - NEW.qty
        WHERE item_id = NEW.item_id;
    ELSIF NEW.trx_type = 'ADJUSTMENT' THEN
        UPDATE inventory_items
        SET stock_qty = stock_qty + NEW.qty
        WHERE item_id = NEW.item_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;