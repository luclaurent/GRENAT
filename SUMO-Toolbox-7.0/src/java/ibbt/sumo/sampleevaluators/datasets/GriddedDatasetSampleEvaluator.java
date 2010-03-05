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
import ibbt.sumo.config.InputDescription;
import ibbt.sumo.sampleevaluators.SampleEvaluatorException;

import java.util.logging.Level;
import java.util.logging.Logger;

import org.dom4j.Node;

/**
 * This class implements a gridded dataset lookup sample evaluator.
 * When given a sample point, this evaluator looks in a table for a simulation of a point as close to the given point as possible.
 * It returns the output parameters at the closest point, and changes the input parameters to match the closest point that was used.
 */
public class GriddedDatasetSampleEvaluator extends DatasetSampleEvaluator {
	private static Logger logger = Logger.getLogger("ibbt.sumo.sampleevaluators.datasets.GriddedDatasetSampleEvaluator");
	private Node fFileNode;
	//private int fInputDimension;
	private int fFlatOutputDimension;
	
	private double[] fMinima;
	private double[] fMaxima;
	
	public GriddedDatasetSampleEvaluator(Config config) throws SampleEvaluatorException {
		super(config);
		
		fFlatOutputDimension = config.output.getSimulatorOutputDimension();
		//fInputDimension = config.input.getSimulatorInputDimension();

		//how many datafiles are available
		int numFiles = config.context.getSimulatorConfig().getGriddedDataFiles().size();
		
		//No datafiles specified, error
		if(numFiles < 1){
			SampleEvaluatorException ex = new SampleEvaluatorException("No gridded datafile specified in the simulator configuration!");
			logger.log(Level.SEVERE,ex.getMessage(),ex);
			throw ex;
		}else{
			//get the id of the dataset to use
			String id = config.self.getOption("id", "");
			
			//The user did not specify a specific dataset to use
			if(id.length() < 1){
				//more than 1 files are available
				if(numFiles > 1){
					//more than one possibility, try to use the one marked 'default'
					fFileNode = config.context.getSimulatorConfig().getGriddedDataFile("default");
				
					if(fFileNode == null){
						String msg = "There are " + numFiles + " gridded datafiles available but none with the id attribute set to 'default', which one to use?";
						SampleEvaluatorException ex = new SampleEvaluatorException(msg);
						logger.log(Level.SEVERE,ex.getMessage(),ex);
						throw ex;
					}
				//Only one file is available, use that one
				}else{
					fFileNode = config.context.getSimulatorConfig().getGriddedDataFiles().get(0);
				}
			
			//The user specified a specific dataset to use	
			}else{
				fFileNode = config.context.getSimulatorConfig().getGriddedDataFile(id);
				if(fFileNode == null){
					SampleEvaluatorException ex = new SampleEvaluatorException("No gridded datafile with id '" + id + "' specified in the simulator configuration!");
					logger.log(Level.SEVERE,ex.getMessage(),ex);
					throw ex;
				}
			}
			
			String fileName = fFileNode.getText();
			
			// create the arrays which store the minima/maxima in each dimension
			fMinima = new double[config.input.getSimulatorInputDimension()];
			fMaxima = new double[config.input.getSimulatorInputDimension()];
			
			// fill up arrays, both for constant and normal dimensions as we work in simulator space
			InputDescription[] inputs = config.input.getInputDescriptions();
			for (int i = 0; i < inputs.length; ++i) {
				int inputSelect = inputs[i].getInputSelect()[0];
				fMinima[inputSelect] = inputs[i].getMinimum();
				fMaxima[inputSelect] = inputs[i].getMaximum();
			}
			inputs = config.input.getConstantInputDescriptions();
			for (int i = 0; i < inputs.length; ++i) {
				int inputSelect = inputs[i].getInputSelect()[0];
				fMinima[inputSelect] = inputs[i].getMinimum();
				fMaxima[inputSelect] = inputs[i].getMaximum();
			}
			
			
			//Load the file from disk
			load(config, fileName);
			logger.info( "Constructed gridded dataset from file " + fileName);		
		}
	}
	
	protected Dataset construct( ) {
		logger.fine( "Constructing gridded dataset from textual file: " + fFileNode.getText() );		
		
		String[] gridSizes = fFileNode.valueOf("@gridsize").split(",");
		int[] gridSize = new int[gridSizes.length];
		
		logger.fine( "Gridsizes: " );
		for ( int i=0; i<gridSize.length;i++ ) {
			gridSize[i] = new Integer( gridSizes[i] );
			logger.fine( "Dimension " + (i+1) + ": " + gridSizes[i] );
		}		
		
		return new GriddedDataset(gridSize, fMinima, fMaxima, fFlatOutputDimension );		
	}
}
