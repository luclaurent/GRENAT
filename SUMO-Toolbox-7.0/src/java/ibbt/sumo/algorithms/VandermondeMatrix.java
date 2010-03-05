package ibbt.sumo.algorithms;
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
** Revision: $Id: VandermondeMatrix.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import java.util.Arrays;

public class VandermondeMatrix {

	/*
	 * 
	 * 
	 * d = input space dimension point = N x d input locations degrees = M x d
	 * degrees
	 * 
	 * result = N x M Vandermonde matrix
	 */
	static public double[] buildPower( int d, double[] points, double[] degrees) {
		int N = points.length / d;
		int M = degrees.length / d;
		int i, j, k, l;
		int maxDegree;
		
		double point;		
		double[] result = new double[N*M];
		Arrays.fill(result,1.0);

		for (k=0;k<d;k++ ) {
			maxDegree = 0;
			for (j=0;j<M;j++ )
				if ( degrees[k*M+j] > maxDegree )
					maxDegree = (int) degrees[k*M+j];
			double[] bfValues = new double[N*(maxDegree+1)];
			int index = 0;
			
			for (i=0;i<N;i++ ) {
				point = points[k*N+i];
				bfValues[index++] = 1.0;
				for (l=0;l<maxDegree;l++ ) {
					bfValues[index] = bfValues[index-1] * point;
					index++;
				}
			}
			
			for (j=0;j<M;j++ ) {
				index = (int) degrees[k*M+j];
				for (i=0;i<N;i++,index+=maxDegree+1) {
					result[j*N+i] *= bfValues[index];
				}
			}
		}
		
		return result;
	}

	static public double[] buildChebyshev( int d, double[] points, double[] degrees) {
		int N = points.length / d;
		int M = degrees.length / d;
		int i, j, k, l;
		int maxDegree;
		
		double point;		
		double[] result = new double[N*M];
		Arrays.fill(result,1.0);

		for (k=0;k<d;k++ ) {
			maxDegree = 0;
			for (j=0;j<M;j++ )
				if ( degrees[k*M+j] > maxDegree )
					maxDegree = (int) degrees[k*M+j];
			
			if ( maxDegree == 0 )
				continue;
			
			double[] bfValues = new double[N*(maxDegree+1)];
			int index = 0;
			
			for (i=0;i<N;i++ ) {
				point = points[k*N+i];
				bfValues[index++] = 1.0;
				bfValues[index++] = 2.0 * point;
				for (l=2;l<=maxDegree;l++ ) {
					bfValues[index] = 2.0 * point * bfValues[index-1] - bfValues[index-2];
					index++;
				}
			}
			
			for (j=0;j<M;j++ ) {
				index = (int) degrees[k*M+j];
				for (i=0;i<N;i++,index+=maxDegree+1) {
					result[j*N+i] *= bfValues[index];
				}
			}
		}

		return result;
	}
}
