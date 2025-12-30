# Firebase Data Dictionary - Cemetery Management System

## Collection: contract

**Purpose:** Stores burial lot and niche contracts with applicant, deceased, and payment information.

| Field Name | Type | Required | Description |
|------------|------|----------|-------------|
| `contractID` | Integer | Yes | Unique contract identifier (auto-increment) |
| `contractidString` | String | Yes | String version of contract ID |
| `type` | String | Yes | Contract type: "Lot" or "Nitche" |
| **LESSEE INFORMATION** |
| `leessee` | String | Yes | Full name of lessee (2-50 chars, letters & spaces only) |
| `leesseContactNo` | String | No | Lessee contact number (11 digits, starts with 09) |
| **APPLICANT INFORMATION (CURRENT)** |
| `applicantName` | Array\<String\> | Yes | List of applicant full names (2-50 chars each) |
| `applcantAddress` | Array\<String\> | Yes | List of applicant addresses (5+ chars each) |
| `applicantContactNumber` | Array\<Integer\> | Yes | List of contact numbers (9 digits, without leading 0) |
| `appliContNumb` | Array\<String\> | No | Contact numbers as strings (11 digits) |
| **APPLICANT INFORMATION (PAST/TRANSFER)** |
| `pastApplicantName` | String | No | Previous applicant name (for transfer records) |
| `pastApplicantAddress` | String | No | Previous applicant address |
| `pastApplicantContact` | String | No | Previous applicant contact number |
| `applicantStatus` | String | No | Applicant status: "current" or "past" |
| **QUICK ACCESS FIELDS** |
| `latestContNum` | Integer | No | Most recent contact number |
| `latestAddress` | String | No | Most recent address |
| `latestDeceased` | String | No | Most recent deceased name |
| **DECEASED INFORMATION** |
| `decFullName` | Array\<String\> | No | Full names of deceased persons |
| `dateofdeath` | Array\<DateTime\> | No | Dates of death for each deceased |
| `burialinternment` | Array\<DateTime\> | No | Burial/internment dates |
| **LOCATION DETAILS** |
| `tombLocation` | String | No | Physical tomb/lot location description |
| `lotLoccation` | String | No | Lot location identifier |
| `Location` | String | No | General location/section |
| `street` | String | No | Street/path within cemetery |
| `measurement` | String | No | Lot dimensions (e.g., "2m x 2m") |
| `lotpicture` | String | No | URL/path to lot image |
| **CONTRACT DATES** |
| `dateEffective` | DateTime | Yes | Contract start/effective date |
| `dateofexpiration` | DateTime | Yes | Contract expiration date |
| `dateIssued` | DateTime | No | Date contract was issued |
| `dateadded` | DateTime | No | Date record was added to system |
| `stringEffectivedate` | String | No | Effective date as string (MM/DD/YYYY) |
| `stringExpirationdate` | String | No | Expiration date as string (MM/DD/YYYY) |
| `years` | String | No | Contract duration in years |
| **FINANCIAL INFORMATION** |
| `amount` | String | No | Total contract amount as string |
| `amountINT` | Integer | No | Total contract amount as integer |
| `initialfee` | Double | No | Initial payment/down payment |
| `balance` | Integer | No | Remaining balance (≥ 0) |
| `totalContraBalance` | Double | No | Total outstanding contract balance |
| `remainingbalances` | Array\<String\> | No | Historical balance records |
| **DOCUMENTS** |
| `OR` | String | No | Official Receipt number |
| `TIN` | String | No | Tax Identification Number |
| `ResidentCert` | String | No | Resident Certificate number |
| `placeIssued` | String | No | Place where certificate was issued |
| `proofoflease` | String | No | URL/path to proof of lease document |
| **STATUS FIELDS** |
| `status` | String | No | Overall contract status |
| `Lotstatus` | String | No | Lot status: "Available", "Occupied", "Reserved" |
| `contractstatus` | String | No | Contract validity: "Active", "Expired", "Cancelled" |
| `registered` | String | No | Registration status |
| **NICHE SPECIFIC** |
| `nitcheid` | Integer | No | Niche ID (only for type="Nitche") |
| `nitcheidString` | String | No | Niche ID as string |
| **USER INFORMATION** |
| `email` | String | No | Applicant email address |
| `display_name` | String | No | Display name from Firebase Auth |
| `photo_url` | String | No | Profile photo URL |
| `uid` | String | No | Firebase User ID |
| `created_time` | DateTime | No | Account creation timestamp |
| `phone_number` | String | No | Phone number from Firebase Auth |
| **OTHER** |
| `dummy` | String | No | Placeholder field |

---

## Collection: users

**Purpose:** User accounts for admins, staff, and registered family members.

