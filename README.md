# Salesforce Contact Summary Solution

This repository contains a solution for a Salesforce take-home assignment. The primary goal is to implement a feature that maintains a record of the number of Contacts, grouped by Contact Type and State, for each Account. The solution is designed to be triggered manually from an Account record page.

This project demonstrates a deep understanding of Salesforce development best practices, including hybrid solution architecture (Flow + Apex, LWC + Apex), object and field design, error handling, and modern development using Salesforce DX.

## Table of Contents

- [Features](#features)
- [Architecture Overview](#architecture-overview)
- [Metadata Components](#metadata-components)
- [Setup and Deployment](#setup-and-deployment)
  - [Prerequisites](#prerequisites)
  - [Deployment Steps](#deployment-steps)
  - [Post-Deployment Steps](#post-deployment-steps)
- [How to Use](#how-to-use)
- [Technical Decisions and Trade-offs](#technical-decisions-and-trade-offs)
  - [Flow vs. LWC Implementation](#flow-vs-lwc-implementation)
  - [Error Handling Strategy](#error-handling-strategy)
  - [Data Model Design](#data-model-design)

## Features

- A custom button on the Account record page that launches a summary screen.
- The screen displays a table of aggregated Contact counts, grouped by unique combinations of Contact Type and State.
- Users can select multiple rows from this table.
- Based on the user's selection, `Contact_Summary__c` records are created or updated.
- A validation rule on `Contact_Summary__c` prevents the `Contact_Count__c` from exceeding 5.
- Robust error handling ensures that any validation errors are caught and clearly displayed to the user.

## Architecture & Design Decisions

This solution's architecture was carefully designed to be robust, scalable, and maintainable, demonstrating an understanding of both declarative and programmatic development paradigms on the Salesforce platform.

### Dual Implementation: Flow vs. LWC

To showcase versatility and analyze trade-offs, the core user-facing feature was built using two different methods:

1.  **Screen Flow + Invocable Apex:**
    - **Alignment with Client Needs:** This approach was developed first to honor the client's preference for declarative tools. The goal was to provide a solution where they could potentially maintain parts of the logic (e.g., screen text, simple conditional visibility) themselves in the future.
    - **Technical Observations:** To display dynamic, non-SObject data from Apex in the standard `Data Table` component, certain platform limitations were encountered. This required a more complex implementation involving a **"transformation" pattern** within the Flow (transforming Apex-Defined types to in-memory SObject records and back again) to serve as a workaround. While fully functional, this adds a layer of complexity to the Flow's design.

2.  **Lightning Web Component (LWC):**
-   - **Developer Experience & UI/UX:** The LWC approach offers a more direct and streamlined development experience. It communicates directly with Apex via `@AuraEnabled` methods, eliminating the need for complex Invocable wrappers and in-flow data transformations.
-   - **Outcome:** The result is a cleaner, more intuitive, and highly user-friendly module with superior control over the UI, error handling, and overall user experience. It provides a seamless, single-page application feel within the modal window.
-   
### Backend: A Bulkified, Reusable Apex Service

A key design decision was to build the core logic in a **reusable and bulk-safe Apex service layer** (`ContactSummaryController`, etc.).

- **Scalability:** All Apex methods that perform DML are fully bulkified. They are designed to process lists of requests, consuming minimal SOQL queries and DML statements.
- **Future-Proofing:** Although the current use case is a single-record action, this bulk-safe design ensures that the same Apex logic can be safely reused in the future for more complex scenarios, such as batch jobs or record-triggered automations, without any modification.

### Data Model & Error Handling

- A custom object `Contact_Summary__c` uses a formula-driven `Unique_Key__c` (External ID) to enable efficient `Database.upsert` operations.
- Error handling is managed within a `try-catch` block in Apex. The `allOrNone=true` setting in the `upsert` call ensures data integrity by rolling back the entire transaction on any failure. A user-friendly error message is then surfaced to the UI.

**Shared Backend:**
- Both implementations utilize a shared Apex controller (`ContactSummaryController`) for the DML operations, demonstrating the principle of reusable service layers.

## Metadata Components

This solution includes the following metadata components:

- **Custom Object:**
  - `Contact_Summary__c`: Stores the aggregated contact counts.
    - `Account__c` (Master-Detail to Account)
    - `Type__c` (Text)
    - `State__c` (Text)
    *   `Contact_Count__c` (Number)
    *   `Unique_Key__c` (Text, External ID, Unique): An auto-generated key (`AccountId-Type-State`) to support `upsert` logic.

- **Custom Field on Contact:**
  - `Contact.Type__c` (Picklist): A, B, C, D.

- **Lightning Web Component:**
  - `contactSummaryUpdate`: The main UI component for the LWC approach.

- **Apex Classes:**
  - `ContactSummaryController`: A controller with methods to retrieve Contact and save `Contact_Summary__c` records, used by both the LWC and Flow. 
  - `ContactSummaryFetcher`: An Invocable class to query and aggregate Contact data for the Flow.
  - `ContactSummarySaver`: A Invocable class to calling ContactSummaryController to save `Contact_Summary__c` records for Flow.
  - `(Wrappers)`: Various inner or standalone classes to structure data passed between LWC/Flow and Apex.

- **Flow:**
  - `Contact_Summary`: A Screen Flow that guides the user through the summary and update process.

- **Validation Rule:**
  - On `Contact_Summary__c`: `Check_Contact_Count` (`Contact_Count__c > 5`).

- **Quick Action:**
  - `Account.Contact_Summary_LWC`: The button on the Account page layout to launch the LWC.
  - `Account.Contact_Summary_Flow`: The button on the Account page layout to launch the Flow.
