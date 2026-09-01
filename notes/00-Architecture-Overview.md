# P2P Analytics Engine – Architecture Overview

**Project**: `s4hana-p2p-analytics-engine`  
**Description**: Enterprise Procure-to-Pay (P2P) Engine with Analytics built on SAP S/4HANA CDS + AMDP + OData V4.

## High-Level Object Tree

```
Package (DEVC)
└── Database Layer
    ├── ZTB_PO_HDR          (Transparent Table – Header)
    └── ZTB_PO_ITEM         (Transparent Table – Item)
└── Interface Layer (Basic CDS)
    ├── ZI_ProcureOrder     (select from ZTB_PO_HDR)
    └── ZI_PoItem           (select from ZTB_PO_ITEM + parent association)
└── Composite / Business Object Layer
    └── ZI_ProcureOrderComp (Root View Entity)
        ├── composition [0..*] → ZI_PoItem (_POItem)
        └── association [0..1] → ZC_VendorAnalytics (_VendorAnalytics)
└── Analytics Layer (AMDP + Table Function)
    ├── ZTF_VendorAnalytics          (CDS Table Function)
    ├── ZCL_AMDP_VENDOR_ANALYTICS    (AMDP Class implementing the TF)
    ├── ZI_VendorAnalytics           (Interface wrapper on TF)
    └── ZC_VendorAnalytics           (Consumption View)
└── Consumption / UI Projection Layer
    ├── ZC_ProcureOrder              (Root Projection – transactional_query)
    │   ├── redirected composition child → ZC_PoItem01
    │   └── association → _VendorAnalytics
    └── ZC_PoItem01                  (Item Projection)
└── Service Layer
    └── ZUI_PROCUREORDER_O2          (OData V4 Service Definition)
└── Learning / Practice
    └── ZCL_SYNTAX_PRACTICE          (Modern ABAP syntax playground)
```

## Data Flow

1. **Persist** → Data stored in `ZTB_PO_HDR` + `ZTB_PO_ITEM`
2. **Interface** → Simple CDS views (`ZI_*`) expose the tables cleanly
3. **Composite** → `ZI_ProcureOrderComp` adds calculated fields + defines the BO hierarchy via **composition**
4. **Analytics** → AMDP runs SQLScript on HANA, aggregates spend & risk, exposed via Table Function
5. **Consumption** → `ZC_*` projections add UI annotations, facets, search, and redirect associations for the Fiori Elements / RAP UI
6. **Service** → OData V4 service exposes the root + child entities

## Key Design Patterns Used

| Pattern | Where | Why |
|---------|-------|-----|
| **Root View Entity + Composition** | `ZI_ProcureOrderComp` | Creates a true Business Object hierarchy (Header → Items) |
| **Projection + Redirected to** | `ZC_ProcureOrder` / `ZC_PoItem01` | Separates UI concerns from business logic (RAP best practice) |
| **AMDP Table Function** | `ZTF_VendorAnalytics` + AMDP class | Heavy analytics logic pushed to HANA database layer |
| **Association to Analytics** | From composite to `ZC_VendorAnalytics` | Allows side-panel / facet showing vendor risk without changing BO |
| **UI Annotations + Facets** | Consumption views | Zero-code Fiori Elements List Report + Object Page |

## How to use these notes

Each Markdown file corresponds to **one ABAP object**.  
Inside every file you will find:

- Purpose
- Full source code
- Line-by-line / block-by-block explanation (Why used, Function, Relevance)
- Linked objects (the tree edges)

Start reading from the bottom of the stack (tables) and move upwards, or jump via the links.
