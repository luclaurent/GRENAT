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
** Revision: $Id: NodeConfig.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import java.io.IOException;
import java.io.Serializable;
import java.io.Writer;
import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.InvalidXPathException;
import org.dom4j.Node;
import org.dom4j.Visitor;
import org.dom4j.XPath;

public class NodeConfig implements Serializable {
	private static final long serialVersionUID = -7846520737175992375L;

	private static String[] fTrueStrings = { "yes", "true", "enable", "on", "1" };
	private static String[] fFalseStrings = { "no", "false", "disable", "off", "0", "donotwant" };
	
	private Node n = null;
	private static Logger logger = Logger.getLogger("ibbt.sumo.config.NodeConfig");
	
	private NodeConfig(Node node) {
		n = node;
	}
	
	/**
	 * Wrap a dom4j node
	 * @param n
	 * @return
	 */
	public static NodeConfig newInstance(Node n){
		if(n == null){
			return null;
		}else{
			return new NodeConfig(n);
		}
	}

	/**
	 * Convert a collection of Node objects into NodeConfig objects
	 * @param col
	 * @return
	 */
	public static List<NodeConfig> convertToNodeConfig(Collection<Node> col){
		if(col == null) return null;
		
		Iterator<Node> it = col.iterator();
		LinkedList<NodeConfig> l = new LinkedList<NodeConfig>();
		
		while(it.hasNext()){
			l.add(NodeConfig.newInstance(it.next()));
		}
		
		return l;
	}

	/**
	 * Convert a collection of NodeConfig objects into plain Nodes
	 * @param col
	 * @return
	 */
	public static List<Node> convertToNode(Collection<NodeConfig> col){
		Iterator<NodeConfig> it = col.iterator();
		LinkedList<Node> l = new LinkedList<Node>();
		
		while(it.hasNext()){
			l.add(it.next().getNode());
		}
		
		return l;
	}

	/**
	 * Creates a NodeConfig object based on an XML String
	 * @param text XML string
	 * @return
	 */
	public static NodeConfig newInstanceFromText(String text){
        try {
			Document document = DocumentHelper.parseText(text);
			return NodeConfig.newInstance(document.getRootElement());
		} catch (DocumentException e) {
			logger.log(Level.SEVERE,e.getMessage(),e);
			return null;
		}
	}
	
	//Convenience methods
	
	/**
	 * Return the text of the node identified by the given xpath expression
	 * The text of a node is the value xxx in <tag>xxx</tag>.
	 * Returns null if the node was not found.
	 */
	public String getNodeText(String xpath){
		Node k = n.selectSingleNode(xpath);
		if(k == null){
			return null;
		}else{
			return k.getText().trim();
		}
	}
	
	/**
	 * Return the text of the current node, if empty return the default value 
	 */
	public String getText(String defaultValue){
		String s = n.getText().trim();
		if(s.length() < 1){
			return defaultValue;
		}else{
			return s;
		}
	}

	/**
	 * Same as above, except returns a default value if no match is found.
	 * @param xpath
	 * @param defaultValue
	 * @return
	 */
	public String getNodeText(String xpath, String defaultValue){
		String s = getNodeText(xpath);
		if(s == null){
			return defaultValue;
		}else{
			return s.trim();
		}
	}
	
	/**
	 * Return the value of the attribute specified by 'key' within the current node
	 * If the attribute does not exist or is empty return the default value.
	 */
	public String getAttrValue(String key, String defaultValue){
		String res = n.valueOf("@" + key);
		if(res == null || res.trim().length() < 1){
			return defaultValue;
		}else{
			return res;
		}
	}
	
	/**
	 * Return the value of the attribute specified by 'key' within the current node
	 * If the attribute does not exist or is empty return null.
	 */
	public String getAttrValue(String key){
		String res = n.valueOf("@" + key);
		if(res == null || res.trim().length() < 1){
			return null;
		}else{
			return res;
		}
	}
	
