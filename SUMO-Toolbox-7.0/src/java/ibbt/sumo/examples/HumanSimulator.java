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
** Revision: $Id: HumanSimulator.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.sampleevaluators.EvaluationUnitBatch;
import ibbt.sumo.sampleevaluators.SampleEvaluatorException;
import ibbt.sumo.sampleevaluators.SamplePoint;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Simulator where a human fills in the responses for the requested points
 */
public class HumanSimulator  extends AbstractSimulator{
	
	private static Logger logger = Logger.getLogger("ibbt.sumo.examples.HumanSimulator");
	
	public void simulateBatch(EvaluationUnitBatch batch) throws SampleEvaluatorException {

		System.out.println("===============================================");
		System.out.println("=== Starting HumanSimulator");
		System.out.println("===============================================");
		System.out.println();
		System.out.println("** The SUMO Toolbox is requesting " + batch.getSamples().length + " samples: ");
		System.out.println();
		System.out.println("** Please enter the simulator outputs. If there are multiple outputs, " +
				"numbers should be space separated.  Complex numbers should be specified as two (real/imag)." +
				"\nType RESTART to start again.");
		System.out.println();
		
		int i = 1;
		for (SamplePoint point : batch.getSamples()) {
			System.out.println(i + ") " + point.inputsToString() + " (id=" + point.getId() +")");
		}
		System.out.println();
		
		super.simulateBatch(batch);
		
		System.out.println("===============================================");
	}
	
	public void simulate(SamplePoint point) {
		int maxTries = 10;
		int k = 0;
		while(k < maxTries){
			++k;
			String line = "";
		
			System.out.println("* Enter " + point.getOutputDimension() + " output value(s) for point " + point.inputsToString() + " (id=" + point.getId() +") : ");
			
		    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
		    try {
		    	//read the line
		        line = br.readLine();
		        line = line.trim();

		        //start again
		        if(line.equalsIgnoreCase("RESTART")){
		        	continue;
		        }
		        
		        //split into the different outputs
		        Scanner scanner = new Scanner(line);
		        point.outputsFromStream(scanner);
		        
		        //all ok
		        break;
		        
		    } catch (Exception e) { 
		    	logger.severe("Problem while reading output values: " + e.getMessage() + ", please try again.");
		    	e.printStackTrace();
		    	logger.log(Level.FINE,e.getMessage(),e);
		    	continue;
		    }

		}
		
		if(k > maxTries){
		   	logger.severe("There seem to have been problems reading the outputs, considering the point as failed..");
		}
	}
}
