package ibbt.sumo.profiler;
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
** Revision: $Id: FilteredListModel.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import java.util.LinkedList;
import java.util.List;

import javax.swing.AbstractListModel;

public class FilteredListModel extends AbstractListModel {

	private static final long serialVersionUID = -6614597836261419998L;

	private List<Object> fList = new LinkedList<Object>();
	private List<Object> fFilteredList = new LinkedList<Object>();	
	private String fLastFilter = null;
	
	public int getSize() {
		return fFilteredList.size();
	}

	public Object getElementAt(int position) {
		if ( position < 0 || position >= fFilteredList.size() )
			return null;
		
		return fFilteredList.get( position );
	}
	
	public void addElement( Object item ) {
		fList.add( item );
		if ( filter( item ) ) {
			fFilteredList.add( item );
			fireIntervalAdded( this, fFilteredList.size(), fFilteredList.size() );
		}
	}
	
	public void clear( ) {
		int oldSize = fFilteredList.size();
		fList.clear();
		if ( oldSize > 0 ) {
			fFilteredList.clear();
			fireIntervalRemoved( this, 0, oldSize - 1 );
		}
	}
	
	public void updateFilter( String newPattern ) {
		int oldSize = fFilteredList.size();
		fFilteredList.clear();

		if ( oldSize > 0 )
			fireIntervalRemoved( this, 0, oldSize-1 );

		fLastFilter = newPattern;		
		for ( Object item : fList ) {
			if ( filter( item ) ) {
				fFilteredList.add( item );
			}
		}		
				
		if ( fFilteredList.size() > 0 )
			fireIntervalAdded( this, 0, fFilteredList.size() - 1 );		
	}

	private boolean filter(Object item) {
		return fLastFilter == null || item.toString().toUpperCase().contains( fLastFilter.toUpperCase()  );
	}

}
