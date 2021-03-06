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
Ext.namespace('GeoNetwork.editor');


/** api: (define)
 *  module = GeoNetwork.editor
 *  class = ThumbnailPanel
 *  base_link = `Ext.Panel <http://extjs.com/deploy/dev/docs/?class=Ext.Panel>`_
 */
/** api: constructor 
 *  .. class:: ThumbnailPanel(config)
 *
 *     Create a GeoNetwork thumbnail manager panel
 *
 *
 */
GeoNetwork.editor.ThumbnailPanel = Ext.extend(Ext.Panel, {
    title: undefined,
    metadataId: undefined,
    workspace: undefined,
    versionId: undefined,
    setThumbnail: undefined,
    unsetThumbnail: undefined,
    getThumbnail: undefined,
    uploadForm: undefined,
    idField: undefined,
    versionField: undefined,
    /**
     * Thumbnail filename
     */
    thumbnail: undefined,
    editor: undefined,
    dataView: undefined,
    store: undefined,
    thumbnailUploadWindow: undefined,
    addButton: undefined,
    delButton: undefined,
    defaultConfig: {
        border: false,
        frame: false,
        iconCls: 'thumbnailIcon',
        collapsible: true,
        collapsed: false,
        autoScroll: true
    },
    /** private: method[clear] 
     *  Remove all thumbnails from the store
     */
    clear: function() {
        this.store.removeAll();
    },
    /** private: method[reload] 
     *  Reload thumbnails
     */
    reload: function(e, id, schema, version){
        this.metadataId = id || this.metadataId;
        this.versionId = version || this.metadataId;
        if (this.collapsed) {
            return;
        }
        this.idField.setValue(this.metadataId);
        this.versionField.setValue(this.versionId);

        this.store.reload({
            params: {
                id: this.metadataId,
                fromWorkspace: this.workspace
            }
        });
    },
    /** private: method[generateForm] 
     *  Create form according to process parameters description
     */
    uploadThumbnail: function(){
        if (!this.thumbnailUploadWindow) {
            // TODO : before uploading thumbnails, save the current metadata
            // record if ongoing updates
            this.thumbnailUploadWindow = new Ext.Window({
                title: OpenLayers.i18n('thumbnailUploadWindow'),
                width: 300,
                height: 100,
                layout: 'fit',
                modal: true,
                items: this.uploadForm,
                closeAction: 'hide',
                constrain: true,
                iconCls: 'thumbnailAddIcon'
            });
        }
        
        this.thumbnailUploadWindow.show();
    },
    removeThumbnail: function(description){
    	var type = this.thumbnail ? this.thumbnail : description;
		var fileName = this.thumbnailFileName ? encodeURIComponent(this.thumbnailFileName) : "";
        var panel = this,
            url = this.unsetThumbnail + '?id=' + this.metadataId + 
                                            '&version=' + this.versionId + '&fileName' + fileName +
                                            '&type=' + (type === 'thumbnail' ? 'small' : 'large');
        
        OpenLayers.Request.GET({
            url: url,
            success: function(response){
                panel.editor.init(panel.metadataId);
            },
            failure: function(response){
            }
        });
    },
    selectionChangeEvent: function(dv, selections){
    	var store = this.dataView.getStore();
    	var uploadedTumbnailExists = false;
    	if (store.getCount()>0) {
            store.each(function(record){
                var desc = record.get('desc');
                if (desc === 'thumbnail' || desc === 'large_thumbnail') {
                	uploadedTumbnailExists = true;
            		return false;
                }
            });
    	}

    	var records = selections ? dv.getRecords(selections) : [];/*,
            allInternal = this.dataView.getStore().query('desc', /thumbnail|large_thumbnail/).length == 2;
*/
        if (records[0]) {
            this.thumbnail = records[0].get('desc');
            this.thumbnailFileName = records[0].get('href');
            // Only manage GeoNetwork internal thumbnails. Other thumbnail set using URL MUST be removed from the editor
            if (this.thumbnail === 'thumbnail' || this.thumbnail === 'large_thumbnail') {
                this.addButton.setDisabled(false);
                this.delButton.setDisabled(false);
            } else {
                this.addButton.setDisabled(uploadedTumbnailExists && true);
                this.delButton.setDisabled(true);
            }
        } else {
            this.addButton.setDisabled(uploadedTumbnailExists && true);
            this.delButton.setDisabled(true);
            this.thumbnail = undefined;
        }
        
//        this.addButton.setDisabled(allInternal);
    },
    /** private: method[initComponent] 
     *  Initializes the thumbnail panel.
     */
    initComponent: function(){
        Ext.applyIf(this, this.defaultConfig);

        this.title = OpenLayers.i18n('thumbnails');
        this.tools = [{
            id : 'refresh',
            handler : function (e, toolEl, panel, tc) {
                panel.reload(panel, panel.metadataId);
            }
        }];

        var tpl = new Ext.XTemplate('<ul>', 
                                        '<tpl for=".">', 
                                            '<li class="thumbnail">', 
                                                '<img class="thumb-small" src="{href}" title="{desc}"><br/>',
                                                '<a rel="lightbox-set" class="md-mn lightBox" href="{href}"></a>', 
                                                '<span>{desc}</span>', 
                                            '</li>', 
                                        '</tpl>', 
                                    '</ul>');
        
        this.addButton = new Ext.Button({
                text: OpenLayers.i18n('addThumbnail'),
                iconCls: 'thumbnailAddIcon',
                disabled: true,
                handler: this.uploadThumbnail,
                scope: this
            });
        this.delButton = new Ext.Button({
                text: OpenLayers.i18n('removeSelected'),
                iconCls: 'thumbnailDelIcon',
                disabled: true,
                handler: this.removeThumbnail,
                scope: this
            });
        this.bbar = new Ext.Toolbar({
            items: [this.addButton, this.delButton]
        });

       // alert('thumbnailpanel init: workspace? ' + this.workspace);
        this.store = new GeoNetwork.data.MetadataThumbnailStore(this.getThumbnail, {id: this.metadataId, fromWorkspace:this.workspace});
        this.store.on('load', function(comp, records){
        	var uploadedTumbnailExists = false;
        	if (records.length>0) {
                Ext.each(records, function(record){
                    var desc = record.get('desc');
                    if (desc === 'thumbnail' || desc === 'large_thumbnail') {
                		uploadedTumbnailExists = true;
                		return false;
                    }
                });
        	}
        	if (uploadedTumbnailExists) {
        		this.addButton.setText(OpenLayers.i18n('replaceThumbnail'));
                this.addButton.setDisabled(true);
        	} else {
        		this.addButton.setText(OpenLayers.i18n('addThumbnail'));
                this.addButton.setDisabled(false);
        	} 
            this.dataView.fireEvent('selectionchange', this);
            Ext.ux.Lightbox.register('a[rel^=lightbox-set]', true);
            }, this);
        this.idField = new Ext.form.TextField({
            xtype: 'textfield',
            name: 'id',
            value: this.metadataId,
            hidden: true
        });
        this.versionField = new Ext.form.TextField({
            name: 'version',
            value: this.versionId,
            hidden: true
        });
        var tip = new Ext.slider.Tip({
            getText: function(thumb){
                return String.format('<b>{0} px</b>', thumb.value);
            }
        });
        
        this.uploadForm = new Ext.form.FormPanel({
                    fileUpload: true,
                    items: [this.idField, this.versionField, {
                        xtype: 'textfield',
                        name: 'scalingDir',
                        value: 'width',
                        hidden: true
                    }, {
                        xtype: 'textfield',
                        name: 'smallScalingDir',
                        value: 'width',
                        hidden: true
                    }, new Ext.form.FileUploadField({
//	                        xtype: 'fileuploadfield',
	                        emptyText: OpenLayers.i18n('selectImage'),
	                        fieldLabel: OpenLayers.i18n('image'),
	                        name: 'fname',
	                        allowBlank: false,
	                        buttonText: '',
	                        buttonCfg: {
	                            iconCls: 'thumbnailAddIcon',
                                tooltip: 'Blader naar bestand'
	                        }
                    	})
                    /*, {
                        xtype: 'radio',
                        checked: true,
                        fieldLabel: 'Type',
                        boxLabel: OpenLayers.i18n('large'),
                        name: 'type',
                        value: 'large'
                    }, {
                        xtype: 'radio',
                        fieldLabel: '',
                        boxLabel: OpenLayers.i18n('small'),
                        name: 'type',
                        value: 'small'
                    }, {
                        xtype: 'sliderfield',
                        fieldLabel: OpenLayers.i18n('scalingFactor'),
                        name: 'scalingFactor',
                        value: 1000,
                        minValue: 400,
                        maxValue: 1800,
                        increment: 200
                    }, {
                        xtype: 'checkbox',
                        checked: true,
                        hideLabel: true,
                        fieldLabel: '',
                        labelSeparator: '',
                        boxLabel: OpenLayers.i18n('createSmall'),
                        name: 'createSmall',
                        value: 'true'
                    },{
                        xtype: 'sliderfield',
                        fieldLabel: OpenLayers.i18n('smallScalingFactor'),
                        name: 'smallScalingFactor',
                        value: 180,
                        minValue: 100,
                        maxValue: 220,
                        increment: 20
                    }*/],
                    buttons: [{
                        text: OpenLayers.i18n('upload'),
                        formBind: true,
                        iconCls: 'thumbnailGoIcon',
                        scope: this,
                        handler: function(){
                            if (this.uploadForm.getForm().isValid()) {
                                var panel = this;
                                this.uploadForm.getForm().submit({
                                    url: this.setThumbnail,
                                    waitMsg: OpenLayers.i18n('uploading'),
                                    success: function(fp, o){
                                          panel.editor.init(panel.metadataId);
                                          panel.thumbnailUploadWindow.hide();
                                    }
                                });
                            }
                        }
                    }, {
                        text: OpenLayers.i18n('reset'),
                        iconCls: 'cancel',
                        scope: this,
                        handler: function(){
                            this.uploadForm.getForm().reset();
                        }
                    }]
                });

        GeoNetwork.editor.ThumbnailPanel.superclass.initComponent.call(this);
        
        this.dataView = new Ext.DataView({
            autoHeight: true,
            autoWidth: true,
            store: this.store,
            tpl: tpl,
            singleSelect: true,
            selectedClass: 'thumbnail-selected',
            overClass:'thumbnail-over',
            itemSelector: 'li.thumbnail',
            emptyText: OpenLayers.i18n('noimages'),
            listeners: {
                selectionchange: this.selectionChangeEvent,
                scope: this
            }
        });
        this.add(this.dataView);
    
        if (this.metadataId) {
            this.reload(this, this.metadataId);
        }
        
        this.editor.on('editorClosed', this.clear, this);
        this.editor.on('metadataUpdated', this.reload, this);
        this.on('expand', this.reload);
    }
});

/** api: xtype = gn_editor_ThumbnailPanel */
Ext.reg('gn_editor_thumbnailpanel', GeoNetwork.editor.ThumbnailPanel);
