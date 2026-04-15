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
		parentNamespace     : null,

		// ── Initialization ──────────────────────────────────────────────────
		async init() {
			if ( window.COMMANDBOX_NAV_DATA ) {
				this.namespaces  = window.COMMANDBOX_NAV_DATA.namespaces  || [];
				this.topLevel    = window.COMMANDBOX_NAV_DATA.topLevel    || [];
				this.allCommands = window.COMMANDBOX_NAV_DATA.allCommands || [];
			} else {
				console.error( "COMMANDBOX_NAV_DATA not found. Ensure data/navigation.js is loaded." );
			}

			// Handle direct links and back/forward navigation
			this.handleUrlHash();
			window.addEventListener( "hashchange", () => this.handleUrlHash() );
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
			this.contentHtml      = "";
			history.replaceState( null, "", window.location.pathname );
			this.$nextTick( () => this.scrollContentTop() );
		},

		showNamespace( ns, parentNs = null ) {
			if ( !ns ) return;
			// Auto-detect parent namespace from fullNamespace (e.g. "config sync" → parent "config")
			// when it isn't explicitly passed (e.g. sidebar navigation via Alpine x-for scope)
			if ( !parentNs && ns.fullNamespace && ns.fullNamespace.includes( " " ) ) {
				const parentName = ns.fullNamespace.split( " " )[ 0 ];
				parentNs = this.namespaces.find( n => n.name === parentName ) || null;
			}
			this.currentView      = "namespace";
			this.currentNamespace = ns;
			this.parentNamespace  = parentNs || null;
			this.currentCommand   = null;
			this.contentHtml      = "";
			// Expand the correct sidebar key(s)
			if ( parentNs ) {
				// Child namespace: expand parent AND parent/child key
				if ( !this.expandedNamespaces.includes( parentNs.name ) ) {
					this.expandedNamespaces.push( parentNs.name );
				}
				const childKey = parentNs.name + "/" + ns.name;
				if ( !this.expandedNamespaces.includes( childKey ) ) {
					this.expandedNamespaces.push( childKey );
				}
			} else {
				this.parentNamespace = null;
				// Top-level namespace
				if ( !this.expandedNamespaces.includes( ns.name ) ) {
					this.expandedNamespaces.push( ns.name );
				}
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

			// Update URL hash so the browser back button works
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
					this.contentHtml = `
						<div class="alert alert-warning mt-4">
							<h4><i class="bi bi-exclamation-triangle"></i> Not Found</h4>
							<p>Unable to load documentation for <strong>${ cmd.command }</strong>.</p>
						</div>`;
				}
			} catch ( error ) {
				this.contentHtml = `
					<div class="alert alert-danger mt-4">
						<h4><i class="bi bi-x-circle"></i> Error</h4>
						<p>Failed to load <strong>${ cmd.command }</strong>: ${ error.message }</p>
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

		// ── Computed ─────────────────────────────────────────────────────────
		get filteredNamespaces() {
			if ( !this.commandFilter.trim() ) return this.namespaces;
			const f = this.commandFilter.toLowerCase();
			return this.namespaces.filter( ns =>
				ns.name.toLowerCase().includes( f ) ||
				ns.commands.some( c => c.command.toLowerCase().includes( f ) ) ||
				ns.children.some( ch =>
					ch.name.toLowerCase().includes( f ) ||
					ch.commands.some( c => c.command.toLowerCase().includes( f ) )
				)
			);
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

		// Child namespace object for the current command (second word of namespace, if present)
		get currentCommandChildNs() {
			if ( !this.currentCommand?.namespace ) return null;
			const parts = this.currentCommand.namespace.split( " " );
			if ( parts.length < 2 ) return null;
			const parent = this.namespaces.find( n => n.name === parts[ 0 ] );
			return parent?.children?.find( c => c.name === parts[ 1 ] ) || null;
		},

		get totalNamespaceCount() {
			return this.namespaces.length;
		}
	};
}
