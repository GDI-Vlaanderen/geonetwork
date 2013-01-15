//===	Copyright (C) 2001-2005 Food and Agriculture Organization of the
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
//===	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: GeoNetwork@fao.org
//==============================================================================

package org.fao.geonet.kernel;

import jeeves.utils.Log;
import jeeves.utils.Xml;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.jms.ClusterConfig;
import org.fao.geonet.jms.ClusterException;
import org.fao.geonet.jms.Producer;
import org.fao.geonet.jms.message.thesaurus.AddThesaurusElemMessage;
import org.fao.geonet.jms.message.thesaurus.DeleteThesaurusElemMessage;
import org.fao.geonet.jms.message.thesaurus.UpdateThesaurusElemMessage;
import org.fao.geonet.languages.IsoLanguagesMapper;
import org.jdom.Element;
import org.jdom.Namespace;
import org.openrdf.model.BNode;
import org.openrdf.model.Graph;
import org.openrdf.model.GraphException;
import org.openrdf.model.Literal;
import org.openrdf.model.Statement;
import org.openrdf.model.URI;
import org.openrdf.model.Value;
import org.openrdf.model.ValueFactory;
import org.openrdf.sesame.config.AccessDeniedException;
import org.openrdf.sesame.constants.QueryLanguage;
import org.openrdf.sesame.query.MalformedQueryException;
import org.openrdf.sesame.query.QueryEvaluationException;
import org.openrdf.sesame.query.QueryResultsTable;
import org.openrdf.sesame.repository.local.LocalRepository;
import org.openrdf.sesame.sail.StatementIterator;
import org.springframework.util.StringUtils;

import java.io.File;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.concurrent.atomic.AtomicReference;

public class Thesaurus {
	private String fname;

	private String type;

	private String dname;

	private File thesaurusFile;

	private LocalRepository repository;

    private String title;

    private String date;

    private String version;

    private String downloadUrl;

    private String keywordUrl;

	@SuppressWarnings("unused")
	private String name;

	@SuppressWarnings("unused")
	private String description;

	@SuppressWarnings("unused")
	private String source;

	@SuppressWarnings("unused")
	private String langue;

	@SuppressWarnings("unused")
	private String autority;

	/**
	 * @param fname
	 *            file name
	 * @param type
	 * @param dname
	 */
	public Thesaurus(String fname, String type, String dname, File thesaurusFile, String siteUrl) {
		super();
		this.fname = fname;
		this.type = type;
		this.dname = dname;
		this.thesaurusFile = thesaurusFile; 
		this.downloadUrl = buildDownloadUrl(fname, type, dname, siteUrl);
		this.keywordUrl = buildKeywordUrl(fname, type, dname, siteUrl);
		
        retrieveThesaurusTitle(thesaurusFile, dname + "." + fname);

	}

	/**
	 * 
	 * @return Thesaurus identifier
	 */
	public String getKey() {
		return buildThesaurusKey(fname, type, dname);
	}

	public String getDname() {
		return dname;
	}

	public String getFname() {
		return fname;
	}

	public File getFile() {
		return thesaurusFile;
	}

	public String getType() {
		return type;
	}

    public String getTitle() {
		return title;
	}

  public String getVersion() {
		return version;
	}

    public String getDate() {
		return date;
	}

  public String getDownloadUrl() {
		return downloadUrl;
	}

  public String getKeywordUrl() {
		return keywordUrl;
	}

  public void retrieveThesaurusTitle() {
    retrieveThesaurusTitle(thesaurusFile, dname + "." + fname);
	}


	/**
	 * 
	 * @param fname
	 * @param type
	 * @param dname
	 * @return
	 */
	public static String buildThesaurusKey(String fname, String type, String dname) {
		return type + "." + dname + "." + fname.substring(0, fname.indexOf(".rdf"));
	}

	private String buildDownloadUrl(String fname, String type, String dname, String siteUrl) {
		if (type.equals(Geonet.CodeList.REGISTER)) {
			return siteUrl + "/?uuid="+fname.substring(0, fname.indexOf(".rdf"));
		} else {
			return siteUrl + "/thesaurus.download?ref="+Thesaurus.buildThesaurusKey(fname, type, dname);
		}
	}