| Field Name | Type | Required | Description |
|------------|------|----------|-------------|
| **AUTHENTICATION** |
| `email` | String | Yes | User email address (unique, login credential) |
| `uid` | String | Yes | Firebase Authentication User ID (unique) |
| `password` | String | No | Hashed password (managed by Firebase Auth) |
| **PROFILE INFORMATION** |
| `display_name` | String | No | User's display name (2-50 chars) |
| `fullname` | String | Yes | Full legal name (2-100 chars) |
| `phone_number` | String | Yes | Contact number (11 digits, starts with 09) |
| `address` | String | Yes | Physical address (10+ chars) |
| `photo_url` | String | No | Profile photo URL |
| **ROLE & STATUS** |
| `type` | String | Yes | User role: "admin", "staff", or "user" |
| `isSuspended` | Boolean | No | Account suspension status (default: false) |
| `suspensionStartDate` | DateTime | No | When suspension began |
| `suspensionEndDate` | DateTime | No | When suspension ends |
| `suspensionReason` | String | No | Reason for account suspension |
| **TIMESTAMPS** |
| `created_time` | DateTime | Yes | Account creation timestamp |
| `Stringusercreated` | String | No | Creation date as string (MM/DD/YYYY) |
| **RELATIONSHIPS** |
| `registeredDeceasedID` | Array\<Integer\> | No | IDs of deceased registered by this user |

---

## Collection: transactions

**Purpose:** Financial transaction records for payments and balance updates.

| Field Name | Type | Required | Description |
|------------|------|----------|-------------|
| **TRANSACTION INFORMATION** |
| `uID` | String | Yes | User ID who made the payment |
| `transaction_date` | DateTime | Yes | Date and time of transaction |
| `Stringtransactiondate` | String | No | Transaction date as string (MM/DD/YYYY HH:MM) |
| **PAYER INFORMATION** |
| `name` | String | Yes | Name of person making payment (2-100 chars) |
| `email` | String | No | Payer's email address |
| `address` | String | No | Payer's address |
| **PAYMENT DETAILS** |
| `amount` | Integer | Yes | Payment amount (> 0) |
| `payment_method` | String | Yes | Payment method: "Cash", "GCash", "Bank Transfer", "Card" |
| `paymenttype` | String | No | Payment type: "Initial", "Installment", "Full", "Balance" |
| `rem_balance` | String | No | Remaining balance after payment |
| **LOCATION DETAILS** |
| `loc` | String | Yes | Location/lot number being paid for |
| `loctype` | String | Yes | Location type: "Lot" or "Nitche" |
| `type` | String | No | Transaction category |
| `tld` | String | No | Total lot/niche details |
| `deceased` | String | No | Name of deceased (if applicable) |
| **STATUS** |
| `status` | String | Yes | Status: "Completed", "Pending", "Failed", "Refunded" |
| `isClicked` | Boolean | No | UI tracking flag |

---

## Collection: vault

**Purpose:** Records of deceased individuals in vaults/columbariums.

| Field Name | Type | Required | Description |
|------------|------|----------|-------------|
| **DECEASED IDENTIFICATION** |
| `deceasedid` | Integer | Yes | Unique deceased identifier (auto-increment) |
| `deceasedIDstring` | String | Yes | Deceased ID as string |
| `deceasedname` | Array\<String\> | Yes | Names of deceased (2-100 chars each) |
| **DEATH INFORMATION** |
| `deceasedDateofDeath` | DateTime | No | Primary date of death |
| `deceaseddateofdeath` | Array\<DateTime\> | No | Array of death dates (for multiple deceased) |
| `deceasedburialinterment` | Array\<DateTime\> | No | Burial/internment dates |
| **APPLICANT/NEXT OF KIN** |
| `applicantname` | Array\<String\> | Yes | Names of applicants/family members |
| `applicantaddress` | Array\<String\> | Yes | Addresses of applicants |
| `applicantcontactnumber` | Array\<Integer\> | Yes | Contact numbers (9 digits each) |
| **STATUS & TIMESTAMPS** |
| `status` | String | Yes | Vault status: "Occupied", "Reserved", "Available" |
| `timestamp` | DateTime | Yes | Record creation timestamp |
| `Stringvaultadded` | String | No | Creation date as string (MM/DD/YYYY) |
| **REFERENCE** |
| `vaultID` | Reference | No | Self-reference to this vault document |

---

## Collection: audit

**Purpose:** Audit trail for all system activities (security and compliance).

| Field Name | Type | Required | Description |
|------------|------|----------|-------------|
| **AUDIT INFORMATION** |
| `id` | Reference | No | Reference to affected document |
| `userId` | String | Yes | UID of user who performed action |
| `name` | String | Yes | Name of user who performed action |
| `action` | String | Yes | Action performed (e.g., "Updated Contract") |
| `timestamp` | DateTime | Yes | When action occurred (server timestamp) |
| `Stringtimestamp` | String | No | Timestamp as string (MM/DD/YYYY HH:MM:SS) |
| `ipAddress` | String | No | IP address of user |

