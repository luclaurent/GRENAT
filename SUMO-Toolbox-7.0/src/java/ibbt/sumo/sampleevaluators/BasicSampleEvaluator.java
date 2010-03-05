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
import ibbt.sumo.sampleevaluators.EvaluationUnit.EvaluationState;

import java.util.HashMap;
import java.util.logging.Logger;


/**
 * This is class is an partial implementation of the interface SampleEvaluator.
 */
public abstract class BasicSampleEvaluator extends DefaultSampleEvaluator {
	
	private HashMap<Long, EvaluationUnit> fSampleToUnit = new HashMap<Long, EvaluationUnit>();
	private static Logger logger = Logger.getLogger("ibbt.sumo.sampleevaluators.BasicSampleEvaluator");
	
	public BasicSampleEvaluator(Config config) {
		super(config);
	}
	
	/**
	 * Evaluate one point
	 */
	public abstract void evaluate(SamplePoint point);
	
	/**
	 * This function is called by the derived subclass whenever a *successfully*
	 * evaluated point needs to be added to the queue.
	 */
	protected final void submitEvaluatedSample(SamplePoint point) {
		//get the matching unit
		EvaluationUnit unit = fSampleToUnit.remove(point.getId());
		unit.setEvaluationFinishedTime();
		unit.setState(EvaluationState.EVALUATED);
		unit.addOutputSample(point);
		//put it in the output queue
		getSampleQueueManager().submitEvaluatedSample(unit);
		logger.finest("Successfully evaluated point " + point + " added to the output queue");
	}
	
	/**
	 * This function is called by the derived subclass whenever a FAILED point
	 * needs to be added to the queue.
	 */
	protected final void submitFailedSample(SamplePoint point) {
		//get the matching unit
		EvaluationUnit unit = fSampleToUnit.remove(point.getId());
		unit.setEvaluationFinishedTime();
		unit.setState(EvaluationState.FAILED);
		//put it in the output queue
		getSampleQueueManager().submitEvaluatedSample(unit);
		logger.finest("Failed point " + point + " added to the output queue");
	}
	
	
	/**
	 * Request a new sample for evaluation.
	 */
	public SamplePoint requestNewSample() {
		//poll the queue for the next point
		DefaultSampleQueueManager sqm = (DefaultSampleQueueManager)getSampleQueueManager();
		EvaluationUnit unit = sqm.requestNewSample();
		
		if(unit == null){
			//empty queue
			return null;
		}else{
			unit.setEvaluationStartTime();
			//get the nested point and remember which unit it mapped to
			SamplePoint point = unit.getInputSample();
			fSampleToUnit.put(point.getId(), unit);
			return point;
		}
	}
	
	public void cleanup() {
		fSampleToUnit.clear();
		super.cleanup();
	}
}