	private String buildKeywordUrl(String fname, String type, String dname, String siteUrl) {
		return siteUrl + "/xml.keyword.get?thesaurus="+Thesaurus.buildThesaurusKey(fname, type, dname) + "&amp;id="; 
		// needs to have term/concept id tacked onto the end
	}

	public LocalRepository getRepository() {
		return repository;
	}

	public void setRepository(LocalRepository repository) {
		this.repository = repository;
	}

    /**
     * TODO javadoc.
     *
     * @param query
     * @return
     * @throws IOException
     * @throws MalformedQueryException
     * @throws QueryEvaluationException
     * @throws AccessDeniedException
     */
	public QueryResultsTable performRequest(String query) throws IOException, MalformedQueryException,
            QueryEvaluationException, AccessDeniedException {
        if(Log.isDebugEnabled(Geonet.THESAURUS))
        Log.debug(Geonet.THESAURUS, "Query : " + query);

        //printResultsTable(resultsTable);
		return repository.performTableQuery(QueryLanguage.SERQL, query);
	}

	/**
	 * 
	 * @param resultsTable
	 */
    @SuppressWarnings("unused")    
	private void printResultsTable(QueryResultsTable resultsTable) {
		int rowCount = resultsTable.getRowCount();
		int columnCount = resultsTable.getColumnCount();

		for (int row = 0; row < rowCount; row++) {
			for (int column = 0; column < columnCount; column++) {
				Value value = resultsTable.getValue(row, column);

				if (value != null) {
					System.out.print(value.toString());
				} else {
					System.out.print("null");
				}
				System.out.print("\t");
			}
		}
	}

    /**
     * TODO javadoc.
     *
     * @param code
     * @param prefLab
     * @param note
     * @param lang
     * @return
     * @throws GraphException
     * @throws IOException
     * @throws AccessDeniedException
     */
    public URI addElement(String code, String prefLab, String note, String lang) throws GraphException, IOException,
            AccessDeniedException, ClusterException {

        lang = toiso639_1_Lang(lang);
        URI uri = addElementWithoutSendingTopic(code, prefLab, note,  lang);

        // TODO: Maybe better to add methods in ThesaurusManager to abstract add/delete/update thesaurus manager and move this code there?
        if(ClusterConfig.isEnabled()) {
            AddThesaurusElemMessage message = new AddThesaurusElemMessage();
            message.setOriginatingClientID(ClusterConfig.getClientID());
            message.setThesaurusName(getKey());
            message.setNewid(code);
            message.setPrefLab(prefLab);
            message.setDefinition(note);
            message.setLang(lang);

            Producer addThesaurusElProducer = ClusterConfig.get(Geonet.ClusterMessageTopic.ADDTHESAURUS_ELEM);
            addThesaurusElProducer.produce(message);
        }

        return uri;
    }

	public URI addElementWithoutSendingTopic(String code, String prefLab, String note, String lang) throws GraphException, IOException,
            AccessDeniedException {

		Graph myGraph = new org.openrdf.model.impl.GraphImpl();

		ValueFactory myFactory = myGraph.getValueFactory();
		String namespaceSkos = "http://www.w3.org/2004/02/skos/core#";
		//String namespace = "http://geosource.org/keyword#";
		String namespace = "#";

		URI mySubject = myFactory.createURI(namespace, code);

		URI skosClass = myFactory.createURI(namespaceSkos, "Concept");
		URI rdfType = myFactory.createURI(org.openrdf.vocabulary.RDF.TYPE);
		mySubject.addProperty(rdfType, skosClass); 

		URI myPredicate1 = myFactory.createURI(namespaceSkos, "prefLabel");
		Literal myObject1 = myFactory.createLiteral(prefLab, lang);
		myGraph.add(mySubject, myPredicate1, myObject1);

		URI myPredicate2 = myFactory.createURI(namespaceSkos, "scopeNote");
		Literal myObject2 = myFactory.createLiteral(note, lang);
		myGraph.add(mySubject, myPredicate2, myObject2);

		repository.addGraph(myGraph);

		return mySubject;
	}

