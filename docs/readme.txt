Extension: BFSurveyGeo
	
Installation:
	1) Copy code to the 'extension/bfsurveygeo' directory
	2) enable the extension in the Admin or settings/override/site.ini.append.php
	3) regenerate the autoloads to register the new classes.
	4) clear the template caches	
		
	You are now ready to add this datatype to surveys

Functionality:
	New survey question type for 'geo' location
	Render a survey form with the geo lookup question display
	User enters an address to generate the lat/lon
	on Submit; check the input provided if set to manditory
	Store the latitude/longitude in the 'answer' field with '|' delim
