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
** Revision: $Id: AckleySimulator.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.sampleevaluators.SampleEvaluatorException;
import ibbt.sumo.sampleevaluators.SamplePoint;
/**
 * Implements Ackley's Path function
 * @author dgorissen
 */
public class AckleySimulator  extends AbstractSimulator{

	public AckleySimulator() {
		super();
	}

	public void simulate(SamplePoint point) throws SampleEvaluatorException {
		double x = point.getInputParameter(0);
		double y = point.getInputParameter(1);
		
		//scale from [-1 1] to [-2 2]
		x = -2*x;
		y = -2*y;

		double a = 20;
		double b = 0.2;
		double c = 2*Math.PI;
		double n = 2;
				
		double sum = x*x + y*y;
		double sum2 = Math.cos(c*x) + Math.cos(c*y);
		
		double res = -a*Math.exp(-b*Math.sqrt(1/n*sum)) - Math.exp(1/n*sum2) + a + Math.exp(1);

		double[] results = point.getOutputParameters();
		results[0] = res;
	}
}
