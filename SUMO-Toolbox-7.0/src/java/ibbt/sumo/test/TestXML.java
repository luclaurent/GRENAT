package ibbt.sumo.test;
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
** Revision: $Id: TestXML.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.SUMOException;
import ibbt.sumo.config.NodeConfig;

import java.io.File;
import java.util.LinkedList;
import java.util.List;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Node;
import org.dom4j.io.SAXReader;

/**
 * A helper class that reads a test suite xml file for the SUMO toolbox testing framework.
 * @author kcrombec
 */
@SuppressWarnings("unchecked")
public class TestXML {
	
	// test cases
	TestCase[] fTestCases;
	
	
	// read & parse a new xml file
	public TestXML(String fileName) throws SUMOException {
		
		// read the xml file
		SAXReader sr = new SAXReader();
		File file = new File(fileName);
		Document doc;
		try {
			doc = sr.read(file);
		} catch (DocumentException e) {
			throw new SUMOException(e.getMessage());
		}
		
		// temorary list of cases
		List<TestCase> cases = new LinkedList<TestCase>();
		
		// parse into different test cases
		List<Node> nodes = doc.selectNodes("//Suite/Case");
		for (Node node : nodes) {
			
			// for each node, read the config file location
			String config = node.valueOf("@config");
			if (config.length() == 0) throw new SUMOException("Invalid Test Case: 'config' attribute required");
			
			//should this test case be merged with base.xml?
			//usually set to true, but useful for testing stand alone configs (Demo, default) if set to false
			boolean merge = NodeConfig.newInstance(node).getBooleanAttrValue("merge", "true");
			
			// create the test case
			TestCase newCase = new TestCase(config,merge);
			
			// now look for checks
			List<Node> checks = node.selectNodes("Check");
			for (Node check : checks) {
				
				// get the type of check
				String type = check.valueOf("@type");
				if (type.length() == 0) throw new SUMOException("Invalid Test Case: each check needs a type attribute");
				
				// accuracy check
				if (type.equals("accuracy")) {
					newCase.enableAccuracyCheck(Double.parseDouble(check.valueOf("@min")), Double.parseDouble(check.valueOf("@max")));
				}
				
				// # samples check
				else if (type.equals("samples")) {
					newCase.enableSamplesCheck(Integer.parseInt(check.valueOf("@min")), Integer.parseInt(check.valueOf("@max")));
				}
				
				// invalid check
				else {
					throw new SUMOException("Invalid Test Case: " + type + " is not a valid check type");
				}
			}
			
			
			// add case to list of cases
			cases.add(newCase);
		}
		
		// convert list to flat array
		fTestCases = cases.toArray(new TestCase[0]);
	}
	
	
	// get the test cases
	public TestCase[] getTestCases() {
		return fTestCases;
	}
}
