CLASS lhc_poitem DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS CalculateTotalAmount FOR DETERMINE ON MODIFY
       keys FOR POItem~CalculateTotalAmount.

ENDCLASS.

CLASS lhc_poitem IMPLEMENTATION.

  METHOD CalculateTotalAmount.
    READ ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
      ENTITY POItem BY \_ProcureOrderComp
        FIELDS ( po_id )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    IF lt_headers IS INITIAL.
      RETURN.
    ENDIF.

    SORT lt_headers BY po_id.
    DELETE ADJACENT DUPLICATES FROM lt_headers COMPARING po_id.

    READ ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
      ENTITY PurchaseOrder BY \_POItem
        FIELDS ( net_amount )
        WITH CORRESPONDING #( lt_headers )
      RESULT DATA(lt_items).

    DATA lt_header_update TYPE TABLE FOR UPDATE ZI_ProcureOrderComp\\PurchaseOrder.

    LOOP AT lt_headers INTO DATA(ls_header).
      DATA(lv_total) = VALUE ztb_po_hdr-total_amount( ).

      LOOP AT lt_items INTO DATA(ls_item) USING KEY entity WHERE po_id = ls_header-po_id.
        lv_total = lv_total + ls_item-net_amount.
      ENDLOOP.

      APPEND VALUE #(
        %tky                  = ls_header-%tky
        total_amount          = lv_total
        %control-total_amount = if_abap_behv=>mk-on
      ) TO lt_header_update.
    ENDLOOP.

    IF lt_header_update IS NOT INITIAL.
      MODIFY ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
        ENTITY PurchaseOrder
          UPDATE FIELDS ( total_amount )
          WITH lt_header_update
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_reported).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_PurchaseOrder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    " Static session counter to prevent draft key collisions
    CLASS-DATA: gv_max_po TYPE int8.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR PurchaseOrder RESULT result.

    METHODS SetInitialStatus FOR DETERMINE ON SAVE
      IMPORTING keys FOR PurchaseOrder~SetInitialStatus.

    METHODS ValidateTotalAmount FOR VALIDATE ON SAVE
      IMPORTING keys FOR PurchaseOrder~ValidateTotalAmount.

    METHODS setComplete FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseOrder~setComplete RESULT result.
    METHODS CalculateOrderTier FOR DETERMINE ON MODIFY
      IMPORTING keys FOR PurchaseOrder~CalculateOrderTier.

    METHODS CalculateOrderDefaults FOR DETERMINE ON SAVE
       keys FOR PurchaseOrder~CalculateOrderDefaults.

    METHODS ValidateCurrency FOR VALIDATE ON SAVE
       keys FOR PurchaseOrder~ValidateCurrency.

    METHODS ValidateStatus FOR VALIDATE ON SAVE
       keys FOR PurchaseOrder~ValidateStatus.

    METHODS ValidateVendor FOR VALIDATE ON SAVE
       keys FOR PurchaseOrder~ValidateVendor.
    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR PurchaseOrder RESULT result.

    METHODS approveOrder FOR MODIFY
       keys FOR ACTION PurchaseOrder~approveOrder RESULT result.

    METHODS cancelOrder FOR MODIFY
       keys FOR ACTION PurchaseOrder~cancelOrder RESULT result.

    METHODS rejectOrder FOR MODIFY
       keys FOR ACTION PurchaseOrder~rejectOrder RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
       entities FOR CREATE PurchaseOrder.

ENDCLASS.

