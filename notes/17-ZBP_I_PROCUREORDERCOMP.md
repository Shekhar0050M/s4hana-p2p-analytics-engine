# ZBP_I_PROCUREORDERCOMP – Behavior Implementation

**Type**: Behavior Implementation Class (RAP Handler)  
**Layer**: RAP Business Logic  
**Files**:
- `src/zbp_i_procureordercomp.clas.abap` (definition – empty)
- `src/zbp_i_procureordercomp.clas.locals_imp.abap` (actual logic)

## Purpose
Contains the ABAP implementation of:
- Determination `SetInitialStatus`
- Validation `ValidateTotalAmount`
- Action `setComplete`
- Global authorization (stub)

## Class Skeleton

```abap
CLASS zbp_i_procureordercomp DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zi_procureordercomp.
ENDCLASS.

CLASS zbp_i_procureordercomp IMPLEMENTATION.
ENDCLASS.
```
The real logic lives in the local class `lhc_PurchaseOrder` inside `locals_imp.abap`.

## Local Handler Class – Full Source

```abap
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
```

### 1. Determination – SetInitialStatus

```abap
METHOD SetInitialStatus.
  READ ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
    ENTITY PurchaseOrder
      FIELDS ( status )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_purchase_orders).

  DATA: lt_update TYPE TABLE FOR UPDATE ZI_ProcureOrderComp\\PurchaseOrder.

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
```

**Why used**  
New POs must start with status `'N'` (New / Pending).

**Function**  
1. Read the instances being saved.  
2. Build an update table that sets `status = 'N'`.  
3. Modify the transactional buffer (still in local mode).

**Relevance**  
Classic “default value on create” pattern implemented as a determination.

### 2. Validation – ValidateTotalAmount

```abap
METHOD ValidateTotalAmount.
  READ ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
    ENTITY PurchaseOrder
      FIELDS ( total_amount )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_purchase_orders).

  LOOP AT lt_purchase_orders INTO DATA(ls_po).
    IF ls_po-total_amount <= 0.
      INSERT VALUE #( %tky = ls_po-%tky ) INTO TABLE failed-purchaseorder.

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
```

**Why used**  
Business rule: a PO cannot be saved with zero or negative total amount.

**Function**  
- Marks the instance as failed → save is blocked.  
- Returns a message that appears on the UI next to the `total_amount` field.

**Relevance**  
Standard RAP validation pattern (failed + reported).

### 3. Action – setComplete

```abap
METHOD setComplete.
  " 1. Update status to 'C'
  MODIFY ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
    ENTITY PurchaseOrder
      UPDATE FIELDS ( status )
      WITH VALUE #( FOR key IN keys ( %tky   = key-%tky
                                      status = 'C' ) )
    REPORTED DATA(lt_reported)
    FAILED DATA(lt_failed).

  " 2. Read back the updated records
  READ ENTITIES OF ZI_ProcureOrderComp IN LOCAL MODE
    ENTITY PurchaseOrder
      ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_purchase_orders).

  " 3. Fill the result parameter
  result = VALUE #( FOR po IN lt_purchase_orders
                    ( %tky   = po-%tky
                      %param = po ) ).
ENDMETHOD.
```

**Why used**  
Provides a business action “Set Complete” that the user can trigger from the UI.

**Function**  
1. Changes status to `'C'`.  
2. Returns the updated entity so the UI can refresh the instance.

**Relevance**  
Shows how to implement a custom action with a result parameter (`result [1] $self`).

### 4. Global Authorization (stub)
```abap
METHOD get_global_authorizations.
ENDMETHOD.
```
Currently empty – all operations are allowed. In productive code you would check authority objects here.

## Linked Objects
- **Called from**: [[15-ZI_ProcureOrderComp-BDEF]]
- **Exposed via**: [[16-ZC_ProcureOrder-BDEF]]
- **UI button** appears in [[10-ZC_ProcureOrder]] via `@UI.identification` with `type: #FOR_ACTION`

## Relevance
This is where the real business logic of the RAP BO lives.  
All determinations, validations and actions are implemented here using the modern EML (Entity Manipulation Language) statements `READ ENTITIES` / `MODIFY ENTITIES`.
