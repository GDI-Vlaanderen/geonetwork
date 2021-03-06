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

package org.fao.geonet.services.metadata;

import java.util.List;

import jeeves.constants.Jeeves;
import jeeves.exceptions.OperationNotAllowedEx;
import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Log;
import jeeves.utils.Util;

import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.kernel.AccessManager;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.MdInfo;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.services.Utils;
import org.jdom.Element;
import org.tuckey.web.filters.urlrewrite.utils.StringUtils;

/**
 *  Grab lock of metadata, moving it from the current lock owner to the indicated user.
 *
 *  Depending on user profile:
 *
 *   - Administrator: no restrictions
 *   - Reviewer, UserAdmin: if the metadata is owned by the user's groups, can reassign lock to other users in user's groups
 *   - Editor: cannot reassign lock UNLESS 'symbolicLocking' is enabled, then same as if Reviewer
 *   - Other profiles: throw exception OperationNotAllowedEx
 *
 *  @author heikki doeleman
 */
public class GrabLock implements Service {

	public void init(String appPath, ServiceConfig params) throws Exception {}

	public Element exec(Element params, ServiceContext context) throws Exception {
        System.out.println("GRABLOCK");
        // metadata id
        String metadataId = Util.getParam(params, Params.ID);

        // user to assign the lock to
        String targetUserId = Util.getParam(params, Params.USER_ID);

        // current user executing this service
    	UserSession session = context.getUserSession();
        String userId = session.getUserId();
        String userProfile = session.getProfile();

        if (userProfile == null) {
            throw new OperationNotAllowedEx("Unauthorized user " + userId + " attempted to grab lock");
        }

        GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
        SettingManager settingManager = gc.getSettingManager();
        DataManager   dataMan = gc.getDataManager();
        AccessManager accessManager = gc.getAccessManager();
        Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);

        boolean symbolicLocking = settingManager.getValueAsBool("system/symbolicLocking/enable");

        Log.debug(Geonet.EDITOR, "symbolic locking: " + symbolicLocking);

        if(accessManager.grabLockAllowed(userProfile, userId, targetUserId, metadataId, dbms, symbolicLocking)) {
            Log.debug(Geonet.EDITOR, "GrabLock allowed !");
            MdInfo info = dataMan.getMetadataInfo(dbms, metadataId);
            if (info == null) {
                throw new IllegalArgumentException("Metadata not found --> " + metadataId);
            }
            String lockedBy = info.lockedBy;
            dataMan.grabLockMetadata(dbms, metadataId, targetUserId);
            if (!StringUtils.isBlank(lockedBy)) {
        		List<Element> userList = dbms.select("SELECT email FROM Users WHERE id = '" + lockedBy + "'").getChildren();
        		Element user = (Element) userList.get(0);
        		user.detach();
        		Element root = Utils.getNewRootElement(context, dbms, Params.Status.DRAFT, null, userId);
        		Utils.addUserContent(dbms, root, targetUserId, "targetUser", "targetGroup");
        		Element metadata = new Element("metadata");
    			root.addContent(metadata);
    			metadata.addContent(new Element("url").setText(Utils.buildMetadataLink(context, info.uuid)));
    			metadata.addContent(new Element("title").setText(dataMan.extractTitle(context, info.schemaId, metadataId)));
    			metadata.addContent(new Element("currentStatus").setText(""));
    			String replyTo = session.getEmailAddr();
    			String replyToDescr = null;
    			if (replyTo != null) {
    				replyToDescr = session.getName() + " " + session.getSurname();
    			} else {
    				replyTo = settingManager.getValue("system/feedback/email");
    				replyToDescr = context.getServlet().getFromDescription();
    			}
    			Utils.sendEmail(context, user.getChildText("email"), replyTo, replyToDescr, root);
//				sendEmail(context, user.getChildText("email"), root);
            }
        }
        else {
            throw new OperationNotAllowedEx("You are not authorized to grab this metadata lock.");
        }

		Element elResp = new Element(Jeeves.Elem.RESPONSE);
		return elResp;
    }
}