Feature: gpg function test

Background:
* url demoBaseUrl
* string privBase64 = read('data/private.key.base64')
* string pubBase64 = read('data/public.key.base64')
* def req = '{}'

# list all keys
Scenario: simple test no key

    Given path '/'
    Given header Direktiv-ActionID = 'development'
    Given header Direktiv-Tempdir = '/tmp'
    And request 
    """
    { "commands": [
      {
        "command": "gpg --list-keys"
      }
    ]
    }
    """
    When method post
    Then status 200
    And match $ == 
    """
    {
    "gpg": [
    {
      "result": "#notnull",
      "success": true
    }
    ]
    }
    """

# simple test, uses priv/pub key from upload
# checks if it returns the key
Scenario: simple test

    Given path '/'
    Given header Direktiv-ActionID = 'development'
    Given header Direktiv-Tempdir = '/tmp'
    And request 
    """
    { "commands": [
      {
        "command": "gpg --list-keys 792DDB10CD01F96186E546039104BB46A497F800"
      }
    ]
    }
    """
    When method post
    Then status 200
    And match $ == 
    """
    {
    "gpg": [
    {
      "result": "#notnull",
      "success": true
    }
    ]
    }
    """

# add keys in request and check after
Scenario: add keys
    # "bash -c 'echo password | gpg -v --batch --passphrase-fd 0 -d hello.txt.gpg'"
    Given path '/'
    Given header Direktiv-ActionID = 'development'
    Given header Direktiv-Tempdir = '/tmp'
    And request 
    """
    {        
       "public": "#(pubBase64)",
       "private": "#(privBase64)",
       "commands": [
         {
          "command": "gpg --list-keys 792DDB10CD01F96186E546039104BB46A497F800"
         }
       ]
    }
    """
    When method post
    Then status 200
    And match $ == 
    """
    {
    "gpg": [
    {
      "result": "#notnull",
      "success": true
    }
    ]
    }
    """

# encrypt and decrypt a file
Scenario: decrypt
    # "bash -c 'echo password | gpg -v --batch --passphrase-fd 0 -d hello.txt.gpg'"
    Given path '/'
    Given header Direktiv-ActionID = 'development'
    Given header Direktiv-Tempdir = '/tmp'
    And request 
    """
    { 
       "commands": [
         {
         "command": "rm -f /tmp/out.pgp"
         },
         {
         "command": "rm -f /tmp/out.txt"
         },
         {
         "command": "gpg --output /tmp/out.pgp --trust-model always -v --batch -r 792DDB10CD01F96186E546039104BB46A497F800 --encrypt hello.txt"
         },
         {
         "command": "gpg --pinentry-mode loopback --passphrase password -v --output /tmp/out.txt --batch --decrypt /tmp/out.pgp"
         },
         {
         "command": "cat out.txt"
         }
       ]
    }
    """
    When method post
    Then status 200
    And match $ == 
    """
    {
    "gpg": [
    {
      "result": "",
      "success": true
    },
    {
      "result": "",
      "success": true
    },
    {
      "result": "",
      "success": true
    },
    {
      "result": "",
      "success": true
    },
    {
      "result": "Hello",
      "success": true
    }
    ]
    }
    """