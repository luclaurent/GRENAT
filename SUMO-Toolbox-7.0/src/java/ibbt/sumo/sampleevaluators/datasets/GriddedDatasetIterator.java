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

import ibbt.sumo.sampleevaluators.SamplePoint;

import java.util.Iterator;
import java.util.NoSuchElementException;

/**
 * class that can iterate over a gridded dataset
 * @author COMS
 */
public class GriddedDatasetIterator implements Iterator<SamplePoint> {

	private int[] fGridSize;
	private int[] fCurrentIndices;
	private int fOutputDimension;
	private int fInputDimension;
	private double[] fOutputs;
	private int fOutputCounter;
	private boolean fDone;
	
	public GriddedDatasetIterator( int[] gridSize, int outputDimension, double[] outputs ) {
		fGridSize = gridSize;
		fInputDimension = fGridSize.length;
		fCurrentIndices = new int[fInputDimension];
		fOutputDimension = outputDimension;
		fOutputCounter = 0;
		fOutputs = outputs;
		fDone = false;
	}
	
	public boolean hasNext() {
		return !fDone;
	}

	public SamplePoint next() {		
		double[] coords = new double[fInputDimension];
		double[] outputs = new double[fOutputDimension];
		int i;
		
		if ( !hasNext() )
			throw new NoSuchElementException( );
		
		for ( i=0;i<fInputDimension;i++ )
			coords[i] = (double)fCurrentIndices[i] / (double)(fGridSize[i] - 1) * 2.0 - 1.0;

		for ( i=0;i<fInputDimension;i++ )
			if ( ++fCurrentIndices[i] == fGridSize[i] )
				fCurrentIndices[i] = 0;
			else
				break;

		if ( i==fInputDimension )
			fDone = true;

		for ( i=0;i<fOutputDimension;i++ )
			outputs[i] = fOutputs[fOutputCounter++];		

		return new SamplePoint( coords, outputs );
	}

	public void remove() {
		throw new UnsupportedOperationException( );
	}
}
