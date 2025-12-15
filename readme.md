[![All Contributors](https://img.shields.io/github/contributors/Ortus-Solutions/DocBox?style=flat-square)](https://github.com/Ortus-Solutions/DocBox/graphs/contributors)
![Latest release](https://img.shields.io/github/v/release/Ortus-Solutions/DocBox?style=flat-square)

```text
██████╗  ██████╗  ██████╗██████╗  ██████╗ ██╗  ██╗
██╔══██╗██╔═══██╗██╔════╝██╔══██╗██╔═══██╗╚██╗██╔╝
██║  ██║██║   ██║██║     ██████╔╝██║   ██║ ╚███╔╝
██║  ██║██║   ██║██║     ██╔══██╗██║   ██║ ██╔██╗
██████╔╝╚██████╔╝╚██████╗██████╔╝╚██████╔╝██╔╝ ██╗
╚═════╝  ╚═════╝  ╚═════╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝
```

# 📚 DocBox - API Documentation Generator

DocBox is a **JavaDoc-style documentation generator** for BoxLang and CFML codebases, featuring modern HTML themes, JSON output, and UML diagram generation.

📖 [Documentation][1] | 💻 [GitHub][2] | 💬 [Ortus Community][3]

---

## ✨ Features

* 🎨 **Modern HTML Documentation** - Two professional themes with dark mode support
* 🔍 **Real-time Search** - Live method filtering with keyboard navigation
* 📋 **Multiple Output Formats** - HTML, JSON, and XMI/UML diagrams
* 🦤 **BoxLang Native** - First-class BoxLang runtime and CLI support
* 📝 **JavaDoc Compatible** - Standard JavaDoc comment block parsing
* ⚡ **Alpine.js SPA** - Fast, modern single-page application interface
* 🌓 **Dark Mode** - System preference detection with manual toggle

---

## 🚀 Quick Start

### BoxLang Module (Recommended)

Install DocBox as a BoxLang module for CLI access:

```bash
# CommandBox web runtimes
box install bx-docbox

# BoxLang OS runtime
install-bx-module bx-docbox
```

Generate documentation from the command line:

```bash
boxlang module:docbox --source=/path/to/code \
                       --mapping=myapp \
                       --output-dir=/docs \
                       --project-title="My API"
```

### CFML Library

Install as a development dependency:

```bash
box install docbox --saveDev
```

Use programmatically in your build scripts:

```js
new docbox.DocBox()
    .addStrategy( "HTML", {
        projectTitle : "My API Docs",
        outputDir    : expandPath( "./docs" ),
        theme        : "default"  // or "frames"
    })
    .generate(
        source   = expandPath( "./models" ),
        mapping  = "models",
        excludes = "(tests|build)"
    );
```

---

## 📦 Installation Options

| Method | Command | Use Case |
|--------|---------|----------|
| **BoxLang Module** | `box install bx-docbox` | CLI usage, BoxLang projects |
| **CFML Library** | `box install docbox --saveDev` | Programmatic use, build scripts |
| **CommandBox Module** | `box install commandbox-docbox` | Task runner, automated builds |

---

## 🎨 Modern Themes

### Default Theme (Alpine.js SPA)

- ⚡ Client-side routing and dynamic filtering
- 🌓 Dark mode with localStorage persistence
- 🔍 Real-time method search
- 📑 Method tabs (All/Public/Private/Static/Abstract)
- 💜 Modern purple gradient design

### Frames Theme (Traditional)

- 🗂️ Classic frameset layout
- 📚 jstree navigation sidebar
- 🎯 Bootstrap 5 styling
- 📱 Mobile-friendly design

---

## 💻 System Requirements

* **BoxLang 1.0+** or **CFML Engine** (Lucee 5+, Adobe ColdFusion 2023+)
* **CommandBox** (for installation and CLI usage)

---

## 📚 Output Formats

| Format | Description | Use Case |
|--------|-------------|----------|
| **HTML** | Modern browsable documentation | Developer reference, public API docs |
| **JSON** | Machine-readable structured data | Integration with other tools, custom processing |
| **XMI** | UML diagram generation | Architecture diagrams, visual documentation |

---

## 🛠️ CLI Examples

### BoxLang Module CLI

```bash
# Basic usage
boxlang module:docbox --source=/src --mapping=app --output-dir=/docs

# Multiple source mappings
boxlang module:docbox --mappings:v1=/src/v1 --mappings:v2=/src/v2 -o=/docs

# With theme selection
boxlang module:docbox --source=/src --mapping=app --theme=frames -o=/docs

# Show help
boxlang module:docbox --help
```

### CommandBox Task Runner

Install the [commandbox-docbox](https://github.com/Ortus-Solutions/commandbox-docbox) module:

```bash
box install commandbox-docbox
```

Generate documentation using CommandBox commands:

```bash
# Generate HTML docs
box docbox generate source=/path/to/code mapping=myapp outputDir=/docs

# Generate with excludes
box docbox generate source=/src mapping=app outputDir=/docs excludes=(tests|build)

# Generate JSON docs
box docbox generate source=/src mapping=app outputDir=/docs strategy=JSON

# Show help
box docbox generate help
```

Use in a `task.cfc` for automated builds:

```js
component {
    function run() {
        command( "docbox generate" )
            .params(
                source    = getCWD() & "/models",
                mapping   = "models",
                outputDir = getCWD() & "/docs",
                excludes  = "tests"
            )
            .run();
    }
}
```

---

## 📖 Documentation

Complete documentation is available at **[docbox.ortusbooks.com][1]**

* [Getting Started](https://docbox.ortusbooks.com/getting-started/getting-started-with-docbox)
* [BoxLang CLI Tool](https://docbox.ortusbooks.com/getting-started/boxlang-cli)
* [Configuration](https://docbox.ortusbooks.com/getting-started/configuration)
* [Annotating Your Code](https://docbox.ortusbooks.com/getting-started/annotating-your-code)
* [HTML Output](https://docbox.ortusbooks.com/output-formats/html-output)
* [JSON Output](https://docbox.ortusbooks.com/output-formats/json-output)

---

## 🔗 Related Projects

* **[commandbox-docbox](https://github.com/Ortus-Solutions/commandbox-docbox)** - CommandBox module for task runner integration
* **[bx-docbox](https://forgebox.io/view/bx-docbox)** - BoxLang native module with CLI

---

## 🐛 Issues & Feature Requests

Found a bug or have an idea? Report it on our [Jira issue tracker](https://ortussolutions.atlassian.net/projects/DOCBOX)

---

## 💬 Community & Support

* 💬 [CFML Slack](http://cfml-slack.herokuapp.com/) - #box-products channel
* 🗨️ [Ortus Community Forums][3]
* 📧 [Professional Support](https://www.ortussolutions.com/services/support)

---

## 🙏 Credits

Thanks to **Mark Mandel** for the original project that inspired DocBox.

---

## 📄 License

Apache License, Version 2.0

---

## ✝️ The Daily Bread

*"I am the way, and the truth, and the life; no one comes to the Father, but by me (JESUS)"* - John 14:6

---

[1]: https://docbox.ortusbooks.com/
[2]: https://github.com/Ortus-Solutions/DocBox
[3]: https://community.ortussolutions.com/c/communities/docbox/17
