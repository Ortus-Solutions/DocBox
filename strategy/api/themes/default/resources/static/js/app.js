// DocBox Default Theme - Alpine.js Application
function docApp() {
	return {
		// State
		theme: localStorage.getItem( 'docbox-theme' ) || 'dark',
		currentView: 'overview', // overview, package, class
		currentPackage: null,
		currentClass: null,
		packages: [],
		allClasses: [],
		searchQuery: '',
		searchResults: [],
		selectedSearchIndex: 0,
		packageFilter: '',
		expandedPackages: [],
		sidebarCollapsed: false,

		// Initialize
		async init() {
			// Set initial theme
			document.documentElement.setAttribute( 'data-theme', this.theme );

			// Load navigation data
			await this.loadNavigationData();

			// Check URL hash for direct navigation
			this.handleUrlHash();

			// Listen for hash changes
			window.addEventListener( 'hashchange', () => this.handleUrlHash() );
		},

		// Load the navigation data JSON
		async loadNavigationData() {
			try {
				const response = await fetch( 'data/navigation.json' );
				const data = await response.json();
				this.packages = data.packages || [];
				this.allClasses = data.allClasses || [];
			} catch ( error ) {
				console.error( 'Failed to load navigation data:', error );
				this.packages = [];
				this.allClasses = [];
			}
		},

		// Theme Toggle
		toggleTheme() {
			this.theme = this.theme === 'dark' ? 'light' : 'dark';
			document.documentElement.setAttribute( 'data-theme', this.theme );
			localStorage.setItem( 'docbox-theme', this.theme );
		},

		// Search functionality
		performSearch() {
			if ( !this.searchQuery.trim() ) {
				this.searchResults = [];
				this.selectedSearchIndex = 0;
				return;
			}

			const query = this.searchQuery.toLowerCase();
			this.searchResults = this.allClasses.filter( cls => {
				return cls.name.toLowerCase().includes( query ) ||
					   cls.package.toLowerCase().includes( query ) ||
					   cls.fullname.toLowerCase().includes( query ) ||
					   ( cls.hint && cls.hint.toLowerCase().includes( query ) );
			} ).slice( 0, 10 ); // Limit to 10 results

			this.selectedSearchIndex = 0;
		},

		navigateSearch( direction ) {
			if ( this.searchResults.length === 0 ) return;

			this.selectedSearchIndex += direction;
			if ( this.selectedSearchIndex < 0 ) {
				this.selectedSearchIndex = this.searchResults.length - 1;
			} else if ( this.selectedSearchIndex >= this.searchResults.length ) {
				this.selectedSearchIndex = 0;
			}
		},

		selectSearchResult() {
			if ( this.searchResults.length > 0 && this.selectedSearchIndex >= 0 ) {
				const result = this.searchResults[ this.selectedSearchIndex ];
				this.navigateToClass( result );
				this.searchQuery = '';
				this.searchResults = [];
			}
		},

		// Navigation
		showOverview() {
			this.currentView = 'overview';
			this.currentPackage = null;
			this.currentClass = null;
			window.location.hash = '';
		},

		togglePackage( packageName ) {
			const index = this.expandedPackages.indexOf( packageName );
			if ( index > -1 ) {
				this.expandedPackages.splice( index, 1 );
			} else {
				this.expandedPackages.push( packageName );
			}
			this.currentPackage = packageName;
		},

		async navigateToClass( classData ) {
			this.currentView = 'class';
			this.currentClass = classData;
			this.currentPackage = classData.package;

			// Ensure package is expanded
			if ( !this.expandedPackages.includes( classData.package ) ) {
				this.expandedPackages.push( classData.package );
			}

			// Update URL hash
			window.location.hash = classData.fullname.replace( /\./g, '/' );

			// Load class content
			await this.loadClassContent( classData );
		},

		async loadClassContent( classData ) {
			const contentDiv = document.getElementById( 'class-content' );
			if (!contentDiv) return;

			try {
				// Try to load the class HTML file
				const classPath = classData.fullname.replace( /\./g, '/' ) + '.html';
				const response = await fetch( classPath );

				if ( response.ok ) {
					const html = await response.text();
					contentDiv.innerHTML = html;

					// Use setTimeout to ensure DOM is updated before Alpine initializes
					setTimeout( () => {
						// Re-initialize Alpine.js on the newly loaded content
						if ( window.Alpine ) {
							Alpine.initTree( contentDiv );
						}
					}, 0 );

					// Scroll to top
					contentDiv.scrollIntoView( { behavior: 'smooth', block: 'start' } );
				} else {
					contentDiv.innerHTML = `
						<div class="alert alert-warning">
							<h4>Class Not Found</h4>
							<p>Unable to load documentation for ${ classData.fullname }</p>
						</div>
					`;
				}
			} catch ( error ) {
				console.error( 'Failed to load class content:', error );
				contentDiv.innerHTML = `
					<div class="alert alert-danger">
						<h4>Error Loading Class</h4>
						<p>An error occurred while loading ${ classData.fullname }</p>
					</div>
				`;
			}
		},

		handleUrlHash() {
			const hash = window.location.hash.slice( 1 );
			if ( !hash ) {
				this.showOverview();
				return;
			}

			// Convert hash to class fullname (e.g., "docbox/strategy/IStrategy" -> "docbox.strategy.IStrategy")
			const fullname = hash.replace( /\//g, '.' );
			const classData = this.allClasses.find( cls => cls.fullname === fullname );

			if ( classData ) {
				this.navigateToClass( classData );
			}
		},

		// Computed Properties
		get filteredPackages() {
			if ( !this.packageFilter.trim() ) {
				return this.packages;
			}

			const filter = this.packageFilter.toLowerCase();
			return this.packages.filter( pkg => {
				return pkg.name.toLowerCase().includes( filter ) ||
					   pkg.classes.some( cls => cls.name.toLowerCase().includes( filter ) ) ||
					   pkg.interfaces.some( cls => cls.name.toLowerCase().includes( filter ) );
			});
		},

		getCurrentPackageData() {
			if ( !this.currentPackage ) return null;
			return this.packages.find( pkg => pkg.name === this.currentPackage );
		}
	};
}
