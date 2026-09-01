# ZTB_PO_ITEM

**Type**: Transparent Table (TABL)  
**Layer**: Database  
**File**: `src/ztb_po_item.tabl.xml`

## Purpose
Persistence table for Purchase Order **line items**.  
One header (`ZTB_PO_HDR`) can have many items.

## Fields

| Field     | Key | Data Type | Length | Description          | Relevance |
|-----------|-----|-----------|--------|----------------------|---------|
| CLIENT    | X   | CLNT      | 3      | Client               | Client isolation |
| PO_ID     | X   | CHAR      | 10     | Purchase Order ID    | Foreign key to header |
| ITEM_ID   | X   | NUMC      | 4      | Item Number          | Part of composite key |
| MATERIAL  |     | CHAR      | 40     | Material / Product   | What is being ordered |
| QUANTITY  |     | QUAN      | 13,3   | Quantity             | Quantity field → references UNIT |
| UNIT      |     | UNIT      | 3      | Unit of Measure      | UoM for QUANTITY |

## Why this design?

- **Composite primary key** (`CLIENT + PO_ID + ITEM_ID`) → classic SAP item table pattern.
- **Quantity + Unit pair** → required for `@Semantics.quantity.unitOfMeasure` annotation later.
- No amount fields on item level in this simplified model (all value is kept on header for demo purposes).

## Linked Objects
- **Consumed by**: [[03-ZI_PoItem]]
- **Parent relationship**: Linked via `PO_ID` to [[01-ZTB_PO_HDR]]

## Relevance
Enables the classic Header–Item relationship that is later modelled as a **composition** in the CDS BO (`ZI_ProcureOrderComp`).