    /**
     * TODO javadoc.
     *
     * @param code
     * @param prefLab
     * @param note
     * @param east
     * @param west
     * @param south
     * @param north
     * @param lang
     * @throws IOException
     * @throws AccessDeniedException
     * @throws GraphException
     */
    public void addElement(String code, String prefLab, String note, String east, String west, String south,
                           String north, String lang) throws IOException, AccessDeniedException, GraphException, ClusterException {
        lang = toiso639_1_Lang(lang);
        addElementWithoutSendingTopic(code,prefLab, note, east,  west,  south, north, lang);

        // TODO: Maybe better to add methods in ThesaurusManager to abstract add/delete/update thesaurus manager and move this code there?
        if(ClusterConfig.isEnabled()) {
            AddThesaurusElemMessage message = new AddThesaurusElemMessage();
            message.setOriginatingClientID(ClusterConfig.getClientID());
            message.setThesaurusName(getKey());
            message.setNewid(code);
            message.setPrefLab(prefLab);
            message.setDefinition(note);
            message.setLang(lang);
            message.setEast(east);
            message.setWest(west);
            message.setNorth(north);
            message.setSouth(south);

            Producer addThesaurusElProducer = ClusterConfig.get(Geonet.ClusterMessageTopic.ADDTHESAURUS_ELEM);
            addThesaurusElProducer.produce(message);
        }

    }

	public void addElementWithoutSendingTopic(String code, String prefLab, String note, String east, String west, String south,
                           String north, String lang) throws IOException, AccessDeniedException, GraphException {
		Graph myGraph = new org.openrdf.model.impl.GraphImpl();

		ValueFactory myFactory = myGraph.getValueFactory();

		// Define namespace
		String namespaceSkos = "http://www.w3.org/2004/02/skos/core#";
		String namespaceGml = "http://www.opengis.net/gml#";
		String namespace = "#";

		// Create subject
		URI mySubject = myFactory.createURI(namespace, code);

		URI skosClass = myFactory.createURI(namespaceSkos, "Concept");
		URI rdfType = myFactory.createURI(org.openrdf.vocabulary.RDF.TYPE);
		URI predicatePrefLabel = myFactory
				.createURI(namespaceSkos, "prefLabel");
		URI predicateScopeNote = myFactory
				.createURI(namespaceSkos, "scopeNote");

		URI predicateBoundedBy = myFactory.createURI(namespaceGml, "BoundedBy");
		URI predicateEnvelope = myFactory.createURI(namespaceGml, "Envelope");
		URI predicateSrsName = myFactory.createURI(namespaceGml, "srsName");
		URI srsNameURI = myFactory
				.createURI("http://www.opengis.net/gml/srs/epsg.xml#epsg:4326");
		BNode gmlNode = myFactory.createBNode();
		URI predicateLowerCorner = myFactory.createURI(namespaceGml,
				"lowerCorner");
		URI predicateUpperCorner = myFactory.createURI(namespaceGml,
				"upperCorner");

		Literal myObject1 = myFactory.createLiteral(prefLab, lang);
		Literal myObject2 = myFactory.createLiteral(note, lang);

		Literal lowerCorner = myFactory.createLiteral(west + " " + south);
		Literal upperCorner = myFactory.createLiteral(east + " " + north);

		mySubject.addProperty(rdfType, skosClass);
		myGraph.add(mySubject, predicatePrefLabel, myObject1);
		myGraph.add(mySubject, predicateScopeNote, myObject2);
		myGraph.add(mySubject, predicateBoundedBy, gmlNode);

		gmlNode.addProperty(rdfType, predicateEnvelope);
		myGraph.add(gmlNode, predicateLowerCorner, lowerCorner);
		myGraph.add(gmlNode, predicateUpperCorner, upperCorner);
		myGraph.add(gmlNode, predicateSrsName, srsNameURI);

		repository.addGraph(myGraph);

	}

