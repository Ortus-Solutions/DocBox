<cfoutput>
<cfset instance.class.root = RepeatString( '../', ListLen( arguments.package, ".") ) />
<cfset annotations = server.keyExists( "boxlang" ) ? arguments.metadata.annotations : arguments.metadata>
<cfset documentation = server.keyExists( "boxlang" ) ? arguments.metadata.documentation : arguments.metadata>
<!DOCTYPE html>
<html lang="en">
<head>
	<title>#arguments.name#</title>
	<meta name="keywords" content="#arguments.package#.concurrent.Callable interface">
	<!-- common assets -->
	<cfmodule template="inc/common.cfm" rootPath="#instance.class.root#">
	<!-- syntax highlighter -->
	<link type="text/css" rel="stylesheet" href="#instance.class.root#highlighter/styles/shCoreDefault.css">
	<script src="#instance.class.root#highlighter/scripts/shCore.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushBoxLang.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushColdFusion.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushXml.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushSql.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushJScript.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushJava.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushCss.js"></script>
	<script type="text/javascript">SyntaxHighlighter.all();</script>
</head>

<body class="withNavbar">

<cfmodule template="inc/nav.cfm"
			page="Class"
			projectTitle= "#arguments.projectTitle#"
			package = "#arguments.package#"
			file="#replace(arguments.package, '.', '/', 'all')#/#arguments.name#"
			>

<!-- ======== start of class data ======== -->
<div class="container-fluid">
<a name="class"><!-- --></a>

<!-- Package Breadcrumb Navigation -->
<nav aria-label="breadcrumb" class="mb-3">
	<ol class="breadcrumb package-breadcrumb">
		<li class="breadcrumb-item">
			<a href="#instance.class.root#overview-summary.html">📚 All Packages</a>
		</li>
		<cfset local.packageParts = listToArray(arguments.package, ".") />
		<cfset local.packagePath = "" />
		<cfloop array="#local.packageParts#" index="local.part">
			<cfset local.packagePath = listAppend(local.packagePath, local.part, ".") />
			<cfif local.part eq local.packageParts[arrayLen(local.packageParts)]>
				<li class="breadcrumb-item active" aria-current="page">
					📁 #local.part#
				</li>
			<cfelse>
				<li class="breadcrumb-item">
					<a href="#instance.class.root##replace(local.packagePath, '.', '/', 'all')#/package-summary.html">📁 #local.part#</a>
				</li>
			</cfif>
		</cfloop>
	</ol>
</nav>

<!--- Class Header --->
<div class="mb-4">
	<h1 class="display-5">
		<cfif arguments.metadata.type eq "interface">
			<span class="text-info">🔌</span> Interface #arguments.name#
		<cfelse>
			<cfif isAbstractClass( arguments.name, arguments.package )>
				📄 #arguments.name# <span class="badge bg-warning text-dark fs-6 align-middle">Abstract</span>
			<cfelse>
				📦 #arguments.name#
			</cfif>
		</cfif>
	</h1>
</div>

<!--- INHERITANCE COMPOSITION --->
<cfset local.i = 0 />
<cfset local.ls = createObject("java", "java.lang.System").getProperty("line.separator") />
<cfset local.buffer = createObject("java", "java.lang.StringBuilder").init() />
<cfset local.thisClass = arguments.package & "." & arguments.name/>

<cfloop array="#getInheritence(arguments.metadata)#" index="className">
	<cfif local.i++ gt 0>
		<cfset local.buffer.append('#RepeatString("  ", local.i)#<img src="#instance.class.root#resources/inherit.gif" alt="extended by ">') />
		<cfif className neq local.thisClass>
			<cfset local.buffer.append(writeClassLink(getPackage(className), getObjectName(className), arguments.qMetaData, "long")) />
		<cfelse>
			<cfset local.buffer.append(className) />
		</cfif>
	<cfelse>
		<cfset local.buffer.append(className) />
	</cfif>
	<cfset local.buffer.append(local.ls) />
</cfloop>

<!-- Inheritance Tree-->
<pre style="background:white">#local.buffer.toString()#</pre>

<!--- All implemented interfaces --->
<cfif  listFindNoCase( "component,class", arguments.metadata.type )>
	<cfset interfaces = getImplements(arguments.metadata)>
	<cfif NOT arrayIsEmpty(interfaces)>
		<div class="card mb-3">
			<div class="card-header"><strong>All Implemented Interfaces:</strong></div>
  			<div class="card-body">
			<cfset local.len = arrayLen(interfaces)>
			<cfloop from="1" to="#local.len#" index="local.counter">
				<cfset interface = interfaces[local.counter]>
				<cfif local.counter neq 1>,</cfif>
				#writeClassLink(getPackage(interface), getObjectName(interface), arguments.qMetaData, "short")#
			</cfloop>
			</div>
		</div>
	</cfif>
<cfelse>
	<cfif arguments.qImplementing.recordCount>
	<div class="card mb-3">
		<div class="card-header"><strong>All Known Implementing Classes:</strong></div>
  		<div class="card-body">
		<cfloop query="arguments.qimplementing">
			<cfif arguments.qimplementing.currentrow neq 1>,</cfif>
			#writeclasslink(arguments.qimplementing.package, arguments.qimplementing.name, arguments.qmetadata, "short")#
		</cfloop>
		</div>
	</div>
	</cfif>
</cfif>

<!--- All subclasses / subinterfaces --->
<cfif arguments.qSubclass.recordCount>
<div class="card mb-3">
	<div class="card-header"><strong>
		<cfif  listFindNoCase( "component,class", arguments.metadata.type )>Direct Known Subclasses<cfelse>All Known Subinterfaces</cfif>:</strong>
	</div>
  	<div class="card-body">
	<cfloop query="arguments.qsubclass">
		<cfif arguments.qsubclass.currentrow neq 1>,</cfif>
		<a href="#instance.class.root##replace(arguments.qsubclass.package, '.', '/', 'all')#/#arguments.qsubclass.name#.html" title="class in #arguments.package#">#arguments.qsubclass.name#</a>
	</cfloop>
	</div>
