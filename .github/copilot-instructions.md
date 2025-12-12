# DocBox - AI Coding Instructions

DocBox is a JavaDoc-style API documentation generator for CFML/BoxLang codebases. It parses CFC metadata and generates documentation in multiple formats (HTML, JSON, XMI) using a pluggable strategy pattern.

## Architecture & Core Components

**Core Generator** (`DocBox.cfc`): Main orchestrator that accepts source directories and delegates to one or more output strategies. Supports multiple strategies simultaneously (e.g., generate both HTML and JSON in one pass).

**Strategy Pattern**: All output formats extend `AbstractTemplateStrategy.cfc` and implement a `run(query metadata)` method:
- `strategy/api/HTMLAPIStrategy.cfc` - Default HTML documentation with frames/navigation
- `strategy/json/JSONAPIStrategy.cfc` - Machine-readable JSON output
- `strategy/uml2tools/XMIStrategy.cfc` - XMI/UML diagram generation
- `strategy/CommandBox/CommandBoxStrategy.cfc` - CommandBox-specific output format

**Metadata Pipeline**: DocBox builds a query object containing parsed CFC metadata via `buildMetaDataCollection()` which:
1. Recursively scans source directories for `*.cfc` files
2. Parses JavaDoc-style comments and component metadata
3. Resolves inheritance chains (`extends`, `implements`)
4. Applies exclusion regex patterns
5. Returns query with columns: `package`, `name`, `extends`, `metadata`, `type`, `implements`, `fullextends`, `currentMapping`

**Strategy Initialization**: Strategies can be specified as:
- String shortcuts: `"HTML"`, `"JSON"`, `"XMI"`, `"CommandBox"`
- Full class paths: `"docbox.strategy.api.HTMLAPIStrategy"`
- Instantiated objects: `new docbox.strategy.api.HTMLAPIStrategy(outputDir="/docs")`

## Critical Developer Workflows

**Self-Documentation Pattern** (`build/Docs.cfc`): DocBox generates its own API docs by instantiating itself and calling `generate()`. This is the canonical example:
```cfml
new docbox.DocBox()
    .addStrategy("HTML", { projectTitle: "DocBox API Docs", outputDir: "/apidocs" })
    .addStrategy("JSON", { projectTitle: "DocBox API Docs", outputDir: "/apidocs" })
    .generate(source="/docbox", mapping="docbox", excludes="(.github|build|tests)");
```

**Build Scripts** (via CommandBox):
- `box run-script build` - Full build process (source copy, token replacement, checksums)
- `box run-script build:docs` - Generate DocBox's own documentation
- `box run-script tests` - Run TestBox suite via `testbox run` command
- `box run-script format` - Format code using CFFormat
- `box run-script format:watch` - Auto-format on file changes

**Testing**: Uses TestBox BDD suite in `/tests/specs/`. Tests verify:
- Multiple strategy execution
- Default HTML strategy fallback
- Custom strategy injection via mocking
- Directory existence validation
- Exclusion pattern application

## Key Implementation Patterns

**Query-Based Metadata**: Unlike typical ORM patterns, DocBox uses CFML Query objects throughout for metadata storage and manipulation. The `AbstractTemplateStrategy` includes helper methods like `getPackageQuery()`, `buildPackageTree()`, and `visitPackageTree()` that operate on query results using QoQ (Query of Queries).

**Template Rendering**: HTML strategy uses CFML includes (not a template engine) with predefined template paths:
- `/strategy/api/resources/templates/` - CFML template files
- `/strategy/api/resources/static/` - CSS, JS, image assets
- Templates receive metadata via local scope variables, not arguments

**Package Tree Navigation**: `buildPackageTree()` converts flat package names into nested structures for navigation. Example: `"coldbox.system.web"` becomes `{coldbox: {system: {web: {}}}}`. Used by HTML strategy for hierarchical navigation.

**Custom Annotations**: DocBox recognizes standard JavaDoc tags plus custom annotations:
- `@doc_abstract` - Mark components as abstract
- `@doc_generic` - Specify generic types for returns/arguments (e.g., `@doc_generic="Array<User>"`)

**Exclusion Regex**: Applied to relative file paths (not absolute) to ensure portability. Example: `excludes="(coldbox|build|tests)"` matches paths containing those strings.

## Multi-Engine Compatibility

**Server Configurations**: Project includes server JSON files for testing on multiple engines:
- `server-lucee@5.json`, `server-lucee@6.json` - Lucee 5.x and 6.x
- `server-adobe@2023.json`, `server-adobe@2025.json` - Adobe ColdFusion
- `server-boxlang@1.json`, `server-boxlang@be.json` - BoxLang runtime and bleeding edge

**Engine-Specific Considerations**: Code avoids engine-specific features. Uses native CFML query operations, file I/O, and component metadata introspection that work across all engines.

## Build Process Details

**Token Replacement**: Build system replaces `@build.version@` and `@build.number@` tokens in files during packaging. Handled by CommandBox's `tokenReplace` command.

**Artifact Structure**: Build outputs to `.artifacts/{projectName}/{version}/` with:
- Source ZIP with version in filename
- API docs ZIP
- MD5 and SHA-512 checksums for all artifacts

**Exclusion Patterns** (`variables.excludes` in Build.cfc):
```cfml
["build", "testbox", "tests", "server-.*\.json", "^\..*", "coldbox-5-router-documentation.png", "docs"]
```

## Common Development Patterns

**Adding New Strategies**: Extend `AbstractTemplateStrategy.cfc` and implement `run(required query qMetadata)`. Register in `DocBox.cfc` switch statement if using shortcut name.

**Strategy Properties**: Pass via constructor or properties struct. HTML strategy requires `outputDir` and optional `projectTitle`. JSON strategy requires same. XMI requires `outputFile` instead.

**Error Handling**: Strategies throw `InvalidConfigurationException` for missing directories or invalid configuration. DocBox's `generate()` method accepts `throwOnError` boolean to control behavior on invalid components.

**Caching**: `AbstractTemplateStrategy` includes `functionQueryCache` and `propertyQueryCache` properties for storing filtered query results to avoid repeated QoQ operations during rendering.
