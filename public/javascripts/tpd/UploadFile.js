/**
 * @copyright Copyright Intermesh 2007
 * @author Merijn Schering <mschering@intermesh.nl>
 * 
 * Based on the File Upload Widget of Ing. Jozef Sakalos
 * 
 * This file is part of Group-Office.
 * 
 * Group-Office is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.
 * 
 * See file /LICENSE.GPL
 */

Ext.namespace('Ext.ux');

Ext.ux.UploadFile = function(config) {
    
    this.inputs = new Ext.util.MixedCollection();
    
    Ext.ux.UploadFile.superclass.constructor.call(this, config);
    
    
};


Ext.extend(Ext.ux.UploadFile, Ext.BoxComponent, {
    
    defaultAutoCreate : {tag: "div"},
    addText : 'Browse your PC',
    addIcon : 'add.png',
    deleteIcon : 'delete.png',
    fileCls: 'file',
    
    onRender : function(ct, position){
        this.id=Ext.id();
        this.el = ct.createChild({tag: 'div', id: this.id});   
        
        this.createButtons();
               
        this.createUploadInput();
        
    },
    
    createUploadInput: function() {

        if(!this.inputName)
        {
            this.inputName = Ext.id();
        }
        
        var id = Ext.id();
        
        var inp = this.inputWrap.createChild({
            tag:'input'
            , type:'file'
            , cls:'x-uf-input'
            , size:1
            , id:id
            , name:this.inputName+'[]'
        });
        inp.on('change', this.onFileAdded, this);
        this.inputs.add(inp);
        
        return inp;
    },
    
    createButtons: function() {

        // create containers sturcture
        this.buttonsWrap = this.el.createChild({
            tag:'div', cls:'x-uf-buttons-ct',
            children:[
                { tag:'div', cls:'x-uf-input-ct'
                    , children: [
                            {tag:'div', cls:'x-uf-bbtn-ct'}
                        , {tag:'div', cls:'x-uf-input-wrap'}
                    ]
                }

            ]
        });

        // save containers for future use
        this.inputWrap = this.buttonsWrap.select('div.x-uf-input-wrap').item(0);
        this.addBtnCt = this.buttonsWrap.select('div.x-uf-input-ct').item(0);

        // add button
        var bbtnCt = this.buttonsWrap.select('div.x-uf-bbtn-ct').item(0);
        this.browseBtn = new Ext.Button({
            renderTo: bbtnCt,
            text:this.addText + '...'
            , cls: 'x-btn-text-icon'
            , icon: this.addIcon
        });
        

    },
    
    /**
        * File added event handler
        * @param {Event} e
        * @param {Element} inp Added input
        */
     
    onFileAdded: function(e, inp) {

        // hide all previous inputs
        this.inputs.each(function(i) {
            i.setDisplayed(false);
        });

        // create table to hold the file queue list
        if(!this.table) {
            this.table =this.el.createChild({
                tag:'table', cls:'x-uf-table'
                , children: [ {tag:'tbody'} ]
            });
            this.tbody = this.table.select('tbody').item(0);

            this.table.on({
                click:{scope:this, fn:this.onDeleteFile, delegate:'a'}
            });
        }

        // add input to internal collection
        var inp = this.inputs.itemAt(this.inputs.getCount() - 1);

        // uninstall event handler
        inp.un('change', this.onFileAdded, this);

        // append input to display queue table
        this.appendRow(inp);

        // create new input for future use
        this.createUploadInput();
        
    },
    /**
        * Appends row to the queue table to display the file
        * Override if you need another file display
        * @param {Element} inp Input with file to display
        */
    appendRow: function(inp) {
        var filename = inp.getValue();
        var o = {
            id:inp.id
            , fileCls: this.getFileCls(filename)
            , fileName: Ext.util.Format.ellipsis(filename.split(/[/]/).pop(), this.maxNameLength)
            , fileQtip: filename
        }

        var t = new Ext.Template([
            '<tr id="r-{id}">'
            , '<td class="x-unselectable {fileCls} x-tree-node-leaf">'
            , '<img class="x-tree-node-icon" src="' + Ext.BLANK_IMAGE_URL + '">'
            , '<span class="x-uf-filename" unselectable="on" qtip="{fileQtip}">{fileName}</span>'
            , '</td>'
            , '<td id="m-{id}" class="x-uf-filedelete"><a id="d-{id}" href="#"><img src="' + this.deleteIcon + '"></a>'
            , '</td>'
            , '</tr>'
        ]);

        // save row reference for future
        inp.row = t.append(this.tbody, o, true);
    },
    
    onDeleteFile: function(e, target) {
        this.removeFile(target.id.substr(2));
    }, 
    
        /**
        * Removes file from the queue
        * private
        *
        * @param {String} id Id of the file to remove (id is auto generated)
        * @param {Boolean} suppresEvent Set to true not to fire event
        */
    removeFile: function(id) {
        if(this.uploading) {
            return;
        }
        var inp = this.inputs.get(id);
        if(inp && inp.row) {
            inp.row.remove();
        }
        if(inp) {
            inp.remove();
        }
        this.inputs.removeKey(id);

    },
    
    getFileCls: function(name) {
        var atmp = name.split('.');
        if(1 === atmp.length) {
            return this.fileCls;
        }
        else {
            return this.fileCls + '-' + atmp.pop();
        }
    }, 
    clearQueue: function() {
        this.inputs.each(function(inp) {
            if(!inp.isVisible()) {
                this.removeFile(inp.id, true);
            }
        }, this);
    },

    /**
    * Disables/Enables the whole form by masking/unmasking it
    *
    * @param {Boolean} disable true to disable, false to enable
    * @param {Boolean} alsoUpload true to disable also upload button
    */
    setDisabled: function(disable) {

        if(disable) {
            this.addBtnCt.mask();
        }
        else {
            this.addBtnCt.unmask();
        }
    }
    
});