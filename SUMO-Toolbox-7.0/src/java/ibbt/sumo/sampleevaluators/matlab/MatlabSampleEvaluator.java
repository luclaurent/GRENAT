package ibbt.sumo.sampleevaluators.matlab;
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
import ibbt.sumo.config.NodeConfig;
import ibbt.sumo.contrib.MatlabControl;
import ibbt.sumo.sampleevaluators.EvaluationUnitBatch;
import ibbt.sumo.sampleevaluators.SampleEvaluatorException;
import ibbt.sumo.sampleevaluators.SampleEvaluatorStatus;
import ibbt.sumo.sampleevaluators.SamplePoint;
import ibbt.sumo.sampleevaluators.ThreadedBatchSampleEvaluator;
import ibbt.sumo.util.SystemArchitecture;
import ibbt.sumo.util.SystemPlatform;

import java.util.Properties;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

public class MatlabSampleEvaluator extends ThreadedBatchSampleEvaluator {
	
	/**
	 * Name of the script called to calculate the function.
	 */
	String fScriptName;
	String fDirectory;
	
	/**
	 * Matlab interface.
	 */
	private static MatlabControl fMatlab = null;
	private boolean fInputOK = false;
	private boolean fCheckScriptExistence = true;
	private boolean fScriptExists = true;
	private Object[] options = null;
	boolean fBatchMode = false;
	SampleEvaluatorStatus fStatus = new SampleEvaluatorStatus();
	
	private static Logger logger = Logger.getLogger("ibbt.sumo.sampleevaluators.matlab.MatlabSampleEvaluator");

	/**
	 * Constructor. Configures the sample evaluator, also configures the superclass.
	 * @param context The global context configuration data.
	 * @param config The configuration data of this specific part of the toolbox.
	 * @throws SampleEvaluatorException
	 */
	public MatlabSampleEvaluator(Config config) throws SampleEvaluatorException { 
		super(config);
		
		// get the script name from the simulator
		logger.fine( "Getting script name" );
		NodeConfig executable = config.context.getSimulatorConfig().getExecutable( SystemPlatform.MATLAB, SystemArchitecture.ANY );
		
		// not found
		if (executable == null) {
			SampleEvaluatorException ex = new SampleEvaluatorException(
					"No matlab executable specified in simulator file");
			logger.log(Level.SEVERE, ex.getMessage(), ex);
			throw ex;
		}
		
		fScriptName = executable.getText();
		fBatchMode = executable.getBooleanAttrValue("batch", "false");
		int batchSize = executable.getIntAttrValue("batchSize", "1");
		setBatchSize(batchSize);
		fDirectory = config.context.getProjectDirectory();
		
		// get any options the matlab script might need
		readSimulatorOptions(config.context.getSimulatorConfig().getOptions());
		
		if(fMatlab == null){
			//create the matlab control
			logger.fine( "Creating matlab control object for the first time" );
			fMatlab = new MatlabControl();
		}else{
			logger.fine("MatlabControl already exists, re-using object");
		}

		//make sure there is only one thread scheduled
		if(getNumThreads() !=  1){
			SampleEvaluatorException ex = new SampleEvaluatorException(
					"The Matlab sample evaluator only supports one thread!");
			logger.log(Level.SEVERE, ex.getMessage(), ex);
			throw ex;
		}else{
			startThreads();
		}

		logger.info("MatlabSampleEvaluator succesfully configured using matlab script " + fScriptName);
	}
	
	private void readSimulatorOptions(Properties p){
		Set<Object> keys = p.keySet();
		
		options = new Object[keys.size()*2];
		
		int i = 0;
		for(Object key : keys){
			options[i] = key;
			options[i+1] = p.getProperty(key.toString());
			i = i + 2;
		}
		
		if(i > 0)
			logger.info("Matlab simulator configured with " + keys.size() + " options");
	}
	
