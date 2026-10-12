-- ============================================================
-- SOAL 3.2: PREVENT MODIFICATION OF POSTED TRANSACTIONS
-- ============================================================
-- Tujuan: Transaksi berstatus 'POSTED' tidak dapat di-UPDATE
--         maupun di-DELETE. Harus melalui jurnal pembalik
--         (reversing entry / storno).
-- ============================================================

-- Fungsi: cek status_posting sebelum UPDATE/DELETE
CREATE OR REPLACE FUNCTION prevent_posted_modification()
RETURNS TRIGGER AS $$
BEGIN
    -- Cek apakah status_posting = 'POSTED'
    IF OLD.status_posting = 'POSTED' THEN
        RAISE EXCEPTION 'Transaksi POSTED tidak dapat diubah. 
                         Gunakan jurnal pembalik (reversing entry).';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger untuk UPDATE
DROP TRIGGER IF EXISTS trg_prevent_update_posted ON journal_headers;
CREATE TRIGGER trg_prevent_update_posted
BEFORE UPDATE ON journal_headers
FOR EACH ROW
EXECUTE FUNCTION prevent_posted_modification();

-- Trigger untuk DELETE
DROP TRIGGER IF EXISTS trg_prevent_delete_posted ON journal_headers;
CREATE TRIGGER trg_prevent_delete_posted
BEFORE DELETE ON journal_headers
FOR EACH ROW
EXECUTE FUNCTION prevent_posted_modification();

-- ============================================================
-- TEST: Coba update/delete transaksi POSTED
-- ============================================================
-- Buat header POSTED
INSERT INTO journal_headers (trx_date, reference_no, description, status_posting)
VALUES (CURRENT_DATE, 'JV-POSTED-TEST', 'Test posted', 'POSTED')
RETURNING header_id, reference_no, status_posting;

-- Test UPDATE (harus error)
UPDATE journal_headers 
SET description = 'Coba ubah' 
WHERE reference_no = 'JV-POSTED-TEST';

-- Test DELETE (harus error)
DELETE FROM journal_headers 
WHERE reference_no = 'JV-POSTED-TEST';