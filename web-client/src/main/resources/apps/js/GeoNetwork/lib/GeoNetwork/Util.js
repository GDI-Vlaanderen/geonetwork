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
        
        while(current.length > 5) {
            
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
                                selected.push(elem);
                        }
                    });
                } else {
                    rejected.push(pair.className);
                }
            }
        });
        
        var res = null;
        
        if(selected.length > 0) {
            selected.sort();
            var elems = Ext.query("." + selected[selected.length - 1].className);
            Ext.each(elems, function(e){
                if(Ext.query("*[id=" + e.id + "]", Ext.get("source-container").dom).length == 0) {
                    res = e;
                }
            });
        }
        
        return res;
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
    updateDateValue: function(id, value, hasTime, forceDateTime) {
        if (hasTime || forceDateTime) {
            Ext.get(id).dom.value =  "<gco:DateTime xmlns:gco='http://www.isotc211.org/2005/gco' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>" + value + (forceDateTime && value!="" ? "T12:00:00" : "") + "</gco:DateTime>";

        } else {
            Ext.get(id).dom.value =  "<gco:Date xmlns:gco='http://www.isotc211.org/2005/gco' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>" + value + "</gco:Date>";
        }
    },

    /** 
     *  Initialize all div with class cal.
     *  
     *  Those divs will be replaced by an Ext DateTime or DateField.
     *
     */
    initCalendar: function(editorPanel){
        var calendars = Ext.DomQuery.select('div.cal'), i;
        
        for (i = 0; i < calendars.length; i++) {
            var cal = calendars[i];
            var id = cal.id; // Give render div id to calendar input and change
            // its id.
            cal.id = id + 'Id'; // In order to get the input if a get by id is made
            // later (eg. gn_search.js).
            
            if (cal.firstChild === null || cal.childNodes.length === 0) { // Check if
                // already
                // initialized
                // or not
                var format = 'Y-m-d';
                var formatEl = Ext.getDom(id + '_format', editorPanel.dom);
                if (formatEl) {
                    format = formatEl.value;
                }
                
                var valueEl = Ext.getDom(id + '_cal', editorPanel.dom);
                var value = (valueEl ? valueEl.value : '');
                var showTime = format.indexOf('T') === -1 ? false : true;
                var parentId = cal.getAttribute("parentId");
                var dynamicDate = cal.className.contains("dynamicDate");
                if (showTime) {
                	var dtCal = new Ext.ux.form.DateTime({
                        renderTo: cal.id,
                        name: id,
                        id: id,
                        parentId: parentId,
                        value: value,
                        dateFormat: 'Y-m-d',
                        timeFormat: 'H:i',
                        hiddenFormat: 'Y-m-d\\TH:i:s',
                        dtSeparator: 'T'
                    });

                    // See issue AGIV  #2783:
                    // For DateTimes you can give the gmd:dateTime the attribute nilreason ,
                    // then you do not need to include the gco:dateTime.
                    // The isnil attribute does however not exist on the gco:DateTime element.
                    // As a consequence the template contains empy gmd:dateTime elements.
                    // In the GeoNetwork GUI this means that no Datetime control is shown.
                    if (dynamicDate) {
                        dtCal.on('change', function() {
                            GeoNetwork.Util.updateDateValue(this.parentId, textValue=="" ? textValue : this.value, true, false);
                        });
                        GeoNetwork.Util.updateDateValue(parentId, value, true, false);
                    }

                } else {
                    var forceDateTime = cal.getAttribute("forceDateTime")=="true";
                    if (forceDateTime) {
                        value = value.length==19 ? value.substring(0,10) : value;
                    }
                	var dCal = new Ext.form.DateField({
                        renderTo: cal.id,
                        name: id,
                        id: id,
                        parentId: parentId,
                		forceDateTime: forceDateTime,
                        width: 160,
                        value: value,
                        format: value.length==19 ? 'Y-m-d\\TH:i:s' : 'Y-m-d'
                    });

                    //Small hack to put date button on its place
                    if (Ext.isChrome){
                        dCal.getEl().parent().setHeight("18");
                    }
                    // See issue AGIV  #2783:
                    // For DateTimes you can give the gmd:dateTime the attribute nilreason ,
                    // then you do not need to include the gco:dateTime.
                    // The isnil attribute does however not exist on the gco:DateTime element.
                    // As a consequence the template contains empy gmd:dateTime elements.
                    // In the GeoNetwork GUI this means that no Datetime control is shown.
                    if (dynamicDate || forceDateTime) {
                        dCal.on('change', function(component, textValue) {
                            GeoNetwork.Util.updateDateValue(this.parentId, textValue=="" ? textValue : this.value, false, forceDateTime);
                        });
                        GeoNetwork.Util.updateDateValue(parentId, value, false, forceDateTime);
                    }/* else {
                        dCal.on('change', function() {
                        	if (!Ext.isEmpty(this.timeValue)) {
                            	this.setValue(this.value + this.timeValue);
                        	}
                        });
                    }*/
                }
                
            }
        }
    },
    /** 
     *  Initialize all div with class cal.
     *  
     *  Those divs will be replaced by an Ext DateTime or DateField.
     *
     */
    initComboBox: function(editorPanel){
        var combos = Ext.DomQuery.select('div.combobox'), i;
        
        for (i = 0; i < combos.length; i++) {
            var combo = combos[i];
            var id = combo.id; // Give render div id to calendar input and change
            // its id.
            combo.id = id + 'Id'; // In order to get the input if a get by id is made
            // later (eg. gn_search.js).
            
            if (combo.firstChild === null || combo.childNodes.length === 0) { // Check if
                // already
                // initialized
                // or not
                
                var valueEl = Ext.getDom(/*id + '_combobox'*/id.substring(0,id.indexOf("_combobox")), editorPanel.dom);
                var value = (valueEl ? valueEl.value : '');
                var config = combo.getAttribute("config");
                var jsonConfig = Ext.decode(config);
                var data = new Array();
                for (var j=0;j<jsonConfig.optionValues.length;j++) {
                	data.push([jsonConfig.optionValues[j],jsonConfig.optionLabels[j]]);
                }
                var dCombo = new Ext.form.ComboBox({
                    renderTo: combo,
                    id: id,
                    style: 'width: 60%',
                    name: id,
                    mode:'local',
                    value: value,
                    editable:true,
                    triggerAction:'all',
                    selectOnFocus:true,
                    displayField:'label',
                    valueField:'value',
                    forceSelection:false,
                    autoShow:true,
                    store:new Ext.data.SimpleStore({
                        fields:[
                            'value', 'label'
                        ],
                        data: data,
                        autoLoad:true
                    })
                });

                //Small hack to put date button on its place
                if (Ext.isChrome){
                    dCombo.getEl().parent().setHeight("18");
                }
                dCombo.on('change', function() {
                    Ext.get(this.id.substring(0,this.id.indexOf("_combobox"))).dom.value =  this.getValue();
                });
                
            }
        }
    },
    /** 
     *  Initialize all select with class codelist_multiple.
     *  
     *  Those select field on change will create an XML
     *  codelist fragment to be inserted into the record.
     *  It will allows when cardinality is greater than 1 to 
     *  not to have to deal with (+) control to add multiple
     *  values.
     */
    initMultipleSelect: function(){
        var selects = Ext.DomQuery.select('select.codelist_multiple'), i;
        Ext.each(selects, function(select){
            var input = Ext.get('X' + select.id);
            var tpl = input.dom.innerHTML;
            onchangeEvent = function(){
                input.dom.innerHTML = '';
                Ext.each(this.options, function(option){
                    if(option.selected){
                        input.dom.innerHTML += (input.dom.innerHTML === '' ? '' : '&&&') 
                                                   + tpl.replace(new RegExp('codeListValue=".*"'), 
                                                   'codeListValue="' + option.value + '"');
                    }
                });
            };
            
            select.onchange = onchangeEvent;
        });
    },

    /**
     * 
     * Trigger validating event of an element.
     *
     */
    validateMetadataField: function(input){
        // Process only onchange and onkeyup event having validate in event
        // name.
        
        var ch = input.getAttribute("onchange");
        var ku = input.getAttribute("onkeyup");
        // When retrieving a style attribute, IE returns a style object,
        // rather than an attribute value; retrieving an event-handling
        // attribute such as onclick, it returns the contents of the
        // event handler wrapped in an anonymous function;
        if (typeof ch  === 'function') {
            ch = ch.toString();
        }
        if (typeof ku === 'function') {
            ku = ku.toString();
        }
        
        if (!input || 
                (ch !== null && ch.indexOf("validate") === -1) || 
                (ku !== null && ku.indexOf("validate") === -1)) {
            return;
        }
        
        if (input.onkeyup) {
            input.onkeyup();
        }
        if (input.onchange) {
            input.onchange();
        }
    },
    /**
     * 
     *  Retrieve all page's input and textarea element and check the onkeyup and
     *  onchange event (Usually used to check user entry.
     *
     *  @see validateNonEmpty and validateNumber).
     *
     */
    validateMetadataFields: function(scope){
        // --- display lang selector when appropriate
        var items = Ext.DomQuery.select('select.lang_selector');
        Ext.each(items, function(input){
            // --- language selector has a code attribute to be used to be
            // matched with GUI language in order to edit by default
            // element
            // in GUI language. If none, default language is selected.
            for (i = 0; i < input.options.length; i ++) {
                if (input.options[i].getAttribute("code").toLowerCase() === scope.lang) {
                    input.options[i].selected = true;
                    i = input.options.length;
                }
            }
            // FIXME this.enableLocalInput(input, false);
        }, scope);
        
        // --- display validator events when needed.
        items = Ext.DomQuery.select('input,textarea,select');
        Ext.each(items, function(input){
        	GeoNetwork.Util.validateMetadataField(input);
        }, scope);
        
    }


};
