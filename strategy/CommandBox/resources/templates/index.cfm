<cfoutput>
<!DOCTYPE html>
<html lang="en" x-data="commandApp()" x-init="init()">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>#arguments.projectTitle# - Command Documentation</title>
	<link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>⚡</text></svg>">

	<!-- Bootstrap 5 -->
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css">

	<!-- SPA Stylesheet -->
	<link rel="stylesheet" href="css/stylesheet.css">

	<!-- Syntax Highlighter (pre-loaded so injected command pages can re-trigger it) -->
	<link type="text/css" rel="stylesheet" href="highlighter/styles/shCoreEmacs.css">
</head>
<body>

	<!-- ── Skip to content (accessibility) ─────────────────────────── -->
	<a class="visually-hidden-focusable" href="##main-content">Skip to main content</a>

	<!-- ── Top Navbar ──────────────────────────────────────────────── -->
	<header class="spa-navbar" role="banner">
		<a class="spa-navbar-brand" href="##" @click.prevent="showOverview()" aria-label="#arguments.projectTitle# home">
			<svg id="Layer_2" data-name="Layer 2" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 565.97 411.5" style="height: 20px;">
				<g id="Layer_1-2" data-name="Layer 1">
					<g>
						<path class="swirl" d="M504.76,73.24c-47.74-38.38-157.72-64.12-240.56,19.19-90.33,112.33-50.55,280.35,120.74,297.2,94.55-2.81,140.88-42.6,140.88-42.6,9.84-1.87-124.02,125.91-288.76,26.69-76.29-55.23-96.41-139.01-83.31-206.4,13.57-66.46,62.25-119.82,89.86-136.2,123.09-75.35,240.1,5.15,261.15,42.12Z"/>
						<path class="swirl" d="M451.41,64.81s72.54,22,80.03,129.18c7.96,107.64-116.54,161.94-190.01,136.19-71.14-19.65-107.18-114.2-99.22-172.23-6.55,10.3-16.84,93.14,15.45,145.09,41.18,66.46,180.66,118.4,274.73,9.82,68.8-85.65,13.1-192.82-2.34-202.18-7.02-14.52-54.76-43.07-78.63-45.87Z"/>
						<path class="swirl" d="M275.9,144.85s76.29-81.91,157.25-17.32c74.44,70.21,17.8,157.73-13.1,168.96-25.74,18.73-82.37,18.26-82.37,18.26,17.79,7.49,125.43,21.06,157.72-80.03,25.28-97.35-60.37-153.98-108.12-154.92-65.05-.46-97.34,33.23-111.39,65.06Z"/>
					</g>
					<path class="chevron" d="M.5,47.65l132.03,137.37v56.6L.5,379.56v-62.29l100.31-103.53L.5,109.93v-62.29Z"/>
				</g>
			</svg>
			#arguments.projectTitle#
		</a>

		<!-- Global search -->
		<div class="spa-search-wrap">
			<input
				type="search"
				class="spa-search-input"
				placeholder="⚡ Search commands..."
				x-model="searchQuery"
				@input="performSearch()"
				@keydown.escape="searchQuery = ''; searchResults = []"
				@keydown.down.prevent="navigateSearch( 1 )"
				@keydown.up.prevent="navigateSearch( -1 )"
				@keydown.enter.prevent="selectSearchResult()"
				aria-label="Search commands"
				aria-autocomplete="list"
				:aria-expanded="searchResults.length > 0"
				role="combobox"
			>
			<!-- Search results dropdown -->
			<div class="search-results" x-show="searchResults.length > 0" x-cloak role="listbox" aria-label="Search results">
				<template x-for="( result, index ) in searchResults" :key="result.link">
					<a
						href="##"
						class="search-result-item"
						:class="{ 'active': index === selectedSearchIndex }"
						role="option"
						:aria-selected="index === selectedSearchIndex"
						@click.prevent="loadCommand( result ); searchQuery = ''; searchResults = []"
						@mouseenter="selectedSearchIndex = index"
					>
						<div class="d-flex align-items-center gap-2">
							<i class="bi bi-lightning-charge text-warning" aria-hidden="true"></i>
							<div class="flex-grow-1 overflow-hidden">
								<div class="result-name" x-text="result.command"></div>
								<div class="result-hint text-truncate" x-show="result.hint" x-text="result.hint"></div>
							</div>
							<span class="badge bg-secondary ms-1" x-text="result.namespace || 'system'"></span>
						</div>
					</a>
				</template>
			</div>
		</div>

		<!-- Mobile sidebar toggle -->
		<button
			class="sidebar-toggle d-lg-none ms-auto"
			@click="sidebarCollapsed = !sidebarCollapsed"
			:aria-label="sidebarCollapsed ? 'Show navigation' : 'Hide navigation'"
			:aria-expanded="!sidebarCollapsed"
		>
			<i class="bi bi-layout-sidebar-inset" aria-hidden="true"></i>
		</button>
	</header>

	<!-- ── Main Layout ─────────────────────────────────────────────── -->
	<div class="main-container">

		<!-- ── Sidebar ───────────────────────────────────────────── -->
		<aside
			class="sidebar"
			:class="{ 'collapsed': sidebarCollapsed }"
			aria-label="Command navigation"
		>
			<div class="sidebar-header">
				<h1 class="fs-6"><i class="bi bi-terminal" aria-hidden="true"></i> Commands</h1>
				<button
					class="sidebar-toggle"
					@click="sidebarCollapsed = !sidebarCollapsed"
					:aria-label="sidebarCollapsed ? 'Expand sidebar' : 'Collapse sidebar'"
					:aria-expanded="!sidebarCollapsed"
				>
					<i class="bi" :class="sidebarCollapsed ? 'bi-chevron-right' : 'bi-chevron-left'" aria-hidden="true"></i>
				</button>
			</div>

			<div class="sidebar-content" x-show="!sidebarCollapsed">
				<!-- Filter -->
				<div class="mb-2">
					<input
						type="text"
						class="form-control form-control-sm"
						placeholder="Filter commands..."
						x-model="commandFilter"
						aria-label="Filter navigation commands"
					>
				</div>

				<!-- Namespace tree -->
				<nav class="command-tree" aria-label="Command namespaces">

					<template x-for="ns in filteredNamespaces" :key="ns.name">
						<div class="namespace-item">
							<button
								class="namespace-btn"
								:class="{ 'active': currentNamespace?.name === ns.name }"
								:aria-expanded="isExpanded( ns.name )"
							@click="isExpanded( ns.name ) ? toggleNamespace( ns.name ) : ( toggleNamespace( ns.name ), showNamespace( ns ) )"
							>
								<i class="bi" :class="isExpanded( ns.name ) ? 'bi-folder2-open' : 'bi-folder2'" aria-hidden="true"></i>
								<span x-text="ns.name" class="flex-grow-1"></span>
								<span class="badge" x-text="ns.commands.length + ns.children.reduce( ( s, c ) => s + c.commands.length, 0 )"></span>
							</button>

							<!-- Commands in this namespace -->
							<div class="namespace-commands" x-show="isExpanded( ns.name )" x-cloak>
								<template x-for="cmd in ns.commands" :key="cmd.link">
									<a
										href="##"
										class="command-item"
										:class="{ 'active': currentCommand?.link === cmd.link }"
										@click.prevent="loadCommand( cmd )"
										x-text="cmd.name"
									></a>
								</template>

								<!-- Child namespaces (one level deep) -->
								<template x-for="child in ns.children" :key="child.name">
									<div class="child-ns-block">
										<button
											class="namespace-btn child-ns"
											:aria-expanded="isExpanded( ns.name + '/' + child.name )"
											@click="toggleNamespace( ns.name + '/' + child.name )"
										>
											<i class="bi" :class="isExpanded( ns.name + '/' + child.name ) ? 'bi-folder2-open' : 'bi-folder2'" aria-hidden="true"></i>
											<span x-text="child.name" class="flex-grow-1"></span>
											<span class="badge" x-text="child.commands.length"></span>
										</button>
										<div class="namespace-commands" x-show="isExpanded( ns.name + '/' + child.name )" x-cloak>
											<template x-for="cmd in child.commands" :key="cmd.link">
												<a
													href="##"
													class="command-item"
													:class="{ 'active': currentCommand?.link === cmd.link }"
													@click.prevent="loadCommand( cmd )"
													x-text="cmd.name"
												></a>
											</template>
										</div>
									</div>
								</template>
							</div>
						</div>
					</template>

					<!-- System (top-level) commands -->
					<div class="namespace-item" x-show="topLevel.length > 0">
						<button
							class="namespace-btn"
							:aria-expanded="isExpanded( '__system__' )"
							@click="toggleNamespace( '__system__' )"
						>
							<i class="bi bi-gear" aria-hidden="true"></i>
							<span class="flex-grow-1">System Commands</span>
							<span class="badge" x-text="topLevel.length"></span>
						</button>
						<div class="namespace-commands" x-show="isExpanded( '__system__' )" x-cloak>
							<template x-for="cmd in topLevel" :key="cmd.name">
								<a
									href="##"
									class="command-item"
									:class="{ 'active': currentCommand?.name === cmd.name }"
									@click.prevent="loadCommand( cmd )"
									x-text="cmd.name"
								></a>
							</template>
						</div>
					</div>

				</nav>
			</div>
		</aside>

		<!-- ── Main Content ───────────────────────────────────────── -->
		<main
			class="content"
			id="main-content"
			tabindex="-1"
			:class="{ 'sidebar-collapsed': sidebarCollapsed }"
			role="main"
			aria-live="polite"
			aria-atomic="false"
		>

			<!-- Overview ─────────────────────────────────────────── -->
			<div x-show="currentView === 'overview'" x-cloak>
				<div class="mb-4">
					<h1 class="display-5 fw-bold">
						<svg id="Layer_2" data-name="Layer 2" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 565.97 411.5" style="height: 35px;">
							<g id="Layer_1-2" data-name="Layer 1">
								<g>
									<path class="swirl" d="M504.76,73.24c-47.74-38.38-157.72-64.12-240.56,19.19-90.33,112.33-50.55,280.35,120.74,297.2,94.55-2.81,140.88-42.6,140.88-42.6,9.84-1.87-124.02,125.91-288.76,26.69-76.29-55.23-96.41-139.01-83.31-206.4,13.57-66.46,62.25-119.82,89.86-136.2,123.09-75.35,240.1,5.15,261.15,42.12Z"/>
									<path class="swirl" d="M451.41,64.81s72.54,22,80.03,129.18c7.96,107.64-116.54,161.94-190.01,136.19-71.14-19.65-107.18-114.2-99.22-172.23-6.55,10.3-16.84,93.14,15.45,145.09,41.18,66.46,180.66,118.4,274.73,9.82,68.8-85.65,13.1-192.82-2.34-202.18-7.02-14.52-54.76-43.07-78.63-45.87Z"/>
									<path class="swirl" d="M275.9,144.85s76.29-81.91,157.25-17.32c74.44,70.21,17.8,157.73-13.1,168.96-25.74,18.73-82.37,18.26-82.37,18.26,17.79,7.49,125.43,21.06,157.72-80.03,25.28-97.35-60.37-153.98-108.12-154.92-65.05-.46-97.34,33.23-111.39,65.06Z"/>
								</g>
								<path class="chevron" d="M.5,47.65l132.03,137.37v56.6L.5,379.56v-62.29l100.31-103.53L.5,109.93v-62.29Z"/>
							</g>
						</svg>
						#arguments.projectTitle#
					</h1>
					<p class="lead" style="color: var(--cb-text-secondary)">Browse and search CommandBox CLI command documentation.</p>
				</div>

				<!-- Stats -->
				<div class="row g-3 mb-4">
					<div class="col-6 col-md-3">
						<div class="card text-center stats-card border-0">
							<div class="card-body">
								<div class="stats-icon" aria-hidden="true">📁</div>
								<div class="stats-value" x-text="totalNamespaceCount"></div>
								<div class="stats-label">Namespaces</div>
							</div>
						</div>
					</div>
					<div class="col-6 col-md-3">
						<div class="card text-center stats-card border-0">
							<div class="card-body">
								<div class="stats-icon" aria-hidden="true">⚡</div>
								<div class="stats-value" x-text="totalCommandCount"></div>
								<div class="stats-label">Commands</div>
							</div>
						</div>
					</div>
				</div>

				<!-- Namespace cards -->
				<div class="row g-3">
					<template x-for="ns in namespaces" :key="ns.name">
						<div class="col-md-6 col-lg-4">
							<div
								class="card namespace-card border-0"
								@click="toggleNamespace( ns.name ); showNamespace( ns )"
								role="button"
								tabindex="0"
								@keydown.enter.prevent="toggleNamespace( ns.name ); showNamespace( ns )"
								:aria-label="'Browse ' + ns.name + ' namespace'"
							>
								<div class="card-body">
									<h2 class="card-title d-flex align-items-center gap-2 mb-2">
										<i class="bi bi-folder2" aria-hidden="true"></i>
										<span x-text="ns.name"></span>
									</h2>
									<span
										class="badge"
										style="background: rgba(0,180,216,.2); color: var(--cb-primary);"
										x-text="( ns.commands.length + ns.children.reduce( ( s, c ) => s + c.commands.length, 0 ) ) + ' commands'"
									></span>
								</div>
							</div>
						</div>
					</template>
				</div>
			</div>

			<!-- Namespace view ────────────────────────────────────── -->
			<div x-show="currentView === 'namespace' && currentNamespace" x-cloak>
				<nav aria-label="breadcrumb" class="mb-3">
					<ol class="breadcrumb">
						<li class="breadcrumb-item">
							<a href="##" @click.prevent="showOverview()">⚡ All Namespaces</a>
						</li>
						<li class="breadcrumb-item active" aria-current="page">
							<i class="bi bi-terminal" aria-hidden="true"></i>
							<span x-text="currentNamespace?.name"></span>
						</li>
					</ol>
				</nav>

				<h1 class="display-5 mb-4">
					<i class="bi bi-terminal" style="color: var(--cb-primary)" aria-hidden="true"></i>
					<span x-text="currentNamespace?.name"></span>
				</h1>

				<div class="card border-0">
					<table class="table table-hover mb-0">
						<thead>
							<tr>
								<th colspan="2" class="fs-5 py-3">
									<i class="bi bi-lightning-charge" style="color: var(--cb-primary)" aria-hidden="true"></i>
									<strong>Commands</strong>
								</th>
							</tr>
						</thead>
						<tbody>
							<template x-for="cmd in currentNamespace?.commands" :key="cmd.link">
								<tr>
									<td class="py-3" style="width: 28%; white-space: nowrap;">
										<a href="##" @click.prevent="loadCommand( cmd )" class="fw-semibold" x-text="cmd.command"></a>
									</td>
									<td class="py-3" style="color: var(--cb-text-secondary);" x-text="cmd.hint || ''"></td>
								</tr>
							</template>
						</tbody>
					</table>
				</div>
			</div>

			<!-- Command view ──────────────────────────────────────── -->
			<div x-show="currentView === 'command'" x-cloak>
				<!-- Loading spinner -->
				<div x-show="contentLoading" class="text-center py-5" role="status" aria-label="Loading command documentation">
					<div class="spinner-border" aria-hidden="true"></div>
					<p class="mt-3" style="color: var(--cb-text-secondary);">Loading…</p>
				</div>

				<!-- Breadcrumb -->
				<nav aria-label="breadcrumb" class="mb-3" x-show="!contentLoading && currentCommand">
					<ol class="breadcrumb">
						<li class="breadcrumb-item me-2">
							<a href="##" @click.prevent="showOverview()">⚡ All Namespaces /</a>
						</li>
						<template x-if="currentCommand?.namespace">
							<li class="breadcrumb-item">
								<a
									href="##"
									@click.prevent="showNamespace( namespaces.find( n => n.name === currentCommand.namespace.split( ' ' )[ 0 ] ) )"
									x-text="currentCommand?.namespace"
								></a>
							</li>
						</template>
						<li class="breadcrumb-item active" aria-current="page" x-text="currentCommand?.command"></li>
					</ol>
				</nav>

				<!-- Injected command content -->
				<div x-show="!contentLoading" x-html="contentHtml"></div>
			</div>

		</main>
	</div>

	<!-- Navigation data (generated by DocBox) -->
	<script src="data/navigation.js"></script>

	<!-- Bootstrap 5 bundle -->
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL" crossorigin="anonymous"></script>

	<!-- jQuery + Syntax Highlighter (pre-loaded for injected command pages) -->
	<script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha384-1H217gwSVyLSIfaLxHbE7dRb3v4mYCKbpQvzx0cegeju1MVsGrX5xXxAvs/HgeFs" crossorigin="anonymous"></script>
	<script src="highlighter/scripts/shCore.js"></script>
	<script src="highlighter/scripts/shBrushBash.js"></script>
	<script src="highlighter/scripts/shBrushBoxLang.js"></script>
	<script src="highlighter/scripts/shBrushColdFusion.js"></script>
	<script src="highlighter/scripts/shBrushJScript.js"></script>
	<script src="highlighter/scripts/shBrushXml.js"></script>
	<script src="highlighter/scripts/shBrushSql.js"></script>
	<script src="highlighter/scripts/shBrushPlain.js"></script>

	<!-- Alpine.js -->
	<script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>

	<!-- SPA application -->
	<script src="js/app.js"></script>

</body>
</html>
</cfoutput>
