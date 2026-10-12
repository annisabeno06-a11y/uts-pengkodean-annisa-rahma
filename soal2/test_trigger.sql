-- ============================================================
-- SOAL 2.1: TEST TRIGGER
-- ============================================================
-- Tujuan: verifikasi trigger trg_update_stock_and_journal()
--         bekerja sesuai harapan
--
-- Cara pakai:
-- 1. Jalankan schema.sql & trigger.sql dulu
-- 2. Jalankan test ini satu per satu (jangan sekaligus)
-- 3. Screenshot hasil test
-- ============================================================


-- ============================================================
-- TEST 1: PURCHASE — stok bertambah
-- ============================================================
-- Skenario: Beli 5 unit BRG001 (stok awal 10)
-- Ekspektasi: stok jadi 15

SELECT '=== TEST 1: PURCHASE ===' AS test_case;

-- Cek stok sebelum
SELECT item_id, item_name, stock_qty 
FROM inventory_items 
WHERE item_id = 'BRG001';

-- Insert transaksi PURCHASE
INSERT INTO inventory_transactions (item_id, trx_type, qty)
VALUES ('BRG001', 'PURCHASE', 5);

-- Cek stok setelah
SELECT item_id, item_name, stock_qty 
FROM inventory_items 
WHERE item_id = 'BRG001';

-- Ekspektasi: stock_qty = 15 (10 + 5)


-- ============================================================
-- TEST 2: SALE — stok cukup, berkurang
-- ============================================================
-- Skenario: Jual 3 unit BRG001 (stok sekarang 15)
-- Ekspektasi: stok jadi 12

SELECT '=== TEST 2: SALE STOK CUKUP ===' AS test_case;

-- Cek stok sebelum
SELECT item_id, item_name, stock_qty 
FROM inventory_items 
WHERE item_id = 'BRG001';

-- Insert transaksi SALE
INSERT INTO inventory_transactions (item_id, trx_type, qty)
VALUES ('BRG001', 'SALE', 3);

-- Cek stok setelah
SELECT item_id, item_name, stock_qty 
FROM inventory_items 
WHERE item_id = 'BRG001';

-- Ekspektasi: stock_qty = 12 (15 - 3)


-- ============================================================
-- TEST 3: SALE — stok KURANG, HARUS ERROR ⭐
-- ============================================================
-- Skenario: Jual 100 unit BRG001 (stok sekarang 12)
-- Ekspektasi: ERROR — stok tidak mencukupi
-- 
-- ⚠️ WAJIB SCREENSHOT INI!

SELECT '=== TEST 3: SALE STOK KURANG (HARUS ERROR) ===' AS test_case;

-- Cek stok sebelum
SELECT item_id, item_name, stock_qty 
FROM inventory_items 
WHERE item_id = 'BRG001';

-- Insert transaksi SALE dengan qty melebihi stok
INSERT INTO inventory_transactions (item_id, trx_type, qty)
VALUES ('BRG001', 'SALE', 100);

-- Ekspektasi: 
-- ERROR: Stok tidak mencukupi untuk item BRG001. 
--        Stok tersedia: 12, diminta: 100


-- ============================================================
-- TEST 4: Verifikasi stok TIDAK berubah setelah error
-- ============================================================
-- Skenario: Cek stok BRG001 setelah Test 3 error
-- Ekspektasi: stok tetap 12 (transaksi SALE 100 dibatalkan)

SELECT '=== TEST 4: STOK TIDAK BERUBAH SETELAH ERROR ===' AS test_case;

SELECT item_id, item_name, stock_qty 
FROM inventory_items 
WHERE item_id = 'BRG001';

-- Ekspektasi: stock_qty = 12 (tidak berubah)


-- ============================================================
-- TEST 5: SALE — stok tepat habis (jadi 0)
-- ============================================================
-- Skenario: Jual 12 unit BRG001 (stok sekarang 12)
-- Ekspektasi: stok jadi 0 (bukan error, karena hasil = 0)

SELECT '=== TEST 5: SALE STOK TEPAT HABIS ===' AS test_case;

-- Cek stok sebelum
SELECT item_id, item_name, stock_qty 
FROM inventory_items 
WHERE item_id = 'BRG001';

-- Insert transaksi SALE
INSERT INTO inventory_transactions (item_id, trx_type, qty)
VALUES ('BRG001', 'SALE', 12);

