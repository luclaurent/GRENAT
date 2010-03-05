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
** Revision: $Id: DiophantineSolver.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.Logger;

public class DiophantineSolver {

	static final Logger logger = Logger.getLogger("DiophantineSolver");

	/*
	 * This function returns an in array containing the solutions to the problem	 * 
	 *     k1 <= Score(x) < k2	 * 
	 * where x is an array of length ws.length and	 * 
	 *     Score(x) = ws[0] * x[0] + ... + ws[ws.length] * x[ws.length];
	 * Solutions are returned as one large integer array, where blocks of
	 * ws.length + 1 consecutive elements define one solution.
	 * 
	 * The first element of each solution is its score, the remaining ws.length
	 * elements are the actual components x[0] ... of the solution.
	 * 
	 */
	static private int[] solver(int[] ws, int k1, int k2, int chunkSize) {
		logger.fine( "SOLVER called with : " + ws.toString() + "; " + k1 + "; " + k2 + "; " + chunkSize );
		
		int d = ws.length;
		int lbound;
		double ubound;
		int i, j;
		int[] counter = new int[d];
		int runningSum = 0;
		int index = d-1;

		List<int[]> chunks = new LinkedList<int[]>();
		int[] found = new int[chunkSize];
		int count = 0;

		while (index >= 0) {
			if (index == d-1) {
				// last dimension
				ubound = ((double) (k2 - runningSum) / (double) ws[d - 1]);
				lbound = Math.max(0, (int) Math.ceil((double) (k1 - runningSum) / (double) ws[d - 1]));
				assert (ubound >= 0.0);

				for (j = lbound; j < ubound; j++) {
					found[count++] = runningSum + ws[d - 1] * j;
					assert( found[count-1] >= k1 && found[count-1] < k2 );

					for (i = 0; i < d - 1; i++)
						found[count++] = counter[i];
					found[count++] = j;
					
					if (count == chunkSize) {
						chunks.add(found);
						found = new int[chunkSize];
						count = 0;
					}
				}
				index--;
				counter[index]++;
				runningSum += ws[index];
			} else {
				if (runningSum >= k2) {
					// Restore sum
					runningSum -= ws[index] * counter[index];
					counter[index] = 0;
					index--;
					if ( index >= 0 ) {
						counter[index]++;
						runningSum += ws[index];
					}
				}
				else
					index++;				
			}
		}

		// Add last chunk
		chunks.add(found);

		logger.fine( "SOLVER run completed" );
		
		// Glue together allocated chunks...
		return glueIntArrays(chunks, count);
	}

	/*
	 * This method glues integer arrays together, resulting in one large integer array.
	 * The size of the last `chunk' can be specified with the lastSize parameter (in
	 * case only part of the chunk has to be used), or left at -1 to denote that the whole
	 * chunk has to be included.
	 */
	static private int[] glueIntArrays(List<int[]> chunks, int lastSize) {
		// Check for no chunks
		if (chunks.size() == 0) {
			return new int[0];
		}
		// Check for only one chunk
		if (chunks.size() == 1) {
			if (lastSize < 0)
				return chunks.get(0);
			int[] result = new int[lastSize];
			System.arraycopy(chunks.get(0), 0, result, 0, lastSize);
			return result;
		}

		// Calculate total size
		int totalSize = 0;
		int lastLength = 0;
		for (int[] x : chunks) {
			totalSize += x.length;
			lastLength = x.length;
		}

		// Do we have to truncate the last chunk
		if (lastSize >= 0) {
			totalSize = totalSize - lastLength + lastSize;
			lastLength = lastSize;
		}

		int[] glued = new int[totalSize];
		int startPoint = 0;
		Iterator<int[]> it = chunks.iterator();

		// Iterate and glue :)
		while (it.hasNext()) {
			int[] chunk = it.next();
			System.arraycopy(chunk, 0, glued, startPoint, it.hasNext() ? chunk.length : lastLength);
			startPoint += chunk.length;
		}

		return glued;
	}

	/*
	 * The actual interface function, keeps increasing k until a sufficient number of solutions is found
	 */
	static public int[] request(int[] ws, int n) {
		int d = ws.length;

		if ( d == 1 ) {
				int[] result = new int[2*n];
				for ( int i=0;i<n;i++ ) {
					result[2*i] = ws[0]*i;
					result[2*i+1] = i;
				}
				return result;					
		}
		
		List<int[]> blobs = new LinkedList<int[]>();
		// Estimate the necessary `k' value
		int totalSize = 0;
		int lastK = 0;
		int runningN = n;
		int chunkSize = (d + 1) * Math.max(100, (int) (n / 4.0));
//		logger.info("Chunk size : " + chunkSize);

		while (totalSize < n) {
//			logger.info("Running N " + runningN);
			int k = kEstimate(ws, runningN);
//			logger.info("k estimate : " + k);
			int[] solutions = solver(ws, lastK, k, chunkSize);

			blobs.add(solutions);
			totalSize += solutions.length / (d + 1);
//			logger.info("totalsize : " + totalSize);
			lastK = k;
			runningN = (int) (runningN * 1.3) + 1;
		}

		return glueIntArrays(blobs, -1);
	}

	/*
	 * Returns an estimate for k which should accommodate at least `n' solutions
	 * to the solver() problem with ws[]
	 * The estimate is based on the Volume of a simplex with corners at the origin and the axial
	 * points ( 0 ... k/w_j ... 0 ). 
	 */
	private static int kEstimate(int[] ws, int n) {
		int d = ws.length;
		double product = 1.0;
		for (int item : ws)
			product *= item;

		return (int) (Math.pow(factorial(d) * n * product, 1.0 / d));
	}

	static private double factorial(int d) {
		double x = 1.0;
		for (int i = 2; i <= d; i++)
			x *= (double) i;
		return x;
	}

	/*
	public static void main(String args[]) {
		int[] ws = new int[3];

		ws[0] = 9;
		ws[1] = 2;
		ws[2] = 1;

		int[] solutions = request(ws, 100000);

		System.out.println(solutions[0]);

		for (int i = 0; i < solutions.length / 9; i++) {
			System.out.println(i + " --> " + solutions[9 * i] + "," + solutions[9 * i + 1] + ","  
					+ solutions[9 * i + 2] + "," + solutions[9 * i + 3] + "," + solutions[9 * i + 4] + " : "
					+ solutions[9 * i + 8]);
		}
	}
	*/

}
