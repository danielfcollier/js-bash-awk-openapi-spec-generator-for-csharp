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

Create your documentation in the directory: `openapi`, then:

- the `apis` folder has the basic layout for your OpenAPI documents, each document is related to an API.
- any generated code is `auto-generated-spec` folder, where it can be referenced in the OpenAPI document in the `apis`` folder. It will be generated:
  - OpenAPI **schemas** for request and response body provided
  - **Templates** with each object data type accordingly to the OpenAPI specification
- optionally, it is possible to add more data, such as:
  - examples
  - codes

In the `config.json` is mandatory to relate your APIs with your .NET/C# codebase. The JSON file receives a list of objects, with the following properties:

- name: name of the API
- basename: name of the API document in the `apis` directory
- endpoints: a list with endpoints of the API. It is a list of objects, with the following properties:
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
- linting the OpenAPI with `openapi-cli`
- generating a Postman Collection from the OpenAPI files
- converting the descriptions tags `yaml` file to `csv`

To do this, change the `Dockerfile` to run `make complete` instead of the simplified version.

### Parsing Descriptions Tags

Tags applied within code notations are parsed with the help of the dictionary provided in the `openapi/descriptions.yaml` file. The dictionary provides the relationship between tags and definitions. Any description tags not documented will be automatically included in the dictionary with a placeholder "Put a description here" - lookup for these and put the proper descriptions before releasing the final OpenAPI document.

### Code Notations in the Codebase

More information and examples will be provided soon.

### Additional Information

It will be provided soon.