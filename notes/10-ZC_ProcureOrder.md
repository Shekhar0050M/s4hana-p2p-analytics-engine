# ZC_ProcureOrder

**Type**: CDS Root View Entity (Projection – transactional_query)  
**Layer**: Consumption / UI  
**File**: `src/zc_procureorder.ddls.asddls`

## Purpose
The main **UI projection** of the Purchase Order Business Object.  
Adds all Fiori Elements annotations (facets, line items, search, field groups, **chart**, **presentation variants**, and **DataPoint for KPI**) and redirects the composition to the item projection.

## Full Source Code

```abap
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view for Purchase Order'
@Metadata.ignorePropagatedAnnotations: true
//@Metadata.allowExtensions: true
@Search.searchable: true

@UI.headerInfo: {
    typeName: 'Purchase Order',
    typeNamePlural: 'Purchase Orders',
    title: { type: #STANDARD, value: 'po_id' },
    description: { type: #STANDARD, value: 'vendor_name' }
}

@UI.chart: [{
    qualifier: 'POByStatus',
    chartType: #COLUMN,
    dimensions: [ 'status_text' ],
    measures: [ 'total_amount' ],
    dimensionAttributes: [{
        dimension: 'status_text',
        role: #CATEGORY
    }],
    measureAttributes: [{
        measure: 'total_amount',
        role: #AXIS_1
    }]
}]

@UI.presentationVariant: [{
    qualifier: 'ChartView',
    text: 'Chart',
    visualizations: [{ type: #AS_CHART, qualifier: 'POByStatus' }]
},
{
    qualifier: 'TableView',
    text: 'Table',
    visualizations: [{ type: #AS_LINEITEM }]
}]

define root view entity ZC_ProcureOrder
  provider contract transactional_query
  as projection on ZI_ProcureOrderComp
{
      @UI.facet: [
        { id: 'HeaderDetails', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, label: 'General Information', position: 10 },
        { id: 'Financials',    purpose: #STANDARD, type: #FIELDGROUP_REFERENCE, targetQualifier: 'FinancialGroup', label: 'Financial Details', position: 20 },
        { id: 'ItemDetails',   purpose: #STANDARD, type: #LINEITEM_REFERENCE, label: 'Line Items', position: 30, targetElement: '_POItem' },
        { id: 'VendorAnalytics', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, label: 'Vendor Spend & Risk', position: 40, targetElement: '_VendorAnalytics' }
      ]

      @EndUserText.label: 'Purchase Order ID'
      @UI.lineItem: [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 10 }]
  key po_id,

      @EndUserText.label: 'Vendor Name'
      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      @UI.selectionField: [{ position: 20 }]
      @Search.defaultSearchElement: true
      vendor_name,

      vendor_name_upper,
      po_summary_string,

      @EndUserText.label: 'Total Amount'
      @Semantics.amount.currencyCode: 'currency_code'
      @UI.lineItem: [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      @UI.fieldGroup: [{ qualifier: 'FinancialGroup', position: 10 }]
      @UI.dataPoint: {
          qualifier: 'TotalSpendDataPoint',
          title: 'Total Purchase Spend'
      }
      total_amount,

      @EndUserText.label: 'Currency'
      @UI.lineItem: [{ position: 40 }]
      @UI.fieldGroup: [{ qualifier: 'FinancialGroup', position: 20 }]
      currency_code,

      @EndUserText.label: 'Status'
      @UI.lineItem: [{ position: 50 }]
      @UI.identification: [{ position: 50 },
                           { type: #FOR_ACTION, dataAction: 'setComplete', label: 'Set Complete' } ]
      @UI.selectionField: [{ position: 30 }]
      status,

      @EndUserText.label: 'Status Description'
      @UI.lineItem: [{ position: 60 }]
      status_text,

      @EndUserText.label: 'Order Tier'
      @UI.lineItem: [{ position: 70 }]
      order_tier,

      @EndUserText.label: 'Discount Amount'
      @Semantics.amount.currencyCode: 'currency_code'
      @UI.lineItem: [{ position: 80 }]
      @UI.fieldGroup: [{ qualifier: 'FinancialGroup', position: 30 }]
      discount_amount,

      @EndUserText.label: 'Created At'
      @UI.lineItem: [{ position: 90 }]
      created_at,

      /* Associations – this is the critical part */
      _POItem : redirected to composition child ZC_PoItem01,
      _VendorAnalytics
}
```

## Block-by-Block Explanation

### Provider Contract
```abap
provider contract transactional_query
```
- **Why**: Declares that this projection is intended for transactional (RAP) use, not pure analytical.  
- **Function**: Enables draft, CUD operations, etc.  
- **Relevance**: Required for modern RAP projections.

### Projection
```abap
as projection on ZI_ProcureOrderComp
```
- **Why**: Separates UI concerns from business logic.  
- **Function**: The projection can add, hide, or rename fields and add annotations without touching the composite.  
- **Relevance**: Core RAP design principle – never put UI annotations in the interface/composite layer.

### Chart Annotation (NEW – Sep 14, 2026)
```abap
@UI.chart: [{
    qualifier: 'POByStatus',
    chartType: #COLUMN,
    dimensions: [ 'status_text' ],
    measures: [ 'total_amount' ],
    dimensionAttributes: [{ dimension: 'status_text', role: #CATEGORY }],
    measureAttributes: [{ measure: 'total_amount', role: #AXIS_1 }]
}]
```
- **Why**: Enables an analytical chart visualization on the List Report without custom UI5 coding.  
- **Function**: Defines a column chart that groups by `status_text` and sums/measures `total_amount`.  
- **Relevance**: Turns the transactional List Report into a hybrid analytical view. The qualifier `POByStatus` is referenced by the presentation variant.

### Presentation Variants (NEW – Sep 14, 2026)
```abap
@UI.presentationVariant: [{
    qualifier: 'ChartView',
    text: 'Chart',
    visualizations: [{ type: #AS_CHART, qualifier: 'POByStatus' }]
},
{
    qualifier: 'TableView',
    text: 'Table',
    visualizations: [{ type: #AS_LINEITEM }]
}]
```
- **Why**: Provides two alternative ways to look at the same entity set (Chart vs Table).  
- **Function**:  
  - `ChartView` → renders the chart defined by `@UI.chart#POByStatus`  
  - `TableView` → standard line-item table  
- **Relevance**: Used by `quickVariantSelectionX` in the Fiori Elements `manifest.json` so the user can toggle between Chart and Table on the List Report.

### DataPoint / KPI (NEW – Sep 14, 2026)
```abap
@UI.dataPoint: {
    qualifier: 'TotalSpendDataPoint',
    title: 'Total Purchase Spend'
}
total_amount,
```
- **Why**: Marks `total_amount` as a KPI / DataPoint that can be shown as a prominent tile or header KPI.  
- **Function**: The qualifier `TotalSpendDataPoint` is referenced from the `kpis` section in `manifest.json`.  
- **Relevance**: Enables the “Total Purchase Spend” KPI card on the List Report page.

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
_POItem : redirected to composition child ZC_PoItem01,
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
- **Related UI config**: `app/procureorderanalysis/webapp/manifest.json` (quickVariantSelectionX + kpis)
- **See also**: [[20-UI-Chart-KPI-Changes]]

## Relevance
This is the view that the end user actually sees in the Fiori app.  
All UI behaviour (list, object page, search, facets, **chart toggle**, and **KPI tile**) is controlled from here + the manifest.
