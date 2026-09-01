# ZI_ProcureOrderComp

**Type**: CDS Root View Entity (Composite)  
**Layer**: Business Object / Composite  
**File**: `src/zi_procureordercomp.ddls.asddls`

## Purpose
This is the **heart of the Business Object**.  
It:
1. Selects from the basic interface view
2. Adds calculated / derived fields
3. Declares the **composition** to items
4. Declares an **association** to the analytics view

## Full Source Code

```abap
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Composite view for Purchase Order'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZI_ProcureOrderComp
  as select from ZI_ProcureOrder
  composition [0..*] of ZI_PoItem as _POItem
  association [0..1] to ZC_VendorAnalytics as _VendorAnalytics 
    on $projection.po_id = _VendorAnalytics.vendor_id
{

  key po_id,
      vendor_name,

      upper( vendor_name )                                                                                  as vendor_name_upper,
      concat_with_space( po_id, vendor_name, 1 )                                                            as po_summary_string,

      @Semantics.amount.currencyCode: 'currency_code'
      total_amount,
      currency_code,

      status,

      case status
        when 'A' then 'Approved'
        when 'N' then 'New / Pending'
        when 'R' then 'Rejected'
        else 'Unknown Status'
      end                                                                                                   as status_text,

      case
        when total_amount >= 50000.00 then 'HIGH VALUE'
        when total_amount between 10000.00 and 49999.99 then 'MEDIUM VALUE'
        else 'STANDARD'
      end                                                                                                   as order_tier,

      @Semantics.amount.currencyCode: 'currency_code'
      cast( get_numeric_value( total_amount ) / 10 as abap.dec( 13, 2 ) ) * cast( 0.1 as abap.dec( 3, 2 ) ) as discount_amount,

      created_at,

      _POItem,
      _VendorAnalytics
}
```

## Block-by-Block Explanation

### Root + Composition
```abap
define root view entity ZI_ProcureOrderComp
  as select from ZI_ProcureOrder
  composition [0..*] of ZI_PoItem as _POItem
```
- **`define root view entity`**  
  Why: Marks this view as the root of a Business Object.  
  Function: Enables transactional processing, draft, and composition handling in RAP.  
  Relevance: Mandatory for a RAP BO.

- **`composition [0..*] of ZI_PoItem as _POItem`**  
  Why: Creates a strong parent-child relationship (ownership).  
  Function: When the parent is deleted, children are deleted; the runtime manages the hierarchy.  
  Relevance: This is the modern replacement for classic “header-item” foreign-key relationships in RAP.

### Association to Analytics
```abap
association [0..1] to ZC_VendorAnalytics as _VendorAnalytics 
  on $projection.po_id = _VendorAnalytics.vendor_id
```
- Why: We want to show vendor risk/spend next to the PO without making analytics part of the transactional BO.  
- Function: Soft link (association) instead of composition.  
- Relevance: Allows a side-panel / facet in the UI that shows analytics data.

### Calculated Fields

#### 1. String functions
```abap
upper( vendor_name ) as vendor_name_upper,
concat_with_space( po_id, vendor_name, 1 ) as po_summary_string,
```
- **Why used**: Demonstrate CDS string functions.  
- **Function**: `upper()` converts to uppercase; `concat_with_space()` concatenates with a space.  
- **Relevance**: Useful for search, display labels, or derived keys.

#### 2. Status text (CASE)
```abap
case status
  when 'A' then 'Approved'
  when 'N' then 'New / Pending'
  when 'R' then 'Rejected'
  else 'Unknown Status'
end as status_text,
```
- **Why**: Convert technical codes into human-readable text.  
- **Function**: Simple conditional expression evaluated on the database.  
- **Relevance**: Classic pattern for status description fields in CDS.

#### 3. Order Tier (nested CASE)
```abap
case
  when total_amount >= 50000.00 then 'HIGH VALUE'
  when total_amount between 10000.00 and 49999.99 then 'MEDIUM VALUE'
  else 'STANDARD'
end as order_tier,
```
- **Why**: Business classification based on value.  
- **Function**: Range-based CASE.  
- **Relevance**: Shows how to implement simple business rules inside CDS.

#### 4. Discount calculation
```abap
cast( get_numeric_value( total_amount ) / 10 as abap.dec( 13, 2 ) ) 
  * cast( 0.1 as abap.dec( 3, 2 ) ) as discount_amount,
```
- **Why**: Example of numeric calculation + type casting.  
- **Function**:  
  - `get_numeric_value()` extracts the pure number from a currency field.  
  - Division by 10 → 10 % of the amount.  
  - Multiplication by 0.1 is just an additional example of casting.  
- **Relevance**: Demonstrates how to safely calculate with currency amounts inside CDS.

### Exposure of associations
```abap
_POItem,
_VendorAnalytics
```
Must be listed so that higher layers (projections) can redirect or use them.

## Linked Objects
- **From**: [[03-ZI_ProcureOrder]]
- **Composition child**: [[04-ZI_PoItem]]
- **Association target**: [[09-ZC_VendorAnalytics]]
- **Projected by**: [[10-ZC_ProcureOrder]]

## Relevance
This is the **single most important object** in the project.  
Everything above it (UI projections, OData service) is just a thin layer on top of this composite root.
