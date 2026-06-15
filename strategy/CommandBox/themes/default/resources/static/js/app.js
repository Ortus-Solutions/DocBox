// CommandBox Documentation SPA - Alpine.js Application
// Replaces the frameset layout with an accessible single-page experience.
function commandApp() {
	return {
		// ── State ──────────────────────────────────────────────────────────
		currentView         : "overview",
		currentCommand      : null,
		currentNamespace    : null,
		namespaces          : [],
		topLevel            : [],
		allCommands         : [],
		searchQuery         : "",
		searchResults       : [],
		selectedSearchIndex : 0,
		commandFilter       : "",
		expandedNamespaces  : [],
		sidebarCollapsed    : false,
		contentLoading      : false,
		contentHtml         : "",
		parentNamespace          : null,
		systemView               : false,
		_navigatingProgrammatically : false,

		// ── Initialization ──────────────────────────────────────────────────
		async init() {
			if ( window.COMMANDBOX_NAV_DATA ) {
				this.namespaces  = window.COMMANDBOX_NAV_DATA.namespaces  || [];
				this.topLevel    = window.COMMANDBOX_NAV_DATA.topLevel    || [];
				this.allCommands = window.COMMANDBOX_NAV_DATA.allCommands || [];
			} else {
				console.error( "COMMANDBOX_NAV_DATA not found. Ensure data/navigation.js is loaded." );
			}

			// Check and modify legacy/frames link
			this.handleLegacyLink();
			
			// Handle direct links and back/forward navigation
			this.handleUrlHash();
			window.addEventListener( "hashchange", () => {
				// Ignore hash changes that we triggered ourselves inside loadCommand()
				if ( this._navigatingProgrammatically ) {
					this._navigatingProgrammatically = false;
					return;
				}
				this.handleUrlHash();
			} );
		},
		// ── Clean incoming legacy/frames links ────────────────────────────────────────────────
		handleLegacyLink() {
			// if window.location.search is not empty, and starts with "?commandbox"
			if ( window.location.search && window.location.search.startsWith( "?commandbox" ) ) {
				var searchString = window.location.search.slice( 1 ); // remove the "?" at the start
				// if searchString ends with ".html", remove it
				if ( searchString.endsWith( ".html" ) ) {
					searchString = searchString.slice( 0, -5 );
				}
				// replace "?" with "#" and update the URL without reloading the page
				const newHash = "#" + searchString;
				// remove the search part from the URL and add the hash
				window.history.replaceState( null, "", window.location.pathname + newHash );
				return;
			}
		},
		// ── URL Hash Routing ────────────────────────────────────────────────
		handleUrlHash() {
			const hash = window.location.hash.slice( 1 );
			if ( !hash ) {
				this.showOverview();
				return;
			}
			// Hash is the link path minus ".html" (e.g. "commandbox/commands/server/start")
			const link = hash + ".html";
			const cmd  = this.allCommands.find( c => c.link === link );
			if ( cmd ) {
				this.loadCommand( cmd );
			} else {
				this.showOverview();
			}
		},

		// ── Views ────────────────────────────────────────────────────────────
		showOverview() {
			this.currentView      = "overview";
			this.currentCommand   = null;
			this.currentNamespace = null;
			this.parentNamespace  = null;
			this.systemView       = false;
			this.contentHtml      = "";
			history.replaceState( null, "", window.location.pathname );
			this.$nextTick( () => this.scrollContentTop() );
		},

		showNamespace( ns, parentNs = null ) {
			if ( !ns ) return;
			this.currentView      = "namespace";
			this.currentNamespace = ns;
			this.currentCommand   = null;
			this.contentHtml      = "";

			// Expand all ancestor sidebar keys using the space-separated fullNamespace path.
			// e.g. fullNamespace "server java sub" → expands "server", "server/java", "server/java/sub"
			if ( ns.fullNamespace ) {
				const parts = ns.fullNamespace.split( " " );
				for ( let i = 0; i < parts.length; i++ ) {
					const key = parts.slice( 0, i + 1 ).join( "/" );
					if ( !this.expandedNamespaces.includes( key ) ) {
						this.expandedNamespaces.push( key );
					}
				}
				// Resolve immediate parent namespace object when not explicitly supplied
				if ( !parentNs && parts.length > 1 ) {
					const parentParts = parts.slice( 0, -1 );
					let node = this.namespaces.find( n => n.name === parentParts[ 0 ] );
					for ( let i = 1; i < parentParts.length && node; i++ ) {
						node = ( node.children || [] ).find( c => c.name === parentParts[ i ] );
					}
					parentNs = node || null;
				}
			} else {
				// Top-level namespace (no fullNamespace property)
				if ( !this.expandedNamespaces.includes( ns.name ) ) {
					this.expandedNamespaces.push( ns.name );
				}
			}

			this.parentNamespace = parentNs || null;
			this.$nextTick( () => this.scrollContentTop() );
		},

		showSystemCommands() {
			this.currentView      = "system";
			this.currentCommand   = null;
			this.currentNamespace = null;
			this.parentNamespace  = null;
			this.contentHtml      = "";
			if ( !this.expandedNamespaces.includes( "__system__" ) ) {
				this.expandedNamespaces.push( "__system__" );
			}
			this.$nextTick( () => this.scrollContentTop() );
		},

		async loadCommand( cmd ) {
			if ( !cmd || !cmd.link ) return;

			this.currentView    = "command";
			this.currentCommand = cmd;
			this.contentLoading = true;
			this.contentHtml    = "";

			// Expand the parent namespace(s) in the sidebar
			if ( cmd.namespace ) {
				cmd.namespace.split( " " ).forEach( ( part, i, parts ) => {
					const key = i === 0 ? part : parts.slice( 0, i + 1 ).join( "/" );
					if ( !this.expandedNamespaces.includes( key ) ) {
						this.expandedNamespaces.push( key );
					}
				} );
			}

			// Update URL hash for browser back/forward — flag it so the hashchange
			// listener knows this change originated here and skips re-routing.
			this._navigatingProgrammatically = true;
			window.location.hash = cmd.link.replace( /\.html$/, "" );

			try {
				const response = await fetch( cmd.link );
				if ( response.ok ) {
					const html      = await response.text();
					const parser    = new DOMParser();
					const doc       = parser.parseFromString( html, "text/html" );
					// Use the stable id first; nav.cfm also emits a .container-fluid so
					// querySelector( '.container-fluid' ) would return the wrong element.
					const containers = doc.querySelectorAll( ".container-fluid" );
					const container  = doc.getElementById( "command-content" )
						|| ( containers.length > 0 ? containers[ containers.length - 1 ] : null );
					this.contentHtml = container ? container.innerHTML : doc.body.innerHTML;
				} else {
					const safeCommand = this.escapeHtml( cmd.command );
					this.contentHtml = `
						<div class="alert alert-warning mt-4">
							<h4><i class="bi bi-exclamation-triangle"></i> Not Found</h4>
							<p>Unable to load documentation for <strong>${ safeCommand }</strong>.</p>
						</div>`;
				}
			} catch ( error ) {
				const safeCommand = this.escapeHtml( cmd.command );
				const safeMessage = this.escapeHtml( error.message );
				this.contentHtml = `
					<div class="alert alert-danger mt-4">
						<h4><i class="bi bi-x-circle"></i> Error</h4>
						<p>Failed to load <strong>${ safeCommand }</strong>: ${ safeMessage }</p>
					</div>`;
			}

			this.contentLoading = false;

			this.$nextTick( () => {
				this.scrollContentTop();
				// Re-run syntax highlighting on the newly injected content
				if ( window.SyntaxHighlighter ) {
					SyntaxHighlighter.config.stripBrs  = true;
					SyntaxHighlighter.defaults.gutter  = false;
					SyntaxHighlighter.defaults.toolbar = false;
					SyntaxHighlighter.highlight();
				}
			} );
		},

		// ── Sidebar ──────────────────────────────────────────────────────────

		// Recursively count all commands under a namespace at any depth.
		countCommands( ns ) {
			let n = ( ns.commands || [] ).length;
			for ( const ch of ns.children || [] ) n += this.countCommands( ch );
			return n;
		},

		toggleNamespace( key ) {
			const idx = this.expandedNamespaces.indexOf( key );
			if ( idx > -1 ) {
				this.expandedNamespaces.splice( idx, 1 );
			} else {
				this.expandedNamespaces.push( key );
			}
		},

		isExpanded( key ) {
			return this.expandedNamespaces.includes( key );
		},

		// ── Search ────────────────────────────────────────────────────────────
		performSearch() {
			if ( !this.searchQuery.trim() ) {
				this.searchResults      = [];
				this.selectedSearchIndex = 0;
				return;
			}
			const q = this.searchQuery.toLowerCase();
			this.searchResults = this.allCommands
				.filter( c =>
					c.command.toLowerCase().includes( q ) ||
					c.searchList.toLowerCase().includes( q ) ||
					( c.hint && c.hint.toLowerCase().includes( q ) )
				)
				.slice( 0, 12 );
			this.selectedSearchIndex = 0;
		},

		navigateSearch( direction ) {
			if ( !this.searchResults.length ) return;
			this.selectedSearchIndex += direction;
			if ( this.selectedSearchIndex < 0 ) {
				this.selectedSearchIndex = this.searchResults.length - 1;
			} else if ( this.selectedSearchIndex >= this.searchResults.length ) {
				this.selectedSearchIndex = 0;
			}
		},

		selectSearchResult() {
			if ( this.searchResults.length > 0 ) {
				this.loadCommand( this.searchResults[ this.selectedSearchIndex ] );
				this.searchQuery   = "";
				this.searchResults = [];
			}
		},

		// ── Utilities ────────────────────────────────────────────────────────
		scrollContentTop() {
			const main = document.getElementById( "main-content" );
			if ( main ) main.scrollTop = 0;
		},

		// Escape a string for safe insertion into HTML to prevent XSS
		escapeHtml( str ) {
			if ( typeof str !== "string" ) return "";
			const div = document.createElement( "div" );
			div.textContent = str;
			return div.innerHTML;
		},

		// ── Computed ─────────────────────────────────────────────────────────

		/**
		 * Flattens the namespace tree into a depth-annotated list for the sidebar.
		 * Only items whose ancestors are currently expanded are included, so
		 * visibility is driven by list membership rather than x-show.
		 * commandFilter is applied recursively at every depth.
		 *
		 * Each item is one of:
		 *   { type: "ns",  depth, key, ns  }   — namespace header (folder button)
		 *   { type: "cmd", depth, cmd       }   — command link
		 */
		get flatSidebarItems() {
			const items = [];
			const f     = this.commandFilter.toLowerCase().trim();

			const matchesFilter = ( ns ) => {
				if ( !f ) return true;
				if ( ns.name.toLowerCase().includes( f ) ) return true;
				if ( ( ns.commands || [] ).some( c => c.command.toLowerCase().includes( f ) ) ) return true;
				return ( ns.children || [] ).some( ch => matchesFilter( ch ) );
			};

			const flatten = ( nsList, depth, parentKey ) => {
				for ( const ns of nsList ) {
					if ( !matchesFilter( ns ) ) continue;
					const key = parentKey ? parentKey + "/" + ns.name : ns.name;
					items.push( { type: "ns", depth, key, ns } );
					if ( this.isExpanded( key ) ) {
						const visibleCmds = !f
							? ( ns.commands || [] )
							: ( ns.commands || [] ).filter( c => c.command.toLowerCase().includes( f ) );
						for ( const cmd of visibleCmds ) {
							items.push( { type: "cmd", depth: depth + 1, cmd } );
						}
						if ( ns.children && ns.children.length ) {
							flatten( ns.children, depth + 1, key );
						}
					}
				}
			};

			flatten( this.namespaces, 0, "" );
			return items;
		},

		get totalCommandCount() {
			return this.allCommands.length;
		},

		// Root namespace object for the current command (first word of namespace)
		get currentCommandParentNs() {
			if ( !this.currentCommand?.namespace ) return null;
			const parentName = this.currentCommand.namespace.split( " " )[ 0 ];
			return this.namespaces.find( n => n.name === parentName ) || null;
		},

		// Deepest child namespace object for the current command.
		// For "server java sub", walks namespaces → server → children → java → children → sub.
		get currentCommandChildNs() {
			if ( !this.currentCommand?.namespace ) return null;
			const parts = this.currentCommand.namespace.split( " " );
			if ( parts.length < 2 ) return null;
			let node = this.namespaces.find( n => n.name === parts[ 0 ] );
			if ( !node ) return null;
			for ( let i = 1; i < parts.length; i++ ) {
				const next = ( node.children || [] ).find( c => c.name === parts[ i ] );
				if ( !next ) return null;
				node = next;
			}
			return node;
		},

		get totalNamespaceCount() {
			return this.namespaces.length;
		}
	};
}
