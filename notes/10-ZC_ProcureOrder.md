# ZC_ProcureOrder

**Type**: CDS Root View Entity (Projection – transactional_query)  
**Layer**: Consumption / UI  
**File**: `src/zc_procureorder.ddls.asddls`

## Purpose
The main **UI projection** of the Purchase Order Business Object.  
Adds all Fiori Elements annotations (facets, line items, search, field groups) and redirects the composition to the item projection.

## Full Source Code

```abap
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view for Purchase Order'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true

@UI.headerInfo: {
    typeName: 'Purchase Order',
    typeNamePlural: 'Purchase Orders',
    title: { type: #STANDARD, value: 'po_id' },
    description: { type: #STANDARD, value: 'vendor_name' }
}

define root view entity ZC_ProcureOrder
  provider contract transactional_query
  as projection on ZI_ProcureOrderComp
{
  @UI.facet: [
    { id: 'HeaderDetails', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, 
      label: 'General Information', position: 10 },
    { id: 'Financials',    purpose: #STANDARD, type: #FIELDGROUP_REFERENCE, 
      targetQualifier: 'FinancialGroup', label: 'Financial Details', position: 20 },
    { id: 'ItemDetails',   purpose: #STANDARD, type: #LINEITEM_REFERENCE, 
      label: 'Line Items', position: 30, targetElement: '_POItem' },
    { id: 'VendorAnalytics', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, 
      label: 'Vendor Spend & Risk', position: 40, targetElement: '_VendorAnalytics' }
  ]

  @UI.lineItem: [{ position: 10, label: 'Purchase Order ID' }]
  @UI.identification: [{ position: 10, label: 'Purchase Order ID' }]
  @UI.selectionField: [{ position: 10 }]
  @Search.defaultSearchElement: true
  key po_id,

  @UI.lineItem: [{ position: 20, label: 'Vendor Name' }]
  @UI.identification: [{ position: 20, label: 'Vendor Name' }]
  @UI.selectionField: [{ position: 20 }]
  @Search.defaultSearchElement: true
  vendor_name,

  vendor_name_upper,
  po_summary_string,

  @Semantics.amount.currencyCode: 'currency_code'
  @UI.lineItem: [{ position: 30, label: 'Total Amount' }]
  @UI.identification: [{ position: 30, label: 'Total Amount' }]
  @UI.fieldGroup: [{ qualifier: 'FinancialGroup', position: 10, label: 'Total Amount' }]
  total_amount,

  @UI.lineItem: [{ position: 40, label: 'Currency' }]
  @UI.fieldGroup: [{ qualifier: 'FinancialGroup', position: 20, label: 'Currency' }]
  currency_code,

  @UI.lineItem: [{ position: 50, label: 'Status' }]
  @UI.identification: [{ position: 50, label: 'Status Code' }]
  @UI.selectionField: [{ position: 30 }]
  status,

  @UI.lineItem: [{ position: 60, label: 'Status Description' }]
  status_text,

  @UI.lineItem: [{ position: 70, label: 'Order Tier' }]
  order_tier,

  @Semantics.amount.currencyCode: 'currency_code'
  @UI.lineItem: [{ position: 80, label: 'Discount Amount' }]
  @UI.fieldGroup: [{ qualifier: 'FinancialGroup', position: 30, label: 'Calculated Discount' }]
  discount_amount,

  @UI.lineItem: [{ position: 90, label: 'Created At' }]
  created_at,

  /* Associations – this is the critical part */
  _POItem: redirected to composition child ZC_PoItem01,
  _VendorAnalytics
}
```

## Block-by-Block Explanation

### Provider Contract
```abap
provider contract transactional_query
```
- **Why**: Declares that this projection is intended for transactional (RAP) use, not pure analytical.  
- **Function**: Enables draft, CUD operations, etc. (even if not fully implemented yet).  
- **Relevance**: Required for modern RAP projections.

### Projection
```abap
as projection on ZI_ProcureOrderComp
```
- **Why**: Separates UI concerns from business logic.  
- **Function**: The projection can add, hide, or rename fields and add annotations without touching the composite.  
- **Relevance**: Core RAP design principle – never put UI annotations in the interface/composite layer.

### Facets (Object Page layout)
```abap
@UI.facet: [
  { id: 'HeaderDetails', type: #IDENTIFICATION_REFERENCE, ... },
  { id: 'Financials',    type: #FIELDGROUP_REFERENCE, targetQualifier: 'FinancialGroup', ... },
  { id: 'ItemDetails',   type: #LINEITEM_REFERENCE, targetElement: '_POItem', ... },
  { id: 'VendorAnalytics', type: #IDENTIFICATION_REFERENCE, targetElement: '_VendorAnalytics', ... }
]
```
- **Why**: Defines the sections (tabs / groups) on the Fiori Object Page.  
- **Function**:  
  - `#IDENTIFICATION_REFERENCE` → shows fields annotated with `@UI.identification`  
  - `#FIELDGROUP_REFERENCE` → shows fields belonging to a specific field group  
  - `#LINEITEM_REFERENCE` → shows a table of related entities  
- **Relevance**: This is how you design a rich Object Page without writing a single line of UI5 code.

### Search
```abap
@Search.searchable: true
@Search.defaultSearchElement: true   (on po_id and vendor_name)
```
- **Why**: Enables the standard Fiori search bar.  
- **Function**: Marks the whole entity as searchable and chooses which fields participate in free-text search.  
- **Relevance**: Instant search capability.

### Critical Redirect
```abap
_POItem: redirected to composition child ZC_PoItem01,
```
- **Why**: The composition was defined on the interface/composite layer pointing to `ZI_PoItem`.  
  In the UI layer we want the *projection* of the item (`ZC_PoItem01`) instead.  
- **Function**: Redirects the association target.  
- **Relevance**: This is the standard RAP pattern that keeps the BO hierarchy consistent across layers.

## Linked Objects
- **Projection on**: [[05-ZI_ProcureOrderComp]]
- **Composition child**: [[11-ZC_PoItem01]]
- **Association**: [[09-ZC_VendorAnalytics]]
- **Exposed by**: [[12-ZUI_PROCUREORDER_O2]]

## Relevance
This is the view that the end user actually sees in the Fiori app.  
All UI behaviour (list, object page, search, facets) is controlled from here.