**Common Actions:**
- "Created Contract", "Updated Contract", "Deleted Contract"
- "Updated Lessee", "Updated Applicant"
- "Processed Payment"
- "Created User", "Updated User", "Suspended User"
- "Login", "Logout", "Failed Login"

---

## Collection: visitorlog

**Purpose:** Log of cemetery visitors for security and tracking.

| Field Name | Type | Required | Description |
|------------|------|----------|-------------|
| **VISIT INFORMATION** |
| `timestamp` | DateTime | Yes | Date and time of visit |
| `Stringtimestamp` | String | No | Visit time as string (MM/DD/YYYY HH:MM) |
| `name` | String | Yes | Visitor's full name (2-100 chars) |
| `visitorid` | String | No | Unique visitor identifier |
| **CONTACT INFORMATION** |
| `email` | String | No | Visitor's email address |
| `phone_number` | String | Yes | Visitor's contact number (11 digits) |
| **USER INFORMATION (IF REGISTERED)** |
| `display_name` | String | No | Display name (for registered users) |
| `photo_url` | String | No | Profile photo (for registered users) |
| `uid` | String | No | Firebase UID (for registered users) |
| `created_time` | DateTime | No | Record creation timestamp |

---

## Collection: price

**Purpose:** Pricing configuration and ID counters for lots and niches.

| Field Name | Type | Required | Description |
|------------|------|----------|-------------|
| **PRICING** |
| `lotprice` | Integer | Yes | Current price per burial lot (> 0) |
| `nitcheprice` | Integer | Yes | Current price per niche/columbarium (> 0) |
| **ID COUNTERS** |
| `nitcheid1` | Integer | Yes | Next available niche ID (auto-increment) |
| `lotid2` | Integer | Yes | Next available lot ID (auto-increment) |

---

## Data Types Reference

| Type | Description | Example |
|------|-------------|---------|
| `String` | Text data | `"John Doe"` |
| `Integer` | Whole number | `12345` |
| `Double` | Decimal number | `12345.67` |
| `Boolean` | True/false value | `true` or `false` |
| `DateTime` | Timestamp with timezone | `2023-06-15T14:30:00Z` |
| `Array<T>` | List of values of type T | `["Item1", "Item2"]` |
| `Reference` | Firestore document reference | `contract/abc123` |

---

## Collection Paths

```
/contract/{contractId}
/users/{userId}
/transactions/{transactionId}
/vault/{vaultId}
/audit/{auditId}
/visitorlog/{visitorlogId}
/price/{priceId}
```

---

## Validation Summary

### Common Validation Rules

**Names (People):**
- 2-100 characters
- Letters and spaces only
- Example: `"Juan Dela Cruz"`

**Addresses:**
- 5+ characters
- Alphanumeric with punctuation allowed
- Example: `"123 Main St, Manila"`

**Phone Numbers (Philippine):**
- 11 digits starting with 09
- Example: `"09171234567"`

**Email:**
- Standard email format
- Example: `"user@example.com"`

**Amounts/Prices:**
- Must be positive (> 0)
- Example: `50000`

**Balances:**
- Cannot be negative (≥ 0)
- Example: `35000`

### Status Values

**Contract Status:**
- "Active" - Contract is currently valid
- "Expired" - Contract has expired
- "Cancelled" - Contract was cancelled

**Lot Status:**
- "Available" - Lot is available for purchase
- "Occupied" - Lot is currently in use
- "Reserved" - Lot is reserved

**Transaction Status:**
- "Completed" - Payment successfully processed
- "Pending" - Payment being processed
- "Failed" - Payment failed
- "Refunded" - Payment was refunded

**User Types:**
- "admin" - Full system access
- "staff" - Limited access
- "user" - Family member/public user

---

## Business Rules

### Contract Rules
1. Contract ID must be unique
2. Effective date must be before expiration date
3. At least one applicant required (name, address, contact)
4. Balance cannot be negative
5. Lot contracts: no `nitcheid` field
6. Niche contracts: no tomb location details

### User Rules
1. Email must be unique across all users
2. Suspended users cannot log in
3. If `isSuspended` = true, suspension dates and reason required

### Transaction Rules
1. Amount must be greater than zero
2. Transaction date cannot be in the future
3. Location must match an existing contract

### Vault Rules
1. Deceased ID must be unique
2. At least one deceased name required
3. At least one applicant with contact required
4. Burial date must be after death date

---

## Security Notes

### Personal Identifiable Information (PII)
The following fields contain sensitive data:
- `email`
- `phone_number`
- `address`
- `fullname`
- `TIN`
- `ipAddress`

### Access Control
- **Admin:** Full read/write access
- **Staff:** Read contracts, process transactions
- **Users:** Read own data only
- **Public:** No access

---

**Document Version:** 1.0  
**Last Updated:** October 13, 2025
