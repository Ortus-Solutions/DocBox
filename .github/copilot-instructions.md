# DocBox - AI Coding Instructions

DocBox is a JavaDoc-style API documentation generator for CFML/BoxLang codebases. It parses CFC metadata and generates documentation in multiple formats (HTML, JSON, XMI) using a pluggable strategy pattern.

## Architecture & Core Components

**Core Generator** (`DocBox.cfc`): Main orchestrator that accepts source directories and delegates to one or more output strategies. Supports multiple strategies simultaneously (e.g., generate both HTML and JSON in one pass).

**Strategy Pattern**: All output formats extend `AbstractTemplateStrategy.cfc` and implement a `run(query metadata)` method:
- `strategy/api/HTMLAPIStrategy.cfc` - Default HTML documentation with frames/navigation using Bootstrap 5
- `strategy/json/JSONAPIStrategy.cfc` - Machine-readable JSON output
- `strategy/uml2tools/XMIStrategy.cfc` - XMI/UML diagram generation
- `strategy/CommandBox/CommandBoxStrategy.cfc` - CommandBox-specific output format

**Theme Support**: HTMLAPIStrategy now supports theming via the `theme` property (default: "frames"). Theme resources are organized under `/strategy/api/themes/{themeName}/resources/`:
- `/templates/` - CFML template files
- `/static/` - CSS, JS, image assets

**Metadata Pipeline**: DocBox builds a query object containing parsed CFC metadata via `buildMetaDataCollection()` which:
1. Recursively scans source directories for `*.cfc` files
2. Parses JavaDoc-style comments and component metadata
3. Resolves inheritance chains (`extends`, `implements`)
4. Applies exclusion regex patterns
5. Returns query with columns: `package`, `name`, `extends`, `metadata`, `type`, `implements`, `fullextends`, `currentMapping`

**Strategy Initialization**: Strategies can be specified as:
- String shortcuts: `"HTML"`, `"JSON"`, `"XMI"`, `"CommandBox"`
- Full class paths: `"docbox.strategy.api.HTMLAPIStrategy"`
- Instantiated objects: `new docbox.strategy.api.HTMLAPIStrategy(outputDir="/docs", theme="frames")`

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

**Template Rendering**: HTML strategy uses CFML includes (not a template engine) with theme-based template paths:
- `/strategy/api/themes/{theme}/resources/templates/` - CFML template files
- `/strategy/api/themes/{theme}/resources/static/` - CSS, JS, image assets
- Templates receive metadata via local scope variables, not arguments

