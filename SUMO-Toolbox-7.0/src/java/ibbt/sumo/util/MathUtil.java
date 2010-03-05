package ibbt.sumo.util;
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
** Revision: $Id: MathUtil.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

public class MathUtil {
	
	/**
	 * Scale the value 'value' from the interval [a b] to [c d]
	 */
	public static double scale(double a, double b, double c, double d, double value){
		return c*( (value - b)/(a - b) ) + d*( (value - a)/(b - a) ) ;
	}

	/**
	 * Implement the gamma function
	 * @param x
	 * @return
	 */
	public static double gamma( double x ) {
	    int k, n;
	    double w, y;

	    n = x < 1.5 ? -((int) (2.5 - x)) : (int) (x - 1.5);
	    w = x - (n + 2);
	    y = ((((((((((((-1.99542863674e-7 * w + 1.337767384067e-6) * w - 
	        2.591225267689e-6) * w - 1.7545539395205e-5) * w + 
	        1.45596568617526e-4) * w - 3.60837876648255e-4) * w - 
	        8.04329819255744e-4) * w + 0.008023273027855346) * w - 
	        0.017645244547851414) * w - 0.024552490005641278) * w + 
	        0.19109110138763841) * w - 0.233093736421782878) * w - 
	        0.422784335098466784) * w + 0.99999999999999999;
	    if (n > 0) {
	        w = x - 1;
	        for (k = 2; k <= n; k++) {
	            w *= x - k;
	        }
	    } else {
	        w = 1;
	        for (k = 0; k > n; k--) {
	            y *= x - k;
	        }
	    }
	    return w / y;
	}
}
