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
** Revision: $Id: MandelbrotSimulator.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.sampleevaluators.SamplePoint;
import ibbt.sumo.util.Complex;

/**
 * Sample simulator for the Mandelbrot set.
 * Will return discrepancy values, depending on how easy it is to classify a given point as being in the Mandelbrot set.
 * Returns zero for values classified as being outside of the Mandelbrot set.
 * @author Karel Crombecq
 */
public class MandelbrotSimulator extends AbstractSimulator {
	
	private static int col = 20;

	public void simulate(SamplePoint point) {
		
		// calculate output
		Complex c = new Complex(point.getInputParameter(0), point.getInputParameter(1));
		Complex z = new Complex(0,0);
		double[] out = point.getOutputParameters();
		for (int k = 1; k < col; k++) {
			z = z.times(z);
			z = z.plus(c);
			out[0] = Math.exp(-1 * z.mod());
		}
		
		// convert NaN -> 0
		if (Double.isNaN(out[0])) out[0] = 0.0;
	}

}
