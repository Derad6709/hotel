'''sh
curl --location 'http://localhost/register' \
--header 'Content-Type: application/json' \
--data-raw '{"email":"host@exam2ple.com","password":"password123","role":"guest"}'
'''
WRITE DOWN A TOKEN...
'''sh
curl --location 'http://localhost/hotels' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer <TOKEN FROM REGISTRATION>' \
--data '{
    "name": "Test Hotel",
    "city": "Test City",
    "address": "123 Test St",
    "description": "A nice place"
  }'
'''

ERROR!!! TRY TOKEN FROM:
'''sh
curl --location 'http://localhost/register' \
--header 'Content-Type: application/json' \
--data-raw '{"email":"host@exam2ple.com","password":"password123","role":"host"}'
'''
SHOULD BE WALID!