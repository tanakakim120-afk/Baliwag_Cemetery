/// Configuration for external APIs used in the application
class ApiConfig {
  // Google Cloud Document AI Configuration
  // Replace these with your actual Google Cloud project details
  static const String googleCloudProjectId = 'tomb-nav-30luyb';
  static const String documentAiProcessorId = '282fc31e9911b7cd';
  static const String documentAiLocation = 'us'; // or your preferred location
  static const String googleCloudApiKey =
      'AIzaSyBUH3RmID74yenhMNSYxbjAIxaTSGY8qk4';

  // Service Account Configuration for Document AI
  // Extracted from your service account JSON file
  static const String serviceAccountEmail =
      'document-ai-service@tomb-nav-30luyb.iam.gserviceaccount.com';
  static const String serviceAccountPrivateKey = '''-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC+/4oj/ZjOPw1m
2++yioI5a8LYZiywQD4MF4pHH1KLvavUfDPOk2O6ih/fkixqdF8LfzkBGxjO+Fez
ocdZnaIbbVMn72M3HQGUDvLtZMSdc/Gj5NUjlOzXO1tmk6swMjW7Fi6l+lb2IkCC
iHLqZiaiC/ZIhZbpRORLj72qml6cOwjToeDHpVo+uAE5foT1cVr31vVS6NhtMXF8
cqYu/Bo14pydYPSRLQ16b9NE5x1ZIM7mPCLmzPPnCdzIYabZf23r+C0KooyQ6zU/
loLiuVYe7rqDeDS/QrRvohr/rq7XAltrzYWMmEYkjxGWlOZVCnD1miooOwnFFjQm
zqivI8MBAgMBAAECggEABQYcCuykOiSUGdUGKIhBJaPX07EC/ZMrA/loieIL3fYc
EMeVkJpK4MC6VuX1j3VGfLsYyOvUCrmjNkE2nlJUTcFh6GaBEcA3EZRqamPLUihB
vmG0ri4VeWcrynZu5c0kTFVTM8rHwnX4hBZ1DgT9gNICD+VHqL9xpn/TlCsMUF1S
HFD08B+eQV7Z4n+8JD/NAkpbpNkohWZaqTs/YdCyEjlKXzx9Tf6On9IM/Fn24L9y
EPBcTS8AlRSCjYH0W8HvqAK5kxfH0NDRVXA+YaOg/4axWTmPYgdd5nqwCQ1fVEV9
JmmZ0MjI3D3shv6qWyuw2GsddHE1hEnOrUE4I+2XuQKBgQD4wNhlYX1DjrOH901p
S48KT07QzAyU1CsRM2Eo6y4cJISJ5sILjMDQfcDQtxXPOq6ZH9H364R2Vj6OiefV
1dLDJJ714cEg/9lxK8O+U/ZTBdbgri8f5QhP+R6esWQooOJY54y82j+ZHS+wrdCJ
8rMUKFH4ODWNZ4x8YRsVl1wGxQKBgQDEj/fA41bJfaIf56J/F0R2z5V+RKfvXICc
yfw8brx1+U4k2hW1iZqao24d5MaBH8JoAxckV3w0lll0tF0stdA/RKGTKV9RSqIE
fbi0+14n7eYlCf53P9fxfhMKF/ntgDtfE00zKv4qJDCoegCT2c68AL7LzmjxCsvu
nIGkfuhvDQKBgQCbxae9VN9sfuBONL91QKvCeQeSGTWHvZV6oAIn7Z5iYTveX3ME
aJAV/6nPCdfOfaD4osSJzCKXOErUV+emMNBbA4PH1idq0s0H4bAib9HBC9cTvAAm
qPYbnpVeKxfdmWIk6ltnqARLjctfiHke6aza4qTyG8DtW/rNqMGdM7udQQKBgAxr
gF8avkga/RyA+V6IbNYJBcwlsGrKcIH3rU1wPc5Cg3KGqSqAWFl/DB0tcHGGPTVv
RI4STRHRkjNylhSWJGNrBb6TtacgTR51hy9AVtG1EX6zo/WK/i0PJ0rS+wLLwHSg
dpdOFyM4iC6NDu5Iq+xrK6MbFrxsTzhzgSmQr0UdAoGBAOfSSo7H9oNtwUwtQOL2
wxKesHaxqSPXs866nr3MPt7RS2okpD1EOpOi44woZFe7rkJjNZfAj1iqx7o982B6
6vkzJZMOXLKviYhfl0+sdRqIHuyDiHHPso+dYKrIunClacm4s2YsLlMEB9C0aOYk
a8jGSpsVUPnDVcTfaePfwO0t
-----END PRIVATE KEY-----''';

  // Document AI API endpoint
  static String get documentAiEndpoint =>
      'https://documentai.googleapis.com/v1/projects/$googleCloudProjectId/locations/$documentAiLocation/processors/$documentAiProcessorId:process';

  // Alternative verification services (if you want to switch)
  static const String snapptApiKey = 'YOUR_SNAPPT_API_KEY';
  static const String snapptEndpoint = 'https://api.snappt.com/v1/verify';

  // Verification thresholds - adjusted for Document AI entity extraction
  static const double minimumConfidenceThreshold =
      0.4; // Lowered to account for entity-based scoring
  static const double highConfidenceThreshold = 0.7;

  // Document validation settings
  static const int minimumDocumentSize = 1000; // bytes
  static const int maximumDocumentSize = 10000000; // 10MB
  static const List<String> allowedMimeTypes = [
    'application/pdf',
    'image/jpeg',
    'image/png',
    'image/jpg',
  ];

  // Lease document keywords for validation
  static const List<String> leaseKeywords = [
    'lease',
    'rental',
    'tenant',
    'landlord',
    'property',
    'address',
    'monthly',
    'rent',
    'deposit',
    'agreement',
    'terms',
    'signature',
    'premises',
    'occupancy',
    'utilities',
    'maintenance',
    'liability',
    'insurance',
    'notice',
    'termination',
  ];

  // Minimum number of keywords required for validation
  static const int minimumKeywordCount = 3;
}