    /**
     * Remove keyword from thesaurus.
     * 
     * @param keyword
     * @throws MalformedQueryException
     * @throws QueryEvaluationException
     * @throws IOException
     * @throws AccessDeniedException
     */
    public void removeElement(KeywordBean keyword) throws MalformedQueryException,
            QueryEvaluationException, IOException, AccessDeniedException, ClusterException {
        String namespace = keyword.getNameSpaceCode();
        String code = keyword.getRelativeCode();

        removeElement(namespace, code);
    }
    
    /**
     * Remove keyword from thesaurus.
     * 
     * @param namespace
     * @param code
     * @throws AccessDeniedException
     */
    public void removeElement(String namespace, String code) throws AccessDeniedException, ClusterException {
        removeElementWithoutSendingTopic(namespace, code);

        // TODO: Maybe better to add methods in ThesaurusManager to abstract add/delete/update thesaurus manager and move this code there?
        if(ClusterConfig.isEnabled()) {
            DeleteThesaurusElemMessage message = new DeleteThesaurusElemMessage();
            message.setOriginatingClientID(ClusterConfig.getClientID());
            message.setNamespace(namespace) ;
            message.setCode(code);
            message.setThesaurusName(getKey()) ;
            
            Producer deleteThesaurusElProducer = ClusterConfig.get(Geonet.ClusterMessageTopic.DELETETHESAURUS_ELEM);
            deleteThesaurusElProducer.produce(message);
        }
    }


    public void removeElementWithoutSendingTopic(String namespace, String code) throws AccessDeniedException {
        Graph myGraph = repository.getGraph();
        ValueFactory myFactory = myGraph.getValueFactory();
        URI subject = myFactory.createURI(namespace, code);
        StatementIterator iter = myGraph.getStatements(subject, null, null);
        while (iter.hasNext()) {
            AtomicReference<Statement> st = new AtomicReference<Statement>(iter.next());
            if (st.get().getObject() instanceof BNode) {
                BNode node = (BNode) st.get().getObject();
                repository.getGraph().remove(node, null, null);
            }
        }
        myGraph.remove(subject, null, null);
    }

    /**
     * TODO javadoc.
     *
     * @param namespace
     * @param id
     * @param prefLab
     * @param note
     * @param lang
     * @return
     * @throws IOException
     * @throws MalformedQueryException
     * @throws QueryEvaluationException
     * @throws AccessDeniedException
     * @throws GraphException
     */
    public URI updateElement(String namespace, String id, String prefLab, String note, String lang) throws IOException,
            MalformedQueryException, QueryEvaluationException, AccessDeniedException, GraphException, ClusterException {
        lang = toiso639_1_Lang(lang);
        URI uri = updateElementWithoutSendingTopic(namespace, id, prefLab, note, lang);

        // TODO: Maybe better to add methods in ThesaurusManager to abstract add/delete/update thesaurus manager and move this code there?
        if(ClusterConfig.isEnabled()) {
            UpdateThesaurusElemMessage message = new UpdateThesaurusElemMessage();
            message.setOriginatingClientID(ClusterConfig.getClientID());
            message.setThesaurusName(getKey());
            message.setNamespace(namespace);
            message.setNewid(id);
            message.setPrefLab(prefLab);
            message.setDefinition(note);
            message.setLang(lang);

            Producer addThesaurusElProducer = ClusterConfig.get(Geonet.ClusterMessageTopic.UPDATETHESAURUS_ELEM);
            addThesaurusElProducer.produce(message);
        }


        return uri;
    }

