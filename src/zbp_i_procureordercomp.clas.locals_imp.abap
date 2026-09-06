CLASS lhc_PurchaseOrder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR PurchaseOrder RESULT result.

    METHODS SetInitialStatus FOR DETERMINE ON SAVE
      IMPORTING keys FOR PurchaseOrder~SetInitialStatus.

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

ENDCLASS.
