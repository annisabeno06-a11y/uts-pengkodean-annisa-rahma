-- ============================================================
-- SOAL 3.2: HASH CHECKSUM UNTUK INTEGRITAS DATA
-- ============================================================
-- Tujuan: Setiap transaksi punya hash SHA-256 yang di-generate
--         otomatis dari isinya. Kalau isi berubah, hash berubah
--         -> deteksi manipulasi data.
-- ============================================================

-- Step 1: Tambah kolom audit trail
ALTER TABLE journal_headers 
ADD COLUMN IF NOT EXISTS created_by VARCHAR(50),
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS hash_checksum VARCHAR(64);

-- Step 2: Fungsi generate hash SHA-256
CREATE OR REPLACE FUNCTION generate_journal_hash()
RETURNS TRIGGER AS $$
BEGIN
    NEW.hash_checksum = encode(
        digest(
            COALESCE(NEW.reference_no, '') || 
            COALESCE(NEW.trx_date::text, '') || 
            COALESCE(NEW.description, '') ||
            COALESCE(NEW.status_posting, ''),
            'sha256'
        ),
        'hex'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 3: Trigger generate hash otomatis
DROP TRIGGER IF EXISTS trg_generate_hash ON journal_headers;
CREATE TRIGGER trg_generate_hash
BEFORE INSERT OR UPDATE ON journal_headers
FOR EACH ROW
EXECUTE FUNCTION generate_journal_hash();

-- ============================================================
-- TEST: Insert header baru, cek hash muncul
-- ============================================================
INSERT INTO journal_headers 
    (trx_date, reference_no, description, status_posting, created_by)
VALUES 
    (CURRENT_DATE, 'JV-HASH-TEST', 'Test hash checksum', 'DRAFT', 'admin')
RETURNING header_id, reference_no, hash_checksum, created_by, created_at;

-- Ekspektasi: hash_checksum berisi string hex 64 karakter