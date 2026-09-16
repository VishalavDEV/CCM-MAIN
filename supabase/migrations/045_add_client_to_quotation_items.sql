-- Migration 045: Add Client ID and Client Name to Quotation Items Table

ALTER TABLE quotation_items 
ADD COLUMN IF NOT EXISTS client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS client_name VARCHAR(255);

CREATE INDEX IF NOT EXISTS idx_quotation_items_client_id 
ON quotation_items(tenant_id, client_id);

-- Backfill existing quotation items with client details from parent quotation & client
UPDATE quotation_items qi
SET 
    client_id = q.client_id,
    client_name = c.client_name
FROM quotations q
JOIN clients c ON q.client_id = c.id
WHERE qi.quotation_id = q.id
  AND (qi.client_id IS NULL OR qi.client_name IS NULL);

-- Create trigger function to auto-populate client_id and client_name on insert or update
CREATE OR REPLACE FUNCTION set_quotation_item_client()
RETURNS TRIGGER AS $$
DECLARE
    v_client_id UUID;
    v_client_name VARCHAR(255);
BEGIN
    IF NEW.quotation_id IS NOT NULL THEN
        SELECT q.client_id, c.client_name 
        INTO v_client_id, v_client_name
        FROM quotations q
        JOIN clients c ON q.client_id = c.id
        WHERE q.id = NEW.quotation_id;

        IF v_client_id IS NOT NULL THEN
            NEW.client_id := v_client_id;
            NEW.client_name := v_client_name;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_set_quotation_item_client ON quotation_items;
CREATE TRIGGER trigger_set_quotation_item_client
BEFORE INSERT OR UPDATE OF quotation_id ON quotation_items
FOR EACH ROW
EXECUTE FUNCTION set_quotation_item_client();
