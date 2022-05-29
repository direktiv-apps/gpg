
# gpg 1.0

GPG En- and Decryption.

---
- #### Categories: tools, security
- #### Image: gcr.io/direktiv/apps/gpg 
- #### License: [Apache-2.0](https://www.apache.org/licenses/LICENSE-2.0)
- #### Issue Tracking: https://github.com/direktiv-apps/gpg/issues
- #### URL: https://github.com/direktiv-apps/gpg
- #### Maintainer: [direktiv.io](https://www.direktiv.io)
---

## About gpg

This function provides GPG to Direktiv. There are minor differences using it in a container, e.g. decryption needs
the following additional parameters `--pinentry-mode loopback` and `--batch`.

### Example(s)
  #### Function Configuration
  ```yaml
  functions:
  - id: gpg
    image: direktiv/gpg:1.0
    type: knative-workflow
  ```
   #### Decrypting
   ```yaml
   - id: req
     type: action
      action:
        function: gpg
        secrets: ["private-key.asc", "gpg-pwd"]
        files:
        - key: public-key.asc
          scope: namespace
          as: public.key
        input: 
          private: jq(.secrets."private-key.asc")
          commands: 
          - command: gpg --pinentry-mode loopback --passphrase jq(.secrets."gpg-pwd") -v --output pgp.tar.gz --batch --decrypt pgp.tar.gz.pgp
   ```
   #### Encrypting
   ```yaml
   - id: req
     type: action
      action:
        function: gpg
        secrets: ["private-key.asc", "gpg-pwd"]
        files:
        - key: public-key.asc
          scope: namespace
          as: public.key
        input: 
          private: jq(.secrets."private-key.asc")
          commands: 
          - command: gpg --output out/namespace/jq(.name).tar.gz.gpg --trust-model always --batch -r A0FD12334AA0777FB47D05854B687F9FBAC356A3 --encrypt file.tar.gz
   ```

### Request



#### Request Attributes
[PostParamsBody](#post-params-body)

### Response
  Results of command array.
#### Reponse Types
    
  

[PostOKBody](#post-o-k-body)
#### Example Reponses
    
```json
{
  "gpg": [
    {
      "result": "pub   rsa3072 2022-03-23 [SC] [expires: 2024-03-22]\n      A0FD12334AA0777FB47D05854B687F9FBAC356A3\nuid           [ unknown] DirektivTestKey \u003cinfo@direktiv.io\u003e\nsub   rsa3072 2022-03-23 [E] [expires: 2024-03-22]",
      "success": true
    }
  ]
}
```

### Errors
| Type | Description
|------|---------|
| io.direktiv.command.error | Command execution failed |
| io.direktiv.output.error | Template error for output generation of the service |
| io.direktiv.ri.error | Can not create information object from request |


### Types
#### <span id="post-o-k-body"></span> postOKBody

  



**Properties**

| Name | Type | Go type | Required | Default | Description | Example |
|------|------|---------|:--------:| ------- |-------------|---------|
| pgp | [][PostOKBodyPgpItems](#post-o-k-body-pgp-items)| `[]*PostOKBodyPgpItems` |  | |  |  |


#### <span id="post-o-k-body-pgp-items"></span> postOKBodyPgpItems

  



**Properties**

| Name | Type | Go type | Required | Default | Description | Example |
|------|------|---------|:--------:| ------- |-------------|---------|
| result | [interface{}](#interface)| `interface{}` | ✓ | |  |  |
| success | boolean| `bool` | ✓ | |  |  |


#### <span id="post-params-body"></span> postParamsBody

  



**Properties**

| Name | Type | Go type | Required | Default | Description | Example |
|------|------|---------|:--------:| ------- |-------------|---------|
| commands | [][PostParamsBodyCommandsItems](#post-params-body-commands-items)| `[]*PostParamsBodyCommandsItems` |  | | Array of commands. |  |
| files | [][DirektivFile](#direktiv-file)| `[]apps.DirektivFile` |  | | Files are getting created before running commands. |  |
| private | string| `string` |  | | Base64-encoded private GPG key. If not set `private.key` file will be used. |  |
| public | string| `string` |  | | Base64-encoded public GPG key. If not set `public.key` file will be used. |  |


#### <span id="post-params-body-commands-items"></span> postParamsBodyCommandsItems

  



**Properties**

| Name | Type | Go type | Required | Default | Description | Example |
|------|------|---------|:--------:| ------- |-------------|---------|
| command | string| `string` |  | | Command to run | `gpg --list-keys` |
| continue | boolean| `bool` |  | | Stops excecution if command fails, otherwise proceeds with next command |  |
| print | boolean| `bool` |  | `true`| If set to false the command will not print the full command with arguments to logs. |  |
| silent | boolean| `bool` |  | | If set to false the command will not print output to logs. |  |

 
