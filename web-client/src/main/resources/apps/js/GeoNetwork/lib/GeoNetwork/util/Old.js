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
var translations = {};

// TODO : move elsewhere
function translate(text){
    return translations[text] || text;
}


/**
 * This file contains GeoNetwork JS functions used in loaded rendered HTML pages
 * like massive operations for example.
 *
 * Objectives : remove all this code
 */
/**
 * Update value of all input checkbox elements found in container
 * element identified by id.
 */
function checkAllInputsIn(id, checked){
    var list = Ext.getDom(id).getElementsByTagName('input'), i;
    
    for (i = 0; i < list.length; i++) {
        list[i].checked = checked;
    }
}

function setAll(id){
    checkAllInputsIn(id, true);
}

function clearAll(id){
    checkAllInputsIn(id, false);
}

/** 
 *  Modal box with checkbox validation
 *
 */
function checkBoxModalUpdate(div, service, modalbox, title, button){
    var boxes = Ext.DomQuery.select('input[type="checkbox"]');
    var pars = "?";
    var params = {};

    if (service === 'metadata.admin' || service === 'metadata.category') {
//        pars += "id=" + Ext.getDom('metadataid').value;
        params["id"] = Ext.getDom('metadataid').value;
    }
    Ext.each(boxes, function(s){
        if (s.checked && s.name != "") {
//            pars += "&" + s.name + "=on";
			params[s.name] = "on";
        }
    });
    
    // FIXME : title is not an error message title
    catalogue.doAction(service/* + pars*/, /*null*/params, null, title, function(response){
        if(Ext.getDom(div)) {
	        Ext.getDom(div).innerHTML = response.responseText;
        }
        if (service === 'metadata.admin' || service === 'metadata.category') {
            Ext.getCmp('modalWindow').close();
        } else {
        	if (response.status==408 || response.status==504) {
		    	Ext.MessageBox.alert(OpenLayers.i18n('error'), "Request timeout");
		        Ext.getCmp('modalWindow').close();
        	} else {
		        if(response.responseXML && response.responseXML.getElementsByTagName("error").length > 0) {
		            var errorst = "";
		            Ext.each(response.responseXML.getElementsByTagName("error"), 
		                    function(e) {
		            	errorst += e.textContent || e.innerText || e.text;});
		            Ext.MessageBox.alert(OpenLayers.i18n('error'), OpenLayers.i18n(errorst));
			        Ext.getCmp('modalWindow').close();
		        }
	        }
        }
    }, function(response){
    	if (response.status==408 || response.status==504) {
	    	Ext.MessageBox.alert(OpenLayers.i18n('error'), "Request timeout");
    	} else {
	    	getError(response);
    	}
    	if (button) {
        	button.disabled=false;
    	}
    });
}

function radioModalUpdate(div, service, modalbox, title, button) {
    var pars = '?';
    var inputs = Ext.DomQuery.select('input[type="hidden"],textarea,select', div);
    Ext.each(inputs, function(s) {
        pars += "&" + s.name + "=" + s.value;
    });
    var radios = Ext.DomQuery.select('input[type="radio"]', div);
    Ext.each(radios, function(s){
        if (s.checked) {
            pars += "&" + s.name + "=" + s.value;
        }
    });
    
    catalogue.doAction(service + pars, null, null, /*title*/null, function(response){
        if(Ext.getDom(div)) {
            Ext.getDom(div).innerHTML = response.responseText;
        }
        if ((service === 'metadata.status') || (service === 'metadata.grab.lock')) {
            Ext.getCmp('modalWindow').close();
        } else {
        	if (response.status==408 || response.status==504) {
		    	Ext.MessageBox.alert(OpenLayers.i18n('error'), "Request timeout");
		        Ext.getCmp('modalWindow').close();
        	}
        }
        if(response.responseXML && response.responseXML.getElementsByTagName("error").length > 0) {
            var errorst = "";
            Ext.each(response.responseXML.getElementsByTagName("error"), 
                    function(e) {
            	errorst += e.textContent || e.innerText || e.text;});
            Ext.MessageBox.alert(OpenLayers.i18n('error'), OpenLayers.i18n(errorst));
        }
    }, function(response){
    	if (response.status==408 || response.status==504) {
	    	Ext.MessageBox.alert(OpenLayers.i18n('error'), "Request timeout");
    	} else {
	    	getError(response);
    	}
    	if (button) {
        	button.disabled=false;
    	}
    });
}



function addGroups(xmlRes){
    var list = xmlRes.getElementsByTagName('group'), i;
    Ext.getDom('group').options.length = 0;
    for (i = 0; i < list.length; i++) {
        var id = list[i].getElementsByTagName('id')[0].firstChild.nodeValue;
        var name = list[i].getElementsByTagName('description')[0].firstChild.nodeValue;
        var opt = document.createElement('option');
        opt.text = name;
        opt.value = id;
        if (list.length === 1) {
            opt.selected = true;
        }
        Ext.getDom('group').options.add(opt);
    }
}

