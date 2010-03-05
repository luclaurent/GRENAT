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

import ibbt.sumo.SUMOException;
import ibbt.sumo.sampleevaluators.SampleEvaluatorException;
import ibbt.sumo.sampleevaluators.SamplePoint;
import ibbt.sumo.util.SamplePointKDTree;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.io.Serializable;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Pattern;

import edu.wlu.cs.levy.CG.KDTree;
import edu.wlu.cs.levy.CG.KeySizeException;

/**
 * A scattered dataset contains of a series of unsorted columns of data
 * @author COMS
 */
public class ScatteredDataset implements Dataset, Serializable {
	private static final long serialVersionUID = 1L;
	private static Logger logger = Logger.getLogger("ibbt.sumo.sampleevaluators.datasets.ScatteredDataset");

	private transient KDTree fData = null;
	private HashSet<SamplePoint> fUsedDataPoints = null;
	private int fInputDimension;
	private int fOutputDimension;
	private SamplePoint[] fPoints;
	
	/**
	 * constructor
	 * @param inputDimension how many columns are input?
	 * @param outputDimension how many columns are output?
	 */
	public ScatteredDataset( int inputDimension, int outputDimension ) {
		fInputDimension = inputDimension;
		fOutputDimension = outputDimension;
		fUsedDataPoints = new HashSet<SamplePoint>();
	}
	/**
	 * Read a datafile containing n x d numbers with n the number of samples, d the dimensionality
	 * and put it in a KDTree
	 * @param scanner The scanner object to use to read the data
	 * @throws SampleEvaluatorException
	 */
	public void loadText(InputStream stream) throws SampleEvaluatorException {
		logger.finest("Starting to load points from scattered datafile");
		
		HashSet<SamplePoint> points = new HashSet<SamplePoint>();		
		long ignoredCtr = 0;
		SamplePoint point = null;
		double[] inputs = null;
		double[] outputs = null;
		String line = null;
		String[] substrings = null;
		int i,j = 0;
		Pattern pat = Pattern.compile("(\\s)+");
		LineNumberReader reader = new LineNumberReader(new InputStreamReader(stream));
		
		try{
			line = reader.readLine();
			
			while(line != null){
				
				// trim line
				line = line.trim();
				
				// empty line, skip
				if (line.length() == 0) {
					line = reader.readLine();
					continue;
				}
				
				//use trim to prevent empty entries, should be put in the pattern itself
				substrings = pat.split(line);

				if(substrings.length != (fInputDimension + fOutputDimension)){
					String msg = "Line " + reader.getLineNumber() + " contains " + substrings.length 
										+ " columns, while " + (fInputDimension + fOutputDimension) 
										+ " columns were expected (" + fInputDimension + " inputs and " 
										+ fOutputDimension + " outputs)";
					logger.severe(msg);
					throw new SampleEvaluatorException(msg);
				}
				
				inputs = new double[fInputDimension];
				outputs = new double[fOutputDimension];
				
				for (i=0; i<fInputDimension; ++i){
					inputs[i] = Double.parseDouble(substrings[i]);
				}
				
				for (j=0 ; j<fOutputDimension; ++j){
						outputs[j] = Double.parseDouble(substrings[i]);
						++i;
				}
					
				point = new SamplePoint(inputs,outputs);
	
				//NB: relies on a poper hashCode implementation of samplepoint
				if(points.contains(point)){
					++ignoredCtr;
					logger.fine("Skipping duplicate point " + point);
				}else{
					points.add(point);
				}
				
				//read the next line
				line = reader.readLine();
			}
		} catch (IOException e) {
			SampleEvaluatorException ex = new SampleEvaluatorException(e.getMessage(),e);
			logger.log(Level.SEVERE,e.getMessage(),e);
			throw ex;
		}

		if(ignoredCtr > 0){
			logger.warning("Scattered dataset loaded, " + ignoredCtr + " points with identical input and output values removed");
		}else{
			logger.finest(points.size() + " points loaded from dataset");
		}
		
		try {
			logger.finest("Loading points into KD-Tree");
			// create kd tree
			SamplePointKDTree data = new SamplePointKDTree(fInputDimension, points);
			fData = data;
			
			// get list of unique points
			int prevPointSize = points.size();
			fPoints = data.getUniquePoints();
			if (prevPointSize > fPoints.length) logger.warning("Scattered dataset loaded, " + (prevPointSize-fPoints.length) + " points with identical input values removed");
			
			// print out unique point listing
			logger.info(fPoints.length + " unique datapoints read from file");
			
		} catch (SUMOException e) { 
			logger.log(Level.SEVERE,e.getMessage(),e);
			throw new SampleEvaluatorException(e.getMessage());
		}
	}
	/**
	 * Read a serialized ScatteredDataset class from file
	 * @param in
	 * @throws IOException
	 * @throws ClassNotFoundException
	 */
	private void readObject(java.io.ObjectInputStream in) throws IOException, ClassNotFoundException {
		in.defaultReadObject();
		try {
			fData = new SamplePointKDTree( fInputDimension, fPoints );
		} catch (SUMOException e) {
			logger.log(Level.SEVERE,e.getMessage(),e);
			throw new IOException( "Binary Scattered dataset is corrupted: " + e.getMessage() );
		}
	}

