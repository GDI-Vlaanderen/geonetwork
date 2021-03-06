OpenLayers.DOTS_PER_INCH = 90.71;
//OpenLayers.ImgPath = '../js/OpenLayers/theme/default/img/';
OpenLayers.ImgPath = '../js/OpenLayers/img/';

OpenLayers.IMAGE_RELOAD_ATTEMPTS = 3;

// Define a constant with the base url to the MapFish web service.
//mapfish.SERVER_BASE_URL = '../../../../../'; // '../../';

// Remove pink background when a tile fails to load
OpenLayers.Util.onImageLoadErrorColor = "transparent";

// Lang (sets also OpenLayers.Lang)
GeoNetwork.Util.setLang(GeoNetwork.Util.defaultLocale, '..');

OpenLayers.Util.onImageLoadError = function() {
	this._attempts = (this._attempts) ? (this._attempts + 1) : 1;
	if (this._attempts <= OpenLayers.IMAGE_RELOAD_ATTEMPTS) {
		this.src = this.src;
	} else {
		this.style.backgroundColor = OpenLayers.Util.onImageLoadErrorColor;
		this.style.display = "none";
	}
};

// add Proj4js.defs here
// Proj4js.defs["EPSG:27572"] = "+proj=lcc +lat_1=46.8 +lat_0=46.8 +lon_0=0 +k_0=0.99987742 +x_0=600000 +y_0=2200000 +a=6378249.2 +b=6356515 +towgs84=-168,-60,320,0,0,0,0 +pm=paris +units=m +no_defs";
Proj4js.defs["EPSG:2154"] = "+proj=lcc +lat_1=49 +lat_2=44 +lat_0=46.5 +lon_0=3 +x_0=700000 +y_0=6600000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs";
//new OpenLayers.Projection("EPSG:900913")


GeoNetwork.map.printCapabilities = "../../pdf";

// Config for WGS84 based maps
GeoNetwork.map.PROJECTION = "EPSG:4326";
GeoNetwork.map.UNITS = "dd"; //degrees

GeoNetwork.map.EXTENT = new OpenLayers.Bounds(2.55791, 50.67460, 5.92000, 51.49600);
GeoNetwork.map.RESTRICTEDEXTENT = new OpenLayers.Bounds(-2.319882890625,48.267306835937,10.797792890625,53.903293164062);
//GeoNetwork.map.EXTENT = new OpenLayers.Bounds(-180, -90, 180, 90);

GeoNetwork.map.RESOLUTIONS = [/*1.40625000000000000000, 0.70312500000000000000, 0.35156250000000000000, 0.17578125000000000000, 0.08789062500000000000, */0.04394531250000000000, 0.02197265625000000000, 0.01098632812500000000, 0.00549316406250000000, 0.00274658203125000000, 0.00137329101562500000, 0.00068664550781250000, 0.00034332275390625000, 0.00017166137695312500, 0.00008583068847656250, 0.00004291534423828120, 0.00002145767211914060, 0.00001072883605957030, 0.00000536441802978516, 0.00000268220901489258, 0.00000134110450744629, 0.00000067055225372314, 0.00000033527612686157];
//GeoNetwork.map.RESOLUTIONS = [1.40625000000000000000, 0.70312500000000000000, 0.35156250000000000000, 0.17578125000000000000, 0.08789062500000000000, 0.04394531250000000000, 0.02197265625000000000, 0.01098632812500000000, 0.00549316406250000000, 0.00274658203125000000, 0.00137329101562500000, 0.00068664550781250000, 0.00034332275390625000, 0.00017166137695312500, 0.00008583068847656250, 0.00004291534423828120, 0.00002145767211914060, 0.00001072883605957030, 0.00000536441802978516, 0.00000268220901489258, 0.00000134110450744629, 0.00000067055225372314, 0.00000033527612686157];
GeoNetwork.map.MAXRESOLUTION = 0.04394531250000000000;
//GeoNetwork.map.MAXRESOLUTION = 1.40625000000000000000;
GeoNetwork.map.NUMZOOMLEVELS = 18;
//GeoNetwork.map.NUMZOOMLEVELS = 23;
GeoNetwork.map.TILESIZE = new OpenLayers.Size(256,256);

