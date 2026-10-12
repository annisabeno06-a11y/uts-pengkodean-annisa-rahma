-- ============================================================
-- SOAL 1.2: DDL SKEMA GENERAL LEDGER
-- UTS Coding Akuntansi - FEB Undip
-- ============================================================

-- Hapus tabel jika sudah ada (untuk reset)
DROP TABLE IF EXISTS journal_lines CASCADE;
DROP TABLE IF EXISTS journal_headers CASCADE;
DROP TABLE IF EXISTS chart_of_accounts CASCADE;

-- ============================================================
-- TABEL 1: chart_of_accounts (Master Akun)
-- ============================================================
CREATE TABLE chart_of_accounts (
    account_id            VARCHAR(10) PRIMARY KEY,
    account_name          VARCHAR(100) NOT NULL,
    normal_balance        VARCHAR(6) NOT NULL
                          CHECK (normal_balance IN ('DEBIT', 'CREDIT')),
    report_classification VARCHAR(20) NOT NULL
                          CHECK (report_classification IN 
                                 ('ASET', 'LIABILITAS', 'EKUITAS', 
                                  'PENDAPATAN', 'BEBAN'))
);

-- ============================================================
-- TABEL 2: journal_headers (Header Transaksi)
-- ============================================================
CREATE TABLE journal_headers (
    header_id      SERIAL PRIMARY KEY,
    trx_date       DATE NOT NULL,
    reference_no   VARCHAR(30) UNIQUE,
    description    TEXT,
    status_posting VARCHAR(10) NOT NULL DEFAULT 'DRAFT'
                   CHECK (status_posting IN ('DRAFT', 'POSTED', 'VOID'))
);

-- ============================================================
-- TABEL 3: journal_lines (Detail Baris Jurnal)
-- ============================================================
CREATE TABLE journal_lines (
    line_id    SERIAL PRIMARY KEY,
    header_id  INT NOT NULL
               REFERENCES journal_headers(header_id) 
               ON DELETE RESTRICT,
    account_id VARCHAR(10) NOT NULL
               REFERENCES chart_of_accounts(account_id) 
               ON DELETE RESTRICT,
    debit      NUMERIC(15,2) NOT NULL DEFAULT 0
               CHECK (debit >= 0),
    credit     NUMERIC(15,2) NOT NULL DEFAULT 0
               CHECK (credit >= 0),

    -- CONSTRAINT UTAMA: cegah baris jurnal dengan debit=0 DAN credit=0
    CONSTRAINT chk_not_both_zero 
        CHECK (NOT (debit = 0 AND credit = 0))
);

-- ============================================================
-- INDEX untuk performa query
-- ============================================================
CREATE INDEX idx_coa_classification 
    ON chart_of_accounts(report_classification);
CREATE INDEX idx_jh_date 
    ON journal_headers(trx_date);
CREATE INDEX idx_jh_status 
    ON journal_headers(status_posting);
CREATE INDEX idx_jl_header_account 
    ON journal_lines(header_id, account_id);