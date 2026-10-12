# P2P Analytics Engine – Architecture Overview

**Project**: `s4hana-p2p-analytics-engine`  
**Description**: Enterprise Procure-to-Pay (P2P) Engine with Analytics built on SAP S/4HANA CDS + AMDP + OData V4 + Fiori Elements (Chart & KPI) + full RAP transactional BO.  
**Last Updated**: October 12, 2026

## High-Level Object Tree

```
Package (DEVC)
└── Database Layer
    ├── ZTB_PO_HDR          (Transparent Table – Header)
    ├── ZTB_PO_ITEM         (Transparent Table – Item)
    ├── ZDT_PO_HDR_D        (Draft Table – Header)
    └── ZDT_PO_ITEM_D       (Draft Table – Item)

└── Interface Layer (Basic CDS)
    ├── ZI_ProcureOrder     (select from ZTB_PO_HDR)
    └── ZI_PoItem           (select from ZTB_PO_ITEM + parent association)

└── Composite / Business Object Layer
    └── ZI_ProcureOrderComp (Root View Entity)
        ├── composition [0..*] → ZI_PoItem (_POItem)
        ├── association [0..1] → ZC_VendorAnalytics (_VendorAnalytics)
        ├── association [0..1] → ZI_VENDOR01 (_Vendor)
        ├── Calculated fields:
        │   ├── status_text + status_criticality
        │   ├── order_tier + order_tier_criticality
        │   ├── discount_amount
        │   ├── vendor_name_upper
        │   └── po_summary_string

└── Analytics Layer (AMDP + Table Function)
    ├── ZTF_VendorAnalytics          (CDS Table Function)
    ├── ZCL_AMDP_VENDOR_ANALYTICS    (AMDP Class implementing the TF)
    ├── ZI_VendorAnalytics           (Interface wrapper on TF)
    └── ZC_VendorAnalytics           (Consumption View)

└── Consumption / UI Projection Layer
    ├── ZC_ProcureOrder              (Root Projection – transactional_query)
    │   ├── redirected composition child → ZC_PoItem01
    │   ├── association → _VendorAnalytics / _Vendor
    │   ├── @UI.chart (POByStatus + POByTier)
    │   ├── @UI.presentationVariant (ChartView / TableView / TierChartView)
    │   ├── @UI.dataPoint (Header KPIs: Status, Total Spend, Order Tier, Created)
    │   ├── Criticality colors on status & order_tier
    │   └── Value Helps (Vendor, Currency)
    └── ZC_PoItem01                  (Item Projection)

└── RAP Behavior Layer
    ├── ZI_ProcureOrderComp (BDEF)
    │   ├── managed + draft + early numbering
    │   ├── Determinations:
    │   │   ├── SetInitialStatus
    │   │   ├── CalculateOrderDefaults
    │   │   └── CalculateOrderTier (on modify of total_amount)
    │   ├── Validations:
    │   │   ├── ValidateTotalAmount
    │   │   ├── ValidateVendor
    │   │   ├── ValidateCurrency
    │   │   └── ValidateStatus
    │   ├── Actions (instance features):
    │   │   ├── setComplete
    │   │   ├── approveOrder
    │   │   ├── rejectOrder
    │   │   └── cancelOrder
    │   ├── Side Effects (real-time UI sync)
    │   └── implemented by ZBP_I_PROCUREORDERCOMP
    ├── ZC_ProcureOrder (BDEF Projection)
    └── Child determination on ZI_PoItem → recalculates header total

└── Service Layer
    └── ZUI_PROCUREORDER_O2          (OData V4 Service Definition)

└── Fiori Elements App
    └── app/procureorderanalysis
        ├── List Report with Chart ↔ Table toggle
        ├── Header KPIs (Status, Total Spend, Order Tier, Created)
        ├── Criticality colors
        └── Action buttons controlled by instance features

└── Learning / Practice
    └── ZCL_SYNTAX_PRACTICE
```

## Data Flow

1. **Persist** → Data stored in `ZTB_PO_HDR` + `ZTB_PO_ITEM` (drafts in `ZDT_*`)
2. **Interface** → Simple CDS views (`ZI_*`) expose the tables cleanly
3. **Composite** → `ZI_ProcureOrderComp` adds calculated fields, criticality, associations and defines the BO hierarchy via composition
4. **Analytics** → AMDP runs SQLScript on HANA, aggregates spend & risk, exposed via Table Function
5. **Consumption** → `ZC_*` projections add rich UI annotations (facets, search, charts, presentation variants, DataPoints, criticality, value helps)
6. **RAP Behavior** → Managed BO with draft, early numbering, determinations, validations, multiple lifecycle actions and side effects
7. **Service** → OData V4 service exposes the root + child entities + transactional operations
8. **Fiori App** → Hybrid analytical + transactional List Report / Object Page driven almost entirely by annotations + manifest

## Key Design Patterns Used

| Pattern | Where | Why |
|---------|-------|-----|
| **Root View Entity + Composition** | `ZI_ProcureOrderComp` | True Business Object hierarchy (Header → Items) |
| **Projection + Redirected to** | `ZC_ProcureOrder` / `ZC_PoItem01` | Separates UI concerns from business logic |
| **AMDP Table Function** | `ZTF_VendorAnalytics` + AMDP class | Heavy analytics pushed to HANA |
| **Early Numbering** | BDEF | Number range controlled PO IDs |
| **Determinations on modify/save** | BDEF | Auto-calculate tier, discount, defaults, totals |
| **Validations on save** | BDEF | Enforce business rules (amount, vendor, currency, status) |
| **Instance Feature Control + Actions** | BDEF + Implementation | Lifecycle actions with dynamic enablement |
| **Side Effects** | BDEF | Instant UI refresh of calculated fields & button states |
| **Criticality** | CDS + UI annotations | Color coding of status and order tier |
| **@UI.chart + PresentationVariant** | `ZC_ProcureOrder` | Multiple chart/table views |
| **@UI.dataPoint + Header Facets** | `ZC_ProcureOrder` | Rich header KPIs without custom coding |
| **Value Helps** | Consumption view | Vendor master + Currency |

## How to use these notes

Each Markdown file corresponds to one major ABAP object or a focused change set.  
Start from the bottom of the stack (tables) and move upwards, or jump via the links.

**Latest notes**:
- [[21-Latest-Enhancements-Oct2026]] – Full summary of October 2026 work
- [[19-RAP-Changes-Summary]] – Original RAP introduction (Sep 2026) – partially superseded
- [[20-UI-Chart-KPI-Changes]] – Original chart/KPI work (Sep 2026) – extended in latest enhancements
