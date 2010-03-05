package ibbt.sumo.examples;
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
** Revision: $Id: TestFunction2.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.sampleevaluators.SampleEvaluatorException;
import ibbt.sumo.sampleevaluators.SamplePoint;
import ibbt.sumo.util.MathUtil;

/**
 * Example function taken from Matlab (ps_example.m)
 * For a plot see: http://www.mathworks.com/access/helpdesk/help/toolbox/gads/f6436.html#f12782
 */
public class TestFunction2  extends AbstractSimulator {
	
	public TestFunction2() {
		super();
	}

	public void simulate(SamplePoint point) throws SampleEvaluatorException {
		double x = point.getInputParameter(0);
		double y = point.getInputParameter(1);

		//scale from [-1 1] to [-4 4] and [-6 2]
		x = MathUtil.scale(-1,1,-6,2,x);
		y = MathUtil.scale(-1,1,-4,4,y);

		double res = 0;
	    if(x < -5){
	        res = Math.pow(x+5, 2) + Math.abs(y);
	    }else if(x < -3){
	        res = -2*Math.sin(x) + Math.abs(y);
	    }else if(x < 0){
	        res = 0.5*x + 2 + Math.abs(y);
	    }else if(x >= 0){
	        res = .3*Math.sqrt(x) + 5/2 + Math.abs(y);
	    }else{
	    }

	    double[] results = point.getOutputParameters();
		results[0] = res;
	}
}
