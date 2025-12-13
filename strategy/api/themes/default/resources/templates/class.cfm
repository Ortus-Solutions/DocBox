<cfscript>
/**
 * Gets formatted argument list for method signature
 */
local.getArgumentList = function( required func ){
	var result = "";
	var params = arguments.func.parameters ?: [];

	for ( var param in params ) {
		if ( len( result ) ) {
			result &= ", ";
		}
		result &= ( param.type ?: "any" ) & " " & param.name;
		if ( structKeyExists( param, "required" ) && param.required ) {
			result &= " required";
		}
	}

	return result;
}

/**
 * Writes a type link
 */
local.writeTypeLink = function( type, package, qMetaData, struct genericMeta = {} ) {
	return arguments.type;
}
</cfscript>
<cfoutput>
<cfset local.annotations = server.keyExists("boxlang") ? arguments.metadata.annotations : arguments.metadata>
<cfset local.documentation = server.keyExists("boxlang") ? arguments.metadata.documentation : arguments.metadata>

<!-- Class Header -->
<div class="class-header">
	<nav aria-label="breadcrumb">
		<ol class="breadcrumb">
			<li class="breadcrumb-item">
				<a href="##" @click.prevent="showOverview()">📚 All Packages</a>
			</li>
			<cfset local.packageParts = listToArray(arguments.package, ".") />
			<cfset local.packagePath = "" />
			<cfloop array="#local.packageParts#" index="local.part">
				<cfset local.packagePath = listAppend(local.packagePath, local.part, ".") />
				<cfif local.part eq local.packageParts[arrayLen(local.packageParts)]>
					<li class="breadcrumb-item active">📁 #local.part#</li>
				<cfelse>
					<li class="breadcrumb-item">
						<a href="##" @click.prevent="currentPackage = '#local.packagePath#'; currentView = 'package'">📁 #local.part#</a>
					</li>
				</cfif>
			</cfloop>
		</ol>
	</nav>

	<h1 class="class-title">
		<cfif arguments.metadata.type eq "interface">
			<span class="text-info">🔌</span> Interface #arguments.name#
		<cfelse>
			<cfif isAbstractClass(arguments.name, arguments.package)>
				📄 #arguments.name# <span class="badge bg-warning text-dark">Abstract</span>
			<cfelse>
				📦 #arguments.name#
			</cfif>
		</cfif>
	</h1>

	<cfif local.documentation.keyExists("hint") AND len(local.documentation.hint)>
		<p class="class-description">#local.documentation.hint#</p>
	</cfif>
</div>

<cfscript>
local.qFunctions = buildFunctionMetaData(arguments.metadata);
local.qProperties = buildPropertyMetadata(arguments.metadata);
local.qInit = getMetaSubQuery(local.qFunctions, "UPPER(name)='INIT'");
local.qMethods = getMetaSubQuery(local.qFunctions, "UPPER(name)!='INIT'");
</cfscript>

<!-- Properties Section -->
<cfif local.qProperties.recordCount>
	<div class="section-card">
		<h3 class="section-title">
			<i class="bi bi-boxes"></i> Properties
		</h3>

		<div class="table-responsive">
			<table class="table table-hover">
				<thead>
					<tr>
						<th>Type</th>
						<th>Property</th>
						<th>Default</th>
						<th>Required</th>
					</tr>
				</thead>
				<tbody>
					<cfloop query="local.qProperties">
						<cfset local.propMeta = local.qProperties.metadata />
						<cfset local.propDoc = server.keyExists("boxlang") ? local.propMeta.documentation : local.propMeta />
						<cfset local.propAnnotations = server.keyExists("boxlang") ? local.propMeta.annotations : local.propMeta />
						<tr>
							<td><code>#local.propMeta.type#</code></td>
							<td>
								<strong>#local.propMeta.name#</strong>
								<cfif local.propDoc.keyExists("hint") AND len(local.propDoc.hint)>
									<div class="text-muted small">#local.propDoc.hint#</div>
								</cfif>
							</td>
							<td>
								<cfif len(local.propAnnotations.default ?: "")>
									<code>#local.propAnnotations.default#</code>
								</cfif>
							</td>
							<td>
								<code>#local.propAnnotations.required ?: false#</code>
							</td>
						</tr>
					</cfloop>
				</tbody>
			</table>
		</div>
	</div>
