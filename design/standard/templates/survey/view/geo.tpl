<label>{$question.question_number}.
{$question.text|wash('xhtml')} {section show=$question.mandatory}<strong class="required">*</strong>{/section}</label>

<div class="survey-choices">

	<!-- {$question.answer} -->

{* BEGIN GMAPLOCATION CODE PASTE *}
{run-once}
<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor={ezini('GMapSettings', 'UseSensor', 'ezgmaplocation.ini')}"></script>
<script type="text/javascript">
{literal}
function eZGmapLocation_MapControl( attributeId, latLongAttributeBase )
{
    var mapid = 'ezgml-map-' + attributeId;
    var latid  = 'ezcoa-' + latLongAttributeBase + '_latitude';
    var longid = 'ezcoa-' + latLongAttributeBase + '_longitude';
    var geocoder = null;
    var addressid = 'ezgml-address-' + attributeId;
    var zoommax = 13;

    var showAddress = function()
    {
        var address = document.getElementById( addressid ).value;
        if ( geocoder )
        {
            geocoder.geocode( {'address' : address}, function( results, status )
            {
                if ( status == google.maps.GeocoderStatus.OK )
                {
                    map.setOptions( { center: results[0].geometry.location, zoom : zoommax } );
										marker.setPosition(  results[0].geometry.location );
                    updateLatLngFields( results[0].geometry.location );
                }
                else
                {
                     alert( address + " not found" );
                }
            });
        }
    };
    
    var updateLatLngFields = function( point )
    {
        document.getElementById(latid).value = point.lat();
        document.getElementById(longid).value = point.lng();
        document.getElementById( 'ezgml-restore-button-' + attributeId ).disabled = false;
        document.getElementById( 'ezgml-restore-button-' + attributeId ).className = 'btn';
    };

    var restoretLatLngFields = function()
    {
        document.getElementById( latid ).value     = document.getElementById('ezgml_hidden_latitude_' + attributeId ).value;
        document.getElementById( longid ).value    = document.getElementById('ezgml_hidden_longitude_' + attributeId ).value;
        document.getElementById( addressid ).value = document.getElementById('ezgml_hidden_address_' + attributeId ).value;
        if ( document.getElementById( latid ).value && document.getElementById( latid ).value != 0 )
        {
            var point = new google.maps.LatLng( document.getElementById( latid ).value, document.getElementById( longid ).value );
            //map.setCenter(point, 13);
            marker.setPosition( point );
            map.panTo( point );
        }
        document.getElementById( 'ezgml-restore-button-' + attributeId ).disabled = true;
        document.getElementById( 'ezgml-restore-button-' + attributeId ).className = 'btn-disabled';
        return false;
    };

    var getUserPosition = function()
    {
        navigator.geolocation.getCurrentPosition( function( position )
        {
            var location = '';
            var point = new google.maps.LatLng( position.coords.latitude, position.coords.longitude );

            if ( navigator.geolocation.type == 'Gears' && position.gearsAddress )
                location = [position.gearsAddress.city, position.gearsAddress.region, position.gearsAddress.country].join(', ');
            else if ( navigator.geolocation.type == 'ClientLocation' )
                location = [position.address.city, position.address.region, position.address.country].join(', ');

            document.getElementById( addressid ).value = location;
            map.setOptions( {zoom: zoommax, center: point} );
            marker.setPosition( point );
            updateLatLngFields( point );
        },
        function( e )
        {
            alert( 'Could not get your location, error was: ' + e.message );
        },
        { 'gearsRequestAddress': true });
    };

		var startPoint = null;
		var zoom = 0;
		var map = null;
		var marker = null;
        
    if ( document.getElementById( latid ).value && document.getElementById( latid ).value != 0 )
    {
        startPoint = new google.maps.LatLng( document.getElementById( latid ).value, document.getElementById( longid ).value );
        zoom = zoommax;
    }
    else
    {
        startPoint = new google.maps.LatLng( 0, 0 );
    }
    
    map = new google.maps.Map( document.getElementById( mapid ), { center: startPoint, zoom : zoom, mapTypeId: google.maps.MapTypeId.ROADMAP } );
    marker = new google.maps.Marker({ map: map, position: startPoint, draggable: true });
    google.maps.event.addListener( marker, 'dragend', function( event ){
    	updateLatLngFields( event.latLng );
			document.getElementById( addressid ).value = '';
    })
    
    geocoder = new google.maps.Geocoder();
    google.maps.event.addListener( map, 'click', function( event )
    {
			marker.setPosition( event.latLng );
			map.panTo( event.latLng );
			updateLatLngFields( event.latLng );
			document.getElementById( addressid ).value = '';
     });


    document.getElementById( 'ezgml-address-button-' + attributeId ).onclick = showAddress;
    document.getElementById( 'ezgml-restore-button-' + attributeId ).onclick = restoretLatLngFields;

    if ( navigator.geolocation )
    {
        document.getElementById( 'ezgml-mylocation-button-' + attributeId ).onclick = getUserPosition;
        document.getElementById( 'ezgml-mylocation-button-' + attributeId ).className = 'btn';
        document.getElementById( 'ezgml-mylocation-button-' + attributeId ).disabled = false;
    }
 
}
{/literal}
</script>
{/run-once}


