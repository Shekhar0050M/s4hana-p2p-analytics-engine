# ZTB_PO_HDR

**Type**: Transparent Table (TABL)  
**Layer**: Database  
**File**: `src/ztb_po_hdr.tabl.xml`

## Purpose
Primary persistence table for Purchase Order **header** data.  
This is the single source of truth for PO header attributes (vendor, total amount, status, creation timestamp).

## Source (relevant structure)

```xml
<TABNAME>ZTB_PO_HDR</TABNAME>
<TABCLASS>TRANSP</TABCLASS>
<CLIDEP>X</CLIDEP>          <!-- Client-dependent -->
<DDTEXT>Purchase Order Header Table</DDTEXT>
```

### Fields

| Field          | Key | Data Type     | Length | Description                  | Relevance |
|----------------|-----|---------------|--------|------------------------------|---------|
| CLIENT         | X   | CLNT          | 3      | Client                       | Mandatory for client-dependent tables |
| PO_ID          | X   | CHAR          | 10     | Purchase Order ID            | Primary business key |
| VENDOR_NAME    |     | CHAR          | 80     | Vendor Name                  | Free-text vendor identifier |
| TOTAL_AMOUNT  |     | CURR          | 13,2   | Total Amount                 | Amount field → references CURRENCY_CODE |
| CURRENCY_CODE  |     | CUKY          | 5      | Currency Code               | Currency key for TOTAL_AMOUNT |
| STATUS         |     | CHAR          | 20     | Status                       | Simple status code (A/N/R…) |
| CREATED_AT     |     | UTCLONG       | 27     | Creation Timestamp           | Precise UTC timestamp |

## Why this design?

- **Transparent table** → classic ABAP dictionary table, fully supported by CDS `select from`.
- **Client-dependent** (`CLIDEP = X`) → standard multi-tenant isolation.
- **Currency + Amount pair** → required so that CDS can correctly apply `@Semantics.amount.currencyCode`.
- **UTCLONG** for `CREATED_AT` → modern, timezone-independent timestamp (preferred over TIMESTAMP / DATS+TIMS).

## Linked Objects
- **Consumed by**: [[02-ZI_ProcureOrder]] (basic CDS view)
- **Also used by**: AMDP class `ZCL_AMDP_VENDOR_ANALYTICS` (direct SQL access for aggregation)

## Relevance in the overall architecture
This table is the foundation of the entire P2P header data model.  
All higher-layer CDS views ultimately read from here (directly or indirectly).  
The AMDP analytics also reads this table to calculate vendor-level spend and risk.
