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

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * This class simply calls evaluate() in a new thread
 */
public abstract class ThreadedBasicSampleEvaluator extends BasicSampleEvaluator implements Runnable {
	
	private static Logger logger = Logger.getLogger("ibbt.sumo.sampleevaluators.ThreadedBasicSampleEvaluator");

	/**
	 * Expresses whether the thread is active or not.
	 */
	boolean fActive = false;
	
	
	public ThreadedBasicSampleEvaluator(Config config) {
		super(config);
	}

	/**
	 * Polls the input queue for new samples in a separate thread and calls evaluate.
	 */
	public final void run() {
		SamplePoint sample = null;
		fActive = true;
		
		// keep going until stopped
		while (fActive && getStatus().isActive()) {
			try {
				if ((sample = requestNewSample()) != null) {
					evaluate(sample);
				} else {
					//No points available wait a while
					Thread.sleep(500);
				}
				//Dont hog the scheduler
				Thread.sleep(100);
			} catch (InterruptedException e) {
				logger.log(Level.WARNING, e.getMessage(), e);
				submitFailedSample(sample);
				getStatus().disable(e);
			}
		}
	}

	/**
	 * Stop the thread and cleanup
	 */
	public void cleanup() {
		fActive = false;
		super.cleanup();
	}

}