	/**
	 * Return the value of a samplepoint using the scattered data (the sample is clipped to the nearest point)
	 * @param sample the sample to evaluate, its outputparameters are set here.
	 *  Note that its input parameters may be changed if the sample is clipped!
	 * @throws SampleEvaluatorException
	 */
	public void evaluate(SamplePoint sample) throws SampleEvaluatorException {

		try {
			double[] input = sample.getInputParameters();			

			// Check if point has allready been used. If so it will probably cause 
			// unnecessary actions later on, solve by choosing a different point
			int n = 1;
			boolean cont = true;
			while (cont) {
				if (n >= fPoints.length) {
					throw new SampleEvaluatorException("Dataset depleted, no more points available in the dataset");
				}
				//System.out.println("Checking for " + n + " neighbours in array of size " + fPoints.length + ", " + fUsedDataPoints.size() + " points already used.");
				Object[] obs = fData.nearest(input, n);

				SamplePoint clippedPoint = (SamplePoint)obs[n-1];
				if (!fUsedDataPoints.contains(clippedPoint)) {
					sample.setOutputParameters(clippedPoint.getOutputParameters());
					sample.setInputParameters(clippedPoint.getInputParameters());	
					fUsedDataPoints.add(clippedPoint);
					cont = false;
				}
				n++;
			}

		} catch ( KeySizeException kse ) {
			logger.log(Level.WARNING, kse.getMessage(), kse);
		}
	}
	/**
	 * iterate over data
	 * @return 
	 */
	public Iterator<SamplePoint> getIterator( ) {
		return Collections.unmodifiableList( Arrays.asList( fPoints ) ).listIterator();
	}
	
	
	public int getInputDimension() {
		return fInputDimension;
	}
	public int getOutputDimension() {
		return fOutputDimension;
	}
	public int getSize() {
		return fPoints.length;
	}
	public RawDataset getRawDataset() {
		int i;
		
		int nPoints = fPoints.length;
		double[] inputs = new double[nPoints*fInputDimension];
		double[] outputs = new double[nPoints*fOutputDimension];
		int inputCounter=0, outputCounter = 0;
		
		for ( SamplePoint sp : fPoints ) {
			for ( i=0;i<fInputDimension;i++ )
				inputs[inputCounter++] = sp.getInputParameter(i);
			for ( i=0;i<fOutputDimension;i++ )
				outputs[outputCounter++] = sp.getOutputParameter(i);
		}
		
		return new RawDataset( inputs, outputs, nPoints );
	}
}