	/**
	 * Set value of the attribute specified by 'key' to 'value'
	 * If the attribute does not exist, it is created.
	 * @param key
	 * @param value
	 */
	public void setAttributeValue(String key, String value){
		n = ((Element)n).addAttribute(key, value);
	}
	
	public double getDoubleAttrValue(String key, String defaultValue){
		String s = getAttrValue(key, defaultValue);
		return new Double(s).doubleValue();
	}
	
	public int getIntAttrValue(String key, String defaultValue) {
		String s = getAttrValue(key, defaultValue);
		return new Integer(s).intValue();
	}
	
	public boolean getBooleanAttrValue(String key, String defaultValue) {
		String s = getAttrValue(key, defaultValue);
		
		for ( String yes : fTrueStrings )
			if ( s.toLowerCase().equals(yes) )
				return true;
		for ( String no : fFalseStrings )
			if ( s.toLowerCase().equals(no) )
				return false;
		logger.warning("Boolean attribute with key " + key + " invalid value, returning false" );
		return false;
	}
	
	/**
	 * Return the value of the attribute called 'name' within the node 'node'
	 * @param node tag which contains the attribute defined by 'name'
	 * @param name the attribute name
	 * @return the value of the attribute 'name' within the tag 'node'
	 */
	public String getAttributeValue(String node, String name){
		Node nd = n.selectSingleNode(node);
		return nd.valueOf("@" + name);
	}
	
	public int getIntAttributeValue(String node, String name){
		Node nd = n.selectSingleNode(node);
		return new Integer(nd.valueOf("@" + name)).intValue();
	}
	
	public boolean getBooleanAttributeValue(String node, String name){
		Node nd = n.selectSingleNode(node);
		String s = nd.valueOf("@" + name);

		for ( String yes : fTrueStrings )
			if ( s.toLowerCase().equals(yes) )
				return true;
		for ( String no : fFalseStrings )
			if ( s.toLowerCase().equals(no) )
				return false;
		logger.warning("Boolean attribute with name " + name + " invalid value, returning false" );
		return false;
	}
	
	public int getBooleanAsIntAttributeValue(String node, String name){
		if(getBooleanAttributeValue(node,name)){
			return 1;
		}else{
			return 0;
		}
	}
	
	/**
	 * Returns the value of the 'value' attribute of the option
	 * node defined by 'key'.  The option node is relative to the current node.
	 * @param key
	 * @return
	 */
	public String getOption(String key){
		Node option = n.selectSingleNode("Option[@key='" + key + "']");
		if(option == null){
			return null;
		}else{
			return option.valueOf("@value");
		}
	}
	
	/**
	 * Same as above, except takes a default value.
	 * @param key
	 * @param defaultValue
	 * @return
	 */
	public String getOption(String key, String defaultValue){
		String s = getOption(key);
		if(s == null){
			return defaultValue;
		}else{
			return s;
		}
	}
	
	public boolean getBooleanOption(String key){
		String s = getOption(key);
		for ( String yes : fTrueStrings )
			if ( s.toLowerCase().equals(yes) )
				return true;
		for ( String no : fFalseStrings )
			if ( s.toLowerCase().equals(no) )
				return false;
		logger.warning("Boolean option (" + s + ") for key " + key + " invalid value, returning false" );
		return false;
	}
	
	public boolean getBooleanOption(String key, boolean defaultValue){
		String s = getOption(key);
		if(s == null)
			return defaultValue;
		else
			return getBooleanOption( key );
	}

	public int getBooleanAsIntOption(String key){
		String s = getOption(key);
		if(s != null && s.toLowerCase().equals("true")){
			return 1;
		}else{
			return 0;
		}
	}
	
	public int getBooleanAsIntOption(String key, int defaultValue){
		String s = getOption(key);
		if(s == null){
			return defaultValue;
		}else{
			if(s.toLowerCase().equals("true")){
				return 1;
			}else{
				return 0;
			}
		}
	}

	public double getDoubleOption(String key){
		String s = getOption(key);
		return new Double(s).doubleValue();
	}
	
