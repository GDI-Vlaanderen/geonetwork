//=============================================================================
//===	Copyright (C) 2001-2007 Food and Agriculture Organization of the
//===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===	and United Nations Environment Programme (UNEP)
//===
//===	This program is free software; you can redistribute it and/or modify
//===	it under the terms of the GNU General Public License as published by
//===	the Free Software Foundation; either version 2 of the License, or (at
//===	your option) any later version.
//===
//===	This program is distributed in the hope that it will be useful, but
//===	WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===	General Public License for more details.
//===
//===	You should have received a copy of the GNU General Public License
//===	along with this program; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: geonetwork@osgeo.org
//==============================================================================

package org.fao.geonet.jms.message.thesaurus;

import org.fao.geonet.jms.message.Message;

import java.beans.XMLDecoder;
import java.io.ByteArrayInputStream;

/**
 * @author jose garcia
 */
public class AddThesaurusElemMessage extends Message {

    private String thesaurusName;
    private String newid;
    private String prefLab;
    private String definition;
    private String lang;

    private String east;
    private String west;
    private String north;
    private String south;

    private String originatingClientID;


    public String getThesaurusName() {
        return thesaurusName;
    }

    public void setThesaurusName(String thesaurusName) {
        this.thesaurusName = thesaurusName;
    }

    public String getNewid() {
        return newid;
    }

    public void setNewid(String newid) {
        this.newid = newid;
    }

    public String getPrefLab() {
        return prefLab;
    }

    public void setPrefLab(String prefLab) {
        this.prefLab = prefLab;
    }

    public String getDefinition() {
        return definition;
    }

    public void setDefinition(String definition) {
        this.definition = definition;
    }

    public String getLang() {
        return lang;
    }

    public void setLang(String lang) {
        this.lang = lang;
    }

    public String getOriginatingClientID() {
        return originatingClientID;
    }

    public void setOriginatingClientID(String originatingClientID) {
        this.originatingClientID = originatingClientID;
    }

    public String getEast() {
        return east;
    }

    public void setEast(String east) {
        this.east = east;
    }

    public String getWest() {
        return west;
    }

    public void setWest(String west) {
        this.west = west;
    }

    public String getNorth() {
        return north;
    }

    public void setNorth(String north) {
        this.north = north;
    }

    public String getSouth() {
        return south;
    }

    public void setSouth(String south) {
        this.south = south;
    }

    public AddThesaurusElemMessage decode(String xml) {
        XMLDecoder decoder = new XMLDecoder(new ByteArrayInputStream(xml.getBytes()));
        AddThesaurusElemMessage addThesaurusElemMessage = (AddThesaurusElemMessage)decoder.readObject();
        decoder.close();
        return addThesaurusElemMessage;
    }
}
