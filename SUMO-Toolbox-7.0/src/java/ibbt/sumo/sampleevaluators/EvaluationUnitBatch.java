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

import java.util.LinkedList;
import java.util.List;
import java.util.Vector;


public class EvaluationUnitBatch {
	
	/**
	 * A list of evaluation units in this batch.
	 */
	Vector<EvaluationUnit> fUnits = new Vector<EvaluationUnit>();
	
	/**
	 * A list of sample points, extracted from the evaluation units for convenience.
	 */
	Vector<SamplePoint> fNewSamples = new Vector<SamplePoint>();
	
	/**
	 * The list of evaluated samples returned by the sample evaluator.
	 */
	List<SamplePoint> fEvaluatedSamples = new LinkedList<SamplePoint>();
	
	/**
	 * Add a new evaluation unit that will be evaluated.
	 */
	public void addEvaluationUnit(EvaluationUnit unit) {
		fUnits.add(unit);
		fNewSamples.add(unit.getInputSample());
	}
	
	/**
	 * Get the list of samples that have to be evaluated.
	 */
	public SamplePoint[] getSamples() {
		return fNewSamples.toArray(new SamplePoint[0]);
	}
	
	/**
	 * Add a newly evaluated sample.
	 */
	public void addEvaluatedSample(SamplePoint point) {
		fEvaluatedSamples.add(point);
	}
	
	
	/**
	 * Get all the evaluation units, along with the evaluated samples added to them
	 * and the completion times appropriately set.
	 * @return
	 */
	public EvaluationUnit[] getEvaluatedUnits() {
		
		// set the correct batch size
		for (int i = 0; i < fUnits.size(); ++i) {
			fUnits.get(i).setBatchSize(fUnits.size());
		}
		
		// add all evaluated samples to evaluation units
		fUnits.get(0).addOutputSamples(fEvaluatedSamples.toArray(new SamplePoint[0]));
		
		// return all the evaluation units
		return fUnits.toArray(new EvaluationUnit[0]);
	}
}
