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

import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.logging.Logger;

/**
 * This class implements a simple first-in-first-out queue
 */
public class BasicSampleQueueManager extends DefaultSampleQueueManager {
	
	private static Logger logger = Logger.getLogger("ibbt.sumo.sampleevaluators.BasicSampleQueueManager");
	
	/**
	 * The queue of newly submitted samples.
	 */
	private Queue<EvaluationUnit> inputQueue = new ConcurrentLinkedQueue<EvaluationUnit>();
		
	public BasicSampleQueueManager(Config config) {
		super(config);
	}
	
	/**
	 * Add a new point to the input queue
	 */
	public void addToInputQueue(EvaluationUnit unit) {
		inputQueue.add(unit);
		logger.finest("Added a new evaluation unit to the input queue (size: " + inputQueue.size() + "): " + unit.toString());
	}
	
	/**
	 * Request a new SamplePoint from the input queue. Returns null if the queue is empty.
	 */
	public EvaluationUnit getFromInputQueue() {
		return inputQueue.poll();
	}
	
	/**
	 * Cleanup (empty the queue)
	 */
	public void cleanup(){
		inputQueue.clear();
		super.cleanup();
	}
}
