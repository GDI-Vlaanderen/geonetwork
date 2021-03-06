//=============================================================================
//===	Copyright (C) 2001-2012 Food and Agriculture Organization of the
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
package org.fao.geonet.jms;

import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.TextMessage;
import javax.jms.Topic;

import jeeves.utils.Log;

import org.fao.geonet.constants.Geonet;
import org.fao.geonet.jms.message.MessageHandler;
import org.fao.geonet.jms.message.reindex.ReIndexMessage;

/**
 * @author heikki doeleman
 */
public class Consumer extends JMSActor {

    /**
     *
     * @param destinationName
     * @param messagingDomain
     * @param messageHandler
     * @throws ClusterException hmm
     */
    public Consumer(String queueName, String destinationName, MessagingDomain messagingDomain, final MessageHandler messageHandler) throws ClusterException {
        super();
        try {
            switch(messagingDomain) {
                case POINT_TO_POINT:
                    destination = session.createQueue(queueName + destinationName);
                    consumer = session.createConsumer(destination);
                    break;
                case PUBLISH_SUBSCRIBE:
                    destination = session.createTopic(queueName + destinationName);
                    consumer = session.createDurableSubscriber((Topic)destination, ClusterConfig.getClientID() + destinationName);
                    break;
                default:
                    throw new ClusterException("Incorrect messaging domain: " + messagingDomain.name());
            }
            MessageListener messageListener = new MessageListener() {
                public void onMessage(Message message) {
                    try {
                        if (message instanceof TextMessage) {
                            TextMessage textMessage = (TextMessage) message;
                            Log.debug(Geonet.JMS, "Consumer received message: " + textMessage.getText());
                            textMessage.acknowledge();
                            messageHandler.process(textMessage.getText());
                        }
                    } catch (JMSException x) {
                        Log.error(Geonet.JMS, "JMS error receiving message: " + x.getMessage());
                        x.printStackTrace();
                    } catch (ClusterException x) {
                        Log.error(Geonet.JMS,"Cluster error receiving message: " + x.getMessage());
                        x.printStackTrace();
                    }
                }
            };
            consumer.setMessageListener(messageListener);
        }
        catch (JMSException x) {
            Log.error(Geonet.JMS, "Error initializing Consumer for queue " + queueName +  ", destination " + destinationName + ": " + x.getMessage());
            x.printStackTrace();
            throw new ClusterException(x.getMessage(), x);
        }
    }
}