{* END GMAPLOCATION PASTE *}


{def $attribute_base = "geo"
	$html_prefix = concat('geo_',$question.id,'_',$attribute_id)
	$address = ''
	$latitude = ''
	$longitude = ''
	$css_geo_class = "bfsurveygeo"
}

{if $question.answer|count}
	{* split lat/lon storage *}
	{def $aLatLon = $question.answer|explode('|')}
	{if is_set($aLatLon.0)} {set $latitude = $aLatLon.0} {/if}
	{if is_set($aLatLon.1)} {set $longitude = $aLatLon.1} {/if}
{/if}

<script type="text/javascript">
if ( window.addEventListener )
    window.addEventListener('load', function(){ldelim} eZGmapLocation_MapControl( {$attribute_id}, "{$html_prefix}" ) {rdelim}, false);
else if ( window.attachEvent )
    window.attachEvent('onload', function(){ldelim} eZGmapLocation_MapControl( {$attribute_id}, "{$html_prefix}" ) {rdelim} );
</script>

	<div class="geo-input">
	    <input type="text" id="ezgml-address-{$attribute_id}" size="62" name="{$attribute_base}_data_gmaplocation_address_{$attribute_id}" value="{$address}"/>
	    <input class="btn" type="button" id="ezgml-address-button-{$attribute_id}" value="{'Find address'|i18n('extension/ezgmaplocation/datatype')}"/>
	    <input class="btn-disabled" type="button" id="ezgml-restore-button-{$attribute_id}" value="{'Restore'|i18n('extension/ezgmaplocation/datatype')}" onclick="javascript:void( null ); return false" disabled="disabled"  title="{'Restores location and address values to what it was on page load.'|i18n('extension/ezgmaplocation/datatype')}" />

	    <input id="ezgml_hidden_address_{$attribute_id}" type="hidden" name="ezgml_hidden_address_{$attribute_id}" value="{$address}" disabled="disabled" />
	    <input id="ezgml_hidden_latitude_{$attribute_id}" type="hidden" name="ezgml_hidden_latitude_{$attribute_id}" value="{$latitude}" disabled="disabled" />
	    <input id="ezgml_hidden_longitude_{$attribute_id}" type="hidden" name="ezgml_hidden_longitude_{$attribute_id}" value="{$longitude}" disabled="disabled" />
    </div>

    <div id="ezgml-map-{$attribute_id}" style="width: 500px; height: 280px; margin-top: 2px;"></div>

{* todo address is not stored *}

  <div class="geo-latitude">
    <label>{'Latitude'|i18n('extension/ezgmaplocation/datatype')}:</label>
    <input id="ezcoa-{$html_prefix}_latitude" class="box ezcc-" type="text" name="{$prefix_attribute}_ezsurvey_latitude_{$question.id}_{$attribute_id}" value="{$latitude}" />
  </div>
  
  <div class="geo-longitude">
    <label>{'Longitude'|i18n('extension/ezgmaplocation/datatype')}:</label>
    <input id="ezcoa-{$html_prefix}_longitude" class="box ezcc-" type="text" name="{$prefix_attribute}_ezsurvey_longitude_{$question.id}_{$attribute_id}" value="{$longitude}" />
  </div>

  <div class="geo-buttons">
    <input class="btn-disabled" type="button" id="ezgml-mylocation-button-{$attribute_id}" value="{'My current location'|i18n('extension/ezgmaplocation/datatype')}" onclick="javascript:void( null ); return false" disabled="disabled" title="{'Gets your current position if your browser support GeoLocation and you grant this website access to it! Most accurate if you have a built in gps in your Internet device! Also note that you might still have to type in address manually!'|i18n('extension/ezgmaplocation/datatype')}" />
  </div>

</div>