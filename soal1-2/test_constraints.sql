-- ============================================================
-- SOAL 1.2: TEST SKENARIO CONSTRAINT
-- ============================================================
-- Jalankan SETELAH schema.sql berhasil
-- Test ini sengaja dibuat ada yang error untuk membuktikan
-- constraint bekerja
-- ============================================================

-- ============================================================
-- SETUP: Insert data dasar yang valid
-- ============================================================
INSERT INTO chart_of_accounts VALUES 
    ('101', 'Kas', 'DEBIT', 'ASET'),
    ('102', 'Piutang Usaha', 'DEBIT', 'ASET'),
    ('201', 'Utang Usaha', 'CREDIT', 'LIABILITAS'),
    ('301', 'Modal Pemilik', 'CREDIT', 'EKUITAS'),
    ('401', 'Pendapatan Jasa', 'CREDIT', 'PENDAPATAN'),
    ('501', 'Beban Gaji', 'DEBIT', 'BEBAN');

SELECT '✅ Setup COA berhasil' AS status;

-- ============================================================
-- TEST 1: Insert COA dengan normal_balance invalid → HARUS GAGAL
-- ============================================================
INSERT INTO chart_of_accounts 
VALUES ('999', 'Test Invalid', 'SALAH', 'ASET');
-- Ekspektasi: ERROR check constraint "normal_balance"

-- ============================================================
-- TEST 2: Insert COA dengan klasifikasi invalid → HARUS GAGAL
-- ============================================================
INSERT INTO chart_of_accounts 
VALUES ('998', 'Test Invalid', 'DEBIT', 'KLASIFIKASI_SALAH');
-- Ekspektasi: ERROR check constraint "report_classification"

-- ============================================================
-- TEST 3: Insert journal header valid → HARUS SUKSES
-- ============================================================
INSERT INTO journal_headers (trx_date, reference_no, description, status_posting)
VALUES (CURRENT_DATE, 'JV-2026-0001', 'Setoran modal awal', 'DRAFT')
RETURNING header_id, reference_no;
-- Ekspektasi: SUKSES, header_id = 1

-- ============================================================
-- TEST 4: Insert journal line VALID → HARUS SUKSES
-- ============================================================
INSERT INTO journal_lines (header_id, account_id, debit, credit)
VALUES (1, '101', 10000000, 0);
-- Ekspektasi: SUKSES (Debit Kas 10 juta)

INSERT INTO journal_lines (header_id, account_id, debit, credit)
VALUES (1, '301', 0, 10000000);
-- Ekspektasi: SUKSES (Kredit Modal 10 juta)

SELECT '✅ Test 4: Insert line valid berhasil' AS status;

-- ============================================================
-- TEST 5: Insert line dengan debit=0 DAN credit=0 → HARUS GAGAL
-- ============================================================
INSERT INTO journal_lines (header_id, account_id, debit, credit)
VALUES (1, '101', 0, 0);
-- Ekspektasi: ERROR chk_not_both_zero

-- ============================================================
-- TEST 6: Insert line dengan debit NEGATIF → HARUS GAGAL
-- ============================================================
INSERT INTO journal_lines (header_id, account_id, debit, credit)
VALUES (1, '101', -5000, 0);
-- Ekspektasi: ERROR CHECK (debit >= 0)

-- ============================================================
-- TEST 7: Insert line dengan credit NEGATIF → HARUS GAGAL
-- ============================================================
INSERT INTO journal_lines (header_id, account_id, debit, credit)
VALUES (1, '101', 0, -5000);
-- Ekspektasi: ERROR CHECK (credit >= 0)

-- ============================================================
-- TEST 8: Insert line dengan header_id tidak ada → HARUS GAGAL
-- ============================================================
INSERT INTO journal_lines (header_id, account_id, debit, credit)
VALUES (999, '101', 1000, 0);
-- Ekspektasi: ERROR FOREIGN KEY

-- ============================================================
-- TEST 9: Insert line dengan account_id tidak ada → HARUS GAGAL
-- ============================================================
INSERT INTO journal_lines (header_id, account_id, debit, credit)
VALUES (1, 'TIDAK_ADA', 1000, 0);
-- Ekspektasi: ERROR FOREIGN KEY

-- ============================================================
-- TEST 10: DELETE akun yang masih dipakai → HARUS GAGAL
-- ============================================================
DELETE FROM chart_of_accounts WHERE account_id = '101';
-- Ekspektasi: ERROR ON DELETE RESTRICT

-- ============================================================
-- TEST 11: DELETE header yang masih punya line → HARUS GAGAL
-- ============================================================
DELETE FROM journal_headers WHERE header_id = 1;
-- Ekspektasi: ERROR ON DELETE RESTRICT

-- ============================================================
-- TEST 12: Cek balance transaksi
-- ============================================================
SELECT 
    h.header_id,
    h.reference_no,
    SUM(l.debit)  AS total_debit,
    SUM(l.credit) AS total_credit,
    CASE 
        WHEN SUM(l.debit) = SUM(l.credit) THEN 'BALANCED ✅'
        ELSE 'UNBALANCED ❌'
    END AS status
FROM journal_headers h
JOIN journal_lines l ON l.header_id = h.header_id
GROUP BY h.header_id, h.reference_no;
-- Ekspektasi: BALANCED (10.000.000 = 10.000.000)