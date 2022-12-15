# Documentation Update

## Main Routine

1. Run the "Spec Generator": https://github.com/danielfcollier/js-bash-awk-openapi-spec-generator-for-csharp

Command: `make run`

2. Copy the generated files in `assets/openapi` to the documentation website folder at `static/openapi`

3. Use git version control to help you verify if all the changes in the documentation are valid.

### Troubleshooting

If any variable has been incorrectly generated, look up in the codebase for it or its related tag to understand if any adjustment is possible. The Spec Generator is sensible to missing spaces, make sure you have applied the following convention:

```csharp
/// description: @Description-Tag:MyVariable
public TYPE MyVariable { get; set; }
```

- Private members will be excluded from the documentation
- TYPE can be any primitive or object type: the object class definition must be on the same file, it can be within comments if it is defined in other file
- TYPE can be nullable, i.e., TYPE?

Flags are modifiers, possible values are:

- hide the property from the public documentation

```csharp
/// flag: hide
```

- enum: add the possible values separated with underscore

```csharp
/// flag: enum
/// value: 0_1_2_3
```

- date: if the primitive is `DateTime`, but it is used only as a date value

```csharp
/// flag: date
```

- uuid, empty, null, skip, method

## Descriptions Tags

1. First, run the **Main Routine**, it will update automatically with new descripion tags the file `openapi/descriptions.yaml`.

2. All new tags will have the placeholder **Put a description here.**. Thus, put the new description.

3. The new description accept the following convention:

- statement:

```yaml
Description-Tag:MyVariable: Put a description here.
```

- quoted with escaped characters:

```yaml
Description-Tag:MyVariable: 'Put a description here. (pt-br: \"Coloque uma descrição aqui.\").'
```

- quoted with ordered list or unordered list elements:

```yaml
Description-Tag:MyVariable: "Put a description here: <ul><li>Item 1</li> <li>Item 2</li> </ul>"
```

> It is not possible to break lines in the descriptions.

## Adding a New Endpoint

In the desired API document file add a new path with its related content (summary, description, parameters, requestBody, schema, examples, responses). You must also add its information in the `openapi/config.json` file.

For example, the API Merchant, which file is `openapi/apis/tuna-merchant.yaml`, and the endpoint **GetMerchant**:

```yaml
/api/Merchant/GetMerchant:
  post:
    summary: Get Merchant
    description: Get details about a specific merchant.
    operationId: GetMerchant
    parameters:
      - in: header
        name: x-tuna-account
        required: true
        schema:
          $ref: "#/components/schemas/Account"
      - in: header
        name: x-tuna-apptoken
        required: true
        schema:
          $ref: "#/components/schemas/AppToken"
    requestBody:
      content:
        application/json:
          schema:
            $ref: "../auto-generated-spec/Merchant/GetMerchantRequestSchema.yaml"
          examples:
            Template:
              $ref: "../auto-generated-spec/Merchant/GetMerchantRequestTemplate.yaml"
            GetPF:
              $ref: "../examples/Merchant/GetMerchantRequestGetPF.yaml"
            GetPJ:
              $ref: "../examples/Merchant/GetMerchantRequestGetPJ.yaml"
    responses:
      "200":
        description: Success
        content:
          application/json:
            schema:
              $ref: "../auto-generated-spec/Merchant/GetMerchantResponseSchema.yaml"
            examples:
              Template:
                $ref: "../auto-generated-spec/Merchant/GetMerchantResponseTemplate.yaml"
              GetPJ:
                $ref: "../examples/Merchant/GetMerchantResponseGetPJ.json"
              GetPF:
                $ref: "../examples/Merchant/GetMerchantResponseGetPF.json"
```

The excerpt of the configuration file is shown bellow:

```json
{
  "name": "GetMerchant",
  "source": {
    "request": "core/tuna.payment/Tuna.Payment.Engine/Services/Merchants/GetMerchant/GetMerchantRequest.cs",
    "response": "core/tuna.payment/Tuna.Payment.Engine/Services/Merchants/GetMerchant/GetMerchantResponse.cs"
  }
}
```

Note that the generated files will have the structure and files:

```
../auto-generated-spec/{API Name}/{Endpoint Name}RequestSchema.yaml
../auto-generated-spec/{API Name}/{Endpoint Name}RequestTemplate.yaml
../auto-generated-spec/{API Name}/{Endpoint Name}ResponseSchema.yaml
../auto-generated-spec/{API Name}/{Endpoint Name}ResponseTemplate.yaml
```

## Adding a New API

More information will be provided soon.