-- Cek stok setelah
SELECT item_id, item_name, stock_qty 
FROM inventory_items 
WHERE item_id = 'BRG001';

-- Ekspektasi: stock_qty = 0


-- ============================================================
-- TEST 6: SALE dari stok 0 — HARUS ERROR
-- ============================================================
-- Skenario: Jual 1 unit BRG001 (stok sekarang 0)
-- Ekspektasi: ERROR — stok tidak mencukupi

SELECT '=== TEST 6: SALE DARI STOK 0 (HARUS ERROR) ===' AS test_case;

INSERT INTO inventory_transactions (item_id, trx_type, qty)
VALUES ('BRG001', 'SALE', 1);

-- Ekspektasi: 
-- ERROR: Stok tidak mencukupi untuk item BRG001. 
--        Stok tersedia: 0, diminta: 1


-- ============================================================
-- TEST 7: Item BRG002 — verifikasi trigger jalan untuk item lain
-- ============================================================
-- Skenario: Beli 20 unit BRG002 (stok awal 50)
-- Ekspektasi: stok jadi 70

SELECT '=== TEST 7: ITEM LAIN (BRG002) ===' AS test_case;

SELECT item_id, item_name, stock_qty 
FROM inventory_items 
WHERE item_id = 'BRG002';

INSERT INTO inventory_transactions (item_id, trx_type, qty)
VALUES ('BRG002', 'PURCHASE', 20);

SELECT item_id, item_name, stock_qty 
FROM inventory_items 
WHERE item_id = 'BRG002';

-- Ekspektasi: stock_qty = 70 (50 + 20)


-- ============================================================
-- TEST 8: ADJUSTMENT — stok bisa naik/turun
-- ============================================================
-- Skenario: Adjustment +5 unit BRG002 (stok sekarang 70)
-- Ekspektasi: stok jadi 75

SELECT '=== TEST 8: ADJUSTMENT ===' AS test_case;

INSERT INTO inventory_transactions (item_id, trx_type, qty)
VALUES ('BRG002', 'ADJUSTMENT', 5);

SELECT item_id, item_name, stock_qty 
FROM inventory_items 
WHERE item_id = 'BRG002';

-- Ekspektasi: stock_qty = 75


-- ============================================================
-- TEST 9: ADJUSTMENT negatif — stok turun
-- ============================================================
-- Skenario: Adjustment -10 unit BRG002 (stok sekarang 75)
-- Ekspektasi: stok jadi 65

SELECT '=== TEST 9: ADJUSTMENT NEGATIF ===' AS test_case;

INSERT INTO inventory_transactions (item_id, trx_type, qty)
VALUES ('BRG002', 'ADJUSTMENT', -10);

SELECT item_id, item_name, stock_qty 
FROM inventory_items 
WHERE item_id = 'BRG002';

-- Ekspektasi: stock_qty = 65


-- ============================================================
-- TEST 10: Cek riwayat transaksi
-- ============================================================
-- Skenario: Lihat semua transaksi yang tercatat
-- Ekspektasi: semua transaksi yang sukses ada di sini
-- (yang error tidak masuk karena transaksi dibatalkan)

SELECT '=== TEST 10: RIWAYAT TRANSAKSI ===' AS test_case;

SELECT 
    t.trx_id,
    t.item_id,
    i.item_name,
    t.trx_type,
    t.qty,
    t.trx_date,
    i.stock_qty AS stok_saat_ini
FROM inventory_transactions t
JOIN inventory_items i ON i.item_id = t.item_id
ORDER BY t.trx_id;

-- Ekspektasi: transaksi sukses saja (Test 3 & 6 tidak muncul)


-- ============================================================
-- RINGKASAN TEST
-- ============================================================
-- Test 1: PURCHASE 5    → stok 10 → 15   ✅
-- Test 2: SALE 3        → stok 15 → 12   ✅
-- Test 3: SALE 100      → ERROR          ✅ (stok tetap 12)
-- Test 4: Cek stok      → tetap 12       ✅
-- Test 5: SALE 12       → stok 12 → 0    ✅
-- Test 6: SALE 1 dari 0 → ERROR          ✅
-- Test 7: PURCHASE 20   → stok 50 → 70   ✅
-- Test 8: ADJUSTMENT +5 → stok 70 → 75   ✅
-- Test 9: ADJUSTMENT -10→ stok 75 → 65   ✅
-- Test 10: Cek riwayat  → semua transaksi sukses ✅
-- ============================================================