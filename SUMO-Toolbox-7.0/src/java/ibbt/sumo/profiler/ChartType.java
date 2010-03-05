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
** Revision: $Id: ChartType.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * This class maintains a list of possible ways
 * profiler data may be plotted/visualized
 */
public enum ChartType implements Serializable {
	
	XY (null, "XY", "X-Y chart for numeric data"),
	LINE (null, "Line", "Line chart"),
	LINE_3D (LINE, "3D Line", "3D Line chart"),

	BAR (null, "Bar", "Bar chart"),
	BAR_3D (BAR, "3D Bar", "3D Bar chart"),
	BAR_STACKED (BAR, "Stacked Bar", "Stacked Bar chart"),

	PIE (null, "Pie", "Pie chart"),
	PIE_3D (PIE, "3D Pie", "3D Pie chart"),
	
	AREA (null, "Area", "Area chart"),
	AREA_STACKED (AREA, "Stacked Area", "Area chart"),
	LEVEL (AREA_STACKED, "Level", "Error histogram"),
	
	SCATTER (null, "Scatter", "Scatter plot");

	private final ChartType parent; // parent in the hierarchy
	private final List children; // children in the hierarchy
	private final String code; // plot code
	private final String string; // to string value
	private final String description; // plot description
	/**
	* Constructor for the enum.
	* Fills in the code recursively from the parent enum.
	* @param parent parent category
	* @param code category code
	* @param description category description
	*/
	 
	ChartType(ChartType parent, String str, String description) {
		String code = this.name();

		this.string = str;
		this.children = new ArrayList();
		this.parent = parent;
		
		if (parent != null) {
			this.code = parent.getCode() + "." + code;
			parent.addChild(this);
		} else {
			this.code = code;
		}
		 
		this.description = description;
	}
	 
	/**
	* Gets the parent category
	* @return the parent category
	*/	 
	public ChartType getParent() { return parent; }
	
	/**
	* Gets the code including all the parent codes
	* @return the category code
	*/
	public String getCode() { return code; }
	
	/**
	 * Get the user friendly toString value
	 */
	@Override
	public String toString() { return string; }
	
	/**
	* Gets the category description
	* @return the category description
	*/
	public String getDescription() { return description; }
	 
	/**
	* Private method to add a new child
	* @param child
	*/	 
	private void addChild (ChartType child) {
		this.children.add(child);
	}
	
	/**
	* Public method to compare to other enums.
	* @param sp
	*/
	public boolean holds( ChartType sp ) {
		return getCode().startsWith( sp.getCode() );
	}
}
