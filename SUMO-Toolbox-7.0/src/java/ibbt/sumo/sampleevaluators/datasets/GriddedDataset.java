package ibbt.sumo.sampleevaluators.datasets;
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
** Revision: $Id$
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.sampleevaluators.SampleEvaluatorException;
import ibbt.sumo.sampleevaluators.SamplePoint;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Scanner;
import java.util.logging.Logger;

/**
 * A gridded dataset contains of a single column of data, the inputvalues can be 
 * obtained by the relative position of the row
 * @author COMS
 */
public class GriddedDataset implements Dataset {
	private static final long serialVersionUID = 1L;
	private static Logger logger = Logger.getLogger("ibbt.sumo.sampleevaluators.datasets.GriddedDataset");
		
	private double[] fData;
	private int[] fGridSize;
	private double[] fMinima, fMaxima;
	private double[] fSteps;
	private double fRadiusOverlap;
	private int fTotalPoints;
	private int fOutputCount;
	private LinkedList<Integer> fUsedDataPoints = new LinkedList<Integer>();

	/**
	 * constructor
	 * @param gridSize size and dimensions of the grid
	 * @param outputCount how much values are available in the file
	 */
	public GriddedDataset(int[] gridSize, double[] minima, double[] maxima, int outputCount ) {
		fGridSize = gridSize;
		fMinima = minima;
		fMaxima = maxima;
		fTotalPoints = 1;
		fOutputCount = outputCount;
		
		// calculate the total amount of points that should be in the file
		for (int i : gridSize )
			fTotalPoints *= i;
		fData = new double[fTotalPoints*fOutputCount];
		
		// now calculate the "steps" between each point in each dimension
		// also calculate the max/min step
		fSteps = new double[fGridSize.length];
		double max = Double.MIN_VALUE, min = Double.MAX_VALUE;
		for (int i = 0; i < fGridSize.length; ++i) {
			fSteps[i] = (fMaxima[i] - fMinima[i]) / (fGridSize[i]-1);
			if (fSteps[i] > max) max = fSteps[i];
			if (fSteps[i] < min) min = fSteps[i];
		}
		
		/* calculate the radius overlap
		   this occurs if step is in one dimension at least twice as large as in another.
		   In this case, taking only one hypercube around the center is not enough,
		   because we might then be skipping points that actually lie closer to the
		   center, but on a larger hypercube (because the step is 2 times smaller).
		   In this case, we consider a number of hypercubes at the same time.
		   */
		fRadiusOverlap = Math.floor(max / min);
		
		logger.info("Gridded dataset constructed, total expected points: " + fTotalPoints + " for " + fOutputCount + " outputs");
	}
	/**
	 * parse a file (scanner) for data
	 * @param scanner
	 * @throws SampleEvaluatorException
	 */
	public void loadText(InputStream stream) throws SampleEvaluatorException {
		Scanner scanner = new Scanner(new BufferedReader(new InputStreamReader(stream)));
		
		int i = 0;
		while (scanner.hasNext()) {
			
			if (i == fTotalPoints*fOutputCount) {
				throw new SampleEvaluatorException("Grid size mismatch: expecting " + fTotalPoints + " data points (per output), but more found in file");
			}
			
			fData[i] = Double.parseDouble(scanner.next());
			i++;
		}
		
		if (i != fTotalPoints*fOutputCount) {
			throw new SampleEvaluatorException("Grid size mismatch: read " + i + " data points, expecting " + fTotalPoints + " for each of the " + fOutputCount + " output(s) (nb: complex outputs count as 2!)");
		}
	}

	/**
	 * Convert x from [min, max] to [0,gridSize-1] (array index)
	 * @param x Value of the input in one dimension.
	 * @param gridSize Size of the grid in this dimension
	 * @return Converted x.
	 */
	private int convertToGridArray(double x, int dim) {
		return (int)Math.round((x - fMinima[dim]) / fSteps[dim]);
	}
	
