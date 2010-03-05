package ibbt.sumo.config;
/**----------------------------------------------------------------------------------------
** This file is part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
**
** This program is free software; you can redistribute it and/or modify it under
** the terms of the GNU Affero General Public License version 3 as published by the
** Free Software Foundation.
** 
** This program is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
** PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
** 
** You should have received a copy of the GNU Affero General Public License along
** with this program; if not, see http://www.gnu.org/licenses or write to the Free
** Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
** 02110-1301 USA, or download the license from the following URL:
** 
** http://www.sumo.intec.ugent.be
** 
** In accordance with Section 7(b) of the GNU Affero General Public License, these
** Appropriate Legal Notices must retain the display of the "SUMO Toolbox" text and
** homepage.  In addition, when mentioning the program in written work, reference
** must be made to the corresponding publication.
** 
** You can be released from these requirements by purchasing a commercial license.
** Buying such a license is in most cases mandatory as soon as you develop
** commercial activities involving the SUMO Toolbox software. Commercial activities
** include: consultancy services or using the SUMO Toolbox in commercial projects 
** (standalone, on a server, through a webservice or other remote access technology).
** 
** For more information, please contact SUMO lab at
** 
**             sumo@intec.ugent.be - www.sumo.intec.ugent.be
**
** Revision: $Id: ConfigUtil.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import java.io.File;
import java.io.FileWriter;
import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.Logger;

import org.dom4j.Attribute;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.Node;
import org.dom4j.io.OutputFormat;
import org.dom4j.io.SAXReader;
import org.dom4j.io.XMLWriter;

/**
 * A class with configuration related helper functions
 */
public class ConfigUtil {
	