	public URI updateElementWithoutSendingTopic(String namespace, String id, String prefLab, String note, String lang) throws IOException,
            MalformedQueryException, QueryEvaluationException, AccessDeniedException, GraphException {
		// Get thesaurus graph
		Graph myGraph = repository.getGraph();		
		
		// Set namespace skos and predicates 
		ValueFactory myFactory = myGraph.getValueFactory();
		String namespaceSkos = "http://www.w3.org/2004/02/skos/core#";
		URI predicatePrefLabel = myFactory
				.createURI(namespaceSkos, "prefLabel");
		URI predicateScopeNote = myFactory
				.createURI(namespaceSkos, "scopeNote");

		// Get subject (URI)
		URI subject = myFactory.createURI(namespace,id);

		// Remove old one
		StatementIterator iter = myGraph.getStatements(subject,
				predicatePrefLabel, null);
		while (iter.hasNext()) {
			AtomicReference<Statement> st = new AtomicReference<Statement>(iter.next());
			if (st.get().getObject() instanceof Literal) {
				Literal litt = (Literal) st.get().getObject();
				if (litt.getLanguage() != null
						&& litt.getLanguage().equals(lang)) {
					// remove
					myGraph.remove(st.get());
					break;
				}
			}
		}
		// Supp de scopeNote
		iter = myGraph.getStatements(subject, predicateScopeNote, null);
		while (iter.hasNext()) {
			AtomicReference<Statement> st = new AtomicReference<Statement>(iter.next());
			if (st.get().getObject() instanceof Literal) {
				Literal litt = (Literal) st.get().getObject();
				if (litt.getLanguage() != null
						&& litt.getLanguage().equals(lang)) {
					// Remove
					myGraph.remove(st.get());
					break;
				}
			}
		}

		Literal litPrefLab = myFactory.createLiteral(prefLab, lang);
		Literal litNote = myFactory.createLiteral(note, lang);

		myGraph.add(subject, predicatePrefLabel, litPrefLab);
		myGraph.add(subject, predicateScopeNote, litNote);

		return subject;
	}

    private String toiso639_1_Lang(String lang) {
         if (lang != null && lang.length() > 2) {
             try {
                 lang = IsoLanguagesMapper.getInstance().iso639_2_to_iso639_1(lang);
             } catch (Exception e) {
                 throw new RuntimeException(e);
             }
         }
         return lang;
     }

    /**
     * TODO javadoc.
     *
     * @param namespace
     * @param id
     * @param prefLab
     * @param note
     * @param east
     * @param west
     * @param south
     * @param north
     * @param lang
     * @throws AccessDeniedException
     * @throws IOException
     * @throws MalformedQueryException
     * @throws QueryEvaluationException
     * @throws GraphException
     */
    public void updateElement(String namespace, String id, String prefLab, String note, String east, String west,
                              String south, String north, String lang) throws AccessDeniedException, IOException,
            MalformedQueryException, QueryEvaluationException, GraphException, ClusterException {

      updateElementWithoutSendingTopic(namespace, id, prefLab, note, east, west, south, north, lang);

        // TODO: Maybe better to add methods in ThesaurusManager to abstract add/delete/update thesaurus manager and move this code there?
        if(ClusterConfig.isEnabled()) {
            UpdateThesaurusElemMessage message = new UpdateThesaurusElemMessage();
            message.setOriginatingClientID(ClusterConfig.getClientID());
            message.setThesaurusName(getKey());
            message.setNamespace(namespace);
            message.setNewid(id);
            message.setPrefLab(prefLab);
            message.setDefinition(note);
            message.setLang(lang);
            message.setEast(east);
            message.setWest(west);
            message.setSouth(south);
            message.setNorth(north);

            Producer addThesaurusElProducer = ClusterConfig.get(Geonet.ClusterMessageTopic.UPDATETHESAURUS_ELEM);
            addThesaurusElProducer.produce(message);
        }
    }
    
    
	public void updateElementWithoutSendingTopic(String namespace, String id, String prefLab, String note, String east, String west,
                              String south, String north, String lang) throws AccessDeniedException, IOException,
            MalformedQueryException, QueryEvaluationException, GraphException {

		// update label and definition
		URI subject = updateElementWithoutSendingTopic(namespace, id, prefLab, note, lang);

		// update bbox

		Graph myGraph = repository.getGraph();

		ValueFactory myFactory = myGraph.getValueFactory();
		String namespaceGml = "http://www.opengis.net/gml#";
		URI predicateBoundedBy = myFactory.createURI(namespaceGml, "BoundedBy");
		URI predicateLowerCorner = myFactory.createURI(namespaceGml,
				"lowerCorner");
		URI predicateUpperCorner = myFactory.createURI(namespaceGml,
				"upperCorner");

		BNode subjectGml = null;
		StatementIterator iter = myGraph.getStatements(subject,
				predicateBoundedBy, null);
		while (iter.hasNext()) {
			AtomicReference<Statement> st = new AtomicReference<Statement>(iter.next());
			if (st.get().getObject() instanceof BNode) {
				subjectGml = (BNode) st.get().getObject();
			}
		}
		if (subjectGml != null) {
			// lowerCorner
			iter = myGraph.getStatements(subjectGml, predicateLowerCorner, null);
			while (true) {
                if (!(iter.hasNext())) {
                    break;
                }
                AtomicReference<Statement> st = new AtomicReference<Statement>(iter.next());
				myGraph.remove(st.get());
				break;
			}
			// upperCorner
			iter = myGraph.getStatements(subjectGml, predicateUpperCorner, null);
			while (true) {
                if (!(iter.hasNext())) {
                    break;
                }
                AtomicReference<Statement> st = new AtomicReference<Statement>(iter.next());
				myGraph.remove(st.get());
				break;
			}
			// Preparation des nouveaux statements
			Literal lowerCorner = myFactory.createLiteral(west + " " + south);
			Literal upperCorner = myFactory.createLiteral(east + " " + north);

			// ajout des nouveaux statements
			myGraph.add(subjectGml, predicateLowerCorner, lowerCorner);
			myGraph.add(subjectGml, predicateUpperCorner, upperCorner);
		}
	}

