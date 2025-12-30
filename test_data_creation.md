# Test Contract Data for Testing

Here are 5 test contracts you can manually add to your Firebase database for testing:

## Contract 1 - Lot Type (Active)
```json
{
  "contractID": 1001,
  "contractidString": "1001",
  "type": "Lot",
  "status": "active",
  "contractstatus": "active",
  "location": "Block A, Lot 15",
  "street": "Main Street",
  "measurement": "2m x 3m",
  "amount": "5000",
  "dateadded": "2024-01-15T10:30:00Z",
  "dateEffective": "2024-01-15T10:30:00Z",
  "dateofexpiration": "2025-01-15T10:30:00Z",
  "leessee": "John Doe",
  "applicantName": ["John Doe"],
  "applcantAddress": ["123 Main St, City"],
  "applicantContactNumber": [9876543210],
  "decFullName": ["Maria Doe"],
  "dateofdeath": ["2023-12-01T00:00:00Z"],
  "burialinternment": ["2023-12-15T00:00:00Z"]
}
```

## Contract 2 - Lot Type (Expired - Will Create Vault Record)
```json
{
  "contractID": 1002,
  "contractidString": "1002",
  "type": "Lot",
  "status": "expired",
  "contractstatus": "expired",
  "location": "Block B, Lot 22",
  "street": "Second Street",
  "measurement": "2.5m x 3m",
  "amount": "6000",
  "dateadded": "2023-06-01T10:30:00Z",
  "dateEffective": "2023-06-01T10:30:00Z",
  "dateofexpiration": "2024-12-01T10:30:00Z",
  "leessee": "Jane Smith",
  "applicantName": ["Jane Smith"],
  "applcantAddress": ["456 Oak Ave, City"],
  "applicantContactNumber": [9876543211],
  "decFullName": ["Robert Smith"],
  "dateofdeath": ["2023-05-01T00:00:00Z"],
  "burialinternment": ["2023-05-15T00:00:00Z"]
}
```

## Contract 3 - Nitche Type (Active)
```json
{
  "contractID": 1003,
  "contractidString": "1003",
  "type": "nitche",
  "status": "available",
  "contractstatus": "available",
  "location": "7",
  "amount": "1000",
  "dateadded": "2024-07-01T10:30:00Z",
  "dateEffective": "2024-07-01T10:30:00Z",
  "dateofexpiration": "2025-07-01T10:30:00Z",
  "leessee": null,
  "nitcheid": 7,
  "nitcheidString": "7",
  "decFullName": ["Carlos Garcia"],
  "dateofdeath": ["2024-06-15T00:00:00Z"],
  "burialinternment": ["2024-06-25T00:00:00Z"]
}
```

## Contract 4 - Nitche Type (Expired - Will Create Special Vault Record)
```json
{
  "contractID": 1004,
  "contractidString": "1004",
  "type": "nitche",
  "status": "available",
  "contractstatus": "available",
  "location": "12",
  "amount": "1000",
  "dateadded": "2023-08-01T10:30:00Z",
  "dateEffective": "2023-08-01T10:30:00Z",
  "dateofexpiration": "2024-12-15T10:30:00Z",
  "leessee": null,
  "nitcheid": 12,
  "nitcheidString": "12",
  "decFullName": ["Ana Rodriguez"],
  "dateofdeath": ["2023-07-20T00:00:00Z"],
  "burialinternment": ["2023-07-30T00:00:00Z"]
}
```

## Contract 5 - Lot Type (Active, Multiple Deceased)
```json
{
  "contractID": 1005,
  "contractidString": "1005",
  "type": "Lot",
  "status": "active",
  "contractstatus": "active",
  "location": "Block C, Lot 8",
  "street": "Third Avenue",
  "measurement": "3m x 4m",
  "amount": "8000",
  "dateadded": "2023-09-01T10:30:00Z",
  "dateEffective": "2023-09-01T10:30:00Z",
  "dateofexpiration": "2025-06-01T10:30:00Z",
  "leessee": "Michael Johnson",
  "applicantName": ["Michael Johnson", "Sarah Johnson"],
  "applcantAddress": ["789 Pine St, City", "789 Pine St, City"],
  "applicantContactNumber": [9876543212, 9876543213],
  "decFullName": ["Elizabeth Johnson", "William Johnson"],
  "dateofdeath": ["2023-03-01T00:00:00Z", "2023-05-15T00:00:00Z"],
  "burialinternment": ["2023-03-15T00:00:00Z", "2023-05-25T00:00:00Z"]
}
```

## Testing Scenarios

### Expected Behavior:
1. **Active Contracts (1001, 1003, 1005)**: Should appear in ManageContract list
2. **Expired Contracts (1002, 1004)**: Should automatically create vault records when app starts
3. **Contract 1004 (Expired Nitche)**: Should create vault record with only these fields:
   - Location: "12"
   - amount: "1000" 
   - dateadded: "2023-08-01T10:30:00Z"
   - leessee: null
   - nitcheid: 12
   - nitcheidString: "12"
   - status: "available"
   - type: "nitche"

### How to Add:
1. Go to Firebase Console → Firestore Database
2. Navigate to the `contract` collection
3. Click "Add document"
4. Copy and paste each JSON above
5. Make sure to convert date strings to proper Timestamp format in Firebase

### Quick Test:
- Run your app and check ManageContract - should show 3 active contracts
- Check VaultList - should show 2 vault records created from expired contracts
- Contract 1004 vault record should only have the specific nitche fields








