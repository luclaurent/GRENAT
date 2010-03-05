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

import ibbt.sumo.config.Config;
import ibbt.sumo.config.ContextConfig;
import ibbt.sumo.sampleevaluators.AbstractSampleQueueManager;
import ibbt.sumo.sampleevaluators.EvaluationUnit;
import ibbt.sumo.sampleevaluators.SampleEvaluator;
import ibbt.sumo.sampleevaluators.SampleEvaluatorException;
import ibbt.sumo.sampleevaluators.SampleEvaluatorStatus;
import ibbt.sumo.sampleevaluators.SamplePoint;
import ibbt.sumo.sampleevaluators.EvaluationUnit.EvaluationState;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.util.Hashtable;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * This class implements a dataset lookup sample evaluator. When given a sample
 * point, this evaluator looks in a table for a simulation of a point as close
 * to the given point as possible. It returns the output parameters at the
 * closest point, and changes the input parameters to match the closest point
 * that was used.
 */
public abstract class DatasetSampleEvaluator extends AbstractSampleQueueManager implements SampleEvaluator {
	//A cache for storing datasets
	static private Hashtable<String, Dataset> datasetCache = new Hashtable<String,Dataset>();
	
	private Dataset fData;
	private SampleEvaluatorStatus fStatus = new SampleEvaluatorStatus();
	
	private boolean fInputSelection;
	
	private static Logger logger = Logger
			.getLogger("ibbt.sumo.sampleevaluators.datasets.DatasetSampleEvaluator");

	public DatasetSampleEvaluator(Config config) {
		super(config);
		
		// store if input selection was used
		fInputSelection = config.input.getInputDimension() != config.input.getSimulatorInputDimension();
	}

	public Dataset getData() {
		return fData;
	}

	protected void load(Config config, String fileName) throws SampleEvaluatorException {
		
		String fileId = null;
		ContextConfig context = config.context;
		File file = null;
		
		//Try to load the file as is (ie: treat is as an absolute path)
		if(new File(fileName).exists()){
			file = new File(fileName);
			fileId = file.getAbsolutePath();
		}else{
			// look for it in the toolbox path
			try {
				
				file = context.findFileInPath( fileName );
				fileId = file.getAbsolutePath();

			} catch (FileNotFoundException e) {
				//file not found, try adding .txt
				
				try {
					
					file = context.findFileInPath( fileName + ".txt" );
					fileId = file.getAbsolutePath();
					
				} catch (FileNotFoundException e1) {
					// file still not found, throw error
					SampleEvaluatorException ex = new SampleEvaluatorException(
							"Unable to find data file " + fileName + " or " + fileName + ".txt in the toolbox path or project directory");
					logger.log(Level.SEVERE, ex.getMessage(), ex);
					throw ex;
				}
			}
		}
			
		//Before reading the file first check the cache to see if this dataset was already loaded before
		if(fileId != null && datasetCache.containsKey(fileId)){
			fData = datasetCache.get(fileId);
			logger.fine("Dataset " + fileId + " found in cache, NOT re-loading from disk");
			return;
		}else{
			logger.fine("Dataset " + fileId + " not found in cache, loading from disk");

			logger.fine("Reading textual input file " + file);
			fData = construct( );
			
			try {
				fData.loadText(new FileInputStream(file));

				//cache the dataset to prevent it being loaded multiple times
				datasetCache.put(fileId, fData);
				logger.fine("Added dataset from " + fileId + " to cache");
				
			} catch (FileNotFoundException e) {
				SampleEvaluatorException ex = new SampleEvaluatorException(
						"Unable to find data file " + file.getAbsolutePath(),e);
				logger.log(Level.SEVERE, ex.getMessage(), ex);
				throw ex;
			}
		
		}
	}

	protected abstract Dataset construct();

	/**
	 * Schedule points for evaluation
	 */
	public void submitSamplesForEvaluation(SamplePoint[] points){
		//add them to the queue
		this.submitNewSamples(points);
	}
	
	/**
	 * Return the number of poitns pending evaluation
	 */
	public int getNumPendingSamples(){
		return this.pendingSamples();
	}
	
	/**
	 * Return the number of evaluated points waiting to be fetched
	 */
	public int getNumEvaluatedSamples(){
		return this.evaluatedSamples();
	}
	
	public double getAverageEvaluationTime(){
		return this.averageEvaluationTime();
	}
	
	/**
	 * Since this class uses a data file to evaluate points this method immediately
	 * evaluates the incoming unit and puts it back on the evaluated queue.  We do this
	 * since we assume such a dataset lookup is fast, thus blocking is permitted.
	 */
	public void addToInputQueue(EvaluationUnit unit) {
		
		// if null or not active, just return
		if (!fStatus.isActive()) return;
		
		// input filtering does not work with datasets and adaptive sampling
		if (fInputSelection) {
			SampleEvaluatorException ex = new SampleEvaluatorException("Input filtering is incompatible with datasets and adaptive sampling, please use a different sample evaluator or disable adaptive sampling");
			logger.log(Level.SEVERE,ex.getMessage(),ex);
			fStatus.disable(ex);
			return;
		}

		//set the timestamp evaluation started on
		unit.setEvaluationStartTime();

		SamplePoint sample = unit.getInputSample();
		
		// evaluate the sample
		try {
			//evaluate the sample
			fData.evaluate(sample);
			
			//evaluation finished
			unit.setEvaluationFinishedTime();
			
			//Update the state
			unit.setState(EvaluationUnit.EvaluationState.EVALUATED);
				
			// everything ok
			unit.addOutputSample(sample);
			
			//put it in the output queue
			submitEvaluatedSample(unit);
				
		} catch (SampleEvaluatorException e) {
			logger.log(Level.SEVERE,e.getMessage(),e);
			unit.setState(EvaluationState.FAILED);
			submitEvaluatedSample(unit);
			fStatus.disable(e);
			logger.severe("DatasetSampleEvaluator disabled...");
		}
	}
	
	/**
	 * Get the next evaluated point
	 */
	public SamplePoint fetchEvaluatedSample(){
		//get the next evaluated point from the output queue
		return this.requestEvaluatedSample();
	}
		
	public SampleEvaluatorStatus getStatus() {
		return fStatus;
	}
	
	public void cleanup() {
		datasetCache.clear();
	}
}