CLASS lhc_PurchaseOrder IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.


  METHOD SetInitialStatus.

    " Ensure status is populated right before saving to the database
    READ ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
      ENTITY PurchaseOrder
        FIELDS ( status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_purchase_orders).

    DATA: lt_update TYPE TABLE FOR UPDATE ZI_ProcureOrderComp\\PurchaseOrder.

    " 4. Populate the update table variable
    lt_update = VALUE #(
      FOR ls_po IN lt_purchase_orders
      ( %tky   = ls_po-%tky
        status = 'N'
        %control-status = if_abap_behv=>mk-on )
    ).

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
        ENTITY PurchaseOrder
          UPDATE FIELDS ( status )
          WITH lt_update
        REPORTED DATA(lt_reported)
        FAILED DATA(lt_failed).
    ENDIF.

  ENDMETHOD.

  METHOD ValidateTotalAmount.

    " 1. Read the purchase order instances being saved
    READ ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
      ENTITY PurchaseOrder
        FIELDS ( total_amount )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_purchase_orders).

    " 2. Loop and check business conditions
    LOOP AT lt_purchase_orders INTO DATA(ls_po).
      IF ls_po-total_amount <= 0.

        " Mark the instance as failed so the save is blocked
        INSERT VALUE #( %tky = ls_po-%tky ) INTO TABLE failed-purchaseorder.

        " Return a user-friendly error message to the Fiori UI
        INSERT VALUE #(
          %tky                  = ls_po-%tky
          %msg                  = new_message(
                                    id       = 'Z_PO_MSG'
                                    number   = '001'
                                    severity = if_abap_behv_message=>severity-error
                                    v1       = 'Total amount must be greater than zero' )
          %element-total_amount = if_abap_behv=>mk-on
        ) INTO TABLE reported-purchaseorder.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD setComplete.

    " 1. Update the status to complete ('C')
    MODIFY ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
      ENTITY PurchaseOrder
        UPDATE FIELDS ( status )
        WITH VALUE #( FOR key IN keys ( %tky   = key-%tky
                                        status = 'C' ) )
      REPORTED DATA(lt_reported)
      FAILED DATA(lt_failed).

    " 2. Read back the updated records to return the result parameter
    READ ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
      ENTITY PurchaseOrder
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_purchase_orders).

    " 3. Populate the result table so the UI knows which instances changed
    result = VALUE #( FOR po IN lt_purchase_orders
                      ( %tky   = po-%tky
                        %param = po ) ).

  ENDMETHOD.

  METHOD earlynumbering_create.
    " Initialize sequence once by checking BOTH active table and draft table
    IF gv_max_po IS INITIAL.
      DATA: lv_max_act   TYPE c LENGTH 10,
            lv_max_draft TYPE c LENGTH 10.
      SELECT MAX( po_id ) FROM ztb_po_hdr INTO @lv_max_act.
      SELECT MAX( po_id ) FROM zdt_po_hdr_d INTO @lv_max_draft.
      DATA(lv_highest) = COND #(
        WHEN lv_max_draft > lv_max_act THEN lv_max_draft
        ELSE lv_max_act ).
      IF lv_highest IS INITIAL OR lv_highest < '4500000000'.
        gv_max_po = 4500000000.
      ELSE.
        TRY.
            gv_max_po = CONV int8( lv_highest ).
          CATCH cx_root.
            gv_max_po = 4500000000.
        ENDTRY.
      ENDIF.
    ENDIF.
    DATA: lv_new_po TYPE ztb_po_hdr-po_id.
    " Assign unique sequential numbers ensuring complete contract mapping
    LOOP AT entities INTO DATA(entity).
      IF entity-po_id IS INITIAL.
        gv_max_po += 1.
        lv_new_po = |{ gv_max_po WIDTH = 10 ALIGN = RIGHT PAD = '0' }|.
      ELSE.
        lv_new_po = entity-po_id.
      ENDIF.
      APPEND VALUE #(
        %cid      = entity-%cid
        %is_draft = entity-%is_draft
        po_id     = lv_new_po
      ) TO mapped-purchaseorder.
    ENDLOOP.
  ENDMETHOD.

  METHOD CalculateOrderTier.
    "  Dynamic calculation handled by CDS view expressions; determination hook available for side effects
  ENDMETHOD.

  METHOD CalculateOrderDefaults.
    "  Populate default currency code ('USD') and created_at timestamp if missing
    READ ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
      ENTITY PurchaseOrder
        FIELDS ( currency_code created_at )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_purchase_orders).
    DATA: lt_update TYPE TABLE FOR UPDATE ZI_ProcureOrderComp\\PurchaseOrder.
    DATA ls_upd LIKE LINE OF lt_update.
    DATA(lv_timestamp) = utclong_current( ).
    LOOP AT lt_purchase_orders INTO DATA(ls_po).
      DATA(lv_needs_update) = abap_false.
      ls_upd-%tky = ls_po-%tky.
      IF ls_po-currency_code IS INITIAL.
        ls_upd-currency_code = 'USD'.
        ls_upd-%control-currency_code = if_abap_behv=>mk-on.
        lv_needs_update = abap_true.
      ENDIF.
      IF ls_po-created_at IS INITIAL.
        ls_upd-created_at = lv_timestamp.
        ls_upd-%control-created_at = if_abap_behv=>mk-on.
        lv_needs_update = abap_true.
      ENDIF.
      IF lv_needs_update = abap_true.
        APPEND ls_upd TO lt_update.
      ENDIF.
    ENDLOOP.
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
        ENTITY PurchaseOrder
          UPDATE FIELDS ( currency_code created_at )
          WITH lt_update
        REPORTED DATA(lt_reported)
        FAILED DATA(lt_failed).
    ENDIF.
  ENDMETHOD.

  METHOD ValidateCurrency.

    READ ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
      ENTITY PurchaseOrder
        FIELDS ( currency_code )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_purchase_orders).
    LOOP AT lt_purchase_orders INTO DATA(ls_po).
      IF ls_po-currency_code IS NOT INITIAL.
        DATA(lv_curr) = to_upper( ls_po-currency_code ).
        IF lv_curr <> 'USD' AND lv_curr <> 'EUR' AND lv_curr <> 'GBP' AND
           lv_curr <> 'JPY' AND lv_curr <> 'CAD' AND lv_curr <> 'INR' AND
           lv_curr <> 'CHF' AND lv_curr <> 'AUD'.
          APPEND VALUE #( %tky = ls_po-%tky ) TO failed-purchaseorder.
          APPEND VALUE #(
            %tky                   = ls_po-%tky
            %msg                   = new_message_with_text(
                                       severity = if_abap_behv_message=>severity-error
                                       text     = |Invalid currency code { ls_po-currency_code }| )
            %element-currency_code = if_abap_behv=>mk-on
          ) TO reported-purchaseorder.
        ENDIF.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD ValidateStatus.

    READ ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
      ENTITY PurchaseOrder
        FIELDS ( status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_purchase_orders).
    LOOP AT lt_purchase_orders INTO DATA(ls_po).
      IF ls_po-status <> 'N' AND ls_po-status <> 'A' AND
         ls_po-status <> 'R' AND ls_po-status <> 'C' AND
         ls_po-status <> 'X'.
        APPEND VALUE #( %tky = ls_po-%tky ) TO failed-purchaseorder.
        APPEND VALUE #(
          %tky            = ls_po-%tky
          %msg            = new_message_with_text(
                              severity = if_abap_behv_message=>severity-error
                              text     = |Invalid status code { ls_po-status }| )
          %element-status = if_abap_behv=>mk-on
        ) TO reported-purchaseorder.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD ValidateVendor.

    READ ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
      ENTITY PurchaseOrder
        FIELDS ( vendor_name )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_purchase_orders).
    LOOP AT lt_purchase_orders INTO DATA(ls_po).
      DATA(lv_vendor_trimmed) = condense( ls_po-vendor_name ).
      IF lv_vendor_trimmed IS INITIAL OR strlen( lv_vendor_trimmed ) < 3.
        APPEND VALUE #( %tky = ls_po-%tky ) TO failed-purchaseorder.
        APPEND VALUE #(
          %tky                 = ls_po-%tky
          %msg                 = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = 'Valid vendor name required (minimum 3 characters)' )
          %element-vendor_name = if_abap_behv=>mk-on
        ) TO reported-purchaseorder.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
      ENTITY PurchaseOrder
        FIELDS ( status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_purchase_orders).
    result = VALUE #(
      FOR ls_po IN lt_purchase_orders
      ( %tky = ls_po-%tky
        " Approve: Enabled only for New/Pending orders ('N')
        %features-%action-approveOrder = COND #(
          WHEN ls_po-status = 'N'
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled )
        " Reject: Enabled for New ('N') or Approved ('A') orders
        %features-%action-rejectOrder = COND #(
          WHEN ls_po-status = 'N' OR ls_po-status = 'A'
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled )
        " Cancel: Enabled for New ('N') or Approved ('A') orders
        %features-%action-cancelOrder = COND #(
          WHEN ls_po-status = 'N' OR ls_po-status = 'A'
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled )
       " Set Complete: Enabled ONLY for Approved orders ('A')
        %features-%action-setComplete = COND #(
          WHEN ls_po-status = 'A'
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled )
      )
    ).

  ENDMETHOD.

  METHOD approveOrder.

    MODIFY ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
      ENTITY PurchaseOrder
        UPDATE FIELDS ( status )
        WITH VALUE #( FOR key IN keys ( %tky   = key-%tky
                                        status = 'A' ) )
      REPORTED DATA(lt_reported)
      FAILED DATA(lt_failed).
    READ ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
      ENTITY PurchaseOrder
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_purchase_orders).
    result = VALUE #( FOR po IN lt_purchase_orders
                      ( %tky   = po-%tky
                        %param = po ) ).

  ENDMETHOD.

  METHOD cancelOrder.

    MODIFY ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
      ENTITY PurchaseOrder
        UPDATE FIELDS ( status )
        WITH VALUE #( FOR key IN keys ( %tky   = key-%tky
                                        status = 'X' ) )
      REPORTED DATA(lt_reported)
      FAILED DATA(lt_failed).
    READ ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
      ENTITY PurchaseOrder
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_purchase_orders).
    result = VALUE #( FOR po IN lt_purchase_orders
                      ( %tky   = po-%tky
                        %param = po ) ).

  ENDMETHOD.

  METHOD rejectOrder.

    MODIFY ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
      ENTITY PurchaseOrder
        UPDATE FIELDS ( status )
        WITH VALUE #( FOR key IN keys ( %tky   = key-%tky
                                        status = 'R' ) )
      REPORTED DATA(lt_reported)
      FAILED DATA(lt_failed).
    READ ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
      ENTITY PurchaseOrder
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_purchase_orders).
    result = VALUE #( FOR po IN lt_purchase_orders
                      ( %tky   = po-%tky
                        %param = po ) ).

  ENDMETHOD.

ENDCLASS.