	@Override
	public void evaluate(EvaluationUnitBatch batch) throws SampleEvaluatorException {
		
		// get the samples that have to be evaluated
		SamplePoint[] points = batch.getSamples();
		
		// more than one point is only allowed in batch mode
		assert(fBatchMode || points.length == 1);
		
		// try to evaluate the point
		try {
			
			// existence of the script hasn't been verified yet
			// this has to happen here instead of constructor, because it needs a separate thread
			if (fCheckScriptExistence) {
				fCheckScriptExistence = false;
				Object[] args = new Object[1];
				
				// only add the directory to the path if it is a project dir
				// this avoids adding the entire toolbox to the path
				args[0] = fDirectory;
				fMatlab.blockingFeval("addpathRecursive", args);
				
				args[0] = fScriptName;
				
				double out[] = (double[])fMatlab.blockingFeval("exist", args);
				
				if (out[0] == 0)
					fScriptExists = false;
				
			}
			
			// script doesn't exist -> abort
			if (!fScriptExists)
				throw new SampleEvaluatorException("Unable to find script '" + fScriptName +"'. Make sure it is either in the Matlab path or the toolbox path. Do not define an absolute path for the script in the simulator file.");
			
			// Because MatlabControl can only be used from a separate Thread
			if (!fInputOK){
				
				// perform range checking:
				// - if the function has a set amount of inputs, we check against the simulator config
				// - if the function has a variable amount of inputs (varargin), we let the checking up to the script itself
				Object[] args = new Object[1];
				args[0] = fScriptName;
				double out[] = (double[])fMatlab.blockingFeval("nargin", args);
				
				
				// nargin failed to execute
				if (out.length != 1) {
					SampleEvaluatorException ex = new SampleEvaluatorException(
					"Failed to execute command nargin, aborting...");
					logger.log(Level.SEVERE, ex.getMessage(), ex);
					getStatus().disable(ex);
				}
				
				// in batch mode, we only allow varargin or 1 input (array of points) or 2 inputs (array of points + options)
				else if (fBatchMode) {
					long nargin = Math.round(out[0]);
					if (nargin < 0 || (options.length == 0 && nargin == 1) || (options.length > 0 && nargin == 2)) {
						// ok
					}
					else {
						SampleEvaluatorException ex = new SampleEvaluatorException(
						"Dimension mismatch between batch mode input format (one array of doubles) and number of matlab function parameters (" + nargin + ").");
						logger.log(Level.SEVERE, ex.getMessage(), ex);
						getStatus().disable(ex);
					}
				}
				
				// if in normal mode, we only allow varargin or the same amount of inputs as there are dimensions, or 1+dimension inputs (one extra for options)
				else {
					long nargin = Math.round(out[0]);
					if (nargin < 0 || (options.length == 0 && nargin == 1) || (options.length > 0 && nargin == 2) || (options.length == 0 && nargin == getInputDimension()) || (options.length > 0 && nargin == getInputDimension() + 1)) {
						// ok
					}
					else {
						SampleEvaluatorException ex = new SampleEvaluatorException(
						"Dimension mismatch between input dimension (" + getInputDimension() + ") and matlab function parameters (" + nargin + ").");
						logger.log(Level.SEVERE, ex.getMessage(), ex);
						getStatus().disable(ex);
					}
				}
				fInputOK = true;
			}
			// produce the proper inputs
			Object[] args = null;
			if(options.length > 1){
				args = new Object[4];
			}else{
				args = new Object[3];
			}
			// first input is the actual script to be run
			args[0] = fScriptName;
			
			// second argument is the argument list of the script
			double[] inputs = new double[getInputDimension() * points.length];
			for (int i = 0; i < points.length; ++i) {
				System.arraycopy(points[i].getInputParameters(), 0, inputs, i*getInputDimension(), getInputDimension());
			}
			args[1] = inputs;
			
			// third argument is the input dimension (to support batch mode)
			args[2] = getInputDimension();
			
			// add any options if present
			if(args.length > 3){
				//Options are passed to matlab as someFcn(input,{'option1','value1','option2',...})
				args[3] = options;
			}
			
			// execute the wrapper script
			Object outo = fMatlab.blockingFeval("executeMatlabFromJava", args);
			
			// output is string error message
			if (outo.getClass().getCanonicalName().equals("java.lang.String")) {
				throw new SampleEvaluatorException("Script error: '" + outo.toString() + "'");
			}
			
			// output is array of double
			else if (!outo.getClass().getCanonicalName().equals("double[]")) {
				throw new SampleEvaluatorException("Invalid output from Matlab");
			}

			// must be array of double
			double[] out = (double[])outo;
			
			
			// non-batch mode parsing (only the outputs)
			if (!fBatchMode) {
				
				// check: output dimension mismatch
				if (out.length != getOutputDimension()) { 
					SampleEvaluatorException ex = new SampleEvaluatorException(
							"Dimension mismatch between the number of expected outputs (" + getOutputDimension() + ")" +
							" and the number of outputs the matlab script returns (" + out.length + ") (remember that a complex output should return 2 values). Maybe the matlab script returns outputs in batch mode format (inputs and outputs in one single matrix, one sample per row)?");
					logger.log(Level.SEVERE, ex.getMessage(), ex);
					getStatus().disable(ex);
				}
				
				// set output parameters
				points[0].setOutputParameters(out);
				batch.addEvaluatedSample(points[0]);
			}
			
			// batch mode parsing (inputs & outputs)
			else {
				
				// check: output mismatch
				if (out.length % (getInputDimension() + getOutputDimension()) != 0) { 
					SampleEvaluatorException ex = new SampleEvaluatorException(
							"Dimension mismatch between the number of expected outputs (batch mode, so a multiple of " + (getOutputDimension()+getInputDimension()) + ")" +
							" and the number of values the matlab script returns (" + out.length + ") (remember that a complex output should return 2 values). Maybe the matlab script does not work in batch mode?");
					logger.log(Level.SEVERE, ex.getMessage(), ex);
					getStatus().disable(ex);
				}
				
				// now read the evaluated samples from the array
				int sampleSize = getInputDimension() + getOutputDimension();
				for (int i = 0; i < out.length / sampleSize; ++i) {
					SamplePoint point = new SamplePoint(getInputDimension(), getOutputDimension());
					System.arraycopy(out, i*sampleSize, point.getInputParameters(), 0, getInputDimension());
					System.arraycopy(out, i*sampleSize + getInputDimension(), point.getOutputParameters(), 0, getOutputDimension());
					batch.addEvaluatedSample(point);
				}
			}
			
			// add the evaluated batch
			submitEvaluatedBatch(batch);
			
		} catch (InterruptedException e) {
			SampleEvaluatorException ex = new SampleEvaluatorException(
			"Failed to execute matlab script " + fScriptName + " to evaluate point: " + e.getMessage());
			ex.initCause(e);
			logger.log(Level.SEVERE, ex.getMessage(), ex);
			getStatus().disable(ex);
		}
	}
}