    /**
     * TODO javadoc.
     *
     * @param namespace
     * @param code
     * @return
     * @throws AccessDeniedException
     */
	public boolean isFreeCode(String namespace, String code) throws AccessDeniedException {
		boolean res = true;				
		Graph myGraph = repository.getGraph();
		ValueFactory myFactory = myGraph.getValueFactory();		
		URI obj = myFactory.createURI(namespace,code);
		Collection statementsCollection = myGraph.getStatementCollection(obj,null,null);
		if (statementsCollection!=null && statementsCollection.size()>0){
			res = false;
		}
		statementsCollection = myGraph.getStatementCollection(null,null,obj);
		if (statementsCollection!=null && statementsCollection.size()>0){
			res = false;
		}				
		return res;
	}

    /**
     * TODO javadoc.
     *
     * @param namespace
     * @param oldcode
     * @param newcode
     * @throws AccessDeniedException
     * @throws IOException
     */
	public void updateCode(String namespace, String oldcode, String newcode) throws AccessDeniedException, IOException {
		Graph myGraph = repository.getGraph();
		//Graph myTmpGraph = new org.openrdf.model.impl.GraphImpl();
		
		ValueFactory myFactory = myGraph.getValueFactory();
		//ValueFactory myTmpFactory = myTmpGraph.getValueFactory();
		
		URI oldobj = myFactory.createURI(namespace,oldcode);
		URI newobj = myFactory.createURI(namespace,newcode);
		StatementIterator iterStSubject = myGraph.getStatements(oldobj,null,null);
		while(iterStSubject.hasNext()){
			AtomicReference<Statement> st = new AtomicReference<Statement>(iterStSubject.next());
			myGraph.add(newobj, st.get().getPredicate(), st.get().getObject());
		}		
		
		StatementIterator iterStObject = myGraph.getStatements(null,null,oldobj);
		while(iterStObject.hasNext()){
			Statement st = iterStObject.next();
			myGraph.add(st.getSubject(), st.getPredicate(), newobj);
		}
		myGraph.remove(oldobj,null,null);
		myGraph.remove(null,null,oldobj);		
		//repository.addGraph(myTmpGraph);
	}