</div>
</cfif>

<!--- Documentation --->
<cfif documentation.keyExists( "hint" ) AND len( documentation.hint )>
<div id="class-hint">
	<p>#documentation.hint#</p>
</div>
</cfif>

<!-- Class Attributes -->
<div class="class-attributes mb-4">
	<h5 class="mb-3"><i class="bi bi-tags"></i> <strong>Class Attributes</strong></h5>
	<div>
		<cfset local.attributesCount = 0>
		<cfloop collection="#annotations#" item="local.classMeta">
		<cfif isSimpleValue( annotations[ local.classMeta ] ) AND
				!listFindNoCase( "hint,extends,fullname,functions,hashcode,name,path,properties,type,remoteaddress", local.classMeta ) >
			<cfset local.attributesCount++>
			<span class="badge bg-light text-dark border">
				<strong>#lcase( local.classMeta )#</strong><cfif len( annotations[ local.classMeta ] )>: #annotations[ local.classMeta ]#</cfif>
			</span>
		</cfif>
		</cfloop>
		<cfif local.attributesCount eq 0>
			<span class="badge bg-light text-muted border"><em>None</em></span>
		</cfif>
	</div>
</div>

<cfscript>
	instance.class.cache = StructNew();
	local.localFunctions = StructNew();
	local.qFunctions = buildFunctionMetaData(arguments.metadata);
	local.qProperties = buildPropertyMetadata(arguments.metadata);
	local.qInit = getMetaSubQuery(local.qFunctions, "UPPER(name)='INIT'");
</cfscript>

<cfif local.qProperties.recordCount>
<!-- ========== METHOD SUMMARY =========== -->

<a name="property_summary"><!-- --></a>
<div class="card mb-4">
	<table class="table table-hover mb-0">
		<thead class="table-light">
		<tr>
			<th colspan="5" class="fs-5 py-3">
				<i class="bi bi-box text-primary"></i> <strong>Property Summary</strong>
			</th>
		</tr>
		<tr class="table-secondary">
			<th><strong>Type</strong></th>
			<th><strong>Property</strong></th>
			<th><strong>Default</strong></th>
			<th><strong>Serializable</strong></th>
			<th><strong>Required</strong></th>
		</tr>
		</thead>
		<tbody>

		<cfloop query="local.qproperties">
		<cfset local.propMeta = local.qproperties.metadata />
		<cfset local.propDocumentation = server.keyExists( "boxlang" ) ? local.propMeta.documentation : local.propMeta />
		<cfset local.propAnnotations = server.keyExists( "boxlang" ) ? local.propMeta.annotations : local.propMeta />
		<cfset local.localproperties[ local.propMeta.name ] = 1 />
		<tr>
			<!--- Property Type --->
			<td align="right" valign="top" width="1%">
				<code>#writetypelink( local.propMeta.type, arguments.package, arguments.qmetadata, local.propMeta )#</code>
			</td>
			<!--- Property Name and Description --->
			<td>
				#writeMethodLink( arguments.name, arguments.package, local.propMeta, arguments.qMetaData )#
				<br>
				<cfif local.propDocumentation.keyExists( "hint" ) AND len( local.propDocumentation.hint )>
					<!-- only grab the first sentence of the hint -->
					#repeatString( '&nbsp;', 5)# #listGetAt( local.propDocumentation.hint, 1, chr(13) & chr(10) & '.' )#.
				</cfif>
				<br><br>
				<!--- Property Annotations --->
				<ul>
				<cfloop collection="#local.propAnnotations#" item="local.propAnnotationKey">
					<cfif not listFindNoCase( "hint,name,nameAsKey,default,type,serializable,required", local.propAnnotationKey ) >
					<li class="badge bg-secondary label-annotations">#lcase( local.propAnnotationKey )# = #local.propAnnotations[ local.propAnnotationKey ]#</li>
					</cfif>
				</cfloop>
				</ul>
			</td>

			<!--- Property Default Value --->
			<td align="right" valign="top" width="1%">
				<cfif len( local.propAnnotations.default )>
					<code>#local.propAnnotations.default#</code>
				</cfif>
			</td>

			<!--- Property Serializable --->
			<td align="right" valign="top" width="1%">
				<code>
					#local.propAnnotations.serializable ?: true#
				</code>
			</td>

			<!--- Property Required --->
			<td align="right" valign="top" width="1%">
				<code>
					#local.propAnnotations.required ?: false#
				</code>
			</td>
		</tr>
		</cfloop>
		</tr>
	</table>
</div>
</cfif>

<cfif local.qInit.recordCount>
	<cfset local.init = local.qInit.metadata />
	<cfset local.initDocumentation = server.keyExists( "boxlang" ) ? local.init.documentation : local.init />
	<cfset local.initAnnotations = server.keyExists( "boxlang" ) ? local.init.annotations : local.init />
	<cfset local.localFunctions[ local.init.name ] = 1 />
	<!-- ======== CONSTRUCTOR SUMMARY ======== -->

	<a name="constructor_summary"><!-- --></a>
	<div class="card mb-4">
		<table class="table table-hover mb-0">
			<thead class="table-light">
			<tr>
				<th colspan="2" class="fs-5 py-3">
					<i class="bi bi-hammer text-primary"></i> <strong>Constructor Summary</strong>
				</th>
			</tr>
			</thead>
			<tbody>
			<tr>
				<cfif local.init.access neq "public">
					<td align="right" valign="top" width="1%">
						<code>#local.init.access# </code>
					</td>
				</cfif>
				<td>
					#writemethodlink(arguments.name, arguments.package, local.init, arguments.qmetadata)#
					<br>
					<cfif StructKeyExists(local.initDocumentation, "hint") and len( local.initDocumentation.hint ) >
					#repeatString( '&nbsp;', 5)# #listGetAt( local.initDocumentation.hint, 1, chr(13) & chr(10) & '.' )#.
					</cfif>
				</td>
			</tr>
			</tbody>
		</table>
	</div>
