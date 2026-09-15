-- Migration 020: Create Due List View

CREATE OR REPLACE VIEW view_due_list AS
SELECT 
    cal.id AS calibration_id,
    cal.tenant_id,
    cal.organization_id,
    cal.calibration_number,
    cal.calibration_date,
    cal.calibration_frequency,
    cal.next_due_date,
    cal.result AS calibration_result,
    cal.outcome AS calibration_outcome,
    im.id AS item_master_id,
    im.item_code,
    im.item_name,
    im.item_type,
    im.manufacturer,
    im.model,
    im.serial_number,
    c.id AS client_id,
    c.client_name,
    c.client_code,
    CASE 
        WHEN cal.next_due_date < NOW() THEN 'OVERDUE'
        WHEN cal.next_due_date <= NOW() + INTERVAL '30 days' THEN 'DUE_SOON'
        ELSE 'UPCOMING'
    END AS due_status
FROM calibrations cal
JOIN request_items ri ON cal.request_item_id = ri.id
JOIN calibration_requests cr ON cal.request_id = cr.id
JOIN clients c ON cr.client_id = c.id
JOIN item_masters im ON ri.item_master_id = im.id;