</cfif>

<!-- Constructor Section -->
<cfif local.qInit.recordCount>
	<cfset local.init = local.qInit.metadata />
	<cfset local.initDoc = server.keyExists("boxlang") ? local.init.documentation : local.init />

	<div class="section-card">
		<h3 class="section-title">
			<i class="bi bi-hammer"></i> Constructor
		</h3>

		<div class="method-item">
			<div class="method-name">#local.init.name#()</div>

			<div class="method-signature">
				#local.init.access# #writeTypeLink(
					local.init.returnType,
					arguments.package,
					arguments.qMetaData,
					local.init
				)# #local.init.name#( #getArgumentList( local.init )# )
			</div>

			<cfif local.initDoc.keyExists( "hint" ) AND len( local.initDoc.hint )>
				<p>#local.initDoc.hint#</p>
			</cfif>

			<cfif structKeyExists( local.init, "parameters" ) AND arrayLen(local.init.parameters)>
				<h6>Parameters:</h6>
				<ul>
					<cfloop array="#local.init.parameters#" index="local.param">
						<cfset local.paramDoc = server.keyExists( "boxlang" ) ? local.param.documentation : local.param />
						<li>
							<code>#local.param.name#</code>
							<cfif local.paramDoc.keyExists( "hint" )>
								- #local.paramDoc.hint#
							</cfif>
						</li>
					</cfloop>
				</ul>
			</cfif>
		</div>
	</div>
</cfif>