    /**
     * Retrieves the thesaurus title from rdf file.
     *
     * Used to set the thesaurusName, thesaurusDate and thesaurusVersion
     * for keywords. Note we assume that the thesaurus is versioned according
     * to the SKOS Core Guide on http://www.w3.org/TR/2005/WD-swbp-skos-core-guide-20051102/#secschemeversioning
     *
     */
    private void retrieveThesaurusTitle(File thesaurusFile, String defaultTitle) {
        try {
            Element thesaurusEl = Xml.loadFile(thesaurusFile);

            List<Namespace> theNSs = new ArrayList<Namespace>();
	    Namespace rdfNs = Namespace.getNamespace("rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#");
            theNSs.add(rdfNs);
            theNSs.add(Namespace.getNamespace("skos", "http://www.w3.org/2004/02/skos/core#"));
            theNSs.add(Namespace.getNamespace("dc", "http://purl.org/dc/elements/1.1/"));
            theNSs.add(Namespace.getNamespace("dcterms", "http://purl.org/dc/terms/"));

            Element title = Xml.selectElement(thesaurusEl, "skos:ConceptScheme/dc:title", theNSs);
            if (title != null) {
                this.title = title.getValue();
            } else {
                this.title = defaultTitle;
            }

            Element dateEl = Xml.selectElement(thesaurusEl, "skos:ConceptScheme/dcterms:issued", theNSs);

            Date thesaususDate = parseThesaurusDate(dateEl);

            if (thesaususDate == null) {
                dateEl = Xml.selectElement(thesaurusEl, "skos:ConceptScheme/dcterms:modified", theNSs);
                thesaususDate = parseThesaurusDate(dateEl);
            }

            if (thesaususDate != null) {
                DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
                this.date = df.format(thesaususDate);
            }

            Element versionEl = Xml.selectElement(thesaurusEl, "skos:ConceptScheme", theNSs);
						if (versionEl != null) {
							this.version = versionEl.getAttributeValue("about",rdfNs);
							if (!StringUtils.hasLength(this.version)) this.version="unknown";
						} else {
							this.version = "unknown"; // not really acceptable!
						}

        } catch (Exception ex) {
            Log.error(Geonet.THESAURUS_MAN, "Error getting thesaurus info: " + ex.getMessage());
        }
    }

    /**
     * Method to parse the thesaurus date value
     *
     * @param dateEl   thesaurus date element
     * @return  Date object representing the thesaurus date value
     */
    private Date parseThesaurusDate(Element dateEl) {
        Date thesaurusDate = null;

        if (dateEl == null) return thesaurusDate;

        String dateVal = dateEl.getText();
        // inspire-theme.rdf contains an invalid date starting with Fry
        if(dateVal.startsWith("Fry")) {
            dateVal = dateVal.replace("Fry", "Fri");
        }

        // Try several date formats (date format seem not unified)
        List<SimpleDateFormat> dfList = new ArrayList<SimpleDateFormat>();

        dfList.add(new SimpleDateFormat("EEE MMM d HH:mm:ss z yyyy"));
        dfList.add(new SimpleDateFormat("EEE MMM d HH:mm:ss zzz yyyy"));
        dfList.add(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss"));
        dfList.add(new SimpleDateFormat("yyyy-MM-dd"));

        StringBuffer errorMsg = new StringBuffer("Error parsing the thesaurus date value: ");
        errorMsg.append(dateVal);
        boolean success = false;
        
        for(SimpleDateFormat df: dfList) {
            try {
                thesaurusDate = df.parse(dateVal);
                success = true;
            } catch(Exception ex) {
                // Ignore the exception and try next format
                errorMsg.append("\n  * with format: ");
                errorMsg.append(df.toPattern());
                errorMsg.append(". Error is: ");
                errorMsg.append(ex.getMessage());
            }
        }
        // Report error if no success
        if (!success) {
            errorMsg.append("\nCheck thesaurus date in ");
            errorMsg.append(this.fname);
            Log.error(Geonet.THESAURUS_MAN, errorMsg.toString());
        }
        return thesaurusDate;
    }

		/**
		 * finalize method shuts down the local sesame repository just before an 
		 * unused Thesaurus object is garbage collected - to save resources 
		 *
	   */
		protected void finalize() {
			if (repository != null) {
				repository.shutDown();
			}
		}

}
