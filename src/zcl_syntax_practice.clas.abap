CLASS zcl_syntax_practice DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_syntax_practice IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

** Inline declaration
*    DATA(l_v_name) = 'Shekhar Suman'.
*    out->write( l_v_name ).
*
** Select Statement with Inline declaration
*    SELECT SINGLE currency,
*                  decimals
*           FROM i_currency
*           WHERE currency = 'USD'
*           INTO @DATA(l_wa_currency).
*
*    out->write( |Select output { l_wa_currency-Currency } { l_wa_currency-Decimals } | ).
*
** Select Statement with Inline declaration
*    SELECT SINGLE currency AS money,
*                  decimals AS value
*           FROM i_currency
*           WHERE currency = 'USD'
*           INTO @DATA(l_wa_icurrency).
*
*    out->write( |Select output { l_wa_icurrency-money } { l_wa_icurrency-value } | ).
*
*******************************************************************************************
** 01+practiceCode
*
*    SELECT *
*        FROM i_currency
*        INTO TABLE @DATA(l_i_ekko)
*        UP TO 10 ROWS.
*
*    LOOP AT l_i_ekko ASSIGNING FIELD-SYMBOL(<l_fs_ekko>).
*      out->write( |{ <l_fs_ekko>-Currency } { <l_fs_ekko>-CurrencyISOCode } { <l_fs_ekko>-Decimals } | ).
*    ENDLOOP.
*
*******************************************************************************************
*
** Reading a row from internal table
*
*    DATA(idx) = sy-tabix.
*    IF line_exists( l_i_ekko[ idx ] ).
*      DATA(wa1) = l_i_ekko[ 1 ].
*      out->write( |{ wa1-Currency } { wa1-CurrencyISOCode }| ).
*    ENDIF.
*
** Concatenate of string
*
*    DATA(l_v_string) = |Sample String concatenate | && wa1-Currency && | The return code is { sy-subrc } |.
*    out->write( l_v_string ).
*
** Alpha formatting
*
*    DATA(value1) = '00000012345'.
*    DATA(outvalue1) = | { value1 ALPHA = OUT } |.
*    DATA(outvalue2) = | { outvalue1 ALPHA = IN } |.
*
*    CONDENSE outvalue1.
*    out->write( | { outvalue1 } is getting converted to  { outvalue2 } | ).
*
** Conversion Operator
*
*    DATA: cust_name TYPE c LENGTH 30 VALUE 'Shekhar Suman'.
*
*    DATA(str1) = CONV string( cust_name ).
*
*    out->write( | The value is { str1 } and it's type is { cl_abap_typedescr=>describe_by_data( str1 )->type_kind } | ).
*
** Casting
*
**    DATA(components) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name( 'ZBP_STRUCT' ) )->components.
*
** Value operator
*
*    TYPES: l_r_tab TYPE RANGE OF STRing.
*    DATA: l_r_tabtype TYPE l_r_tab.
*
*    l_r_tabtype = VALUE #( ( sign = 'I' option = 'EQ' low = 'Hello' )
*                       ( sign = 'I' option = 'GT' low = 'World' ) ).
*
*    LOOP AT l_r_tabtype ASSIGNING FIELD-SYMBOL(<l_fs_tab>).
*      out->write( | { <l_fs_tab>-low } | ).
*    ENDLOOP.
*
** FOR operator
*
*    DATA(l_i_tablevalues) = VALUE L_r_tab( FOR l_wa_tab IN l_r_tabtype WHERE ( low EQ 'Hello' ) ( l_wa_tab ) ).
*
*    LOOP AT l_i_tablevalues ASSIGNING FIELD-SYMBOL(<l_fs_tablevalues>).
*      out->write( | { <l_fs_tablevalues>-low } | ).
*    ENDLOOP.
*
** Reduce operator
*    DATA(l_v_lines) = REDUCE i( INIT x = 0 FOR l_wa_tab IN l_r_tabtype NEXT x = x + 1 ).
*    out->write( | { l_v_lines } | ).
*
** Conditional operator
*    DATA(l_v_cond) = COND #( WHEN <l_fs_tablevalues>-low EQ 'Hello'
*                             THEN | It is hello. |
*                             WHEN <l_fs_tablevalues>-low EQ 'World'
*                             THEN | World is ending. |
*                           ).
*
*    out->write( |{ l_v_cond }| ).
*
** Corresponding Operator
*
*    TYPES: BEGIN OF l_ty_type,
*             val1 TYPE c LENGTH 2,
*             val2 TYPE c LENGTH 2,
*             val3 TYPE c LENGTH 2,
*           END OF l_ty_type,
*           l_ty_t_type TYPE STANDARD TABLE OF l_ty_type WITH EMPTY KEY.
*    DATA: l_wa_tp1 TYPE l_ty_type,
*          l_wa_tp2 TYPE l_ty_type,
*          l_i_tp   TYPE l_ty_t_type.
*
*    l_wa_tp1-val1 = 'AB'.
*    l_wa_tp1-val2 = 'BC'.
*    l_wa_tp1-val3 = 'CD'.
*
*    l_wa_tp2-val1 = 'EF'.
*    l_wa_tp2-val2 = 'GH'.
*
*    l_i_tp = VALUE l_ty_t_type( ( l_wa_tp1 ) ( l_wa_tp2 ) ).
*
*    DATA(l_i_ftp2) = CORRESPONDING l_ty_t_type( l_i_tp MAPPING val1 = val1 ).
*
*    LOOP AT l_i_ftp2 ASSIGNING FIELD-SYMBOL(<l_fs_ftp2>).
*      out->write( | { <l_fs_ftp2>-val1 } :: { <l_fs_ftp2>-val2 } :: { <l_fs_ftp2>-val3 } | ).
*    ENDLOOP.
*
*    DATA(l_wa_ftp1) = CORRESPONDING l_ty_type( BASE ( l_wa_tp1 ) l_wa_tp2 EXCEPT val3 ).
*
*    out->write( | { l_wa_ftp1-val1 } :: { l_wa_ftp1-val2 } :: { l_wa_ftp1-val3 } | ).
*
** Object creation using new syntax
*
*    DATA: l_o_obj TYPE REF TO zcl_0001_flight.
*    TRY.
*        l_o_obj = NEW #( carrier_id = 'AA'
*                         connection_id = '0017'
*                         plane_type = '747-400' ).
*        DATA(l_o_obj2) = NEW zcl_0001_flight( carrier_id = 'AA'
*                         connection_id = '0017'
*                         plane_type = '747-400' ).
*        NEW zcl_0001_flight( carrier_id = 'AA'
*                         connection_id = '0017'
*                         plane_type = '747-400' ).
*      CATCH cx_root.
*    ENDTRY.
*
** Select statement for modern abap
*
**    SELECT FROM i_table
**    FIELDS field1,
**           field2,
**           field3
**    INTO TABLE @DATA(l_i_table)
**    UP TO 10 ROWS.

    DATA: lt_hdrs  TYPE TABLE OF ztb_po_hdr,
          lt_items TYPE TABLE OF ztb_po_item,
          lv_pattern TYPE string VALUE '10000000%'.

    " 1. Prepare 50 Header Records
    lt_hdrs = VALUE #(
      ( po_id = '1000000001' vendor_name = 'TechCorp Solutions' total_amount = '2500.00' currency_code = 'USD' status = 'A' created_at = '2026-01-10T10:00:00.0000000' )
      ( po_id = '1000000002' vendor_name = 'CloudScale Networks' total_amount = '12000.00' currency_code = 'USD' status = 'A' created_at = '2026-01-12T11:30:00.0000000' )
      ( po_id = '1000000003' vendor_name = 'OfficeDepot Global' total_amount = '850.00' currency_code = 'USD' status = 'N' created_at = '2026-01-15T09:15:00.0000000' )
      ( po_id = '1000000004' vendor_name = 'Apex Industrial Supplies' total_amount = '55000.00' currency_code = 'USD' status = 'N' created_at = '2026-01-18T14:20:00.0000000' )
      ( po_id = '1000000005' vendor_name = 'QuickOffice Express' total_amount = '150.00' currency_code = 'USD' status = 'R' created_at = '2026-01-20T16:45:00.0000000' )
      ( po_id = '1000000006' vendor_name = 'Global Logistics Inc' total_amount = '4300.00' currency_code = 'USD' status = 'A' created_at = '2026-01-22T08:30:00.0000000' )
      ( po_id = '1000000007' vendor_name = 'Alpha Software Corp' total_amount = '18500.00' currency_code = 'USD' status = 'A' created_at = '2026-01-25T10:10:00.0000000' )
      ( po_id = '1000000008' vendor_name = 'Beta Hardware Ltd' total_amount = '9200.00' currency_code = 'USD' status = 'N' created_at = '2026-01-28T12:00:00.0000000' )
      ( po_id = '1000000009' vendor_name = 'Gamma Solutions' total_amount = '3400.00' currency_code = 'USD' status = 'R' created_at = '2026-02-01T09:00:00.0000000' )
      ( po_id = '1000000010' vendor_name = 'Delta Enterprise' total_amount = '78000.00' currency_code = 'USD' status = 'A' created_at = '2026-02-03T15:45:00.0000000' )
      ( po_id = '1000000011' vendor_name = 'Echo Technologies' total_amount = '1450.00' currency_code = 'USD' status = 'N' created_at = '2026-02-05T11:11:00.0000000' )
      ( po_id = '1000000012' vendor_name = 'Zeta Systems' total_amount = '6100.00' currency_code = 'USD' status = 'A' created_at = '2026-02-08T13:22:00.0000000' )
      ( po_id = '1000000013' vendor_name = 'Theta Innovations' total_amount = '23000.00' currency_code = 'USD' status = 'R' created_at = '2026-02-10T09:40:00.0000000' )
      ( po_id = '1000000014' vendor_name = 'Iota Supplies' total_amount = '450.00' currency_code = 'USD' status = 'N' created_at = '2026-02-12T14:00:00.0000000' )
      ( po_id = '1000000015' vendor_name = 'Kappa Corp' total_amount = '39000.00' currency_code = 'USD' status = 'A' created_at = '2026-02-15T16:00:00.0000000' )
      ( po_id = '1000000016' vendor_name = 'Lambda Services' total_amount = '7200.00' currency_code = 'USD' status = 'A' created_at = '2026-02-18T10:20:00.0000000' )
      ( po_id = '1000000017' vendor_name = 'Mu Electronics' total_amount = '15600.00' currency_code = 'USD' status = 'N' created_at = '2026-02-20T11:50:00.0000000' )
      ( po_id = '1000000018' vendor_name = 'Nu Workspace' total_amount = '2900.00' currency_code = 'USD' status = 'R' created_at = '2026-02-22T08:15:00.0000000' )
      ( po_id = '1000000019' vendor_name = 'Xi Cloud Partners' total_amount = '48000.00' currency_code = 'USD' status = 'A' created_at = '2026-02-25T13:00:00.0000000' )
      ( po_id = '1000000020' vendor_name = 'Omicron Retail' total_amount = '1100.00' currency_code = 'USD' status = 'N' created_at = '2026-02-28T15:30:00.0000000' )
      ( po_id = '1000000021' vendor_name = 'Pi Consulting' total_amount = '19000.00' currency_code = 'USD' status = 'A' created_at = '2026-03-02T09:30:00.0000000' )
      ( po_id = '1000000022' vendor_name = 'Rho Distribution' total_amount = '8400.00' currency_code = 'USD' status = 'R' created_at = '2026-03-05T10:40:00.0000000' )
      ( po_id = '1000000023' vendor_name = 'Sigma Global' total_amount = '67000.00' currency_code = 'USD' status = 'A' created_at = '2026-03-08T14:10:00.0000000' )
      ( po_id = '1000000024' vendor_name = 'Tau Logistics' total_amount = '3200.00' currency_code = 'USD' status = 'N' created_at = '2026-03-10T11:20:00.0000000' )
      ( po_id = '1000000025' vendor_name = 'Upsilon Tech' total_amount = '21000.00' currency_code = 'USD' status = 'A' created_at = '2026-03-12T16:00:00.0000000' )
      ( po_id = '1000000026' vendor_name = 'Phi Networks' total_amount = '9900.00' currency_code = 'USD' status = 'N' created_at = '2026-03-15T08:50:00.0000000' )
      ( po_id = '1000000027' vendor_name = 'Chi Industrial' total_amount = '41000.00' currency_code = 'USD' status = 'A' created_at = '2026-03-18T12:30:00.0000000' )
      ( po_id = '1000000028' vendor_name = 'Psi Dynamics' total_amount = '5400.00' currency_code = 'USD' status = 'R' created_at = '2026-03-20T10:15:00.0000000' )
      ( po_id = '1000000029' vendor_name = 'Omega Systems' total_amount = '89000.00' currency_code = 'USD' status = 'A' created_at = '2026-03-22T15:00:00.0000000' )
      ( po_id = '1000000030' vendor_name = 'Apex Solutions' total_amount = '1750.00' currency_code = 'USD' status = 'N' created_at = '2026-03-25T09:45:00.0000000' )
      ( po_id = '1000000031' vendor_name = 'Vertex Corp' total_amount = '13400.00' currency_code = 'USD' status = 'A' created_at = '2026-03-28T11:00:00.0000000' )
      ( po_id = '1000000032' vendor_name = 'Nexus Enterprise' total_amount = '26000.00' currency_code = 'USD' status = 'A' created_at = '2026-04-01T13:15:00.0000000' )
      ( po_id = '1000000033' vendor_name = 'Pioneer Goods' total_amount = '680.00' currency_code = 'USD' status = 'R' created_at = '2026-04-03T14:40:00.0000000' )
      ( po_id = '1000000034' vendor_name = 'Summit Partners' total_amount = '31000.00' currency_code = 'USD' status = 'N' created_at = '2026-04-05T10:00:00.0000000' )
      ( po_id = '1000000035' vendor_name = 'Vanguard Supply' total_amount = '9400.00' currency_code = 'USD' status = 'A' created_at = '2026-04-08T16:20:00.0000000' )
      ( po_id = '1000000036' vendor_name = 'Zenith Trading' total_amount = '42000.00' currency_code = 'USD' status = 'A' created_at = '2026-04-10T09:10:00.0000000' )
      ( po_id = '1000000037' vendor_name = 'Horizon Tech' total_amount = '5100.00' currency_code = 'USD' status = 'N' created_at = '2026-04-12T11:45:00.0000000' )
      ( po_id = '1000000038' vendor_name = 'Pinnacle Services' total_amount = '18900.00' currency_code = 'USD' status = 'R' created_at = '2026-04-15T13:50:00.0000000' )
      ( po_id = '1000000039' vendor_name = 'Cascade Distribution' total_amount = '76000.00' currency_code = 'USD' status = 'A' created_at = '2026-04-18T15:00:00.0000000' )
      ( po_id = '1000000040' vendor_name = 'Beacon Logistics' total_amount = '2300.00' currency_code = 'USD' status = 'N' created_at = '2026-04-20T08:30:00.0000000' )
      ( po_id = '1000000041' vendor_name = 'Meridian Global' total_amount = '14200.00' currency_code = 'USD' status = 'A' created_at = '2026-04-22T10:00:00.0000000' )
      ( po_id = '1000000042' vendor_name = 'Aegis Solutions' total_amount = '33000.00' currency_code = 'USD' status = 'A' created_at = '2026-04-25T12:15:00.0000000' )
      ( po_id = '1000000043' vendor_name = 'Catalyst Corp' total_amount = '910.00' currency_code = 'USD' status = 'R' created_at = '2026-04-28T14:30:00.0000000' )
      ( po_id = '1000000044' vendor_name = 'Dynamic Systems' total_amount = '27000.00' currency_code = 'USD' status = 'N' created_at = '2026-05-01T09:15:00.0000000' )
      ( po_id = '1000000045' vendor_name = 'Eclipse Networks' total_amount = '8300.00' currency_code = 'USD' status = 'A' created_at = '2026-05-03T11:00:00.0000000' )
      ( po_id = '1000000046' vendor_name = 'Frontier Tech' total_amount = '49000.00' currency_code = 'USD' status = 'A' created_at = '2026-05-06T13:40:00.0000000' )
      ( po_id = '1000000047' vendor_name = 'Genesis Supplies' total_amount = '4100.00' currency_code = 'USD' status = 'N' created_at = '2026-05-08T15:10:00.0000000' )
      ( po_id = '1000000048' vendor_name = 'Harbor Logistics' total_amount = '16700.00' currency_code = 'USD' status = 'R' created_at = '2026-05-10T10:20:00.0000000' )
      ( po_id = '1000000049' vendor_name = 'Infinite Ventures' total_amount = '61000.00' currency_code = 'USD' status = 'A' created_at = '2026-05-12T14:00:00.0000000' )
      ( po_id = '1000000050' vendor_name = 'Junction Trading' total_amount = '3500.00' currency_code = 'USD' status = 'N' created_at = '2026-05-15T16:00:00.0000000' ) ).

    " 2. Prepare Corresponding Item Records (Multi-items per PO)
    lt_items = VALUE #(
      ( po_id = '1000000001' item_id = '0010' material = 'LAPTOP-PRO-15' quantity = '2.000' unit = 'PC' )
      ( po_id = '1000000001' item_id = '0020' material = 'WIRELESS-MOUSE' quantity = '5.000' unit = 'PC' )
      ( po_id = '1000000002' item_id = '0010' material = 'CLOUD-SERVER-SUB' quantity = '1.000' unit = 'MON' )
      ( po_id = '1000000003' item_id = '0010' material = 'OFFICE-DESK' quantity = '2.000' unit = 'PC' )
      ( po_id = '1000000003' item_id = '0020' material = 'OFFICE-CHAIR' quantity = '4.000' unit = 'PC' )
      ( po_id = '1000000004' item_id = '0010' material = 'SAFETY-HELMET' quantity = '50.000' unit = 'PC' )
      ( po_id = '1000000004' item_id = '0020' material = 'STEEL-TOE-BOOTS' quantity = '20.000' unit = 'PAR' )
      ( po_id = '1000000005' item_id = '0010' material = 'PRINTER-PAPER' quantity = '10.000' unit = 'RM' )
      ( po_id = '1000000006' item_id = '0010' material = 'LOGISTICS-BOX' quantity = '100.000' unit = 'PC' )
      ( po_id = '1000000007' item_id = '0010' material = 'ENTERPRISE-LICENSE' quantity = '5.000' unit = 'EA' )
      ( po_id = '1000000008' item_id = '0010' material = 'MONITOR-27' quantity = '6.000' unit = 'PC' )
      ( po_id = '1000000009' item_id = '0010' material = 'KEYBOARD-MECH' quantity = '10.000' unit = 'PC' )
      ( po_id = '1000000010' item_id = '0010' material = 'SERVER-RACK' quantity = '2.000' unit = 'PC' )
      ( po_id = '1000000010' item_id = '0020' material = 'ETHERNET-CABLE' quantity = '50.000' unit = 'M'  )
      ( po_id = '1000000011' item_id = '0010' material = 'USB-C-HUB' quantity = '15.000' unit = 'PC' )
      ( po_id = '1000000012' item_id = '0010' material = 'OFFICE-SOFA' quantity = '1.000' unit = 'PC' )
      ( po_id = '1000000013' item_id = '0010' material = 'CONSULTING-HRS' quantity = '40.000' unit = 'H'  )
      ( po_id = '1000000014' item_id = '0010' material = 'STATIONERY-KIT' quantity = '5.000' unit = 'BOX' )
      ( po_id = '1000000015' item_id = '0010' material = 'INDUSTRIAL-FAN' quantity = '10.000' unit = 'PC' )
      ( po_id = '1000000016' item_id = '0010' material = 'LED-PROJECTOR' quantity = '2.000' unit = 'PC' )
      ( po_id = '1000000017' item_id = '0010' material = 'TABLET-TAB-PRO' quantity = '8.000' unit = 'PC' )
      ( po_id = '1000000018' item_id = '0010' material = 'WHITEBOARD' quantity = '3.000' unit = 'PC' )
      ( po_id = '1000000019' item_id = '0010' material = 'CLOUD-STORAGE' quantity = '12.000' unit = 'MON' )
      ( po_id = '1000000020' item_id = '0010' material = 'COFFEE-BEANS' quantity = '20.000' unit = 'KG' )
      ( po_id = '1000000021' item_id = '0010' material = 'AUDIT-SERVICES' quantity = '1.000' unit = 'EA' )
      ( po_id = '1000000022' item_id = '0010' material = 'PACKAGING-TAPE' quantity = '30.000' unit = 'PC' )
      ( po_id = '1000000023' item_id = '0010' material = 'GENERATOR-DIESEL' quantity = '1.000' unit = 'PC' )
      ( po_id = '1000000024' item_id = '0010' material = 'SAFETY-VEST' quantity = '25.000' unit = 'PC' )
      ( po_id = '1000000025' item_id = '0010' material = 'ROUTER-CISCO' quantity = '4.000' unit = 'PC' )
      ( po_id = '1000000026' item_id = '0010' material = 'SWITCH-MANAGED' quantity = '3.000' unit = 'PC' )
      ( po_id = '1000000027' item_id = '0010' material = 'FORKLIFT-BATTERY' quantity = '2.000' unit = 'PC' )
      ( po_id = '1000000028' item_id = '0010' material = 'FIRE-EXTINGUISHER' quantity = '10.000' unit = 'PC' )
      ( po_id = '1000000029' item_id = '0010' material = 'ENTERPRISE-ERP-MOD' quantity = '1.000' unit = 'EA' )
      ( po_id = '1000000030' item_id = '0010' material = 'DESK-LAMP' quantity = '15.000' unit = 'PC' )
      ( po_id = '1000000031' item_id = '0010' material = 'SCNER-DOCUMENT' quantity = '4.000' unit = 'PC' )
      ( po_id = '1000000032' item_id = '0010' material = 'WORKSTATION-PC' quantity = '5.000' unit = 'PC' )
      ( po_id = '1000000033' item_id = '0010' material = 'STAPLER-HEAVY' quantity = '12.000' unit = 'PC' )
      ( po_id = '1000000034' item_id = '0010' material = 'HVAC-UNIT' quantity = '2.000' unit = 'PC' )
      ( po_id = '1000000035' item_id = '0010' material = 'SECURITY-CAM' quantity = '8.000' unit = 'PC' )
      ( po_id = '1000000036' item_id = '0010' material = 'PALLET-JACK' quantity = '3.000' unit = 'PC' )
      ( po_id = '1000000037' item_id = '0010' material = 'SHREDDER-HEAVY' quantity = '2.000' unit = 'PC' )
      ( po_id = '1000000038' item_id = '0010' material = 'LEGAL-ADVISORY' quantity = '10.000' unit = 'H'  )
      ( po_id = '1000000039' item_id = '0010' material = 'CONVEYOR-BELT' quantity = '1.000' unit = 'PC' )
      ( po_id = '1000000040' item_id = '0010' material = 'BARCODE-SCANNER' quantity = '6.000' unit = 'PC' )
      ( po_id = '1000000041' item_id = '0010' material = 'UPS-BATTERY-BACKUP' quantity = '4.000' unit = 'PC' )
      ( po_id = '1000000042' item_id = '0010' material = 'SOLAR-PANEL-MOD' quantity = '20.000' unit = 'PC' )
      ( po_id = '1000000043' item_id = '0010' material = 'MARKER-SET' quantity = '50.000' unit = 'PK' )
      ( po_id = '1000000044' item_id = '0010' material = 'CONFERENCE-MIC' quantity = '4.000' unit = 'PC' )
      ( po_id = '1000000045' item_id = '0010' material = 'STORAGE-RACK' quantity = '10.000' unit = 'PC' )
      ( po_id = '1000000046' item_id = '0010' material = 'AUTOMATED-GATE' quantity = '1.000' unit = 'PC' )
      ( po_id = '1000000047' item_id = '0010' material = 'CLEANING-SUPPLIES' quantity = '15.000' unit = 'KIT' )
      ( po_id = '1000000048' item_id = '0010' material = 'CONTAINER-20FT' quantity = '1.000' unit = 'PC' )
      ( po_id = '1000000049' item_id = '0010' material = 'INDUSTRIAL-LASER' quantity = '2.000' unit = 'PC' )
      ( po_id = '1000000050' item_id = '0010' material = 'SAFETY-SIGNAGE' quantity = '30.000' unit = 'PC' )
    ).

    " Clear old rows and insert fresh data
    DELETE FROM ztb_po_hdr WHERE po_id LIKE @lv_pattern.
    DELETE FROM ztb_po_item WHERE po_id LIKE @lv_pattern.

    INSERT ztb_po_hdr FROM TABLE @lt_hdrs.
    INSERT ztb_po_item FROM TABLE @lt_items.

    IF sy-subrc = 0.
      out->write( 'Success: 50 Purchase Order Headers and corresponding Items inserted successfully!' ).
    ELSE.
      out->write( 'Error: Database seeding failed.' ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
