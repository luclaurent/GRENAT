package ibbt.sumo.sampleevaluators;
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
import ibbt.sumo.util.SystemArchitecture;
import ibbt.sumo.util.SystemPlatform;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.logging.Level;
import java.util.logging.Logger;


/**
 * This class implements a local sample evaluator. The user provides a Simulator
 * in the constructor, which is used to calculate the value of each sample point
 * locally.
 */
public class LocalSampleEvaluator extends ThreadedBatchSampleEvaluator {

	/**
	 * Simulator used for each evaluation.
	 */
	private Simulator fSimulator = null;
	private static Logger logger = Logger.getLogger("ibbt.sumo.sampleevaluators.LocalSampleEvaluator");
	
	
	public LocalSampleEvaluator(Config config) throws SampleEvaluatorException {
		super(config);
		
		// Read the config describing the simulator, and construct the simulator object
		constructSimulator(config);
		
		//start the evaluation threads
		startThreads();
		
		logger.finer("LocalSampleEvaluator constructed");
	}

	public void evaluate(EvaluationUnitBatch batch) throws SampleEvaluatorException{
		fSimulator.simulateBatch(batch);
		submitEvaluatedBatch(batch);
	}
	
	public void setSimulator(Simulator sim) {
		assert (sim != null);
		fSimulator = sim;
		logger.finer("Simulator set to " + sim.toString());
	}
	
	private void constructSimulator( Config config ) throws SampleEvaluatorException {
		
		// get list of native executables for this platform/architecture
		NodeConfig executable = config.context.getSimulatorConfig().getExecutable(
																		config.context.getPlatform(),
																		config.context.getArch());
		// data for executable
		String executableName = null;
		boolean batchMode = false;
		int batchSize = 1;
		
		// no node found
		if (executable == null) {
			logger.warning("Not a single native executable declaration (in your simulator configuration file) was found for your platform '" + config.context.getPlatform() + "' and architecture '" + config.context.getArch() + "'");
		} else {
			executableName = executable.getText();
			batchMode = executable.getBooleanAttrValue("batch", "false");
			batchSize = executable.getIntAttrValue("batchSize", "1");
		}

		String javaClassName = null;
		NodeConfig javaExe = config.context.getSimulatorConfig().getExecutable( SystemPlatform.JAVA, SystemArchitecture.ANY );
		if(javaExe != null){
			javaClassName = javaExe.getText();
		}

		// get the simulator type
		String simulatorType = config.self.getOption("simulatorType", "");

		boolean tryJava = true;
		boolean tryExternal = true;

		//must use external
		if (simulatorType.equals("external")) {
			tryJava = false;
			if (executableName == null || executableName.length() < 1) {
				tryExternal = false;
			}
		//must use java
		} else if (simulatorType.equals("java")) {
			tryExternal = false;
			if (javaClassName == null || javaClassName.length() < 1) {
				tryJava = false;
			}
		//nothing specified, try both
		} else if (simulatorType.equals("")) {
			if (javaClassName == null || javaClassName.length() < 1) {
				tryJava = false;
			}
			if (executableName == null || executableName.length() < 1) {
				tryExternal = false;
			}
		//invalid identifier used
		} else {
			SampleEvaluatorException ex = new SampleEvaluatorException(
					"Invalid simulatorType specified in sample evaluator, must be one of 'external' or 'java'");
			logger.log(Level.SEVERE, ex.getMessage(), ex);
		}
		
		// try loading a java object
		if (tryJava) {
			try {
				logger.info("Trying to construct a java object named " + javaClassName);
				//instantiate the java object
				Simulator sim = (Simulator) Class.forName(javaClassName).newInstance();
				//configure it
				sim.configure(config.context.getSimulatorConfig().getOptions());
				//set it
				setSimulator(sim);
				
				// no batch mode supported by the java simulator
				setBatchSize(1);
				
			} catch (Exception e) {
				fSimulator = null;
				SampleEvaluatorException ex = new SampleEvaluatorException(
						"Error loading simulator class: " + e.getMessage(), e);
				throw ex;
			}
		
		//try loading an external executable
		} else if (tryExternal && fSimulator == null) {
			logger.info("LocalSampleEvaluator configured with executable "
					+ executableName + " (platform="
					+ config.context.getPlatform() + ", arch=" + config.context.getArch()
					+ ")");
			try {
				File nativeExe = config.context.findFileInPath(executableName);
				logger.finer("Full executable path resolved to " + nativeExe.getAbsolutePath());
				long timeout = config.self.getIntOption("timeout", -1);
				if ( timeout > 0 )
					timeout *= 1000;
				
				// create external simulator
				ExternalSimulator sim = new ExternalSimulator(nativeExe,timeout);
				
				// set batch mode
				sim.setBatchMode(batchMode);
				
				// no batch mode, always set to size 1
				if (!batchMode)
					setBatchSize(1);
				
				// batch mode, set to size from simulator
				else
					setBatchSize(batchSize);
				
				// set the simulator
				setSimulator(sim);
			} catch (FileNotFoundException e) {
				SampleEvaluatorException ex = new SampleEvaluatorException("Simulator file '"
						+ executableName + "' not found in path", e);
				logger.log(Level.SEVERE, ex.getMessage(), ex);
				throw ex;
			}
		}else{
			SampleEvaluatorException ex = new SampleEvaluatorException("No valid simulator executable (native or Java) specified in your simulator configuration file, unable to use LocalSampleEvaluator");
			logger.log(Level.SEVERE, ex.getMessage(), ex);
			throw ex;
		}
	}
	
	
	public void cleanup() {
		super.cleanup();
	}
}
