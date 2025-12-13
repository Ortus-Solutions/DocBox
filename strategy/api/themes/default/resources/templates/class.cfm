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

/**
 * Checks if a class exists in the metadata and returns a link if it does
 */
local.getClassLink = function( required className, required qMetaData ) {
	// Check if the class exists in the metadata
	var qClass = queryExecute(
		"SELECT package, name FROM qMetaData WHERE CONCAT( package, '.', name ) = :fullName",
		{ fullName : arguments.className },
		{ dbtype : "query" }
	);

	if ( qClass.recordCount ) {
		// Generate the relative path to the class
		var classPath = replace( qClass.package, ".", "/", "all" ) & "/" & qClass.name & ".html";
		return '<a href="##" @click.prevent="navigateToClass({ fullname: ''#arguments.className#'', package: ''#qClass.package#'', name: ''#qClass.name#'' })">#arguments.className#</a>';
	}

	// Class doesn't exist in docs, return plain text
	return arguments.className;
}

/**
 * Gets the inheritance chain for a class/interface
 */
local.getInheritence = function( metadata ) {
	var localMeta   = arguments.metadata;
	var inheritence = [ arguments.metadata.name ];

	while ( localMeta.keyExists( "extends" ) && localMeta.extends.count() ) {
		// Manage interfaces
		if ( localMeta.type eq "interface" ) {
			localMeta = localMeta.extends[ structKeyList( localMeta.extends ) ];
		} else {
			localMeta = localMeta.extends;
		}

		arrayPrepend( inheritence, localMeta.name );
	}

	return inheritence;
}

/**
 * Gets all implemented interfaces for a class
 */
local.getImplements = function( metadata ) {
	var localMeta  = arguments.metadata;
	var interfaces = {};
	var key        = 0;
	var imeta      = 0;

	while ( localMeta.keyExists( "extends" ) && localMeta.extends.count() ) {
		if ( structKeyExists( localMeta, "implements" ) ) {
			for ( key in localMeta.implements ) {
				imeta                = localMeta.implements[ key ];
				interfaces[ imeta.name ] = 1;
			}
		}
		localMeta = localMeta.extends;
	}

	interfaces = structKeyArray( interfaces );
	arraySort( interfaces, "textnocase" );

	return interfaces;
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
				<li class="breadcrumb-item">
					<a href="##" @click.prevent="currentPackage = '#local.packagePath#'; currentView = 'package'">📁 #local.part#</a>
				</li>
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

<!-- Inheritance Tree -->
<cfscript>
local.thisClass   = arguments.package & "." & arguments.name;
local.inheritance = local.getInheritence( arguments.metadata );
</cfscript>

<cfif arrayLen( local.inheritance ) gt 1>
	<div class="section-card">
		<h3 class="section-title">
			<i class="bi bi-diagram-3"></i> Inheritance Hierarchy
		</h3>
		<div class="inheritance-tree">
			<cfloop array="#local.inheritance#" index="local.i" item="local.className">
				<cfif local.i gt 1>
					<div class="inheritance-level" style="padding-left: #( local.i - 1 ) * 1.5#rem;">
						<span class="inheritance-arrow">↳</span>
						<cfif local.className neq local.thisClass>
							<code>#local.getClassLink( local.className, arguments.qMetaData )#</code>
						<cfelse>
							<strong><code class="text-primary">#local.className#</code></strong>
						</cfif>
					</div>
				<cfelse>
					<div class="inheritance-level">
						<code>#local.getClassLink( local.className, arguments.qMetaData )#</code>
					</div>
				</cfif>
			</cfloop>
		</div>
	</div>
</cfif>

<!-- Implemented Interfaces -->
<cfif listFindNoCase( "component,class", arguments.metadata.type )>
	<cfscript>
	local.interfaces = local.getImplements( arguments.metadata );
	</cfscript>

	<cfif !arrayIsEmpty( local.interfaces )>
		<div class="section-card">
			<h3 class="section-title">
				<i class="bi bi-puzzle"></i> Implemented Interfaces
			</h3>
			<div class="implemented-interfaces">
				<cfloop array="#local.interfaces#" index="local.interface">
					<span class="badge badge-info me-2 mb-2">
						🔌 #local.getClassLink( local.interface, arguments.qMetaData )#
					</span>
				</cfloop>
			</div>
		</div>
	</cfif>
</cfif>

<!-- Class Annotations -->
<div class="section-card">
	<h3 class="section-title">
		<i class="bi bi-tags"></i> Class Annotations
	</h3>
	<div>
		<cfset local.attributesCount = 0>
		<cfloop collection="#local.annotations#" item="local.classMeta">
			<cfif isSimpleValue( local.annotations[ local.classMeta ] ) AND
				!listFindNoCase( "hint,extends,fullname,functions,hashcode,name,path,properties,type,remoteaddress", local.classMeta ) >
				<cfset local.attributesCount++>
				<span class="badge bg-light text-dark border me-2 mb-2">
					<strong>#lcase( local.classMeta )#</strong><cfif len( local.annotations[ local.classMeta ] )>: #local.annotations[ local.classMeta ]#</cfif>
				</span>
			</cfif>
		</cfloop>
		<cfif local.attributesCount eq 0>
			<span class="badge bg-light text-muted border"><em>None</em></span>
		</cfif>
	</div>
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