**Modern UI/UX Design** (Bootstrap 5):
- **Framework**: Bootstrap 5.3.2 with modern component syntax and data-bs-* attributes
- **Icons**: Bootstrap Icons 1.11.2 for UI elements and visual indicators
- **Design System**: CSS custom properties for theming with light/dark mode support
- **Color Scheme**: Purple gradient accents (#5e72e4 primary), softer colors, reduced blue overload
- **Emojis**: Visual indicators throughout (📚 packages, 📁 folders, 🔌 interfaces, 📦 classes, 🟢 public, 🔒 private, ⚡ static, 📝 abstract)
- **Typography**: Modern font stack with proper hierarchy and spacing
- **Cards**: Modern card-based layouts with subtle shadows and hover effects
- **Breadcrumbs**: Package navigation with clickable hierarchy
- **Method Tabs**: Tabbed interface for filtering methods (All/Public/Private/Static/Abstract)
- **Visibility Indicators**: Emoji badges with Bootstrap tooltips for access levels and modifiers
- **Dark Mode**: Full dark mode support with theme toggle, localStorage persistence, and smooth transitions
- **Method Search**: Real-time search with keyboard navigation (Enter/Shift+Enter), visual highlighting, and auto-scroll

**Interactive Features**:
- **jstree Navigation**: Auto-expands first 2 levels for better UX
- **Bootstrap Tooltips**: Contextual help on visibility badges and deprecated methods
- **Method Search**: Live filtering with highlight, navigate with Enter (next) / Shift+Enter (previous), clear with Escape
- **Smooth Scrolling**: Enhanced navigation with smooth scroll behavior
- **Theme Toggle**: Persistent dark/light mode preference with moon/sun icon indicator

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

## HTML Documentation Styling & Components

**CSS Architecture**:
- **Custom Properties**: Comprehensive theming system with CSS variables for colors, spacing, and component styles
- **Light Mode**: Clean white backgrounds, dark text, soft borders (#e9ecef), purple primary (#5e72e4)
- **Dark Mode**: Dark blue-gray backgrounds (#1a202c), light text (#e2e8f0), adjusted colors for visibility
- **Transitions**: Smooth 0.3s transitions for theme changes and interactive elements
- **Responsive Design**: Mobile-friendly layouts with proper breakpoints

**Key Template Files**:
- `class.cfm` - Individual class/interface documentation with method details, tabbed summaries, and search
- `package-summary.cfm` - Package overview with class/interface listings
- `overview-summary.cfm` - Project overview with all packages
- `overview-frame.cfm` - Left navigation tree with jstree
- `inc/nav.cfm` - Top navigation bar with theme toggle
- `inc/common.cfm` - Shared assets (Bootstrap CDN, jQuery, tooltips, theme toggle JS)

**UI Components**:
- **Breadcrumbs**: Package hierarchy navigation with emoji indicators (📚 All Packages, 📁 package names)
- **Cards**: Modern card layouts for sections (properties, constructors, methods)
- **Tables**: Hover states, proper borders, responsive design
- **Badges**: Access modifiers (public/private), abstract indicators, deprecated warnings
- **Method Tabs**: Bootstrap 5 nav-tabs with counts for each visibility level
- **Signatures**: Code blocks with syntax highlighting and border accents
- **Search Input**: Positioned in Method Summary header with real-time filtering

**JavaScript Features**:
- **Tooltip Initialization**: Bootstrap tooltips for visibility badges and metadata
- **Theme Toggle**: Detects saved preference, toggles data-theme attribute, updates icon (moon/sun)
- **Method Search**: Indexes methods by name/signature, filters on input, highlights matches, keyboard navigation
- **Smooth Scroll**: Auto-scrolls to search results and hash targets
- **jstree Auto-expand**: Expands first 2 levels of package tree on load

**Accessibility**:
- **ARIA Labels**: Proper labeling for navigation, tabs, and interactive elements
- **Semantic HTML**: Proper heading hierarchy, nav elements, table structure
- **Tooltips**: Descriptive titles for icons and badges
- **Keyboard Navigation**: Tab order, Enter/Escape for search, arrow keys supported

## Coding Conventions

**JavaScript Style**:
- **Spacing Requirements**: All JavaScript code must include spacing in parentheses, brackets, and quotes for improved readability
- **Function Calls**: Space after function name and inside parentheses: `func( arg1, arg2 )`
- **Array Literals**: Space inside brackets: `[ item1, item2, item3 ]`
- **Object Literals**: Space inside braces and around colons: `{ key: value, another: val }`
- **Conditionals**: Space inside condition parentheses: `if ( condition )`, `while ( test )`
- **Template Literals**: Space inside interpolation: `${ variable }` not `${variable}`
- **Method Chaining**: Proper spacing in chains: `.filter( x => x.active ).map( x => x.name )`
- **Arrow Functions**: Space around arrows: `( x ) => x + 1` or `x => x + 1` for single param
- **Examples**:
  ```javascript
  // Correct spacing
  const result = array.filter( item => item.active ).slice( 0, 10 );
  if ( !value ) return null;
  localStorage.setItem( 'key', data );
  obj.method( param1, param2 );
  const html = `<p>${ value }</p>`;
  
  // Incorrect - missing spacing
  const result = array.filter(item => item.active).slice(0, 10);
  if (!value) return null;
  localStorage.setItem('key', data);
  obj.method(param1, param2);
  const html = `<p>${value}</p>`;
  ```

**CFML/BoxLang Style**: 
- Follow CFFormat rules defined in `.cfformat.json`
- Spacing in all markers: function calls `func( arg )`, conditions `if ( test )`, arrays `[ 1, 2 ]`, structs `{ key : value }`
- Binary operators require padding: `a + b`, `x == y`
- 4-space tabs, max 115 columns, double quotes for strings
- Consecutive assignments, properties, and parameters are aligned