	public double getDoubleOption(String key, double defaultValue){
		String s = getOption(key);
		if(s == null){
			return defaultValue;
		}else{
			return new Double(s).doubleValue();
		}
	}

	public int getIntOption(String key){
		String s = getOption(key);
		return new Integer(s).intValue();
	}
	
	public int getIntOption(String key, int defaultValue){
		String s = getOption(key);
		if(s == null){
			return defaultValue;
		}else{
			return new Integer(s).intValue();
		}
	}
	
	public long getLongOption(String key){
		String s = getOption(key);
		return new Long(s).longValue();
	}
	
	public long getLongOption(String key, long defaultValue){
		String s = getOption(key);
		if(s == null){
			return defaultValue;
		}else{
			return new Long(s).longValue();
		}
	}

	public Properties getAllOptionsAsProperties(){
		Properties p = new Properties();
		
		List options = n.selectNodes("Option");
		Iterator it = options.iterator();

		Node tmp = null;
		String key = "";
		String value = "";
		while(it.hasNext()){
			tmp = (Node)it.next();
			key = tmp.valueOf("@key");
			value = tmp.valueOf("@value");
			
			p.put(key,value);
		}
		
		return p;
	}
	
	public String toString(){
		return n.toString();
	}
	
	// ----- All other methods simply delegate to the nested Node -----
	
	public boolean supportsParent() {
		return n.supportsParent();
	}

	public Element getParent() {
		return n.getParent();
	}

	public void setParent(Element arg0) {
		n.setParent(arg0);

	}

	public Document getDocument() {
		return n.getDocument();
	}

	public void setDocument(Document arg0) {
		n.setDocument(arg0);

	}

	public boolean isReadOnly() {
		return n.isReadOnly();
	}

	public boolean hasContent() {
		return n.hasContent();
	}

	public String getName() {
		return n.getName();
	}

	public void setName(String arg0) {
		n.setName(arg0);
	}

	public String getText() {
		return n.getText();
	}

	public void setText(String arg0) {
		n.setText(arg0);
	}

	public String getStringValue() {
		return n.getStringValue();
	}

	public String getPath() {
		return n.getPath();
	}

	public String getPath(Element arg0) {
		return n.getPath(arg0);
	}

	public String getUniquePath() {
		return n.getUniquePath();
	}

	public String getUniquePath(Element arg0) {
		return n.getUniquePath(arg0);
	}

	public String asXML() {
		return n.asXML();
	}

	public void write(Writer arg0) throws IOException {
		n.write(arg0);

	}

	public Node getNode() {
		return n;
	}

	public Element getElement() {
		return (Element)n;
	}
	
	public short getNodeType() {
		return n.getNodeType();
	}

	public String getNodeTypeName() {
		return n.getNodeTypeName();
	}

	public Node detach() {
		return n.detach();
	}

	public List selectNodes(String arg0) {
		return n.selectNodes(arg0);
	}

	public Object selectObject(String arg0) {
		return n.selectObject(arg0);
	}

	public List selectNodes(String arg0, String arg1) {
		return n.selectNodes(arg0,arg1);
	}

	public List selectNodes(String arg0, String arg1, boolean arg2) {
		return n.selectNodes(arg0,arg1,arg2);
	}

	public Node selectSingleNode(String arg0) {
		return n.selectSingleNode(arg0);
	}

	public String valueOf(String arg0) {
		String res = "";
		try {
			res = n.valueOf(arg0);
		} catch (Exception e) { 
			e.printStackTrace();
		}
		return res;
	}

	public Number numberValueOf(String arg0) {
		return n.numberValueOf(arg0);
	}

	public boolean matches(String arg0) {
		return n.matches(arg0);
	}

	public XPath createXPath(String arg0) throws InvalidXPathException {
		return n.createXPath(arg0);

	}

	public Node asXPathResult(Element arg0) {
		return n.asXPathResult(arg0);

	}

	public void accept(Visitor arg0) {
		n.accept(arg0);
	}
	
	public Object clone(){
		return new NodeConfig((Node)n.clone());
	}
}
