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

/**
 * Interface to an entity that is able to evaluate sample points
 */
public interface SampleEvaluator {
	
	/**
	 * Schedule a number of sample points for evaluation
	 */
	public void submitSamplesForEvaluation(SamplePoint[] points);

	/**
	 * Get the next evaluated point
	 */
	public SamplePoint fetchEvaluatedSample();

	/**
	 * Return the number of samples pending evaluation
	 */
	public int getNumPendingSamples();
	
	/**
	 * Return the number of samples that have already been evaluated
	 * and are waiting to be fetched
	 */
	public int getNumEvaluatedSamples();
	
	/**
	 * Get the average time in seconds to simulate one data point
	 */
	public double getAverageEvaluationTime();

	/**
	 * Clean up the threads started and the resources used by the sample evaluator.
	 * Called automatically when the SampleEvaluator is not to be used anymore.
	 */
	public void cleanup();
	
	/**
	 * Get the status of the sample evaluator. This status contains, for example,
	 * if the sample evaluator is still capable of evaluating samples and how many
	 * it can evaluate at once.
	 * @return The status.
	 */
	public SampleEvaluatorStatus getStatus();
}