	/**
	 * Convert x from [0,gridSize] back to [min, max] (modeling domain)
	 * @param x Value of the input as an array index.
	 * @param gridSize Size of the grid in this dimension
	 * @return Converted x.
	 */
	private double convertFromGridArray(int x, int dim) {
		return fMinima[dim] + (double)x * fSteps[dim];
	}
	
	
	/**
	 * evaluate a samplepoint with the parsed data
	 * @param sample
	 * @throws SampleEvaluatorException
	 */
	public void evaluate(SamplePoint sample) throws SampleEvaluatorException {
		
		// we have already returned all the sample points in the dataset, produce error
		if (fUsedDataPoints.size() == fTotalPoints)
			throw new SampleEvaluatorException("Dataset depleted, no more points available in the dataset");
		
		// convert to array indices in all dimensions
		double[] inputs = sample.getInputParameters();
		long[] arrayIndex = new long[inputs.length];
		for (int i = 0; i < inputs.length; i++) {
			arrayIndex[i] = convertToGridArray(inputs[i], i);
		}
		
		// keep going until we have found a sample point that was not yet returned
		long radius = 0;
		long[] closestPoint = null;
		while (closestPoint == null) {
			
			// recursively find closest point that hasn't been evaluated yet
			closestPoint = findClosestPoint(radius, arrayIndex);
			
			// update radius for next iteration
			++radius;
		}
		
		/* now if our radius is not zero (which means there was clipping)
		   AND the radius overlap is > 1, we make sure we're not skipping
		   any closer points on a "larger" hypercube.
		   */
		if (radius > 0 && fRadiusOverlap > 1) {
			for (int i = 1; i < fRadiusOverlap; ++i) {
				
				// look in larger radius hypercube for closer point
				long[] candidateClosestPoint = findClosestPoint(radius+i, arrayIndex);
				
				// compare distance
				if (getDistance(candidateClosestPoint, arrayIndex) < getDistance(closestPoint, arrayIndex)) {
					closestPoint = candidateClosestPoint;
				}
			}
		}
		
		// calculate index of closest unused point
		int index = getDataIndex(closestPoint);
		
		// set output parameters
		double[] outputs = new double[fOutputCount];
		for (int i = 0; i < outputs.length; i++) {
			outputs[i] = fData[index+i];
		}
		sample.setOutputParameters(outputs);
		
		// update input parameters to closest point
		for (int i = 0; i < inputs.length; ++i) {
			inputs[i] = convertFromGridArray((int)closestPoint[i], i);
		}
		
		// add to list of points used before
		fUsedDataPoints.add(index);
	}
	