</cfif>

<!-- ========== METHOD SUMMARY =========== -->

<cfset local.qFunctions = getMetaSubQuery(local.qFunctions, "UPPER(name)!='INIT'") />
<cfif local.qFunctions.recordCount>

<a name="method_summary"><!-- --></a>
<div class="card mb-4">
	<div class="card-header bg-light border-bottom">
		<div class="d-flex justify-content-between align-items-center">
			<h4 class="mb-0">⚙️ Method Summary</h4>
			<div class="ms-auto" style="width: 300px;">
				<input type="text" class="form-control form-control-sm" id="methodSearch" placeholder="🔍 Search methods..." />
			</div>
		</div>
	</div>
	<div class="card-body p-0">
		<!-- Method Filter Tabs -->
		<ul class="nav nav-tabs method-tabs" id="methodTabs" role="tablist">
			<li class="nav-item" role="presentation">
				<button class="nav-link active" id="all-methods-tab" data-bs-toggle="tab" data-bs-target="##all-methods" type="button" role="tab" aria-controls="all-methods" aria-selected="true">
					All Methods (#local.qFunctions.recordCount#)
				</button>
			</li>
			<cfset local.publicCount = 0 />
			<cfset local.privateCount = 0 />
			<cfset local.staticCount = 0 />
			<cfset local.abstractCount = 0 />
			<cfloop query="local.qFunctions">
				<cfset local.funcAnnotations = server.keyExists( "boxlang" ) ? local.qFunctions.metadata.annotations : local.qFunctions.metadata />
				<cfset local.qFunctionsMetadata = local.qFunctions.metadata />
				<cfif local.qFunctionsMetadata.access eq "public"><cfset local.publicCount++ /></cfif>
				<cfif local.qFunctionsMetadata.access eq "private"><cfset local.privateCount++ /></cfif>
				<cfif structKeyExists( local.funcAnnotations, "static" ) AND local.funcAnnotations.static><cfset local.staticCount++ /></cfif>
				<cfif structKeyExists( local.funcAnnotations, "abstract" ) AND local.funcAnnotations.abstract><cfset local.abstractCount++ /></cfif>
			</cfloop>
			<li class="nav-item" role="presentation">
				<button class="nav-link" id="public-methods-tab" data-bs-toggle="tab" data-bs-target="##public-methods" type="button" role="tab" aria-controls="public-methods" aria-selected="false">
					🟢 Public (#local.publicCount#)
				</button>
			</li>
			<li class="nav-item" role="presentation">
				<button class="nav-link" id="private-methods-tab" data-bs-toggle="tab" data-bs-target="##private-methods" type="button" role="tab" aria-controls="private-methods" aria-selected="false">
					🔒 Private (#local.privateCount#)
				</button>
			</li>
			<cfif local.staticCount gt 0>
			<li class="nav-item" role="presentation">
				<button class="nav-link" id="static-methods-tab" data-bs-toggle="tab" data-bs-target="##static-methods" type="button" role="tab" aria-controls="static-methods" aria-selected="false">
					⚡ Static (#local.staticCount#)
				</button>
			</li>
			</cfif>
			<cfif local.abstractCount gt 0>
			<li class="nav-item" role="presentation">
				<button class="nav-link" id="abstract-methods-tab" data-bs-toggle="tab" data-bs-target="##abstract-methods" type="button" role="tab" aria-controls="abstract-methods" aria-selected="false">
					📝 Abstract (#local.abstractCount#)
				</button>
			</li>
			</cfif>
		</ul>

		<!-- Tab Content -->
		<div class="tab-content" id="methodTabContent">
			<!-- All Methods Tab -->
			<div class="tab-pane fade show active" id="all-methods" role="tabpanel" aria-labelledby="all-methods-tab">
				<table class="table table-hover mb-0">
					<tbody>
					<cfloop query="local.qFunctions">
					<cfset local.func = local.qFunctions.metadata />
					<cfset local.funcDocumentation = server.keyExists( "boxlang" ) ? local.func.documentation : local.func />
					<cfset local.funcAnnotations = server.keyExists( "boxlang" ) ? local.func.annotations : local.func />
					<cfset local.localFunctions[ local.func.name ] = 1 />
					<tr data-access="#local.func.access#" <cfif structKeyExists(local.funcAnnotations, "static") AND local.funcAnnotations.static>data-static="true"</cfif> <cfif structKeyExists(local.funcAnnotations, "abstract") AND local.funcAnnotations.abstract>data-abstract="true"</cfif>>
						<td align="right" valign="top" width="1%">
							<code><cfif local.func.access neq "public">#local.func.access#&nbsp;</cfif>#writetypelink(local.func.returntype, arguments.package, arguments.qmetadata, local.func)#</code>
						</td>
						<td>
							#writemethodlink(arguments.name, arguments.package, local.func, arguments.qmetadata)#
							<br>
							<cfif StructKeyExists(local.funcDocumentation, "hint") AND Len(local.funcDocumentation.hint)>
							#repeatString( '&nbsp;', 5)##listGetAt( local.funcDocumentation.hint, 1, chr(13) & chr(10) & '.' )#.
							</cfif>
						</td>
					</tr>
					</cfloop>
					</tbody>
				</table>
			</div>

			<!-- Public Methods Tab -->
			<div class="tab-pane fade" id="public-methods" role="tabpanel" aria-labelledby="public-methods-tab">
				<table class="table table-hover mb-0">
					<tbody>
					<cfloop query="local.qFunctions">
					<cfset local.func = local.qFunctions.metadata />
					<cfset local.funcDocumentation = server.keyExists( "boxlang" ) ? local.func.documentation : local.func />
					<cfset local.funcAnnotations = server.keyExists( "boxlang" ) ? local.func.annotations : local.func />
					<cfif local.func.access eq "public">
					<tr>
						<td align="right" valign="top" width="1%">
							<code>#writetypelink(local.func.returntype, arguments.package, arguments.qmetadata, local.func)#</code>
						</td>
						<td>
							#writemethodlink(arguments.name, arguments.package, local.func, arguments.qmetadata)#
							<br>
							<cfif StructKeyExists(local.funcDocumentation, "hint") AND Len(local.funcDocumentation.hint)>
							#repeatString( '&nbsp;', 5)##listGetAt( local.funcDocumentation.hint, 1, chr(13) & chr(10) & '.' )#.
							</cfif>
						</td>
					</tr>
					</cfif>
					</cfloop>
					</tbody>
				</table>
			</div>

			<!-- Private Methods Tab -->
			<div class="tab-pane fade" id="private-methods" role="tabpanel" aria-labelledby="private-methods-tab">
				<table class="table table-hover mb-0">
					<tbody>
					<cfloop query="local.qFunctions">
					<cfset local.func = local.qFunctions.metadata />
					<cfset local.funcDocumentation = server.keyExists( "boxlang" ) ? local.func.documentation : local.func />
					<cfset local.funcAnnotations = server.keyExists( "boxlang" ) ? local.func.annotations : local.func />
					<cfif local.func.access eq "private">
					<tr>
						<td align="right" valign="top" width="1%">
							<code>private #writetypelink(local.func.returntype, arguments.package, arguments.qmetadata, local.func)#</code>
						</td>
						<td>
							#writemethodlink(arguments.name, arguments.package, local.func, arguments.qmetadata)#
							<br>
							<cfif StructKeyExists(local.funcDocumentation, "hint") AND Len(local.funcDocumentation.hint)>
							#repeatString( '&nbsp;', 5)##listGetAt( local.funcDocumentation.hint, 1, chr(13) & chr(10) & '.' )#.
							</cfif>
						</td>
					</tr>
					</cfif>
					</cfloop>
					</tbody>
				</table>
			</div>

			<!-- Static Methods Tab -->
			<cfif local.staticCount gt 0>
			<div class="tab-pane fade" id="static-methods" role="tabpanel" aria-labelledby="static-methods-tab">
				<table class="table table-hover mb-0">
					<tbody>
					<cfloop query="local.qFunctions">
					<cfset local.func = local.qFunctions.metadata />
					<cfset local.funcDocumentation = server.keyExists( "boxlang" ) ? local.func.documentation : local.func />
					<cfset local.funcAnnotations = server.keyExists( "boxlang" ) ? local.func.annotations : local.func />
					<cfif structKeyExists(local.funcAnnotations, "static") AND local.funcAnnotations.static>
					<tr>
						<td align="right" valign="top" width="1%">
							<code><cfif local.func.access neq "public">#local.func.access#&nbsp;</cfif>#writetypelink(local.func.returntype, arguments.package, arguments.qmetadata, local.func)#</code>
						</td>
						<td>
							#writemethodlink(arguments.name, arguments.package, local.func, arguments.qmetadata)#
							<br>
							<cfif StructKeyExists(local.funcDocumentation, "hint") AND Len(local.funcDocumentation.hint)>
							#repeatString( '&nbsp;', 5)##listGetAt( local.funcDocumentation.hint, 1, chr(13) & chr(10) & '.' )#.
							</cfif>
						</td>
					</tr>
					</cfif>
					</cfloop>
					</tbody>
				</table>
			</div>
			</cfif>

			<!-- Abstract Methods Tab -->
			<cfif local.abstractCount gt 0>
			<div class="tab-pane fade" id="abstract-methods" role="tabpanel" aria-labelledby="abstract-methods-tab">
				<table class="table table-hover mb-0">
					<tbody>
					<cfloop query="local.qFunctions">
					<cfset local.func = local.qFunctions.metadata />
					<cfset local.funcDocumentation = server.keyExists( "boxlang" ) ? local.func.documentation : local.func />
					<cfset local.funcAnnotations = server.keyExists( "boxlang" ) ? local.func.annotations : local.func />
					<cfif structKeyExists(local.funcAnnotations, "abstract") AND local.funcAnnotations.abstract>
					<tr>
						<td align="right" valign="top" width="1%">
							<code><cfif local.func.access neq "public">#local.func.access#&nbsp;</cfif>#writetypelink(local.func.returntype, arguments.package, arguments.qmetadata, local.func)#</code>
						</td>
						<td>
							#writemethodlink(arguments.name, arguments.package, local.func, arguments.qmetadata)#
							<br>
							<cfif StructKeyExists(local.funcDocumentation, "hint") AND Len(local.funcDocumentation.hint)>
							#repeatString( '&nbsp;', 5)##listGetAt( local.funcDocumentation.hint, 1, chr(13) & chr(10) & '.' )#.
							</cfif>
						</td>
					</tr>
					</cfif>
					</cfloop>
					</tbody>
				</table>
			</div>
			</cfif>
		</div>
	</div>
</div>

</cfif>

<a name="inherited_methods"><!-- --></a>
<cfset local.localmeta = arguments.metadata />
<cfloop condition="local.localMeta.keyExists( 'extends' ) and local.localMeta.extends.count()">
	<cfscript>
		if(local.localmeta.type eq "interface")
		{
			local.localmeta = local.localmeta.extends[ structKeyList( local.localmeta.extends ) ];
		}
		else
		{
			local.localmeta = local.localmeta.extends;
		}
    </cfscript>

	<cfset local.qFunctions = buildFunctionMetaData( local.localmeta )>

	&nbsp;
	<a name="methods_inherited_from_class_#local.localmeta.name#"><!-- --></a>
	<table class="table table-hover table-bordered">
		<tr class="info">
			<th align="left">
				<strong>Methods inherited from class <kbd>#writeClassLink(getPackage(local.localmeta.name), getObjectName(local.localmeta.name), arguments.qMetaData, 'long')#</kbd></strong>
			</th>
		</tr>
		<tr>
			<td>
				<cfset local.buffer.setLength(0) />
				<cfset i = 1 />
				<cfloop query="local.qFunctions">
					<cfset local.func = local.qFunctions.metadata />
					<cfset local.funcDocumentation = server.keyExists( "boxlang" ) ? local.func.documentation : local.func />
					<cfset local.funcAnnotations = server.keyExists( "boxlang" ) ? local.func.annotations : local.func />
					<cfif NOT StructKeyExists(local.localFunctions, local.func.name)>
						<cfif i++ neq 1>
							<cfset local.buffer.append(", ") />
						</cfif>
						<cfset local.buffer.append('<a href="#instance.class.root##replace(getPackage(local.localmeta.name), '.', '/', 'all')#/#getObjectName(local.localmeta.name)#.html###local.func.name#()">#local.func.name#</a>') />
						<cfset local.localFunctions[local.func.name] = 1 />
					</cfif>
				</cfloop>

			<cfif local.buffer.length()>
				#local.buffer.toString()#
			<cfelse>
				<span class="badge bg-warning text-dark"><em>None</em></span>
			</cfif>
			</td>
		</tr>
	</table>
</cfloop>

<hr>

<!-- ========= CONSTRUCTOR DETAIL ======== -->
<cfif StructKeyExists( local, "init" )>
	<a name="constructor_detail"><!-- --></a>
	<div class="card mb-4">
		<div class="card-header bg-light border-bottom">
			<h4 class="mb-0">🔨 Constructor Detail</h4>
		</div>
		<div class="card-body">
			<a name="#local.init.name#()"><!-- --></a>
			<h4 class="text-primary mb-3">#local.init.name#</h4>

			<div class="method-signature mb-3">
				<code class="language-java">#local.init.access# #writeMethodLink(arguments.name, arguments.package, local.init, arguments.qMetaData, false)#</code>
			</div>

			<cfif StructKeyExists( local.initDocumentation, "hint" )>
				<div class="method-description mb-3">
					<p class="lead">#local.initDocumentation.hint#</p>
				</div>
			</cfif>

			<cfif StructKeyExists( local.init, "parameters" ) AND ArrayLen( local.init.parameters )>
				<div class="method-parameters">
					<h6 class="text-muted mb-2">📋 Parameters:</h6>
					<ul class="list-unstyled ms-3">
					<cfloop array="#local.init.parameters#" index="local.param">
						<cfset local.paramDocumentation = server.keyExists( "boxlang" ) ? local.param.documentation : local.param />
						<li class="mb-2">
							<code class="text-primary">#local.param.name#</code>
							<cfif StructKeyExists(local.paramDocumentation, "hint")>
								<span class="text-muted">- #local.paramDocumentation.hint#</span>
							</cfif>
						</li>
					</cfloop>
					</ul>
				</div>
			</cfif>
		</div>
	</div>
</cfif>

<!-- ============ PROPERTY DETAIL ========== -->
<cfif local.qProperties.recordCount>
	<a name="property_detail"><!-- --></a>
	<div class="card mb-4">
		<div class="card-header bg-light border-bottom">
			<h4 class="mb-0">📦 Property Detail</h4>
		</div>
		<div class="card-body">
		<cfloop query="local.qProperties">
			<cfset local.prop = local.qProperties.metadata />
			<cfset local.propDocumentation = server.keyExists( "boxlang" ) ? local.prop.documentation : local.prop />
			<cfset local.propAnnotations = server.keyExists( "boxlang" ) ? local.prop.annotations : local.prop />

			<div class="property-detail-item <cfif local.qProperties.currentRow lt local.qProperties.recordCount>mb-4 pb-4 border-bottom</cfif>">
				<a name="#local.prop.name#()"><!-- --></a>
				<h4 class="text-primary mb-3">#local.prop.name#</h4>

				<div class="property-signature mb-3">
					<code class="language-java">property #writeTypeLink(local.prop.type, arguments.package, arguments.qMetaData, local.prop)#
					#writeMethodLink(arguments.name, arguments.package, local.prop, arguments.qMetaData, false)#<cfif structKeyExists( local.propAnnotations, "default" ) and len( local.propAnnotations.default )> = [#local.propAnnotations.default#]</cfif></code>
				</div>

				<cfif StructKeyExists(local.propDocumentation, "hint") AND Len(local.propDocumentation.hint)>
					<div class="property-description mb-3">
						<p class="lead">#local.propDocumentation.hint#</p>
					</div>
				</cfif>

				<div class="property-attributes">
					<h6 class="text-muted mb-2">🏷️ Attributes:</h6>
					<div class="ms-3">
					<cfloop collection="#local.prop#" item="local.param">
						<cfif not listFindNoCase( "name,type,hint,default,annotations,documentation", local.param )>
							<div class="mb-1">
								<code class="text-primary">#lcase( local.param )#</code>
								<span class="text-muted">- #local.prop[ local.param ]#</span>
							</div>
						</cfif>
					</cfloop>
					</div>
				</div>
			</div>
		</cfloop>
		</div>
	</div>
</cfif>



<cfset local.qFunctions = buildFunctionMetaData(arguments.metadata) />
<cfset local.qFunctions = getMetaSubQuery(local.qFunctions, "UPPER(name)!='INIT'") />
<cfif local.qFunctions.recordCount>

<!-- ============ METHOD DETAIL ========== -->

<a name="method_detail"><!-- --></a>
<div class="card mb-4">
	<div class="card-header bg-light border-bottom">
		<h4 class="mb-0">⚙️ Method Detail</h4>
	</div>
	<div class="card-body">

<cfloop query="local.qFunctions">
	<cfset local.func = local.qFunctions.metadata />
	<cfset local.funcDocumentation = server.keyExists( "boxlang" ) ? local.func.documentation : local.func />
	<cfset local.funcAnnotations = server.keyExists( "boxlang" ) ? local.func.annotations : local.func />

	<div id="method-detail-#local.func.name#" class="method-detail-item <cfif local.qFunctions.currentRow lt local.qFunctions.recordCount>mb-4 pb-4 border-bottom</cfif>">
		<a name="#local.func.name#()"><!-- --></a>
		<h5 class="text-primary mb-2">
			<cfif local.func.access eq "public">
				<span class="visibility-badge" data-bs-toggle="tooltip" data-bs-placement="top" title="Public method - accessible from anywhere">🟢</span>
			<cfelseif local.func.access eq "private">
				<span class="visibility-badge" data-bs-toggle="tooltip" data-bs-placement="top" title="Private method - only accessible within this class">🔒</span>
			<cfelseif local.func.access eq "package">
				<span class="visibility-badge" data-bs-toggle="tooltip" data-bs-placement="top" title="Package method - accessible within the same package">📦</span>
			<cfelseif local.func.access eq "remote">
				<span class="visibility-badge" data-bs-toggle="tooltip" data-bs-placement="top" title="Remote method - accessible via web services">🌐</span>
			</cfif>

			#local.func.name#

			<cfif structKeyExists(local.funcAnnotations, "static") AND local.funcAnnotations.static>
				<span class="visibility-badge" data-bs-toggle="tooltip" data-bs-placement="top" title="Static method - belongs to the class rather than instances">⚡</span>
			</cfif>
			<cfif structKeyExists(local.funcAnnotations, "abstract") AND local.funcAnnotations.abstract>
				<span class="visibility-badge" data-bs-toggle="tooltip" data-bs-placement="top" title="Abstract method - must be implemented by subclasses">📝</span>
			</cfif>
			<cfif structKeyExists( local.funcAnnotations, "deprecated" )>
				<span class="badge bg-danger ms-2" data-bs-toggle="tooltip" data-bs-placement="top" title="This method is deprecated and should not be used">Deprecated</span>
			</cfif>
		</h4>

		<div class="method-signature mb-3">
			<code class="language-java">#local.func.access# #writeTypeLink(local.func.returnType, arguments.package, arguments.qMetaData, local.func)# #writeMethodLink(arguments.name, arguments.package, local.func, arguments.qMetaData, false)#</code>
		</div>

		<cfif StructKeyExists(local.funcDocumentation, "hint") AND Len(local.funcDocumentation.hint)>
			<div class="method-description mb-3">
				<p class="lead">#local.funcDocumentation.hint#</p>
			</div>
		</cfif>

		<cfif StructKeyExists(local.funcAnnotations, "deprecated") AND isSimplevalue(local.funcAnnotations.deprecated)>
			<div class="alert alert-danger mb-3">
				<h6 class="alert-heading mb-1">⚠️ Deprecated</h6>
				<p class="mb-0">#local.funcAnnotations.deprecated#</p>
			</div>
		</cfif>

		<cfif listFindNoCase( "component,class", arguments.metadata.type )>
			<cfset local.specified = findSpecifiedBy(arguments.metaData, local.func.name) />
			<cfif Len(local.specified)>
				<div class="mb-3">
					<h6 class="text-muted mb-2">🔗 Specified by:</h6>
					<div class="ms-3">
						<code><a href="#instance.class.root##replace(getPackage(local.specified), '.', '/', 'all')#/#getObjectName(local.specified)#.html###local.func.name#()">#local.func.name#</a></code>
						in interface
						<code>#writeClassLink(getPackage(local.specified), getObjectName(local.specified), arguments.qMetaData, 'short')#</code>
					</div>
				</div>
			</cfif>
		</cfif>

		<cfset local.overWrites = findOverwrite(arguments.metaData, local.func.name) />
		<cfif Len(local.overWrites)>
			<div class="mb-3">
				<h6 class="text-muted mb-2">⬆️ Overrides:</h6>
				<div class="ms-3">
					<code><a href="#instance.class.root##replace(getPackage(local.overWrites), '.', '/', 'all')#/#getObjectName(local.overWrites)#.html###local.func.name#()">#local.func.name#</a></code>
					in class
					<code>#writeClassLink(getPackage(local.overWrites), getObjectName(local.overWrites), arguments.qMetaData, 'short')#</code>
				</div>
			</div>
		</cfif>

		<cfif StructKeyExists(local.func, "parameters") AND ArrayLen(local.func.parameters)>
			<div class="mb-3">
				<h6 class="text-muted mb-2">📋 Parameters:</h6>
				<ul class="list-unstyled ms-3">
				<cfloop array="#local.func.parameters#" index="local.param">
					<cfset local.paramDocumentation = server.keyExists( "boxlang" ) ? local.param.documentation : local.param />
					<li class="mb-2">
						<code class="text-primary">#local.param.name#</code>
						<cfif StructKeyExists(local.paramDocumentation, "hint")>
							<span class="text-muted">- #local.paramDocumentation.hint#</span>
						</cfif>
					</li>
				</cfloop>
				</ul>
			</div>
		</cfif>

		<cfif StructKeyExists(local.func, "return") AND isSimplevalue(local.func.return)>
			<div class="mb-3">
				<h6 class="text-muted mb-2">↩️ Returns:</h6>
				<div class="ms-3">
					<p class="mb-0">#local.func.return#</p>
				</div>
			</div>
		</cfif>

		<cfif StructKeyExists(local.funcAnnotations, "throws") AND isSimplevalue(local.funcAnnotations.throws)>
			<div class="mb-3">
				<h6 class="text-muted mb-2">💥 Throws:</h6>
				<div class="ms-3">
					<code class="text-danger">#local.funcAnnotations.throws#</code>
				</div>
			</div>
		</cfif>

		<cfset local.hasCustomAnnotations = false />
		<cfloop collection="#local.funcAnnotations#" item="keyName">
			<cfif not listFindNoCase(
				"hint,name,nameAsKey,deprecated,access,type,parameters,return,throws,required,returnformat,returntype,output,modifier,owner,default,closure,serializable,description",
				keyName ) && isSimpleValue( local.funcAnnotations[ keyName ] ) >
				<cfset local.hasCustomAnnotations = true />
				<cfbreak />
			</cfif>
		</cfloop>

		<cfif local.hasCustomAnnotations>
			<div class="method-annotations">
				<h6 class="text-muted mb-2">🏷️ Custom Annotations:</h6>
				<div class="ms-3">
				<cfloop collection="#local.funcAnnotations#" item="keyName">
					<cfif not listFindNoCase(
						"hint,name,nameAsKey,deprecated,access,type,parameters,return,throws,required,returnformat,returntype,output,modifier,owner,default,closure,serializable,description",
						keyName ) && isSimpleValue( local.funcAnnotations[ keyName ] ) >
						<div class="mb-1">
							<span class="badge bg-secondary">#lcase( keyName )#</span>
							<span class="text-muted">#local.funcAnnotations[ keyName ]#</span>
						</div>
					</cfif>
				</cfloop>
				</div>
			</div>
		</cfif>
	</div>
</cfloop>

	</div>
</div>
</cfif>

</div><!-- end container-fluid -->

<script>
// Method Search Functionality
(function() {
	const searchInput = document.getElementById('methodSearch');
	if (!searchInput) return;

	// Build searchable method index
	const methodIndex = [];
	document.querySelectorAll('[id^="method-detail-"]').forEach(methodDiv => {
		const methodId = methodDiv.id;
		const methodName = methodDiv.querySelector('h5')?.textContent.trim() || '';
		const methodSignature = methodDiv.querySelector('.method-signature')?.textContent.trim() || '';

		methodIndex.push({
			id: methodId,
			name: methodName,
			signature: methodSignature.toLowerCase(),
			element: methodDiv
		});
	});

	let searchResults = [];
	let currentResultIndex = -1;

	function performSearch(query) {
		if (!query) {
			clearHighlights();
			searchResults = [];
			currentResultIndex = -1;
			return;
		}

		const lowerQuery = query.toLowerCase();
		searchResults = methodIndex.filter(method =>
			method.name.toLowerCase().includes(lowerQuery) ||
			method.signature.includes(lowerQuery)
		);

		clearHighlights();

		if (searchResults.length > 0) {
			currentResultIndex = 0;
			highlightResults();
			navigateToResult(0);
		}
	}

	function highlightResults() {
		searchResults.forEach((result, index) => {
			result.element.style.backgroundColor = index === currentResultIndex ? '##fff3cd' : '##f8f9fa';
			result.element.style.border = '2px solid ' + (index === currentResultIndex ? '##ffc107' : '##e9ecef');
			result.element.style.transition = 'all 0.3s ease';
		});
	}

	function clearHighlights() {
		methodIndex.forEach(method => {
			method.element.style.backgroundColor = '';
			method.element.style.border = '';
		});
	}

	function navigateToResult(index) {
		if (index < 0 || index >= searchResults.length) return;

		const result = searchResults[index];
		result.element.scrollIntoView({ behavior: 'smooth', block: 'center' });

		// Update search input to show count
		const countText = searchResults.length > 1 ? ` (${index + 1}/${searchResults.length})` : '';
		searchInput.setAttribute('data-count', countText);
	}

	// Search on input
	let searchTimeout;
	searchInput.addEventListener('input', (e) => {
		clearTimeout(searchTimeout);
		searchTimeout = setTimeout(() => {
			performSearch(e.target.value);
		}, 300);
	});

	// Navigate with Enter (next) and Shift+Enter (previous)
	searchInput.addEventListener('keydown', (e) => {
		if (e.key === 'Enter') {
			e.preventDefault();
			if (searchResults.length === 0) return;

			if (e.shiftKey) {
				// Previous result
				currentResultIndex = (currentResultIndex - 1 + searchResults.length) % searchResults.length;
			} else {
				// Next result
				currentResultIndex = (currentResultIndex + 1) % searchResults.length;
			}

			highlightResults();
			navigateToResult(currentResultIndex);
		}
	});

	// Clear search on Escape
	searchInput.addEventListener('keydown', (e) => {
		if (e.key === 'Escape') {
			searchInput.value = '';
			performSearch('');
		}
	});
})();
</script>

</body>
</html>
</cfoutput>
<cfsilent>
	<cffunction name="writeMethodLink" hint="draws a method link" access="private" returntype="string" output="false">
		<cfargument name="name" hint="the name of the class" type="string" required="Yes">
		<cfargument name="package" hint="out current package" type="string" required="Yes">
		<cfargument name="func" hint="the function to link to" required="Yes">
		<cfargument name="qMetaData" hint="the meta daya query" type="query" required="Yes">
		<cfargument name="drawMethodLink" hint="actually draw the link on the method" type="boolean" required="No" default="true">
		<cfset var param = 0 />
		<cfset var i = 1 />
		<cfset var builder = createObject("java", "java.lang.StringBuilder").init() />
		<cfsilent>

		<cfif StructKeyExists(arguments.func, "parameters")>
			<cfset builder.append("(") />
				<cfloop array="#arguments.func.parameters#" index="param">
					<cfscript>
						if(i++ neq 1)
						{
							builder.append(", ");
						}

						if(NOT StructKeyExists(param, "required"))
						{
							param.required = false;
						}

						if(NOT param.required)
						{
							builder.append("[");
						}
					</cfscript>

					<cfscript>
						safeParamMeta(param);
						builder.append(writeTypeLink(param.type, arguments.package, arguments.qMetadata, param));

						builder.append(" " & param.name);

						if( !isNull( param.default ) )
						{
							builder.append("='" & param.default.toString() & "'");
						}

						if(NOT param.required)
						{
							builder.append("]");
						}
					</cfscript>
				</cfloop>
			<cfset builder.append(")") />
		</cfif>

		</cfsilent>
		<cfif arguments.drawMethodLink>
			<cfreturn '<strong><a href="#arguments.name#.html###arguments.func.name#()">#arguments.func.name#</A></strong>#builder.toString()#'/>
		<cfelse>
			<cfreturn '<strong>#arguments.func.name#</strong>#builder.toString()#'/>
		</cfif>
	</cffunction>

	<cffunction name="writeTypeLink" hint="writes a link to a type, or a class" access="private" returntype="string" output="false">
		<cfargument name="type" hint="the type/class" type="string" required="Yes">
		<cfargument name="package" hint="the current package" type="string" required="Yes">
		<cfargument name="qMetaData" hint="the meta data query" type="query" required="Yes">
		<cfargument name="genericMeta" hint="optional meta that may contain generic type information" type="struct" required="No" default="#structNew()#">
		<cfscript>
			var result = createObject("java", "java.lang.StringBuilder").init();
			var local = {};

			if(isPrimitive(arguments.type))
			{
				result.append(arguments.type);
			}
			else
			{
				arguments.type = resolveClassName(arguments.type, arguments.package);
				result.append(writeClassLink(getPackage(arguments.type), getObjectName(arguments.type), arguments.qMetaData, 'short'));
			}

			if(NOT structIsEmpty(arguments.genericMeta))
			{
				local.array = getGenericTypes(arguments.genericMeta, arguments.package);
				if(NOT arrayIsEmpty(local.array))
				{
					result.append("&lt;");

					local.len = ArrayLen(local.array);
                    for(local.counter=1; local.counter lte local.len; local.counter++)
                    {
						if(local.counter neq 1)
						{
							result.append(",");
						}

                    	local.generic = local.array[local.counter];
						result.append(writeTypeLink(local.generic, arguments.package, arguments.qMetaData));
                    }

					result.append("&gt;");
				}
			}

			return result.toString();
        </cfscript>
	</cffunction>

	<cfscript>
		/*
		function getArgumentList(func)
		{
			var list = "";
			var len = 0;
			var counter = 1;
			var param = 0;

			if(StructKeyExists(arguments.func, "parameters"))
			{
				len = ArrayLen(arguments.func.parameters);
				for(; counter lte len; counter = counter + 1)
				{
					param = safeParamMeta(arguments.func.parameters[counter]);
					list = listAppend(list, param.type);
				}
			}

			return list;
		}
		*/

		function writeClassLink(package, name, qMetaData, format)
		{
			var qClass = getMetaSubQuery(arguments.qMetaData, "LOWER(package)=LOWER('#arguments.package#') AND LOWER(name)=LOWER('#arguments.name#')");
			var builder = 0;
			var safeMeta = 0;
			var title = 0;

			if(qClass.recordCount)
			{
				safeMeta = StructCopy(qClass.metadata);

				title = "class";
				if(safeMeta.type eq "interface")
				{
					title = "interface";
				}

				builder = createObject("java", "java.lang.StringBuilder").init();
				builder.append('<a href="#instance.class.root##replace(qClass.package, '.', '/', 'all')#/#qClass.name#.html" title="#title# in #qClass.package#">');
				if(arguments.format eq "short")
				{
					builder.append(qClass.name);
				}
				else
				{
					builder.append(qClass.package & "." & qClass.name);
				}
				builder.append("</a>");

				return builder.toString();
			}

			return package & "." & name;
		}

		function getInheritence( metadata )
		{
			var localmeta = arguments.metadata;
			var inheritence = [arguments.metadata.name];

			while( localMeta.keyExists( "extends" ) and localMeta.extends.count() )
			{
				//manage interfaces
				if(localmeta.type eq "interface")
				{
					localmeta = localmeta.extends[structKeyList(localmeta.extends)];
				}
				else
				{
					localmeta = localmeta.extends;
				}

				ArrayPrepend( inheritence, localmeta.name );
			}

			return inheritence;
		}

		function getImplements(metadata)
		{
			var localmeta = arguments.metadata;
			var interfaces = {};
			var key = 0;
			var imeta = 0;

			while( localMeta.keyExists( "extends" ) and localMeta.extends.count() )
			{
				if(StructKeyExists(localmeta, "implements"))
				{
					for(key in localmeta.implements)
					{
						imeta = localmeta.implements[local.key];
						interfaces[imeta.name] = 1;
					}
				}
				localmeta = localmeta.extends;
			}

			interfaces = structKeyArray(interfaces);

			arraySort(interfaces, "textnocase");

			return interfaces;
		}

		function findOverwrite(metadata, functionName)
		{
			var qFunctions = 0;

			while( arguments.metadata.keyExists( "extends" ) and arguments.metadata.extends.count() )
			{
				if(arguments.metadata.type eq "interface")
				{
					arguments.metadata = arguments.metadata.extends[structKeyList(arguments.metadata.extends)];
				}
				else
				{
					arguments.metadata = arguments.metadata.extends;
				}

				qFunctions = buildFunctionMetaData(arguments.metadata);
				qFunctions = getMetaSubQuery(qFunctions, "name='#arguments.functionName#'");

				if(qFunctions.recordCount)
				{
					return arguments.metadata.name;

				}
			}

			return "";
		}

		function findSpecifiedBy(metadata, functionname)
		{
			var imeta = 0;
			var qFunctions = 0;
			var key = 0;

			if(structKeyExists(arguments.metadata, "implements"))
			{
				for(key in arguments.metadata.implements)
				{
					imeta = arguments.metadata.implements[local.key];

					qFunctions = buildFunctionMetaData(imeta);
					qFunctions = getMetaSubQuery(qFunctions, "name='#arguments.functionName#'");

					if(qFunctions.recordCount)
					{
						return imeta.name;
					}

					// now look up super-interfaces
					while( iMeta.keyExists( "extends" ) && iMeta.extends.count() )
					{
						imeta = imeta.extends[structKeyList(imeta.extends)];

						qFunctions = buildFunctionMetaData(imeta);
						qFunctions = getMetaSubQuery(qFunctions, "name='#arguments.functionName#'");

						if(qFunctions.recordCount)
						{
							return imeta.name;
						}
					}
				}

			}

			return "";
		}

		//stupid cleanup

		StructDelete( variables, "findOverwrite" );
		StructDelete( variables, "writeTypeLink" );
		StructDelete( variables, "writeMethodLink" );
		StructDelete( variables, "getArgumentList" );
		StructDelete( variables, "writeClassLink" );
		StructDelete( variables, "getInheritence" );
		StructDelete( variables, "writeObjectLink" );
		StructDelete( variables, "getImplements" );
		StructDelete( variables, "findSpecifiedBy" );

		//store for resident data
		StructDelete( variables.instance, "class" );
	</cfscript>
</cfsilent>