/** Update owner modal box
 *
 */
function doGroups(userid){
    catalogue.doAction('xml.usergroups.list?id=' + userid, null, null, "Error retrieving groups", function(xmlRes){
        if (xmlRes.nodeName === 'error') {
            //ker.showError(translate('cannotRetrieveGroup'), xmlRes);
            Ext.getDom('group').options.length = 0; // clear out the options
            Ext.getDom('group').value = '';
            var user = Ext.getDom('user');
            for (i = 0; i < user.options.length; i++) {
                user.options[i].selected = false;
            }
        } else {
            addGroups(xmlRes.responseXML);
        }
    });
}

/** Massive new owner
 *
 */
function checkMassiveNewOwner(action, title){
    var user = Ext.getDom('user').value;
    var group = Ext.getDom('group').value;
    if (user === '') {
        Ext.Msg.alert(title, "selectNewOwner");
        return false;
    }
    if (group.value === '') {
        Ext.Msg.alert(title, "selectOwnerGroup");
        return false;
    }
    catalogue.doAction(action + '?user=' + user + '&group=' + group, null, null, null, function(response){
        Ext.getDom('massivenewowner').parentNode.innerHTML = response.responseText;
    });
}

/** Prepare download
 *
 */
function doDownload(id, all){
    var list = Ext.getDom('downloadlist').getElementsByTagName('INPUT'), pars = '&id=' + id + '&access=private', selected = false;
    
    for (var i = 0; i < list.length; i++) {
        if (list[i].checked || all !== null) {
            selected = true;
            var name = list[i].getAttribute('name');
            pars += '&fname=' + name;
        }
    }
    
    if (!selected) {
        Ext.Msg.alert('Alert', OpenLayers.i18n('selectOneFile'));
        return;
    }
    
    catalogue.doAction(catalogue.services.fileDisclaimer + "?" + pars, null, null, null, function(response){
        Ext.getDom('downloadlist').parentNode.innerHTML = response.responseText;
    });
}

function feedbackSubmit(){
    var f = Ext.getDom('feedbackf');
    // TODO : restore form control.
    //    if (isWhitespace(f.comments.value)) {
    //        f.comments.value = OpenLayers.i18n('noComment');
    //    }
    //    
    //    if (isWhitespace(f.name.value) || isWhitespace(f.org.value)) {
    //        alert(OpenLayers.i18n("addName"));
    //        return;
    //    } else if (!isEmail(f.email.value)) {
    //        alert(OpenLayers.i18n("checkEmail"));
    //        return;
    //    }
    catalogue.doAction(catalogue.services.fileDownload + "?" + Ext.Ajax.serializeForm(f), null, null, null, function(response){
        Ext.getDom('feedbackf').parentNode.innerHTML = response.responseText;
    });
}

function goSubmit(form_name){
    document.forms[form_name].submit();
}


function checkBatchNewOwner(action, title) {
    if (Ext.getDom('user').value == '') {
        Ext.Msg.alert(title, "selectNewOwner");
        return false;
    }
    if (Ext.getDom('group').value == '') {
        Ext.Msg.alert(title, "selectOwnerGroup");
        return false;
    }
    catalogue.doAction(catalogue.services.metadataMassiveNewOwner + "?" + Ext.Ajax.serializeForm(Ext.getDom('batchnewowner')), null, null, null, function(response){
        Ext.getDom('batchnewowner').parentNode.innerHTML = response.responseText;
    });
}

function getError(response){
    if (response && response.responseText) {
        var errorPage = response.responseText, 
            errorTitle1, errorTitle, 
            errorMsg, errorMsg1, errorMsg2;
            
        errorTitle = errorPage.match(/<h2 class=\"error\"\>(.*)<\/h2\>/);
        errorTitle1 = errorTitle || errorPage.match(/<div id=\"error\"\>\n[ ]*<h2>(.*)<\/h2\>/);
        errorMsg = errorPage.match(/<\/h2\>\n[ ]*<p\><\/p\>(.*)/);
        if (!errorMsg) {
             errorMsg1 = errorPage.match(/<p id=\"error\">(.*)<\/p\>/);
             errorMsg2 = errorPage.match(/<p id=\"stacktrace\">(.*)<\/p\>/);
             errorMsg = errorMsg1[1] + errorMsg2[1];
        } else {
            errorMsg = errorMsg[1];
        }
        
        if (errorTitle1) {
            Ext.Msg.alert(errorTitle1[1], (errorMsg ? errorMsg : ''));
        }
    } 
}