	long[] findClosestPoint(long radius, long[] arrayIndex) {
		
		// radius is zero, just get the actual point (shortcut, more efficient)
		if (radius == 0) {
			int index = getDataIndex(arrayIndex);
			if (!fUsedDataPoints.contains(index))
				return arrayIndex;
			else
				return null;
		}
		
		// no closest point so far
		long[] closestSoFar = null;
		double closestDistanceSoFar = Double.MAX_VALUE;
		
		// take each dimension fixed and walk the plane of the hypercube in that dimension
		for (int fixedDim = 0; fixedDim < arrayIndex.length; ++fixedDim) {
			
			// two planes for each dimension to check, so we multiply by -1 one time to invert radius
			for (int whichSide = -1; whichSide <=  1; whichSide += 2) {
				
				// create copy of arrayIndex, but transformed to the center of the plane
				long[] planeCenter = (long[])arrayIndex.clone();
				planeCenter[fixedDim] += radius * whichSide;
				
				// find the closest point on the plane
				long[] closestPoint = findClosestPointInPlane(radius, planeCenter, arrayIndex, fixedDim, 0);
				
				// point found on this plane that wasn't returned yet
				if (closestPoint != null) {
					
					// compare best point so far with new candidate
					double newDistance = getDistance(closestPoint, arrayIndex);
					if (newDistance < closestDistanceSoFar) {
						closestSoFar = (long[])closestPoint.clone();
						closestDistanceSoFar = newDistance;
					}
				}
			}
		}
		
		// return closest unused point in this hypercube
		return closestSoFar;
	}
	
	
	// find closest point in given plane
	long[] findClosestPointInPlane(long radius, long[] point, long[] center, int fixedDim, int dim) {
		
		// we have done all dimensions, see if this point is valid
		if (dim >= point.length) {
			
			// see if this point is within bounds
			for (int i = 0; i < point.length; ++i) {
				if (point[i] < 0) return null;
				if (point[i] >= fGridSize[i]) return null;
			}
			
			// point not used before, so return it
			int index = getDataIndex(point);
			if (!fUsedDataPoints.contains(index)) return point;
			
			// used before
			else return null;
		}
		
		// when we have found the fixed dim, we skip
		if (dim == fixedDim) return findClosestPointInPlane(radius, point, center, fixedDim, dim+1);
		
		// we move to the corner in this dimension
		point[dim] -= radius;
		
		// no fixed dim, proceed with visiting all points
		long[] closestSoFar = null;
		double closestDistanceSoFar = Double.MAX_VALUE;
		for (int i = 0; i <= radius*2; ++i) {
			
			// find closest point in remaining dimensions
			long[] closestPoint = findClosestPointInPlane(radius, point, center, fixedDim, dim+1);
			
			// point is not used before & best match for next dim
			if (closestPoint != null) {
				
				// compare best point so far with new candidate
				double newDistance = getDistance(closestPoint, center);
				if (newDistance < closestDistanceSoFar) {
					closestSoFar = (long[])closestPoint.clone();
					closestDistanceSoFar = newDistance;
				}
			}
			
			// move on the next row in this dimension
			point[dim] += 1;
		}
		
		// we revert back to center before we return, so that in the next iteration we start over again from the center
		point[dim] -= (radius+1); // 1 added because point[dim] += 1 is done one time too many
		
		// return best match so far
		return closestSoFar;
	}

	
	// get distance^2 between two points on the grid
	double getDistance(long[] p1, long[] p2) {
		double sum = 0.0;
		for (int i = 0; i < p1.length; ++i) {
			sum += fSteps[i] * (double)(p1[i] - p2[i]) * fSteps[i] * (double)(p1[i] - p2[i]);
		}
		return sum;
	}
	
	
	
	// get index in data array
	int getDataIndex(long[] dimensionIndex) {
		
		// calculate index in flat array
		int index = 0;
		for(int i = 0; i < dimensionIndex.length; i++) { 
			int temp = 1;
			for (int j = i+1; j < dimensionIndex.length; j++) {
				temp *= fGridSize[j];
			}
			index += dimensionIndex[i] * temp;
		}
		
		// multiple output dimensions, so index is also multiplied
		index *= fOutputCount;
		
		return index;
	}
	
	
	
	
	/**
	 * iterate over data
	 * @return 
	 */
	public Iterator<SamplePoint> getIterator( ) {
		return new GriddedDatasetIterator( fGridSize, fOutputCount, fData );		
	}
	public int getInputDimension() {
		return fGridSize.length;
	}
	public int getOutputDimension() {
		return fOutputCount;
	}
	public int getSize() {
		return fTotalPoints;
	}
	public RawDataset getRawDataset() {
		
		// get the input dimension
		int nInputs = fGridSize.length;
		
		// create raw inputs array
		double[] inputs = new double[nInputs*fTotalPoints];
		
		// initialize index to [0, 0, ..., 0]
		long[] index = new long[nInputs];
		Arrays.fill(index, 0);
		
		// visit every item, in the right order
		int inputCounter = 0;
		while (index != null) {
			
			// convert to input array
			for (int i = 0; i < index.length; ++i) {
				inputs[inputCounter * nInputs + i] = convertFromGridArray((int)index[i], i);
			}
			
			// get the next sample
			++inputCounter;
			index = getNextArrayIndex(index);
		}
		
		// compile raw dataset
		return new RawDataset( inputs, fData, fTotalPoints );
	}
	
	public long[] getNextArrayIndex(long[] index) {
		
		// we increment the last index, and perform addition along the indices
		int dim = index.length - 1;
		++index[dim];
		while (dim >= 0 && index[dim] == fGridSize[dim]) {
			
			// reset this dim
			index[dim] = 0;
			
			// move to next dim
			--dim;
			// we have visited all grid locations 
			if (dim == -1) return null;
			
			// increment next dim
			++index[dim];
		}
		
		// return the current location
		return index;
	}
}
