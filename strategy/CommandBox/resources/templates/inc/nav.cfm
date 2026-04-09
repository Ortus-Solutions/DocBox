<cfparam name="attributes.package" default="">
<cfparam name="attributes.file">

<cfset root = RepeatString('../', ListLen(attributes.package, ".")) />

<!-- ========= START OF NAVBAR ======= -->
<a name="navbar_top"></a>
<a href="#skip-navbar_top" title="skip navigation links"></a>

<nav class="navbar navbar-expand-lg navbar-light bg-light fixed-top" role="navigation">
	<div class="container-fluid">

		<a class="navbar-brand" href="#"><strong><cfoutput>#attributes.projecttitle#</cfoutput></strong></a>

		<button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#class-navigation" aria-controls="class-navigation" aria-expanded="false" aria-label="Toggle navigation">
			<span class="navbar-toggler-icon"></span>
		</button>

	    <div class="collapse navbar-collapse" id="class-navigation">
	    	<ul class="navbar-nav me-auto mb-2 mb-lg-0">
				<cfif attributes.page eq "overview">
					<li class="nav-item"><a class="nav-link active" aria-current="page" href="#"><i class="bi bi-airplane"></i> Overview</a></li>
				<cfelse>
					<cfoutput>
					<li class="nav-item"><a class="nav-link" href="#root#overview-summary.html"><i class="bi bi-airplane"></i> Overview</a></li>
					</cfoutput>
				</cfif>

				<cfif attributes.page eq "package">
					<li class="nav-item"><a class="nav-link active" aria-current="page" href="#"><i class="bi bi-terminal"></i> Namespace</a></li>
				<cfelseif attributes.page eq "class">
					<li class="nav-item"><a class="nav-link" href="package-summary.html"><i class="bi bi-terminal"></i> Namespace</a></li>
				</cfif>

	      	</ul>

			<ul class="navbar-nav">
				<li class="nav-item"><cfoutput><a class="nav-link" href="#root & attributes.file#.html" target="_blank" title="Open in new window without frames">
					<i class="bi bi-box-arrow-up-right"></i>
					</a></cfoutput>
				</li>
			</ul>
	    </div>	
	</div>
</nav>

<a name="skip-navbar_top"></a>
<!-- ========= END OF NAVBAR ========= -->