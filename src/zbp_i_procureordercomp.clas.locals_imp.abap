CLASS lhc_PurchaseOrder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR PurchaseOrder RESULT result.

    METHODS SetInitialStatus FOR DETERMINE ON SAVE
      IMPORTING keys FOR PurchaseOrder~SetInitialStatus.

    METHODS ValidateTotalAmount FOR VALIDATE ON SAVE
      IMPORTING keys FOR PurchaseOrder~ValidateTotalAmount.

    METHODS setComplete FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseOrder~setComplete RESULT result.

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

ENDCLASS.