	private static Logger logger = Logger.getLogger("ibbt.sumo.config.ConfigUtil");
	private static boolean fVerbose = false;
	
//	-------------------------------------------------------------------------------------
	public static Document readXML(String file)throws DocumentException {
		return readXML(new File(file));
	}
//	-------------------------------------------------------------------------------------
	public static Document readXML(File file)throws DocumentException {
		SAXReader sr = new SAXReader();
		return sr.read(file);
	}
//	-------------------------------------------------------------------------------------	
	public static void writeXML(Document doc, String filename) {
		try { 
			OutputFormat pp = OutputFormat.createPrettyPrint();
			XMLWriter writer = new XMLWriter(new FileWriter(filename),pp);
	        writer.write(doc);
	        writer.close();			
		} catch (Exception e) {
			logger.info("Error Writing Document to file " + filename);
		}
	}
//	------------------------------------------------------------------------------------- 
	public static List getPlanLevelConfig(Document doc){
		return doc.selectNodes("//Plan/child::*[name()!='Run']");
	}
//	-------------------------------------------------------------------------------------	
	public static List getRunLevelConfig(Document doc, int run){
		return doc.selectNodes("//Plan/Run[" + run + "]/*");
	}
//	-------------------------------------------------------------------------------------	
	public static String getRunName(Document doc, int run){
		Node n = doc.selectSingleNode("//Plan/Run[" + run + "]/@name");
		if(n == null){
			return "";
		}else{
			return n.getText();
		}
	}
//	-------------------------------------------------------------------------------------
	/**
	 * Is a sample selector defined for this run
	 */
	public static boolean samplingEnabled(List runConfig){
		
		List res = getTagByNameAsList(runConfig, "SampleSelector", true);
	
		return (res != null && res.size() > 0);
	}
//	-------------------------------------------------------------------------------------	
	@SuppressWarnings("unchecked")
	public static List updateConfig(List baseConfig, List extendedConfig){
		
/*		System.out.println("** The base level configs are: ");
		for(Object n : baseConfig){
			System.out.println(((Node)n).getName() + " - " + ((Node)n).getText().trim());
		}
		
		System.out.println("** The extended level configs are: ");
		for(Object n : extendedConfig){
			System.out.println(((Node)n).getName() + " - " + ((Node)n).getText().trim());
		} */
		
		
		logger.finer("Merging the extended level config with the base level config...");
		Iterator baseIt = baseConfig.iterator();
		Iterator extendedIt = null;
		
		List res = new LinkedList();
		boolean overridden = true;
		boolean matchFound = false;
		Node baseNode = null;
		Node extendedNode = null;

		//for every element in the base config
		while(baseIt.hasNext()){
			baseNode = (Node)baseIt.next();
			extendedIt = extendedConfig.iterator();
			
			matchFound = false;
			
			//for every element in the extended config
			while(extendedIt.hasNext() && !matchFound){
			
				extendedNode = (Node)extendedIt.next();
				
				//find a tag with the same name at the extended level
				if(baseNode.getName().equals(extendedNode.getName())){
					
					//we found a match, keep the extended level entry
					matchFound = true;
					res.add(extendedNode.clone());
					extendedIt.remove();
					
					//now decide what we should do with the base level entry, should it be discarded (overridden) or retained (ie, it complements the extended level entry)
					if( baseNode.getName().equals("Measure")){
						overridden = false;
					}else{
						overridden = true;
					}
				}
			}
			
			//If a match was found for this base level component, should it be overridden or complemented
			if(matchFound){
				//if the the base level entry is overridden we ignore it, if not we also add it to the result list
				if (overridden) {
					logger.fine("   Extended level " + extendedNode.getName() + " with id " + extendedNode.getText().trim() + " REPLACES the one at base level with id " + baseNode.getText().trim());
				} else{
					logger.fine("   Extended level " + extendedNode.getName() + " with id " + extendedNode.getText().trim() + " COMPLEMENTS the one at base level with id " + baseNode.getText().trim());
					res.add(baseNode.clone());
				}
				
			//No match was found this means it is not re-defined at the extended level, thus we should keep it
			}else{
				logger.fine("   Base level " + baseNode.getName() + " with id " + baseNode.getText().trim() + " is not redefined at extended level, keeping it");
				res.add(baseNode);
			}
		}
		
		//Add any remaining items that are only defined on the extended level
		extendedIt = extendedConfig.iterator();
		while(extendedIt.hasNext()){
			extendedNode = (Node)extendedIt.next();
			logger.fine("   " + extendedNode.getName() + " with id " + extendedNode.getText().trim() + " is only defined at the extended level, keeping it");
			res.add(extendedNode.clone());
		}
		
	/*	System.out.println("** The merged configs are: ");
		for(Object n : res){
			System.out.println(((Node)n).getName() + " - " + ((Node)n).getText().trim());
		} */
		
		
		return res;
	}
//	-------------------------------------------------------------------------------------	
	public static Node getTagByName(List runConfig, String name) {
		Iterator it = runConfig.iterator();
		Node n;
		while(it.hasNext()){
			n = (Node)it.next();
			if(n.getName().equals(name)){
				return n;
			}
		}
		return null;
	}
//	-------------------------------------------------------------------------------------
	public static List<NodeConfig> getTagByNameAsList(List runConfig, String name, boolean recurse) {

		Node n;
		Iterator<Node> it = runConfig.iterator();
		List<NodeConfig> res = new LinkedList<NodeConfig>();
		List<Node> tmp = null;
		
		while(it.hasNext()){
			n = it.next();
			
			//should we recursively look at our decendants
			if(recurse){
				tmp = n.selectNodes("descendant-or-self::" + name);
				
			//only look at ourselves
			}else{
				if(n.getName().equals(name)){
					tmp = new LinkedList<Node>();
					tmp.add(n);
				}else{
					tmp = null;
				}
			}
			
			if(tmp == null || tmp.size() < 1){
				//no match
			}else{
				res.addAll(NodeConfig.convertToNodeConfig(tmp));
			}
		}
		
		return res;
	}
//	-------------------------------------------------------------------------------------	
	public static String getTagTextByName( List runConfig, String type ){
		
		Node n = getTagByName(runConfig,type);
		if(n == null){
			return null;
		}else{
			return n.getText();
		}
	}
//	-------------------------------------------------------------------------------------
	public static List<String> getTagTextByNameAsList(List runConfig, String name, boolean recurse) {

		List<NodeConfig> res = getTagByNameAsList(runConfig, name, recurse);
		
		if(res == null){
			return null;
		}
		
		List<String> ids = new LinkedList<String>();
		
		for(NodeConfig n : res){
			ids.add(n.getText());
		}
		
		return ids;
	}
//	-------------------------------------------------------------------------------------	
	public static Node toNode(Object o){
		return (Node)o;
	}
//	-------------------------------------------------------------------------------------	
	public static Node[] resolveReference(Document doc, String name, String[] id){
		
		// must be valid & matching name & id arrays
		if ( name == null || id == null )
			return null;
		
		// create node array
		Node[] nodes = new Node[id.length];
		for (int i = 1; i < id.length; ++i)
			nodes[i] = doc.selectSingleNode("//" + name + "[@id='" + id[i].trim() + "']");
		
		// return full node array
		return nodes;
	}
//	-------------------------------------------------------------------------------------	
	public static Node resolveReference(Document doc, String name, String id){
		
		// must be valid & matching name & id arrays
		if ( name == null || id == null )
			return null;
		
		// return full node array
		return doc.selectSingleNode("//" + name + "[@id='" + id.trim() + "']");
	}
//	-------------------------------------------------------------------------------------	
	public static String getToolboxVersion(Document doc){
		NodeConfig n = NodeConfig.newInstance(doc.selectSingleNode("/ToolboxConfiguration"));
		return n.getAttrValue("version","");
	}
//	-------------------------------------------------------------------------------------
	@SuppressWarnings("unchecked")
	/**
	 * A run can have a repeat attribute, this function
	 * creates 'repeat' number copies of each run and returns the flattened document
	 */
	public static Document flattenRuns(Document doc){
		Document flatdoc = (Document)doc.clone();

		List<NodeConfig> detachedRuns = new LinkedList<NodeConfig>();
		
		//remove all the run tags
		List<Node> runs = flatdoc.selectNodes("//Plan/child::*[name()='Run']");
		for(Node n : runs){
			detachedRuns.add(NodeConfig.newInstance(n.detach()));
		}
		
		Element plan = (Element)flatdoc.selectSingleNode("//Plan");
		
		Element tmp = null;
		String name = null;
		
		int repeats = 1;
		int ctr = 1;
		for(NodeConfig n : detachedRuns){
			repeats = n.getIntAttrValue("repeat", "1");
			name = n.getAttrValue("name","#simulator#_#adaptivemodelbuilder#"); // set a nice default template if empty
			name = name + "_rep";
	
			for(int i=1;i <= repeats; ++i){
				//if there is only one repeat there is no need to change the name
				if(repeats > 1){
					if(i < 10){
						n.setAttributeValue("name", name + "0" + i);
					}else{
						n.setAttributeValue("name", name + i);
					}
				}
				tmp = (Element)n.getNode().clone();
				tmp.addAttribute("repeat", "1");
				plan.add(tmp); 
			}
			ctr = ctr + 1;
		}
		
		return flatdoc;
	}
//	-------------------------------------------------------------------------------------	
	public static int getNumberOfRuns(Document doc){
		return doc.selectNodes("//Plan/child::*[name()='Run']").size();
	}
//	-------------------------------------------------------------------------------------	
	@SuppressWarnings("unchecked")
	private static List getListItems(Element e, Document customConfig) {
		String path = e.getPath();
		List<? extends Node>  l = customConfig.getRootElement().selectNodes(path);
		if (l.size() == 1)
			return l;
		for (int i = 0; i < l.size(); i++) {
			Node node = l.get(i);
			if (node.selectSingleNode("@id") != null) {
				l.clear();
				return l;
			}
		}
		return l;
	}
//	-------------------------------------------------------------------------------------		
	/**
	 * Takes 2 XML configuration files a default config and a user supplied one.
	 * This function replaces the plan in the default config with the plan supplied in the
	 * user config.  Additional non-plan entries in the user config are simply added.
	 * The merged configuration is returned.
	 * <p>
	 * TODO: this can be improved
	 * @param def Filename of the default configuration
	 * @param user Filename of the user specified configuration
	 * @return a merged configuration as DOM4J XML document
	 * @throws Exception
	 */
	public static org.dom4j.Document mergeConfigs(String def, String user) throws Exception {
		Document userConfig = readXML(user);
		Document defaultConfig = readXML(def);
        return mergeConfigs(defaultConfig,userConfig);
	}
//	-------------------------------------------------------------------------------------	    
	public static Document mergeConfigs(Document defaultConfig, Document userConfig) throws Exception{

		logger.info("Merging user config with default config");
		
		Element ccfg = (Element)defaultConfig.getRootElement().selectSingleNode("/ToolboxConfiguration/ContextConfig");

		// merge the profilers (bit of a haxx)
		/*Element profilersDef = (Element)defaultConfig.getRootElement().selectSingleNode("/ToolboxConfiguration/ContextConfig/Profiling");
		Element profilersUsr = (Element)userConfig.getRootElement().selectSingleNode("/ToolboxConfiguration/ContextConfig/Profiling");
		if (ccfg != null && profilersUsr != null) { 
			if (profilersDef != null) {
				profilersDef.detach();
			}
			ccfg.add(profilersUsr.detach());
		}*/
		
		// now we fix the config version first, so that we don't have to update
		// the test suite each time the toolbox version changes
		Element toolboxDef = (Element)defaultConfig.getRootElement().selectSingleNode("/ToolboxConfiguration");
		Element toolboxUsr = (Element)userConfig.getRootElement().selectSingleNode("/ToolboxConfiguration");
		toolboxUsr.addAttribute("version", toolboxDef.attributeValue("version"));
		
		// Do the rest of the merging
		treeWalkMerge(userConfig.getRootElement(), userConfig, defaultConfig, "");

		// for debugging: write to file
		//if (fVerbose) writeXML(defaultConfig, "D:\\Work\\M3\\M3-Toolbox\\trunk\\Merged.xml");
		
		return defaultConfig;
	}
//	-------------------------------------------------------------------------------------	
	@SuppressWarnings("unchecked")
    private static void treeWalkMerge(Element element, Document customConfig, Document defaultConfig, String currPath) {
		
		String oldPath = currPath;
		currPath += "/" + element.getName();
		
		if (fVerbose) logger.info("* " + currPath);
		
		//List<? extends Node>  l = getListItems(element, customConfig);
		
		// special case: Option
		if (element.getName().compareTo("Option") == 0) {
			if (fVerbose) logger.info("** option");
			String v = element.selectSingleNode("@key").getText();
			String atrPath = currPath + "[@key='" + v + "']'";
			Node n = defaultConfig.selectSingleNode(atrPath);
			if (n != null) { 
				Node n2 = n.selectSingleNode("@value");
				n2.setText(element.selectSingleNode("@value").getText());
				if (fVerbose) logger.finest("Changed default option " + atrPath + " to " + n2.getText());
			} else { 
				Element n2 = (Element)defaultConfig.selectSingleNode(oldPath);
				n2.add(element.detach());
				if (fVerbose) logger.finest("Added a new option to the default config: " + oldPath);
			}
		}
			
		// other special case: List Item - temp deleted, didn't work well
		/*else if (l.size() > 1) {
			if (fVerbose) logger.info("* found list item: " + element.getPath());
			Element n = (Element)defaultConfig.selectSingleNode(oldPath);
			for (Node node : l) {
				Element e = (Element)node;
				if (n != null) { 
					n.add(e.detach());
				}
			}
	 	}*/
		else {
			
	    	// ATTRIBUTES
	    	for (Iterator i = element.attributeIterator(); i.hasNext(); ) {
	    		if (fVerbose) logger.info("** attribute");
	            Attribute attribute = (Attribute)i.next();
	            /*String atrPath = currPath + "/@" + attribute.getName();            
	            Attribute n = (Attribute)defaultConfig.selectSingleNode(atrPath);            
	            if (attribute.getName().compareTo("id") != 0) {
	            	if (n != null) {
	            		n.setValue(attribute.getValue());
	            	} else {
	    				Element n2 = (Element)defaultConfig.selectSingleNode(oldPath);
	    				n2.add(element.detach());
	            	}
	            }*/
	            currPath += "[@" + attribute.getName() + "='" + attribute.getValue() + "']";
	        }
	    	
	    	// ELEMENTS
			/*if (element.getText().trim().compareTo("") != 0) {
				if (fVerbose) logger.info("** element contains text");
	            Node n = defaultConfig.selectSingleNode(currPath);
	            // this element exists in the default config, just overwrite
	            if (n != null) {
	            	if (fVerbose) logger.info("*** overwrite text in default");
	            	n.setText(element.getText());
	            }
	            // this element does not exist in default config, add
	            else {
	            	if (fVerbose) logger.info("*** element does not exist, add element + text");
	            	Element blah = (Element)defaultConfig.getRootElement().selectSingleNode(oldPath);
	            	blah.addElement(element.getName()).addText(element.getText());
	            }
			}*/
		}
		
   		// CHILD NODES
		
		// not found in default, copy
		if (defaultConfig.getRootElement().selectSingleNode(currPath) == null) { 
			// found an element in custom that is not in default, copy this entire node
			if (fVerbose) logger.info("* Current element not found in default, copying");
			Element n = (Element)defaultConfig.getRootElement().selectSingleNode(oldPath);
			n.add(((Element)element.clone()).detach());
		}
		
		// plan or logging tag, overwrite the default
		else if (currPath.endsWith("/Plan") || currPath.endsWith("/Logging")) {
			if (fVerbose) logger.info("* Current element Logging/Plan found in default, overwriting");
			
			// remove the original element from default
			defaultConfig.getRootElement().selectSingleNode(currPath).detach();
			
			// copy the element from custom to default
			Element n = (Element)defaultConfig.getRootElement().selectSingleNode(oldPath);
			n.add(((Element)element.clone()).detach());
		}
		
		// exists, recursively copy
		else {
			if (fVerbose) logger.info("* Current element (" + currPath + ") exists in default, explore children");
			
			// current element exists in default, further treewalking is required
			List<? extends Node> nodes = element.content();
			
			boolean eraseDefaultText = true;
			try {
				for (Node node : nodes) {
					
					// this is a (non-empty) text node, just add the text to the default config
					if (node.getPath().endsWith("text()")) {
						if (!node.getText().trim().equals("")) {
							if (fVerbose) logger.info("** child " + node.getPath() + " is a text node, add to default");
							
							// add the node to the node in default config
							Element defNode = (Element)defaultConfig.selectSingleNode(currPath);
							
							// if this node contains at least some text (not only whitespace), we overwrite the text in default
							if (eraseDefaultText) {
								eraseDefaultText = false;
								defNode.setText("");
							}
							
							// add the node
							defNode.add(((Node)node.clone()).detach());
						}
					}
					
					// this is a normal node, explore it
					else if (!node.getPath().endsWith("comment()")) {
						if (fVerbose) logger.info("** child " + node.getPath() + " is a normal node, explore");
						treeWalkMerge((Element)node, customConfig, defaultConfig, currPath);
					}
				}
				
			}
			catch (java.util.NoSuchElementException ex) {
			}
		}
	}
//	-------------------------------------------------------------------------------------
	public static String asXML(Collection<Node> col){
		String s = "";
		for(Node n : col){
			s += n.asXML() + "\n";
		}
		
		return s;
	}

//	-------------------------------------------------------------------------------------
	public static String[] dd2s( OutputDescription[] x ) {
		String[] ret = new String[x.length];
		
		for ( int i=0;i<x.length;i++ )
			ret[i] = x[i].getName();
		
		return ret;
	}
	
	public static String[] dd2s( InputDescription[] x ) {
		String[] ret = new String[x.length];
		
		for ( int i=0;i<x.length;i++ )
			ret[i] = x[i].getName();
		
		return ret;
	}
}
