-- ============================================================
-- SOAL 2.1: TRIGGER UPDATE STOCK & ANTI-NEGATIVE
-- ============================================================

-- Fungsi trigger
CREATE OR REPLACE FUNCTION trg_update_stock_and_journal()
RETURNS TRIGGER AS $$
BEGIN
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

    IF (SELECT stock_qty FROM inventory_items WHERE item_id = NEW.item_id) < 0 THEN
        RAISE EXCEPTION 'Stok tidak mencukupi untuk item %. Stok tersedia: %, diminta: %',
            NEW.item_id,
            (SELECT stock_qty + NEW.qty FROM inventory_items WHERE item_id = NEW.item_id),
            NEW.qty;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger
DROP TRIGGER IF EXISTS trg_update_stock_and_journal ON inventory_transactions;
CREATE TRIGGER trg_update_stock_and_journal
AFTER INSERT ON inventory_transactions
FOR EACH ROW
EXECUTE FUNCTION trg_update_stock_and_journal();