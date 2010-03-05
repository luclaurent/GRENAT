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
** Revision: $Id: TestCase.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

/**
 * This object defines a test case for the unit testing framework.
 */
public class TestCase {
	
	// config file used for the test case
	private String fConfig;
	
	// allowed accuracy range
	private double fMinAccuracy, fMaxAccuracy;
	private boolean fCheckAccuracy = false;
	
	// allowed # samples at end of run
	private int fMinSamples, fMaxSamples;
	private boolean fCheckSamples = false;
	
	// should this test case be merged or not
	private boolean fMergeable = true;
	
	// constructor, only config is required
	public TestCase(String config, boolean merge) {
		fConfig = config;
		fMergeable = merge;
	}
	
	public boolean isMergeable(){
		return fMergeable;
	}
	
	// set the different checks
	public void enableAccuracyCheck(double min, double max) {
		fCheckAccuracy = true;
		fMinAccuracy = min;
		fMaxAccuracy = max;
	}
	public boolean checkAccuracy() { return fCheckAccuracy; }
	
	public boolean checkExpression() { return true; }

	public boolean checkMembers() { return true; }
	
	public void enableSamplesCheck(int min, int max) {
		fCheckSamples = true;
		fMinSamples = min;
		fMaxSamples = max;
	}
	public boolean checkSamples() { return fCheckSamples; }
	
	// getters
	public String getConfig() {
		return fConfig;
	}
	public double getMaxAccuracy() {
		return fMaxAccuracy;
	}
	public int getMaxSamples() {
		return fMaxSamples;
	}
	public double getMinAccuracy() {
		return fMinAccuracy;
	}
	public int getMinSamples() {
		return fMinSamples;
	}	
}
