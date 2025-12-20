<cfoutput>
<!DOCTYPE html>
<html lang="en" x-data="docApp()" x-init="init()" :data-theme="theme">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>#arguments.projectTitle# - API Documentation</title>

	<!-- Bootstrap 5 -->
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
	<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.css" rel="stylesheet">

	<!-- Custom Styles -->
	<link href="css/stylesheet.css" rel="stylesheet">
</head>
<body>
	<!-- Top Navigation -->
	<nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
		<div class="container-fluid">
			<a class="navbar-brand fw-bold" href="##" @click.prevent="showOverview()">
				<i class="bi bi-book"></i> #arguments.projectTitle#
			</a>

			<!-- Global Search -->
			<div class="flex-grow-1 mx-4">
				<div class="position-relative">
					<input
						type="text"
						class="form-control form-control-sm search-input"
						placeholder="🔍 Search classes, interfaces, packages..."
						x-model="searchQuery"
						@input="performSearch()"
						@keydown.escape="searchQuery = ''; searchResults = []"
						@keydown.down.prevent="navigateSearch(1)"
						@keydown.up.prevent="navigateSearch(-1)"
						@keydown.enter.prevent="selectSearchResult()"
					>

					<!-- Search Results Dropdown -->
					<div class="search-results" x-show="searchResults.length > 0" x-cloak>
						<template x-for="(result, index) in searchResults" :key="result.fullname">
							<a
								href="##"
								class="search-result-item"
								:class="{ 'active': index === selectedSearchIndex }"
								@click.prevent="navigateToClass(result); searchQuery = ''; searchResults = []"
								@mouseenter="selectedSearchIndex = index"
							>
								<div class="d-flex align-items-center">
									<span class="result-icon" x-text="result.type === 'interface' ? '🔌' : '📦'"></span>
									<div class="flex-grow-1">
										<div class="result-name" x-text="result.name"></div>
										<div class="result-package text-muted small" x-text="result.package"></div>
									</div>
									<span class="badge bg-secondary" x-text="result.type"></span>
								</div>
							</a>
						</template>
					</div>
				</div>
			</div>

			<!-- Theme Toggle -->
			<button class="btn btn-sm btn-outline-light" @click="toggleTheme()" title="Toggle dark/light mode">
				<i class="bi" :class="theme === 'dark' ? 'bi-sun-fill' : 'bi-moon-stars-fill'"></i>
			</button>
		</div>
	</nav>

	<!-- Main Layout -->
	<div class="main-container">
		<!-- Sidebar Navigation -->
		<aside class="sidebar" :class="{ 'collapsed': sidebarCollapsed }">
			<div class="sidebar-header">
				<h6 class="mb-0">📚 Packages</h6>
				<button class="btn btn-sm btn-link p-0" @click="sidebarCollapsed = !sidebarCollapsed">
					<i class="bi" :class="sidebarCollapsed ? 'bi-chevron-right' : 'bi-chevron-left'"></i>
				</button>
			</div>

			<div class="sidebar-content" x-show="!sidebarCollapsed">
				<!-- Package Filter -->
				<div class="mb-3">
					<input
						type="text"
						class="form-control form-control-sm"
						placeholder="Filter packages..."
						x-model="packageFilter"
					>
				</div>

				<!-- Package Tree -->
				<div class="package-tree">
					<template x-for="pkg in filteredPackages" :key="pkg.name">
						<div class="package-item">
							<div
								class="package-name"
								:class="{ 'active': currentPackage === pkg.name }"
								@click="togglePackage(pkg.name)"
							>
								<i class="bi" :class="expandedPackages.includes(pkg.name) ? 'bi-folder2-open' : 'bi-folder2'"></i>
								<span x-text="pkg.name"></span>
								<span class="badge bg-secondary ms-auto" x-text="pkg.classes.length + pkg.interfaces.length"></span>
							</div>

							<!-- Classes in Package -->
							<div class="package-classes" x-show="expandedPackages.includes(pkg.name)" x-cloak>
								<template x-if="pkg.interfaces.length > 0">
									<div class="class-group">
										<div class="class-group-header">🔌 Interfaces</div>
										<template x-for="cls in pkg.interfaces" :key="cls.fullname">
											<a
												href="##"
												class="class-item"
												:class="{ 'active': currentClass?.fullname === cls.fullname }"
												@click.prevent="navigateToClass(cls)"
												x-text="cls.name"
											></a>
										</template>
									</div>
								</template>

								<template x-if="pkg.classes.length > 0">
									<div class="class-group">
										<div class="class-group-header">📦 Classes</div>
										<template x-for="cls in pkg.classes" :key="cls.fullname">
											<a
												href="##"
												class="class-item"
												:class="{ 'active': currentClass?.fullname === cls.fullname }"
												@click.prevent="navigateToClass(cls)"
												x-text="cls.name"
											></a>
										</template>
									</div>
								</template>
							</div>
						</div>
					</template>
				</div>
			</div>
		</aside>

		<!-- Main Content -->
		<main class="content" :class="{ 'sidebar-collapsed': sidebarCollapsed }">
			<!-- Overview Page -->
			<div x-show="currentView === 'overview'" x-cloak>
				<h1 class="display-4 mb-4">#arguments.projectTitle#</h1>

				<!--- Project Description --->
				<p class="lead">#arguments.projectDescription#</p>

				<!--- Documentation Stats --->
				<div class="row g-3 my-4">
					<div class="col-6 col-md-3">
						<div class="card text-center stats-card">
							<div class="card-body">
								<div class="stats-icon">📁</div>
								<div class="stats-value" x-text="packages.length"></div>
								<div class="stats-label">Packages</div>
							</div>
						</div>
					</div>
					<div class="col-6 col-md-3">
						<div class="card text-center stats-card">
							<div class="card-body">
								<div class="stats-icon">📦</div>
								<div class="stats-value" x-text="packages.reduce( ( sum, p ) => sum + p.classes.length, 0 )"></div>
								<div class="stats-label">Classes</div>
							</div>
						</div>
					</div>
					<div class="col-6 col-md-3">
						<div class="card text-center stats-card">
							<div class="card-body">
								<div class="stats-icon">🔌</div>
								<div class="stats-value" x-text="packages.reduce( ( sum, p ) => sum + p.interfaces.length, 0 )"></div>
								<div class="stats-label">Interfaces</div>
							</div>
						</div>
					</div>
					<div class="col-6 col-md-3">
						<div class="card text-center stats-card">
							<div class="card-body">
								<div class="stats-icon">📚</div>
								<div class="stats-value" x-text="packages.reduce( ( sum, p ) => sum + p.classes.length + p.interfaces.length, 0 )"></div>
								<div class="stats-label">Total Types</div>
							</div>
						</div>
					</div>
				</div>

				<!--- Packages Overview --->
				<div class="row g-4 mt-4">
					<template x-for="pkg in packages" :key="pkg.name">
						<div class="col-md-6 col-lg-4">
							<div class="card h-100 package-card" @click="togglePackage(pkg.name); currentView = 'package'">
								<div class="card-body">
									<h5 class="card-title">
										<i class="bi bi-folder2"></i>
										<span x-text="pkg.name"></span>
									</h5>
									<div class="mt-3">
										<span class="badge bg-primary me-2" x-text="pkg.classes.length + ' classes'"></span>
										<span class="badge bg-info" x-text="pkg.interfaces.length + ' interfaces'"></span>
									</div>
								</div>
							</div>
						</div>
					</template>
				</div>
			</div>

			<!-- Package View -->
			<div x-show="currentView === 'package' && currentPackage" x-cloak>
				<div class="mb-4">
					<nav aria-label="breadcrumb">
						<ol class="breadcrumb">
							<li class="breadcrumb-item">
								<a href="##" @click.prevent="showOverview()">📚 All Packages</a>
							</li>
							<li class="breadcrumb-item active" x-text="currentPackage"></li>
						</ol>
					</nav>

					<h1 class="display-5">Package <span x-text="currentPackage"></span></h1>
				</div>

				<template x-if="getCurrentPackageData()">
					<div>
						<!-- Interfaces -->
						<div class="mb-4" x-show="getCurrentPackageData().interfaces.length > 0">
							<h3>🔌 Interfaces</h3>
							<div class="list-group">
								<template x-for="cls in getCurrentPackageData().interfaces" :key="cls.fullname">
									<a
										href="##"
										class="list-group-item list-group-item-action"
										@click.prevent="navigateToClass(cls)"
									>
										<div class="d-flex justify-content-between align-items-center">
											<div>
												<strong x-text="cls.name"></strong>
												<div class="text-muted small" x-text="cls.hint || 'No description'"></div>
											</div>
											<i class="bi bi-chevron-right"></i>
										</div>
									</a>
								</template>
							</div>
						</div>

						<!-- Classes -->
						<div class="mb-4" x-show="getCurrentPackageData().classes.length > 0">
							<h3>📦 Classes</h3>
							<div class="list-group">
								<template x-for="cls in getCurrentPackageData().classes" :key="cls.fullname">
									<a
										href="##"
										class="list-group-item list-group-item-action"
										@click.prevent="navigateToClass(cls)"
									>
										<div class="d-flex justify-content-between align-items-center">
											<div>
												<strong x-text="cls.name"></strong>
												<div class="text-muted small" x-text="cls.hint || 'No description'"></div>
											</div>
											<i class="bi bi-chevron-right"></i>
										</div>
									</a>
								</template>
							</div>
						</div>
					</div>
				</template>
			</div>

			<!-- Class View -->
			<div x-show="currentView === 'class' && currentClass" x-cloak>
				<div id="class-content">
					<!-- Content loaded dynamically -->
				</div>
			</div>
		</main>
	</div>

	<!-- Navigation Data (loaded as JS to support file:// protocol) -->
	<script src="data/navigation.js"></script>

	<!-- Alpine.js -->
	<script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>

	<!-- App Script -->
	<script src="js/app.js"></script>
</body>
</html>
</cfoutput>
