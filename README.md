# OpenAPI Spec Generator for .NET/C# Codebase

Developed with:

- Node.js
- Bash
- AWK
- Docker
- .NET/C#
- OpenAPI v3.0.1

## How To Use It

### OpenAPI

Create your documentation in the directory `openapi`, where:

- the `apis` folder has the basic layout for your OpenAPI documents - each `yaml` document is related to one API
- any generated code is put in the `auto-generated-spec` folder, where it can be referenced in the OpenAPI  `yaml` document in the `apis` folder. It will be generated:
  - OpenAPI **schemas** for request and response bodies provided
  - **Templates** with each object data type accordingly to the OpenAPI specification
- optionally, it is possible to add more data, such as:
  - examples
  - codes

Exemplary structure of the `openapi` directory:

```
openapi/
├── apis
│   ├── tuna-merchant.yaml
│   ├── tuna-payment.yaml
│   └── tuna-token.yaml
├── auto-generated-spec
│   ├── Merchant
│   ├── Payment
│   └── Token
├── codes
│   ├── errorList.json
│   ├── paymentMethods.json
│   ├── paymentMethodStatus.json
│   └── paymentStatus.json
├── config.json
├── descriptions.yaml
└── examples
    ├── Merchant
    ├── Payment
    └── Token
```

In the `config.json` is mandatory to relate your APIs with your .NET/C# codebase. The JSON file receives a list of objects, with the following properties:

- name: name of the API
- basename: name of the API file document in the `apis` directory
- endpoints: a list of the API's endpoints. Each element of the list is an object with the following properties:
  - name: name of the endpoint
  - source: an object with the request and response files locations

### Generated Schema

Run the solution with **Docker** on Linux/Unix systems with:

```bash
make run
```

OR, locally, on Linux (only tested on Fedora 36):

```bash
make simplified
```

> The generated files will be located at `assets/openapi`

#### Generating More Assets

It is possible to modify the process to generate more assets related with:

- spell checks in the OpenAPI document and codebase
- linting the OpenAPI with the `redocly/openapi-cli`
- generating a Postman Collection from the OpenAPI files
- converting the descriptions tags from `yaml` to `csv`

To do this, change the `Dockerfile` to run `make complete` instead of the simplified version.

### Parsing Descriptions Tags

Tags applied within code notations are parsed with the help of the dictionary provided in the `openapi/descriptions.yaml` file.

The dictionary provides the relationship between tags and definitions.

> Any description tags not documented will be automatically included in the dictionary with a placeholder **"Put a description here"** - lookup for these and put the proper descriptions before releasing the final OpenAPI document.

### Codebase

In the project directory, add a folder name `csharp` and within it add your codebase. The relative paths in your `config.json` are related to this directory.

> Suggestion: add your codebase as git submodules in this directory.

### Code Notations in the Codebase

More information and examples will be provided soon.

### Additional Information

It will be provided soon.