<!-- Methods Section -->
<cfif local.qMethods.recordCount>
	<cfset local.methodsJSON = [] />
	<cfloop query="local.qMethods">
		<cfset local.func = local.qMethods.metadata />
		<cfset local.funcDoc = server.keyExists("boxlang") ? local.func.documentation : local.func />
		<cfset local.funcAnnotations = server.keyExists("boxlang") ? local.func.annotations : local.func />

		<cfsavecontent variable="local.methodHTML">
			<div class="method-name">
				<cfif local.func.access eq "public">
					<span class="visibility-badge" title="Public">🟢</span>
				<cfelseif local.func.access eq "private">
					<span class="visibility-badge" title="Private">🔒</span>
				<cfelseif local.func.access eq "package">
					<span class="visibility-badge" title="Package">📦</span>
				<cfelseif local.func.access eq "remote">
					<span class="visibility-badge" title="Remote">🌐</span>
				</cfif>

				#local.func.name#

				<cfif structKeyExists(local.funcAnnotations, "static") AND local.funcAnnotations.static>
					<span class="badge bg-info">⚡ Static</span>
				</cfif>
				<cfif structKeyExists(local.funcAnnotations, "abstract") AND local.funcAnnotations.abstract>
					<span class="badge bg-warning">📝 Abstract</span>
				</cfif>
			</div>

			<div class="method-signature">
				#local.func.access# #writeTypeLink(local.func.returnType, arguments.package, arguments.qMetaData, local.func)# #local.func.name#(#getArgumentList(local.func)#)
			</div>

			<cfif local.funcDoc.keyExists("hint") AND len(local.funcDoc.hint)>
				<p class="mt-2">#local.funcDoc.hint#</p>
			</cfif>

			<cfif structKeyExists(local.func, "parameters") AND arrayLen(local.func.parameters)>
				<h6 class="mt-3">Parameters:</h6>
				<ul>
					<cfloop array="#local.func.parameters#" index="local.param">
						<cfset local.paramDoc = server.keyExists("boxlang") ? local.param.documentation : local.param />
						<li>
							<code class="text-primary">#local.param.name#</code>
							<cfif local.paramDoc.keyExists("type")>
								(<code>#local.paramDoc.type#</code>)
							</cfif>
							<cfif local.paramDoc.keyExists("hint")>
								- #local.paramDoc.hint#
							</cfif>
						</li>
					</cfloop>
				</ul>
			</cfif>

			<cfif structKeyExists(local.func, "return") AND isSimpleValue(local.func.return)>
				<h6 class="mt-3">Returns:</h6>
				<p>#local.func.return#</p>
			</cfif>
		</cfsavecontent>

		<cfset arrayAppend(local.methodsJSON, {
			"name": local.func.name,
			"access": local.func.access,
			"isStatic": structKeyExists(local.funcAnnotations, "static") AND local.funcAnnotations.static,
			"html": trim(local.methodHTML)
		}) />
	</cfloop>

	<script type="application/json" id="methods-data">#serializeJSON(local.methodsJSON)#</script>

	<div class="section-card" x-data="{
		activeTab: 'all',
		searchQuery: '',
		allMethods: [],

		init() {
			const dataScript = document.getElementById('methods-data');
			if (dataScript) {
				this.allMethods = JSON.parse(dataScript.textContent);
			}
		},

		get counts() {
			return {
				all: this.allMethods.length,
				public: this.allMethods.filter(m => m.access === 'public').length,
				remote: this.allMethods.filter(m => m.access === 'remote').length,
				private: this.allMethods.filter(m => m.access === 'private').length,
				static: this.allMethods.filter(m => m.isStatic).length
			};
		},

		get filteredMethods() {
			let methods = this.allMethods;

			if (this.activeTab === 'public') {
				methods = methods.filter(m => m.access === 'public');
			} else if (this.activeTab === 'remote') {
				methods = methods.filter(m => m.access === 'remote');
			} else if (this.activeTab === 'private') {
				methods = methods.filter(m => m.access === 'private');
			} else if (this.activeTab === 'static') {
				methods = methods.filter(m => m.isStatic);
			}

			if (this.searchQuery.trim()) {
				const query = this.searchQuery.toLowerCase();
				methods = methods.filter(m =>
					m.name.toLowerCase().includes(query) ||
					m.html.toLowerCase().includes(query)
				);
			}

			return methods;
		}
	}" x-init="init()">
		<div class="d-flex justify-content-between align-items-center mb-3">
			<h3 class="section-title mb-0">
				<i class="bi bi-gear"></i> Methods (<span x-text="filteredMethods.length"></span>)
			</h3>

			<!-- Method Search -->
			<div class="method-search" style="width: 300px;">
				<input
					type="text"
					class="form-control form-control-sm"
					placeholder="🔍 Search methods..."
					x-model="searchQuery"
				>
			</div>
		</div>

		<!-- Method Tabs -->
		<ul class="nav nav-tabs mb-3" role="tablist">
			<li class="nav-item" role="presentation">
				<button
					class="nav-link"
					:class="{ 'active': activeTab === 'all' }"
					@click="activeTab = 'all'"
					type="button"
				>
					All (<span x-text="counts.all"></span>)
				</button>
			</li>
			<li class="nav-item" role="presentation">
				<button
					class="nav-link"
					:class="{ 'active': activeTab === 'public' }"
					@click="activeTab = 'public'"
					type="button"
				>
					🟢 Public (<span x-text="counts.public"></span>)
				</button>
			</li>
			<li class="nav-item" role="presentation">
				<button
					class="nav-link"
					:class="{ 'active': activeTab === 'remote' }"
					@click="activeTab = 'remote'"
					type="button"
				>
					🌐 Remote (<span x-text="counts.remote"></span>)
				</button>
			</li>
			<li class="nav-item" role="presentation">
				<button
					class="nav-link"
					:class="{ 'active': activeTab === 'private' }"
					@click="activeTab = 'private'"
					type="button"
				>
					🔒 Private (<span x-text="counts.private"></span>)
				</button>
			</li>
			<li class="nav-item" role="presentation">
				<button
					class="nav-link"
					:class="{ 'active': activeTab === 'static' }"
					@click="activeTab = 'static'"
					type="button"
				>
					⚡ Static (<span x-text="counts.static"></span>)
				</button>
			</li>
		</ul>

		<!-- Methods List -->
		<template x-for="method in filteredMethods" :key="method.name">
			<div class="method-item" x-html="method.html"></div>
		</template>

		<!-- No Results Message -->
		<div x-show="filteredMethods.length === 0" class="alert alert-info">
			No methods found matching your criteria.
		</div>
	</div>
</cfif>
</cfoutput>
