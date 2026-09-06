# Draft Tables

**Type**: Transparent Tables (generated / maintained for RAP Draft)  
**Layer**: Persistence – Draft  
**Files**:
- `src/zdt_po_hdr_d.tabl.xml` → `ZDT_PO_HDR_D`
- `src/zdt_po_item_d.tabl.xml` → `ZDT_PO_ITEM_D`

## Purpose
Temporary storage for draft (unsaved) versions of Purchase Order Header and Item.  
When a user clicks **Edit**, the current active data is copied into the draft table.  
On **Activate** the draft is moved back to the persistent table; on **Discard** it is deleted.

## Header Draft – ZDT_PO_HDR_D

- **DDTEXT**: Draft table for entity ZI_PROCUREORDERCOMP
- Contains all fields of the CDS entity (including calculated ones that RAP stores for draft consistency):
  - `MANDT`, `PO_ID`
  - `VENDOR_NAME`, `VENDOR_NAME_UPPER`, `PO_SUMMARY_STRING`
  - `TOTAL_AMOUNT`, `CURRENCY_CODE`
  - `STATUS`, `STATUS_TEXT`, `ORDER_TIER`, `DISCOUNT_AMOUNT`
  - `CREATED_AT`
  - Plus technical draft administration fields (automatically added by RAP)

## Item Draft – ZDT_PO_ITEM_D

- **DDTEXT**: Draft table for entity ZI_POITEM
- Contains:
  - `MANDT`, `PO_ID`, `ITEM_ID`
  - `MATERIAL`, `QUANTITY`, `UNIT`
  - Plus draft administration fields

## Why Draft Tables are needed

| Feature | Without Draft | With Draft |
|---------|---------------|------------|
| Edit existing document | Changes are written immediately | User can cancel without side-effects |
| Create new document | Must save incomplete data | Can work on incomplete data safely |
| Concurrent editing | Harder to handle | Lock + ETag + draft isolation |
| Fiori Elements | Limited | Full draft-enabled Object Page |

## Linked Objects
- Referenced in [[15-ZI_ProcureOrderComp-BDEF]] via:
  ```abap
  draft table zdt_po_hdr_d
  draft table zdt_po_item_d
  ```
- Used by the draft actions: Edit, Activate, Discard, Resume, Prepare

## Relevance
Draft is a core RAP capability that makes the Fiori Elements Object Page behave like a modern transactional UI (similar to classic BOPF draft or SAPUI5 Smart Templates with draft).
