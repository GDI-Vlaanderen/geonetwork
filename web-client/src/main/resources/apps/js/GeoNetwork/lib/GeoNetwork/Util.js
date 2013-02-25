/*
 * Copyright (C) 2001-2011 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 * 
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */
Ext.namespace('GeoNetwork');

GeoNetwork.Lang = {};

GeoNetwork.Util = {
    defaultLocale: 'eng',
    /**
     * Supported GeoNetwork GUI languages
     */
    locales: [
            ['ar', 'عربي', 'ara'], 
            ['ca', 'Català', 'cat'], 
            ['cn', '中文', 'chi'], 
            ['de', 'Deutsch', 'ger'], 
            ['en', 'English', 'eng'], 
            ['es', 'Español', 'spa'], 
            ['fr', 'Français', 'fre'], 
            ['nl', 'Nederlands', 'dut'], 
            ['no', 'Norsk', 'nor'],
            ['pt', 'Рortuguês', 'por'], 
            ['ru', 'Русский', 'rus']
    ],
    
    /**
     * Set OpenLayers lang and load ext required lang files
     */
    setLang: function(lang, baseUrl){
        lang = lang || GeoNetwork.Util.defaultLocale;
        // translate to ISO2 language code
        var openlayerLang = this.getISO2LangCode(lang);

        OpenLayers.Lang.setCode(openlayerLang);

        // Update templates with new language texts
        new GeoNetwork.Templates().refreshTemplates();

        var s = document.createElement("script");
        s.type = 'text/javascript';
        s.src = baseUrl + "/js/ext/src/locale/ext-lang-" + openlayerLang + ".js";
        document.getElementsByTagName("head")[0].appendChild(s);
    },
    /**
     * Return a valid language code if translation is available.
     * Catalogue use ISO639-2 code.
     */
    getCatalogueLang: function(lang){
        var i;
        for (i = 0; i < GeoNetwork.Util.locales.length; i++) {
            if (GeoNetwork.Util.locales[i][0] === lang) {
                return GeoNetwork.Util.locales[i][2];
            }
        }
        return 'eng';
    },
    /**
     * Return ISO2 language code (Used by OpenLayers lang and before GeoNetwork 2.7.0)
     * for corresponding ISO639-2 language code.
     */
    getISO2LangCode: function(lang){
        var i;
        for (i = 0; i < GeoNetwork.Util.locales.length; i++) {
            if (GeoNetwork.Util.locales[i][2] === lang) {
                return GeoNetwork.Util.locales[i][0];
            }
        }
        return 'en';
    },
    getParameters: function(url){
        var parameters = OpenLayers.Util.getParameters(url);
        if (OpenLayers.String.contains(url, '#')) {
            var start = url.indexOf('#') + 1;
            var end = url.length;
            var paramsString = url.substring(start, end);
            
            var pairs = paramsString.split(/[\/]/);
            for (var i = 0, len = pairs.length; i < len; ++i) {
                var keyValue = pairs[i].split('=');
                var key = keyValue[0];
                var value = keyValue[1] || '';
                parameters[key] = value;
            }
        }
        return parameters;
    },
    getBaseUrl: function(url){
        return url.substring(0, url.indexOf('?') || url.indexOf('#') || url.length);
    },

    // TODO : add function to compute color map
    defaultColorMap: [
                       "#2205fd", 
                       "#28bc03", 
                       "#bc3303", 
                       "#e4ff04", 
                       "#ff04a0", 
                       "#a6ff96", 
                       "#408d5d", 
                       "#7d253e", 
                       "#2ce37e", 
                       "#10008c", 
                       "#ff9e05", 
                       "#ff7b5d", 
                       "#ff0000", 
                       "#00FF00"],
    /**
     *  Return a random color map
     */
    generateColorMap: function (classes) {
        var colors = [];
        for (var i = 0; i < classes; i++) {
            // http://paulirish.com/2009/random-hex-color-code-snippets/
            colors[i] = '#'+('00000'+(Math.random()*(1<<24)|0).toString(16)).slice(-6);
        }
        return colors;
    },
    
    findContainerId: function(node) {
	  if(node == null) {
		  return null;
	  }
	  if(node.parentNode.tagName == 'DIV' && node.parentNode.id) {
	  	return node.parentNode.id;
	  }
	  return GeoNetwork.Util.findContainerId(node.parentNode);
    },
    

    openSections: function(current) {
        var current = Ext.get(current);
        
        while(current) {
            
            if(current.dom.tagName === 'FORM') {
                break;
            }
            
            if(current.id.startsWith("toggled")) {
                this._openSections_down(current.prev());
            }
            
            current = current.parent();
        }
    },
    _openSections_down: function(current) {
        var current = Ext.get(current);
        
        Ext.each(current.dom.childNodes, function(e) {
            if(e.className && e.className.contains("tgRight")) {
                e.onclick();
            }
            if(e.childNodes.length > 0) {
                GeoNetwork.Util._openSections_down(e);
            }
        });
    },
    
    findClosestSiblingPair: function(current, id) {
        var current = Ext.get(current);
        if(!id) {
            id = current.id;
        }
        
        current = current.dom.className;
        
        while(current.length > 0) {
            
           var tmp = GeoNetwork.Util._findClosestSiblingPair(current, id);
           if(tmp) {
               return tmp;
           }
           var index = current.length - 1;
           current = current.substring(0, index);
        }
    },

    _findClosestSiblingPair: function(current, id) {
        
        var pairs = Ext.query("*[class*=" + current + "]");
        var rejected = [];
        var selected = [];
        Ext.each(pairs, function(pair){
            if(!rejected.contains(pair.className)) {
                var elems = Ext.query("*[class=" + pair.className + "]");
                
                if(elems.length > 1) {
                    Ext.each(elems, function(elem){
                        if(elem.id != id && !rejected.contains(elem.className)
                                &&!selected.contains(elem)) {
                            var tmp = Ext.get(elem);
                            var isVisible = true;
                            while(tmp && isVisible) {
                                if(!tmp.isVisible()) {
                                    isVisible = false;
                                    rejected.push(elem.className);
                                }
                                tmp = tmp.parent();
                            }
                            if(isVisible) {
                                selected.push(elem);
                            }
                        }
                    });
                } else {
                    rejected.push(pair.className);
                }
            }
        });
        
        if(selected.length > 0) {
            selected.sort();
            return selected[selected.length - 1];
        }
        
        return null;
    },
    
    getTopLeft: function (elm) {

		var x, y = 0;
		
		//set x to elm’s offsetLeft
		x = elm.offsetLeft;
		
		
		//set y to elm’s offsetTop
		y = elm.offsetTop;
		
		
		//set elm to its offsetParent
		elm = elm.offsetParent;
		
		
		//use while loop to check if elm is null
		// if not then add current elm’s offsetLeft to x
		//offsetTop to y and set elm to its offsetParent
		
		while(elm != null)
		{
		
		x = parseInt(x) + parseInt(elm.offsetLeft);
		y = parseInt(y) + parseInt(elm.offsetTop);
		elm = elm.offsetParent;
		}
		
		//here is interesting thing
		//it return Object with two properties
		//Top and Left
		
		return {Top:y, Left: x};
		
	},

    /* Sets the value for hidden element for minimumValue, maximumValue elements when gco:Real is not defined in template.
        This allows to add to add this element in metadata when submit the form.
     */
    updateVectorExtentValue: function(value, id) {
        Ext.get(id).dom.value = "<gco:Real xmlns:gco='http://www.isotc211.org/2005/gco'>" + value + "</gco:Real>";
    },

    /* Sets the value for hidden element for gmd:DateTime when gco:Date or gco:DateTime is not defined in template.
     This allows to add this element in metadata when submit the form.

        "_"+ id -> control related with calendar that stores the date
        id      -> hidden control to store the value of gco:Date or gco:DateTime and it' submitted
     */
    updateDateValue: function(id, hasTime) {
        if (hasTime) {
            Ext.get(id).dom.value =  "<gco:DateTime xmlns:gco='http://www.isotc211.org/2005/gco'>" + Ext.get("_" + id).dom.value + "</gco:DateTime>";

        } else {
            Ext.get(id).dom.value =  "<gco:Date xmlns:gco='http://www.isotc211.org/2005/gco'>" + Ext.get("_" + id).dom.value + "</gco:Date>";
        }
    }

};