GeoNetwork.map.BACKGROUND_LAYERS=[
      new OpenLayers.Layer.WMS(OpenLayers.i18n('backgroundLayer'), 'http://www2.demis.nl/wms/wms.ashx?WMS=BlueMarble', {layers: 'Earth Image,Borders,Coastlines', format: 'image/jpeg'}, {isBaseLayer: true, /*transitionEffect: 'resize',*/ singleTile: true})
    //new OpenLayers.Layer.WMS("GRB", 'http://grb.agiv.be/geodiensten/raadpleegdiensten/GRB-basiskaart/wms', { layers: 'GRB_BASISKAART', transparent: false, format: 'image/png' }, { isBaseLayer: true , transitionEffect: 'resize'})
    //new OpenLayers.Layer.WMS("GRB", 'http://wms.agiv.be/inspire/wms/administratieve_eenheden', { layers: 'Refgem,Refarr,Refprv,Refgew', transparent: true, format: 'image/png'}, { isBaseLayer: true , transitionEffect: 'resize', singleTile: true})    
    //new OpenLayers.Layer.TMS(OpenLayers.i18n('backgroundLayer'), "http://grb.agiv.be/geodiensten/raadpleegdiensten/geocache/tms/", {layername: 'grb_bsk@WGS84VL', type: 'png', tileOrigin: new OpenLayers.LonLat(-180, -90), serverResolutions: [1.40625000000000000000, 0.70312500000000000000, 0.35156250000000000000, 0.17578125000000000000, 0.08789062500000000000, 0.04394531250000000000, 0.02197265625000000000, 0.01098632812500000000, 0.00549316406250000000, 0.00274658203125000000, 0.00137329101562500000, 0.00068664550781250000, 0.00034332275390625000, 0.00017166137695312500, 0.00008583068847656250, 0.00004291534423828120, 0.00002145767211914060, 0.00001072883605957030, 0.00000536441802978516, 0.00000268220901489258, 0.00000134110450744629, 0.00000067055225372314, 0.00000033527612686157]}, {isBaseLayer: true})

    //new OpenLayers.Layer.WMS("Background layer", "/geoserver/wms", {layers: 'gn:world,gn:ne_50m_boundary_da,gn:ne_50m_boundary_lines_land,gn:ne_50m_coastline', format: 'image/jpeg'}, {isBaseLayer: true})
    //new OpenLayers.Layer.WMS("Background layer", "http://www2.demis.nl/mapserver/wms.asp?", {layers: 'Countries', format: 'image/jpeg'}, {isBaseLayer: true})
    ];

// Config for OSM based maps
//GeoNetwork.map.PROJECTION = "EPSG:900913";
////GeoNetwork.map.EXTENT = new OpenLayers.Bounds(-550000, 5000000, 1200000, 7000000);
//GeoNetwork.map.EXTENT = new OpenLayers.Bounds(-20037508, -20037508, 20037508, 20037508.34);
//GeoNetwork.map.BACKGROUND_LAYERS = [
//    new OpenLayers.Layer.OSM()
//    //new OpenLayers.Layer.Google("Google Streets");
//    ];

GeoNetwork.map.EXTENT_MAP_OPTIONS = {
    projection: GeoNetwork.map.PROJECTION,
    units: GeoNetwork.map.UNITS,
    resolutions: GeoNetwork.map.RESOLUTIONS,
    maxResolution: GeoNetwork.map.MAXRESOLUTION,
    numZoomLevels: GeoNetwork.map.NUMZOOMLEVELS,
//	tileSize: GeoNetwork.map.TILESIZE,
//	controls: [],
	maxExtent: GeoNetwork.map.EXTENT,
//	restrictedExtent: GeoNetwork.map.RESTRICTEDEXTENT
};
GeoNetwork.map.MAP_OPTIONS = {
    projection: GeoNetwork.map.PROJECTION,
    units: GeoNetwork.map.UNITS,
    resolutions: GeoNetwork.map.RESOLUTIONS,
    maxResolution: GeoNetwork.map.MAXRESOLUTION,
    numZoomLevels: GeoNetwork.map.NUMZOOMLEVELS,
//	tileSize: GeoNetwork.map.TILESIZE,
	controls: [],
	maxExtent: GeoNetwork.map.EXTENT,
//	restrictedExtent: GeoNetwork.map.RESTRICTEDEXTENT
};
GeoNetwork.map.MAIN_MAP_OPTIONS = {
    projection: GeoNetwork.map.PROJECTION,
    units: GeoNetwork.map.UNITS,
    resolutions: GeoNetwork.map.RESOLUTIONS,
    maxResolution: GeoNetwork.map.MAXRESOLUTION,
    numZoomLevels: GeoNetwork.map.NUMZOOMLEVELS,
//	tileSize: GeoNetwork.map.TILESIZE,
	controls: [],
	maxExtent: GeoNetwork.map.EXTENT,
//	restrictedExtent: GeoNetwork.map.RESTRICTEDEXTENT
};
