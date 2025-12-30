# Data Dictionary - Cemetery Management System

## Document Information
- **System Name:** Tomb Navigation & Cemetery Management System
- **Database:** Cloud Firestore (Firebase)
- **Version:** 1.0
- **Last Updated:** October 13, 2025

---

## Table of Contents
1. [Collection: contract](#collection-contract)
2. [Collection: users](#collection-users)
3. [Collection: transactions](#collection-transactions)
4. [Collection: vault](#collection-vault)
5. [Collection: audit](#collection-audit)
6. [Collection: visitorlog](#collection-visitorlog)
7. [Collection: price](#collection-price)

---

## Collection: contract

**Description:** Stores all burial lot and niche contracts, including applicant information, deceased records, payment details, and contract terms.

**Collection Path:** `/contract/{documentId}`

### Fields

| Field Name | Data Type | Required | Description | Validation Rules | Example Value |
|------------|-----------|----------|-------------|------------------|---------------|
| `contractID` | Integer | Yes | Unique numeric contract identifier | Auto-incremented, > 0 | `1001` |
| `contractidString` | String | Yes | String representation of contract ID | Matches contractID format | `"CON-1001"` |
| `type` | String | Yes | Type of burial location | Must be "Lot" or "Nitche" | `"Lot"` |
| `leessee` | String | Yes | Name of the lessee (person leasing the lot) | 2-50 characters, letters and spaces only | `"John Doe"` |
| `leesseContactNo` | String | No | Contact number of lessee | 11 digits, starts with 09 | `"09171234567"` |
| `applicantName` | Array<String> | Yes | List of applicant names (current and historical) | Each name: 2-50 chars, letters and spaces | `["Maria Santos", "Juan Cruz"]` |
| `applcantAddress` | Array<String> | Yes | List of applicant addresses | Each: 5+ chars, alphanumeric with punctuation | `["123 Main St, Manila"]` |
| `applicantContactNumber` | Array<Integer> | Yes | List of applicant contact numbers | Each: 9 digits (without leading 0) | `[917123456, 918765432]` |
| `appliContNumb` | Array<String> | No | String version of contact numbers | Each: 11 digits starting with 09 | `["09171234567"]` |
| `pastApplicantName` | String | No | Previous applicant's name (for transfers) | 2-50 characters | `"Pedro Reyes"` |
| `pastApplicantAddress` | String | No | Previous applicant's address | 5+ characters | `"456 Oak St, Quezon City"` |
| `pastApplicantContact` | String | No | Previous applicant's contact | 11 digits | `"09181234567"` |
| `applicantStatus` | String | No | Status of applicant | "current" or "past" | `"current"` |
| `latestContNum` | Integer | No | Latest contact number for quick access | Positive integer | `917123456` |
| `latestAddress` | String | No | Latest address for quick access | 5+ characters | `"123 Main St"` |
| `latestDeceased` | String | No | Latest deceased name for quick access | 2-50 characters | `"Jose Garcia"` |
| `decFullName` | Array<String> | No | Full names of deceased individuals | Each: 2-100 characters | `["Jose Garcia", "Ana Lopez"]` |
| `dateofdeath` | Array<DateTime> | No | Dates of death for each deceased | Valid date, not future | `[2023-05-15T00:00:00Z]` |
| `burialinternment` | Array<DateTime> | No | Burial/internment dates | Valid date, >= date of death | `[2023-05-18T10:00:00Z]` |
| `tombLocation` | String | No | Physical location of tomb/lot | Alphanumeric with spaces | `"Section A, Row 3, Lot 12"` |
| `lotLoccation` | String | No | Alternative lot location identifier | Alphanumeric | `"A-3-12"` |
| `Location` | String | No | General location description | Text | `"North Cemetery"` |
| `street` | String | No | Street address within cemetery | Text | `"Avenue of Saints"` |
| `measurement` | String | No | Lot dimensions | Text with units | `"2m x 2m"` |
| `lotpicture` | String | No | URL/path to lot image | Valid URL or Firebase Storage path | `"gs://bucket/lots/lot123.jpg"` |
| `dateEffective` | DateTime | Yes | Contract effective/start date | Valid date | `2023-01-01T00:00:00Z` |
| `dateofexpiration` | DateTime | Yes | Contract expiration date | > dateEffective | `2033-01-01T00:00:00Z` |
| `dateIssued` | DateTime | No | Date contract was issued | Valid date | `2023-01-01T00:00:00Z` |
| `dateadded` | DateTime | No | Date record was added to system | Auto-generated timestamp | `2023-01-01T12:00:00Z` |
| `stringEffectivedate` | String | No | Human-readable effective date | Date format: "MM/DD/YYYY" | `"01/01/2023"` |
| `stringExpirationdate` | String | No | Human-readable expiration date | Date format: "MM/DD/YYYY" | `"01/01/2033"` |
| `years` | String | No | Contract duration in years | Numeric string | `"10"` |
| `amount` | String | No | Total contract amount (string) | Currency format | `"50000.00"` |
| `amountINT` | Integer | No | Total contract amount (integer) | Positive integer | `50000` |
| `initialfee` | Double | No | Initial payment amount | >= 0 | `10000.00` |
| `balance` | Integer | No | Remaining balance | >= 0 | `40000` |
| `totalContraBalance` | Double | No | Total outstanding balance | >= 0 | `40000.00` |
| `remainingbalances` | Array<String> | No | Historical balance records | Currency format | `["40000.00", "30000.00"]` |
| `OR` | String | No | Official Receipt number | Alphanumeric | `"OR-2023-0001"` |
| `TIN` | String | No | Tax Identification Number | 9-12 digits with optional hyphens | `"123-456-789-000"` |
| `ResidentCert` | String | No | Resident Certificate number | Alphanumeric | `"RC-2023-001"` |
| `placeIssued` | String | No | Place where certificate was issued | Text | `"Manila City Hall"` |
| `proofoflease` | String | No | URL/path to proof of lease document | Valid URL or path | `"gs://bucket/docs/lease123.pdf"` |
| `status` | String | No | Overall contract status | Text | `"Active"` |
| `Lotstatus` | String | No | Lot availability status | "Available", "Occupied", "Reserved" | `"Occupied"` |
| `contractstatus` | String | No | Contract validity status | "Active", "Expired", "Cancelled" | `"Active"` |
| `registered` | String | No | Registration status | Text | `"Registered"` |
| `nitcheid` | Integer | No | Niche ID (for niche contracts only) | Positive integer | `501` |
| `nitcheidString` | String | No | String representation of niche ID | Matches nitcheid | `"NICHE-501"` |
| `email` | String | No | Applicant's email address | Valid email format | `"user@example.com"` |
| `display_name` | String | No | Display name from Firebase Auth | Text | `"John D."` |
| `photo_url` | String | No | Profile photo URL | Valid URL | `"https://..."` |
| `uid` | String | No | Firebase User ID | Firebase UID format | `"abc123xyz..."` |
| `created_time` | DateTime | No | Account creation timestamp | Auto-generated | `2023-01-01T00:00:00Z` |
| `phone_number` | String | No | Phone number from Firebase Auth | International format | `"+639171234567"` |
| `dummy` | String | No | Placeholder/test field | Any text | `""` |

**Indexes:**
- `contractID` (Ascending)
- `type` (Ascending)
- `contractstatus` (Ascending)
- Composite: `type` (Ascending), `Lotstatus` (Ascending)

**Business Rules:**
1. Contract ID must be unique across all contracts
2. Effective date must be before expiration date
3. At least one applicant name, address, and contact must be provided
4. Balance cannot be negative
5. Lot contracts cannot have nitcheid field populated
6. Niche contracts cannot have tomb location details
7. Date of death must be before burial/internment date

---

## Collection: users

**Description:** Stores user account information including admins, staff, and registered family members.

**Collection Path:** `/users/{userId}`

### Fields

| Field Name | Data Type | Required | Description | Validation Rules | Example Value |
|------------|-----------|----------|-------------|------------------|---------------|
| `email` | String | Yes | User's email address (primary login) | Valid email format, unique | `"admin@cemetery.com"` |
| `uid` | String | Yes | Firebase Authentication User ID | Auto-generated by Firebase Auth | `"abc123xyz..."` |
| `password` | String | No | Password (hashed by Firebase Auth) | Min 8 chars, handled by Firebase | `"********"` |
| `display_name` | String | No | User's display name | 2-50 characters | `"Admin User"` |
| `fullname` | String | Yes | User's full legal name | 2-100 characters, letters and spaces | `"Juan Dela Cruz"` |
| `phone_number` | String | Yes | Contact phone number | 11 digits, starts with 09 | `"09171234567"` |
| `address` | String | Yes | Physical address | 10+ characters | `"123 Main St, Manila"` |
| `photo_url` | String | No | Profile photo URL | Valid URL or Firebase Storage path | `"https://..."` |
| `type` | String | Yes | User role/type | "admin", "staff", "user" | `"admin"` |
| `isSuspended` | Boolean | No | Account suspension status | true/false | `false` |
| `suspensionStartDate` | DateTime | No | When suspension began | Valid date, required if suspended | `2024-01-01T00:00:00Z` |
| `suspensionEndDate` | DateTime | No | When suspension ends | > suspensionStartDate | `2024-02-01T00:00:00Z` |
| `suspensionReason` | String | No | Reason for suspension | Max 500 characters | `"Policy violation"` |
| `created_time` | DateTime | Yes | Account creation timestamp | Auto-generated | `2023-01-01T00:00:00Z` |
| `Stringusercreated` | String | No | Human-readable creation date | Date format: "MM/DD/YYYY" | `"01/01/2023"` |
| `registeredDeceasedID` | Array<Integer> | No | IDs of deceased they registered | Array of positive integers | `[101, 102, 103]` |

**Indexes:**
- `email` (Ascending) - Unique
- `uid` (Ascending) - Unique
- `type` (Ascending)
- `isSuspended` (Ascending)

**Business Rules:**
1. Email must be unique across all users
2. UID is generated by Firebase Authentication
3. Admin type users have full system access
4. Suspended users cannot log in
5. Suspension end date must be after start date
6. If isSuspended is true, suspension dates and reason are required

**User Types:**
- `admin`: Full system access, can manage contracts, users, and settings
- `staff`: Limited access, can view contracts and process transactions
- `user`: Family members, can view their own contracts only

---

## Collection: transactions

**Description:** Records all financial transactions including payments, refunds, and balance updates.

**Collection Path:** `/transactions/{transactionId}`

### Fields

| Field Name | Data Type | Required | Description | Validation Rules | Example Value |
|------------|-----------|----------|-------------|------------------|---------------|
| `uID` | String | Yes | User ID who made the payment | Valid Firebase UID | `"abc123xyz..."` |
| `transaction_date` | DateTime | Yes | Date and time of transaction | Valid timestamp | `2023-06-15T14:30:00Z` |
| `Stringtransactiondate` | String | No | Human-readable transaction date | Format: "MM/DD/YYYY HH:MM" | `"06/15/2023 14:30"` |
| `name` | String | Yes | Name of person making payment | 2-100 characters | `"Maria Santos"` |
| `email` | String | No | Email of person making payment | Valid email format | `"maria@example.com"` |
| `address` | String | No | Address of person making payment | 10+ characters | `"123 Main St, Manila"` |
| `amount` | Integer | Yes | Transaction amount | > 0 | `5000` |
| `payment_method` | String | Yes | Method of payment | "Cash", "GCash", "Bank Transfer", "Card" | `"Cash"` |
| `paymenttype` | String | No | Type of payment | "Initial", "Installment", "Full", "Balance" | `"Installment"` |
| `rem_balance` | String | No | Remaining balance after payment | Currency format | `"35000.00"` |
| `loc` | String | Yes | Location/lot number being paid for | Alphanumeric | `"A-3-12"` |
| `loctype` | String | Yes | Type of location | "Lot" or "Nitche" | `"Lot"` |
| `type` | String | No | Transaction category | Text | `"Payment"` |
| `tld` | String | No | Total lot details | Text | `"Lot A-3-12, Section A"` |
| `deceased` | String | No | Name of deceased (if applicable) | 2-100 characters | `"Jose Garcia"` |
| `status` | String | Yes | Transaction status | "Completed", "Pending", "Failed", "Refunded" | `"Completed"` |
| `isClicked` | Boolean | No | UI tracking flag | true/false | `false` |

**Indexes:**
- `transaction_date` (Descending)
- `uID` (Ascending)
- `status` (Ascending)
- Composite: `loc` (Ascending), `transaction_date` (Descending)

**Business Rules:**
1. Amount must be greater than zero
2. Transaction date cannot be in the future
3. Status must be updated after payment processing
4. Payment method is required for all transactions
5. Location (loc) must match an existing contract location

**Payment Methods:**
- `Cash`: Physical cash payment at office
- `GCash`: Mobile wallet payment
- `Bank Transfer`: Direct bank transfer
- `Card`: Credit/Debit card payment

**Transaction Statuses:**
- `Completed`: Payment successfully processed
- `Pending`: Payment being processed
- `Failed`: Payment failed
- `Refunded`: Payment was refunded

---

## Collection: vault

**Description:** Records of deceased individuals interred in vaults or columbariums.

**Collection Path:** `/vault/{vaultId}`

### Fields

| Field Name | Data Type | Required | Description | Validation Rules | Example Value |
|------------|-----------|----------|-------------|------------------|---------------|
| `deceasedid` | Integer | Yes | Unique deceased identifier | Auto-incremented, > 0 | `1001` |
| `deceasedIDstring` | String | Yes | String representation of deceased ID | Matches deceasedid | `"DEC-1001"` |
| `deceasedname` | Array<String> | Yes | Names of deceased (may have multiple) | Each: 2-100 characters | `["Jose Garcia"]` |
| `deceasedDateofDeath` | DateTime | No | Primary date of death | Valid past date | `2023-05-15T00:00:00Z` |
| `deceaseddateofdeath` | Array<DateTime> | No | Array of death dates (for multiple) | Each: valid past date | `[2023-05-15T00:00:00Z]` |
| `deceasedburialinterment` | Array<DateTime> | No | Burial/internment dates | Each: >= corresponding death date | `[2023-05-18T10:00:00Z]` |
| `applicantname` | Array<String> | Yes | Names of applicants/next of kin | Each: 2-100 characters | `["Maria Garcia"]` |
| `applicantaddress` | Array<String> | Yes | Addresses of applicants | Each: 10+ characters | `["123 Main St, Manila"]` |
| `applicantcontactnumber` | Array<Integer> | Yes | Contact numbers of applicants | Each: 9 digits | `[917123456]` |
| `status` | String | Yes | Vault occupancy status | "Occupied", "Reserved", "Available" | `"Occupied"` |
| `timestamp` | DateTime | Yes | Record creation timestamp | Auto-generated | `2023-05-18T00:00:00Z` |
| `Stringvaultadded` | String | No | Human-readable creation date | Format: "MM/DD/YYYY" | `"05/18/2023"` |
| `vaultID` | DocumentReference | No | Self-reference to this document | Firebase document reference | `vault/abc123` |

**Indexes:**
- `deceasedid` (Ascending) - Unique
- `status` (Ascending)
- `timestamp` (Descending)

**Business Rules:**
1. Deceased ID must be unique
2. At least one deceased name is required
3. At least one applicant with contact details required
4. Burial date must be after death date
5. Status determines vault availability

**Vault Statuses:**
- `Occupied`: Vault is currently in use
- `Reserved`: Vault is reserved for future use
- `Available`: Vault is available for reservation

---

## Collection: audit

**Description:** Audit trail logging all system activities for security, compliance, and troubleshooting.

**Collection Path:** `/audit/{auditId}`

### Fields

| Field Name | Data Type | Required | Description | Validation Rules | Example Value |
|------------|-----------|----------|-------------|------------------|---------------|
| `id` | DocumentReference | No | Reference to affected document | Valid Firestore document reference | `contract/abc123` |
| `userId` | String | Yes | UID of user who performed action | Valid Firebase UID | `"abc123xyz..."` |
| `name` | String | Yes | Name of user who performed action | 2-100 characters | `"Admin User"` |
| `action` | String | Yes | Action performed | Predefined action types | `"Updated Contract"` |
| `timestamp` | DateTime | Yes | When action occurred | Auto-generated timestamp | `2023-06-15T14:30:00Z` |
| `Stringtimestamp` | String | No | Human-readable timestamp | Format: "MM/DD/YYYY HH:MM:SS" | `"06/15/2023 14:30:00"` |
| `ipAddress` | String | No | IP address of user | Valid IPv4 or IPv6 | `"192.168.1.100"` |

**Indexes:**
- `timestamp` (Descending)
- `userId` (Ascending)
- `action` (Ascending)
- Composite: `userId` (Ascending), `timestamp` (Descending)

**Business Rules:**
1. All actions are logged automatically
2. Audit records are immutable (cannot be edited or deleted)
3. Timestamp is server-generated to prevent tampering
4. IP address is captured when available

**Action Types:**
- `Created Contract`: New contract created
- `Updated Contract`: Contract modified
- `Deleted Contract`: Contract removed
- `Created User`: New user account created
- `Updated User`: User account modified
- `Suspended User`: User account suspended
- `Processed Payment`: Transaction processed
- `Updated Lessee`: Lessee name changed
- `Updated Applicant`: Applicant details changed
- `Login`: User logged into system
- `Logout`: User logged out
- `Failed Login`: Login attempt failed
- `Viewed Contract`: Contract details viewed
- `Generated Report`: Report generated

---

## Collection: visitorlog

**Description:** Logs all visitors who enter the cemetery premises.

**Collection Path:** `/visitorlog/{visitorlogId}`

### Fields

| Field Name | Data Type | Required | Description | Validation Rules | Example Value |
|------------|-----------|----------|-------------|------------------|---------------|
| `timestamp` | DateTime | Yes | Date and time of visit | Auto-generated | `2023-06-15T10:00:00Z` |
| `Stringtimestamp` | String | No | Human-readable timestamp | Format: "MM/DD/YYYY HH:MM" | `"06/15/2023 10:00"` |
| `name` | String | Yes | Visitor's full name | 2-100 characters | `"Juan Dela Cruz"` |
| `visitorid` | String | No | Unique visitor ID | Alphanumeric | `"VIS-2023-0001"` |
| `email` | String | No | Visitor's email | Valid email format | `"visitor@example.com"` |
| `phone_number` | String | Yes | Visitor's contact number | 11 digits, starts with 09 | `"09171234567"` |
| `display_name` | String | No | Display name (if registered user) | Text | `"Juan D."` |
| `photo_url` | String | No | Profile photo (if registered user) | Valid URL | `"https://..."` |
| `uid` | String | No | Firebase UID (if registered user) | Firebase UID format | `"abc123xyz..."` |
| `created_time` | DateTime | No | Record creation time | Auto-generated | `2023-06-15T10:00:00Z` |

**Indexes:**
- `timestamp` (Descending)
- `name` (Ascending)
- `uid` (Ascending)

**Business Rules:**
1. Every visitor must provide name and contact number
2. Timestamp is auto-generated upon entry
3. If visitor is a registered user, UID is linked
4. Visitor logs are retained for security purposes

**Use Cases:**
- Security monitoring
- Visitation statistics
- Contact tracing
- Visitor patterns analysis

---

## Collection: price

**Description:** Stores current pricing configuration for lots and niches.

**Collection Path:** `/price/{priceId}`

### Fields

| Field Name | Data Type | Required | Description | Validation Rules | Example Value |
|------------|-----------|----------|-------------|------------------|---------------|
| `lotprice` | Integer | Yes | Current price per burial lot | > 0 | `50000` |
| `nitcheprice` | Integer | Yes | Current price per niche/columbarium | > 0 | `30000` |
| `nitcheid1` | Integer | Yes | Next available niche ID | Auto-incremented | `501` |
| `lotid2` | Integer | Yes | Next available lot ID | Auto-incremented | `1001` |

**Indexes:**
- None (single configuration document)

**Business Rules:**
1. Only one price document should exist (use well-known document ID)
2. Prices cannot be zero or negative
3. Price changes should be logged in audit trail
4. ID counters increment automatically with new contracts

**Usage:**
- Referenced when creating new contracts
- Updated by admin users only
- Historical prices not stored (consider adding price history)

---

## Data Types Reference

| Type | Description | Example |
|------|-------------|---------|
| `String` | Text data | `"Hello World"` |
| `Integer` | Whole numbers | `12345` |
| `Double` | Decimal numbers | `123.45` |
| `Boolean` | True/false values | `true` |
| `DateTime` | Date and time with timezone | `2023-06-15T14:30:00Z` |
| `Array<String>` | List of text values | `["Item1", "Item2"]` |
| `Array<Integer>` | List of numbers | `[1, 2, 3]` |
| `Array<DateTime>` | List of dates | `[2023-01-01, 2023-02-01]` |
| `DocumentReference` | Reference to another document | `users/abc123` |

---

## Validation Rules Summary

### Text Field Validation
- **Names (Person):** 2-100 characters, letters, spaces, periods, apostrophes
- **Addresses:** 10+ characters, alphanumeric with punctuation
- **Email:** Standard email format (user@domain.com)
- **Phone (Philippine):** 11 digits starting with 09

### Numeric Validation
- **Amounts:** Must be positive (> 0)
- **IDs:** Auto-incremented, must be unique
- **Balances:** Cannot be negative (>= 0)

### Date Validation
- **Past Dates:** Cannot be in the future (death dates, birth dates)
- **Date Ranges:** End date must be after start date
- **Effective Dates:** Contract effective < expiration

### Status Values
- **Contract Status:** Active, Expired, Cancelled
- **Lot Status:** Available, Occupied, Reserved
- **Transaction Status:** Completed, Pending, Failed, Refunded
- **User Types:** admin, staff, user

---

## Naming Conventions

### Field Naming
- Use camelCase for field names: `applicantName`, `dateEffective`
- Boolean fields: prefix with `is` or `has`: `isSuspended`, `hasBalance`
- Date strings: prefix with `String`: `Stringtimestamp`
- Array fields: use plural nouns: `applicantNames`, `remainingbalances`

### Collection Naming
- Use lowercase for collection names: `contract`, `users`, `vault`
- Use singular nouns when possible: `audit` (not `audits`)
- Keep names concise and descriptive

### ID Conventions
- Numeric IDs: Use Integer type
- String IDs: Use format PREFIX-NUMBER: `CON-1001`, `DEC-1001`
- Firebase UIDs: Keep as-is from Firebase Auth

---

## Security & Privacy Notes

### Personal Identifiable Information (PII)
Fields containing PII that require protection:
- `email`
- `phone_number`
- `address`
- `fullname`
- `TIN`
- `ipAddress`

### Access Control
- **Admin:** Full read/write access to all collections
- **Staff:** Read-only for contracts, read/write for transactions
- **Users:** Read-only for their own data
- **Public:** No access

### Data Retention
- **Contracts:** Permanent retention
- **Transactions:** Retain for 10 years minimum
- **Audit Logs:** Retain for 7 years minimum
- **Visitor Logs:** Retain for 1 year
- **User Accounts:** Retain while active + 1 year after suspension

---

## Change Log

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-10-13 | Initial data dictionary created | System Admin |

---

## Notes

1. **Duplicate Fields:** Some collections have overlapping fields (email, phone_number, etc.) to maintain denormalized data for performance.

2. **String vs Integer Dates:** Both timestamp formats exist for compatibility with different system components.

3. **Array Fields:** Arrays are used for historical tracking (applicant changes, multiple deceased, balance history).

4. **Optional Fields:** Many fields are optional to accommodate incomplete data during data entry or migration.

5. **Future Enhancements:**
   - Add price history tracking
   - Implement role-based access control fields
   - Add document version tracking
   - Consider adding geolocation for lots
   - Add support for attachments/documents

---

**End of Data Dictionary**

