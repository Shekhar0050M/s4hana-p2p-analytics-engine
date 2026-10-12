CLASS zcl_p2p_data_generator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_p2p_data_generator IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    out->write( |============================================================| ).
    out->write( | S/4HANA Procure-to-Pay (P2P) Realistic Sample Data Generator | ).
    out->write( |============================================================| ).
    " ----------------------------------------------------------------------
    " Step 1: Clean up existing database tables and draft tables
    " ----------------------------------------------------------------------
    DELETE FROM ztb_vendor01.
    DELETE FROM ztb_po_item.
    DELETE FROM ztb_po_hdr.
    DELETE FROM zdt_po_item_d.
    DELETE FROM zdt_po_hdr_d.
    out->write( |[1/4] Purged previous records from ZTB_VENDOR01, ZTB_PO_HDR, ZTB_PO_ITEM, and draft tables.| ).
    " ----------------------------------------------------------------------
    " Step 2: Seed Vendor Master Data (ZTB_VENDOR01)
    " ----------------------------------------------------------------------
    DATA: lt_vendors TYPE TABLE OF ztb_vendor01.
    DATA: lt_headers TYPE TABLE OF ztb_po_hdr.
    DATA: lt_items   TYPE TABLE OF ztb_po_item.
    lt_vendors = VALUE #(
      ( client = sy-mandt vendor_id = 'VEND-001' vendor_name = 'SAP SE'                 country = 'DE' city = 'Walldorf'   payment_terms = 'NT30' risk_score = 15 is_active = 'X' )
      ( client = sy-mandt vendor_id = 'VEND-002' vendor_name = 'Amazon Web Services'     country = 'US' city = 'Seattle'    payment_terms = 'NT30' risk_score = 10 is_active = 'X' )
      ( client = sy-mandt vendor_id = 'VEND-003' vendor_name = 'Dell Technologies'       country = 'US' city = 'Round Rock' payment_terms = 'NT45' risk_score = 25 is_active = 'X' )
      ( client = sy-mandt vendor_id = 'VEND-004' vendor_name = 'Siemens AG'             country = 'DE' city = 'Munich'     payment_terms = 'NT60' risk_score = 12 is_active = 'X' )
      ( client = sy-mandt vendor_id = 'VEND-005' vendor_name = 'Oracle Corporation'     country = 'US' city = 'Austin'     payment_terms = 'NT30' risk_score = 30 is_active = 'X' )
      ( client = sy-mandt vendor_id = 'VEND-006' vendor_name = 'Cisco Systems Inc'      country = 'US' city = 'San Jose'   payment_terms = 'NT45' risk_score = 18 is_active = 'X' )
      ( client = sy-mandt vendor_id = 'VEND-007' vendor_name = 'Microsoft Corp'         country = 'US' city = 'Redmond'    payment_terms = 'NT30' risk_score = 8  is_active = 'X' )
      ( client = sy-mandt vendor_id = 'VEND-008' vendor_name = 'Lenovo Global'          country = 'CN' city = 'Beijing'    payment_terms = 'NT60' risk_score = 35 is_active = 'X' )
    ).
    INSERT ztb_vendor01 FROM TABLE @lt_vendors.
    out->write( |[2/4] Inserted { lines( lt_vendors ) } vendor records into ZTB_VENDOR01.| ).
    " ----------------------------------------------------------------------
    " Step 3: Seed Header Data (20 Enterprise Purchase Orders)
    " ----------------------------------------------------------------------
    DATA(lv_now) = utclong_current( ).

    lt_headers = VALUE #(
      " High Value Orders (>= $50,000)
      ( client = sy-mandt po_id = '4500000001' vendor_id = 'VEND-001' vendor_name = 'SAP SE'                 total_amount = '145000.00' currency_code = 'USD' status = 'A' created_at = lv_now )
      ( client = sy-mandt po_id = '4500000002' vendor_id = 'VEND-002' vendor_name = 'Amazon Web Services'     total_amount = '88500.00'  currency_code = 'USD' status = 'A' created_at = lv_now )
      ( client = sy-mandt po_id = '4500000003' vendor_id = 'VEND-003' vendor_name = 'Dell Technologies'       total_amount = '64200.00'  currency_code = 'USD' status = 'N' created_at = lv_now )
      ( client = sy-mandt po_id = '4500000004' vendor_id = 'VEND-004' vendor_name = 'Siemens AG'             total_amount = '112000.00' currency_code = 'EUR' status = 'C' created_at = lv_now )
      ( client = sy-mandt po_id = '4500000005' vendor_id = 'VEND-005' vendor_name = 'Oracle Corporation'     total_amount = '95400.00'  currency_code = 'USD' status = 'A' created_at = lv_now )
      ( client = sy-mandt po_id = '4500000006' vendor_id = 'VEND-006' vendor_name = 'Cisco Systems Inc'      total_amount = '54000.00'  currency_code = 'USD' status = 'N' created_at = lv_now )
      " Medium Value Orders ($10,000 - $49,999.99)
      ( client = sy-mandt po_id = '4500000007' vendor_id = 'VEND-007' vendor_name = 'Microsoft Corp'         total_amount = '34500.00'  currency_code = 'USD' status = 'A' created_at = lv_now )
      ( client = sy-mandt po_id = '4500000008' vendor_id = 'VEND-008' vendor_name = 'Lenovo Global'          total_amount = '28900.00'  currency_code = 'USD' status = 'N' created_at = lv_now )
      ( client = sy-mandt po_id = '4500000009' vendor_id = 'VEND-003' vendor_name = 'Dell Technologies'       total_amount = '42000.00'  currency_code = 'USD' status = 'C' created_at = lv_now )
      ( client = sy-mandt po_id = '4500000010' vendor_id = 'VEND-001' vendor_name = 'SAP SE'                 total_amount = '38000.00'  currency_code = 'USD' status = 'N' created_at = lv_now )
      ( client = sy-mandt po_id = '4500000011' vendor_id = 'VEND-004' vendor_name = 'Siemens AG'             total_amount = '47500.00'  currency_code = 'EUR' status = 'A' created_at = lv_now )
      ( client = sy-mandt po_id = '4500000012' vendor_id = 'VEND-002' vendor_name = 'Amazon Web Services'     total_amount = '22000.00'  currency_code = 'USD' status = 'N' created_at = lv_now )
      ( client = sy-mandt po_id = '4500000013' vendor_id = 'VEND-006' vendor_name = 'Cisco Systems Inc'      total_amount = '19800.00'  currency_code = 'USD' status = 'A' created_at = lv_now )
      ( client = sy-mandt po_id = '4500000014' vendor_id = 'VEND-007' vendor_name = 'Microsoft Corp'         total_amount = '14500.00'  currency_code = 'GBP' status = 'R' created_at = lv_now )
      " Standard Tier Orders (< $10,000) & Lifecycle Edge Cases
      ( client = sy-mandt po_id = '4500000015' vendor_id = 'VEND-008' vendor_name = 'Lenovo Global'          total_amount = '8400.00'   currency_code = 'USD' status = 'C' created_at = lv_now )
      ( client = sy-mandt po_id = '4500000016' vendor_id = 'VEND-003' vendor_name = 'Dell Technologies'       total_amount = '9200.00'   currency_code = 'USD' status = 'N' created_at = lv_now )
      ( client = sy-mandt po_id = '4500000017' vendor_id = 'VEND-005' vendor_name = 'Oracle Corporation'     total_amount = '7500.00'   currency_code = 'USD' status = 'X' created_at = lv_now )
      ( client = sy-mandt po_id = '4500000018' vendor_id = 'VEND-004' vendor_name = 'Siemens AG'             total_amount = '9800.00'   currency_code = 'EUR' status = 'R' created_at = lv_now )
      ( client = sy-mandt po_id = '4500000019' vendor_id = 'VEND-002' vendor_name = 'Amazon Web Services'     total_amount = '4500.00'   currency_code = 'USD' status = 'X' created_at = lv_now )
      ( client = sy-mandt po_id = '4500000020' vendor_id = 'VEND-007' vendor_name = 'Microsoft Corp'         total_amount = '6800.00'   currency_code = 'USD' status = 'A' created_at = lv_now )
    ).
    INSERT ztb_po_hdr FROM TABLE @lt_headers.
    out->write( |[3/4] Inserted { lines( lt_headers ) } header records into ZTB_PO_HDR.| ).
    " ----------------------------------------------------------------------
    " Step 4: Seed Realistic Line Items (ZTB_PO_ITEM)
    " ----------------------------------------------------------------------
    lt_items = VALUE #(
      " Items for 4500000001 (SAP SE - $145,000)
      ( client = sy-mandt po_id = '4500000001' item_id = '0010' material = 'S/4HANA Cloud Enterprise Edition'      quantity = '100' unit = 'EA'  currency_code = 'USD' net_amount = '100000.00' )
      ( client = sy-mandt po_id = '4500000001' item_id = '0020' material = 'SAP BTP Enterprise License Pack'       quantity = '50'  unit = 'EA'  currency_code = 'USD' net_amount = '45000.00' )
      " Items for 4500000002 (AWS - $88,500)
      ( client = sy-mandt po_id = '4500000002' item_id = '0010' material = 'AWS EC2 c6i.4xlarge Reserved Node'     quantity = '24'  unit = 'EA'  currency_code = 'USD' net_amount = '60000.00' )
      ( client = sy-mandt po_id = '4500000002' item_id = '0020' material = 'AWS S3 High-Availability Bucket'       quantity = '12'  unit = 'MTH' currency_code = 'USD' net_amount = '28500.00' )
      " Items for 4500000003 (Dell - $64,200)
      ( client = sy-mandt po_id = '4500000003' item_id = '0010' material = 'Dell PowerEdge R750 2U Rack Server'     quantity = '8'   unit = 'EA'  currency_code = 'USD' net_amount = '48000.00' )
      ( client = sy-mandt po_id = '4500000003' item_id = '0020' material = 'Dell ProSupport 3-Year Mission Critical' quantity = '8'   unit = 'EA'  currency_code = 'USD' net_amount = '16200.00' )
      " Items for 4500000004 (Siemens - EUR 112,000)
      ( client = sy-mandt po_id = '4500000004' item_id = '0010' material = 'SIMATIC S7-1500 Modular Controller'    quantity = '20'  unit = 'EA'  currency_code = 'EUR' net_amount = '70000.00' )
      ( client = sy-mandt po_id = '4500000004' item_id = '0020' material = 'ET 200SP High-Speed Distributed I/O'   quantity = '40'  unit = 'EA'  currency_code = 'EUR' net_amount = '42000.00' )
      " Items for 4500000005 (Oracle - $95,400)
      ( client = sy-mandt po_id = '4500000005' item_id = '0010' material = 'Oracle Database Enterprise Processor'   quantity = '4'   unit = 'EA'  currency_code = 'USD' net_amount = '60000.00' )
      ( client = sy-mandt po_id = '4500000005' item_id = '0020' material = 'Oracle Real Application Clusters RAC'   quantity = '4'   unit = 'EA'  currency_code = 'USD' net_amount = '35400.00' )
      " Items for 4500000006 (Cisco - $54,000)
      ( client = sy-mandt po_id = '4500000006' item_id = '0010' material = 'Cisco Catalyst 9300 48-Port Switch'    quantity = '12'  unit = 'EA'  currency_code = 'USD' net_amount = '36000.00' )
      ( client = sy-mandt po_id = '4500000006' item_id = '0020' material = 'Cisco DNA Premier 5-Year Term'          quantity = '12'  unit = 'EA'  currency_code = 'USD' net_amount = '18000.00' )
      " Items for 4500000007 (Microsoft - $34,500)
      ( client = sy-mandt po_id = '4500000007' item_id = '0010' material = 'Microsoft 365 E5 Enterprise License'   quantity = '250' unit = 'EA'  currency_code = 'USD' net_amount = '34500.00' )
      " Items for 4500000008 (Lenovo - $28,900)
      ( client = sy-mandt po_id = '4500000008' item_id = '0010' material = 'ThinkPad P1 Gen 6 Workstation 64GB'    quantity = '15'  unit = 'EA'  currency_code = 'USD' net_amount = '28900.00' )
      " Items for 4500000009 (Dell - $42,000)
      ( client = sy-mandt po_id = '4500000009' item_id = '0010' material = 'Dell Precision 5820 Tower Workstation'  quantity = '14'  unit = 'EA'  currency_code = 'USD' net_amount = '42000.00' )
      " Items for 4500000010 (SAP - $38,000)
      ( client = sy-mandt po_id = '4500000010' item_id = '0010' material = 'SAP Analytics Cloud BI Edition'        quantity = '100' unit = 'EA'  currency_code = 'USD' net_amount = '38000.00' )
      " Items for 4500000011 (Siemens - EUR 47,500)
      ( client = sy-mandt po_id = '4500000011' item_id = '0010' material = 'Industrial Ethernet Switch SCALANCE'   quantity = '25'  unit = 'EA'  currency_code = 'EUR' net_amount = '47500.00' )
      " Items for 4500000012 (AWS - $22,000)
      ( client = sy-mandt po_id = '4500000012' item_id = '0010' material = 'Amazon RDS for PostgreSQL Multi-AZ'     quantity = '12'  unit = 'MTH' currency_code = 'USD' net_amount = '22000.00' )
      " Items for 4500000013 (Cisco - $19,800)
      ( client = sy-mandt po_id = '4500000013' item_id = '0010' material = 'Cisco Meraki MR46 Wi-Fi 6 AP'          quantity = '30'  unit = 'EA'  currency_code = 'USD' net_amount = '19800.00' )
      " Items for 4500000014 (Microsoft - GBP 14,500)
      ( client = sy-mandt po_id = '4500000014' item_id = '0010' material = 'Azure Dedicated ExpressRoute 10Gbps'   quantity = '1'   unit = 'EA'  currency_code = 'GBP' net_amount = '14500.00' )
      " Items for 4500000015 (Lenovo - $8,400)
      ( client = sy-mandt po_id = '4500000015' item_id = '0010' material = 'ThinkVision P27u-20 27-inch 4K Monitor' quantity = '20'  unit = 'EA'  currency_code = 'USD' net_amount = '8400.00' )
      " Items for 4500000016 (Dell - $9,200)
      ( client = sy-mandt po_id = '4500000016' item_id = '0010' material = 'Dell UltraSharp 34 Curved Monitor'      quantity = '10'  unit = 'EA'  currency_code = 'USD' net_amount = '9200.00' )
      " Items for 4500000017 (Oracle - $7,500)
      ( client = sy-mandt po_id = '4500000017' item_id = '0010' material = 'Oracle Diagnostic & Tuning Pack'       quantity = '5'   unit = 'EA'  currency_code = 'USD' net_amount = '7500.00' )
      " Items for 4500000018 (Siemens - EUR 9,800)
      ( client = sy-mandt po_id = '4500000018' item_id = '0010' material = 'SINAMICS G120 Smart Inverter'          quantity = '6'   unit = 'EA'  currency_code = 'EUR' net_amount = '9800.00' )
      " Items for 4500000019 (AWS - $4,500)
      ( client = sy-mandt po_id = '4500000019' item_id = '0010' material = 'Amazon CloudWatch Extended Retention'  quantity = '1'   unit = 'EA'  currency_code = 'USD' net_amount = '4500.00' )
      " Items for 4500000020 (Microsoft - $6,800)
      ( client = sy-mandt po_id = '4500000020' item_id = '0010' material = 'GitHub Enterprise Cloud Seat Pack'     quantity = '25'  unit = 'EA'  currency_code = 'USD' net_amount = '6800.00' )
    ).
    INSERT ztb_po_item FROM TABLE @lt_items.
    out->write( |[4/4] Inserted { lines( lt_items ) } item records into ZTB_PO_ITEM.| ).
    out->write( |------------------------------------------------------------| ).
    out->write( | Summary Statistics:| ).
    " Status Breakdown
    SELECT status, COUNT(*) AS count
      FROM ztb_po_hdr
      GROUP BY status
      INTO TABLE @DATA(lt_status_summary).
    LOOP AT lt_status_summary INTO DATA(ls_stat).
      DATA(lv_stat_label) = COND string(
        WHEN ls_stat-status = 'N' THEN 'New / Pending'
        WHEN ls_stat-status = 'A' THEN 'Approved'
        WHEN ls_stat-status = 'C' THEN 'Completed'
        WHEN ls_stat-status = 'R' THEN 'Rejected'
        WHEN ls_stat-status = 'X' THEN 'Cancelled'
        ELSE 'Unknown'
      ).
      out->write( |  - Status '{ ls_stat-status }' ({ lv_stat_label }): { ls_stat-count } orders| ).
    ENDLOOP.
    " Total Spend
    SELECT SUM( total_amount ) AS total_spend FROM ztb_po_hdr INTO @DATA(lv_total_spend).
    out->write( |  - Total Procure-to-Pay Spend: ${ lv_total_spend NUMBER = USER }| ).
    out->write( |============================================================| ).
    out->write( | SUCCESS: Realistic test dataset ready for Fiori Elements & RAP! | ).
    out->write( |============================================================| ).


  ENDMETHOD.
ENDCLASS.
