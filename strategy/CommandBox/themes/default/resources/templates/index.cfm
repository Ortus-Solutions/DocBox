<cfoutput>
<!DOCTYPE html>
<html lang="en" x-data="commandApp()" x-init="init()" data-theme="dark">
<head>
	<title>#arguments.projectTitle# - Command API Documentation</title>
	<cfmodule template="inc/common.cfm" rootPath="">
</head>
<body>

	<!-- ── Skip to content (accessibility) ─────────────────────────── -->
	<a
		class="visually-hidden-focusable"
		href="##"
		@click.prevent="document.getElementById( 'main-content' ).focus()"
	>Skip to main content</a>

	<!-- ── Top Navbar ──────────────────────────────────────────────── -->
	<header class="cs-navbar fixed-top" role="banner">
		<a class="cs-navbar-brand" href="##" @click.prevent="showOverview()" aria-label="#arguments.projectTitle# home">
			<i class="bi bi-book"></i>
			#arguments.projectTitle#
		</a>

		<!-- Global search -->
		<div class="search-wrap">
			<input
				type="search"
				class="form-control form-control-sm search-input"
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
			aria-label="Command">
			<div class="sidebar-header">
				<h2 class="fs-6"><i class="bi bi-terminal" aria-hidden="true"></i> Commands</h2>
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
				<nav class="doc-tree" aria-label="Commands">

					<!--
						Flat namespace tree — Alpine.js does not support recursive templates,
						so the tree is pre-flattened to a depth-annotated list by flatSidebarItems.
						Only items whose ancestors are expanded are included in the list, so
						show/hide is handled by the computed property rather than x-show.
					-->
					<template x-for="item in flatSidebarItems" :key="item.type + ':' + ( item.type === 'ns' ? item.key : item.cmd.link )">
						<!-- display:contents collapses the wrapper so it is invisible to layout -->
						<div style="display: contents">

							<!-- Namespace header row -->
							<template x-if="item.type === 'ns'">
								<div class="doc-item" :style="{ paddingLeft: ( item.depth * 14 ) + 'px' }">
									<button
										class="doc-name-btn"
										:class="{
											'active'   : currentNamespace && ( item.ns.fullNamespace ? currentNamespace.fullNamespace === item.ns.fullNamespace : currentNamespace.name === item.ns.name ),
											'child-ns' : item.depth > 0
										}"
										:aria-expanded="isExpanded( item.key )"
										@click="isExpanded( item.key ) ? toggleNamespace( item.key ) : ( toggleNamespace( item.key ), showNamespace( item.ns ) )"
									>
										<i class="bi" :class="isExpanded( item.key ) ? 'bi-grid-fill' : 'bi-grid'" aria-hidden="true"></i>
										<span x-text="item.ns.name" class="flex-grow-1"></span>
										<span class="badge" x-text="countCommands( item.ns )"></span>
									</button>
								</div>
							</template>

							<!-- Command link row -->
							<template x-if="item.type === 'cmd'">
								<a
									href="##"
									class="doc-subitem"
									:class="{ 'active': currentCommand?.link === item.cmd.link }"
									:style="{ paddingLeft: ( item.depth * 14 ) + 'px' }"
									@click.prevent="loadCommand( item.cmd )"
									x-text="item.cmd.name"
								></a>
							</template>

						</div>
					</template>

					<!-- System (top-level) commands -->
					<div class="namespace-item" x-show="topLevel.length > 0">
						<button
							class="doc-name-btn"
							:class="{ 'active': currentView === 'system' }"
							:aria-expanded="isExpanded( '__system__' )"
							@click="isExpanded( '__system__' ) ? toggleNamespace( '__system__' ) : ( toggleNamespace( '__system__' ), showSystemCommands() )"
						>
							<i class="bi bi-gear" aria-hidden="true"></i>
							<span class="flex-grow-1">System Commands</span>
							<span class="badge" x-text="topLevel.length"></span>
						</button>
						<ul class="list-unstyled doc-subitems" x-show="isExpanded( '__system__' )" x-cloak>
							<template x-for="cmd in topLevel" :key="cmd.name">
								<li>
									<a
										href="##"
										class="doc-subitem"
										:class="{ 'active': currentCommand?.name === cmd.name }"
										@click.prevent="loadCommand( cmd )"
										x-text="cmd.name"
									></a>
								</li>
							</template>
						</ul>
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
			<template x-if="currentView === 'overview'">
				<div>
					<div class="mb-4">
						<h1 class="display-5 fw-bold">
							#arguments.projectTitle#
						</h1>
						<p class="lead" style="color: var(--cb-text-secondary)">Browse and search CommandBox CLI command documentation.</p>
					</div>

					<!-- Stats -->
					<div class="row g-3 mb-4">
						<div class="col-6 col-md-3">
							<div class="card text-center stats-card">
								<div class="card-body">
									<div class="stats-icon" aria-hidden="true">📁</div>
									<div class="stats-value" x-text="totalNamespaceCount"></div>
									<div class="stats-label">Namespaces</div>
								</div>
							</div>
						</div>
						<div class="col-6 col-md-3">
							<div class="card text-center stats-card">
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
									class="card doc-card"
									@click="toggleNamespace( ns.name ); showNamespace( ns )"
									role="button"
									tabindex="0"
									@keydown.enter.prevent="toggleNamespace( ns.name ); showNamespace( ns )"
									:aria-label="'Browse ' + ns.name + ' namespace'"
								>
									<div class="card-body">
										<h2 class="card-title d-flex align-items-center gap-2 mb-2">
											<i class="bi bi-grid" aria-hidden="true"></i>
											<span x-text="ns.name"></span>
										</h2>
										<span
											class="badge bg-info text-dark"
											x-text="( ns.commands.length + ns.children.reduce( ( s, c ) => s + c.commands.length, 0 ) ) + ' commands'"
										></span>
									</div>
								</div>
							</div>
						</template>
					</div>
				</div>
			</template>

			<!-- Namespace view ────────────────────────────────────── -->
			<template x-if="currentView === 'namespace' && currentNamespace">
				<div>
					<nav aria-label="breadcrumb" class="mb-3">
						<ol class="breadcrumb">
							<li class="breadcrumb-item me-2">
								<a href="##" @click.prevent="showOverview()">All Namespaces /</a>
							</li>
							<template x-if="parentNamespace">
								<li class="breadcrumb-item">
									<a href="##" @click.prevent="showNamespace( parentNamespace )" x-text="parentNamespace.name"></a>
								</li>
							</template>
							<li class="breadcrumb-item active" aria-current="page" x-text="currentNamespace?.name"></li>
						</ol>
					</nav>

					<h1 class="display-5 mb-4">
						<i class="bi bi-terminal" style="color: var(--cb-primary)" aria-hidden="true"></i>
						<span x-text="currentNamespace?.fullNamespace || currentNamespace?.name"></span>
					</h1>
					<div class="card border-0 mb-4" x-show="currentNamespace?.children?.length > 0">
						<table class="table table-hover mb-0">
							<thead>
								<tr>
									<th colspan="2" class="fs-5 py-3">
										<i class="bi bi-folder2" style="color: var(--cb-primary)" aria-hidden="true"></i>
										<strong>Namespaces</strong>
									</th>
								</tr>
							</thead>
							<tbody>
								<template x-for="child in currentNamespace?.children" :key="child.name">
									<tr>
										<td class="py-3" style="width: 28%; white-space: nowrap;">
											<a
												href="##"
												@click.prevent="showNamespace( child, currentNamespace )"
												class="fw-semibold"
												x-text="child.fullNamespace || ( currentNamespace.name + ' ' + child.name )"
											></a>
										</td>
										<td class="py-3" style="color: var(--cb-text-secondary);"></td>
									</tr>
								</template>
							</tbody>
						</table>
					</div>

					<div class="card border-0" x-show="currentNamespace?.commands?.length > 0">
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
			</template>

			<!-- System Commands view ─────────────────────────────── -->
			<template x-if="currentView === 'system'">
				<div>
					<nav aria-label="breadcrumb" class="mb-3">
						<ol class="breadcrumb">
							<li class="breadcrumb-item">
								<a href="##" @click.prevent="showOverview()">All Namespaces</a>
							</li>
							<li class="breadcrumb-item active" aria-current="page">System Commands</li>
						</ol>
					</nav>

					<h1 class="display-5 mb-4">
						<i class="bi bi-gear" style="color: var(--cb-primary)" aria-hidden="true"></i>
						System Commands
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
								<template x-for="cmd in topLevel" :key="cmd.link">
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
			</template>

			<!-- Command view ──────────────────────────────────────── -->
			<template x-if="currentView === 'command' && currentCommand">
				<div>
					<!-- Loading spinner -->
					<div x-show="contentLoading" class="text-center py-5" role="status" aria-label="Loading command documentation">
						<div class="spinner-border" aria-hidden="true"></div>
						<p class="mt-3" style="color: var(--cb-text-secondary);">Loading…</p>
					</div>

					<!-- Breadcrumb -->
					<nav aria-label="breadcrumb" class="mb-3" x-show="!contentLoading && currentCommand">
						<ol class="breadcrumb">
							<li class="breadcrumb-item">
								<a href="##" @click.prevent="showOverview()">All Namespaces</a>
							</li>
							<li class="breadcrumb-item" x-show="currentCommandParentNs">
								<a href="##" @click.prevent="showNamespace( currentCommandParentNs )" x-text="currentCommandParentNs?.name"></a>
							</li>
							<li class="breadcrumb-item" x-show="currentCommandChildNs">
								<a href="##" @click.prevent="showNamespace( currentCommandChildNs, currentCommandParentNs )" x-text="currentCommandChildNs?.name"></a>
							</li>
							<li class="breadcrumb-item active" aria-current="page" x-text="currentCommand?.command"></li>
						</ol>
					</nav>
					<!-- Injected command content -->
					<div x-show="!contentLoading" x-html="contentHtml"></div>
				</div>
			</template>
		</main>
	</div>

	<!-- Bootstrap 5 js -->
	<script src="bootstrap/js/bootstrap.min.js"></script>

	<!-- Syntax Highlighter (pre-loaded for injected command pages) -->
	<script src="highlighter/scripts/shCore.js"></script>
	<script src="highlighter/scripts/shBrushBash.js"></script>
	<script src="highlighter/scripts/shBrushBoxLang.js"></script>
	<script src="highlighter/scripts/shBrushColdFusion.js"></script>
	<script src="highlighter/scripts/shBrushJScript.js"></script>
	<script src="highlighter/scripts/shBrushXml.js"></script>
	<script src="highlighter/scripts/shBrushSql.js"></script>
	<script src="highlighter/scripts/shBrushPlain.js"></script>

	<!-- Alpine.js -->
	<script defer src="alpine/cdn.min.js"></script>

	<!-- Navigation data (generated by DocBox) -->
	<script src="data/navigation.js"></script>

	<!-- SPA application -->
	<script src="js/app.js"></script>

</body>
</html>
</cfoutput>
