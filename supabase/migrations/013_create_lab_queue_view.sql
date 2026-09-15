-- Migration 013: Create Lab Queue View

CREATE OR REPLACE VIEW view_lab_queue AS
SELECT 
    ri.id AS request_item_id,
    cr.id AS request_id,
    cr.tenant_id,
    cr.organization_id,
    cr.request_number,
    cr.priority,
    cr.status AS request_status,
    cr.collection_date,
    c.id AS client_id,
    c.client_name,
    c.client_code,
    im.id AS item_master_id,
    im.item_code,
    im.item_name,
    im.item_type,
    im.serial_number AS expected_serial_number,
    ri.quantity AS expected_quantity,
    ri.received_quantity,
    ri.item_condition AS reported_item_condition,
    ri.status AS item_status,
    ri.document_requirement_status,
    ri.remarks AS item_remarks,
    ri.created_at AS item_created_at
FROM request_items ri
JOIN calibration_requests cr ON ri.request_id = cr.id
JOIN clients c ON cr.client_id = c.id
JOIN item_masters im ON ri.item_master_id = im.id
WHERE cr.status IN ('LAB_QUEUE', 'VERIFICATION', 'ON_HOLD', 'DISCREPANCY');
