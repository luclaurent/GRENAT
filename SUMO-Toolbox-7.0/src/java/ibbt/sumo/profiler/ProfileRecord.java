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
** Revision: $Id: ProfileRecord.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import java.io.Serializable;

/**
 * A simple profile record holding a tuple of numeric data
 */
public class ProfileRecord<Type> implements Serializable, Cloneable {

	private static final long serialVersionUID = 8255487268140282940L;

	/**
	 * The data tuple
	 */
	private Type[] data = null;
	
	public ProfileRecord(Type[] data){
		assert(data != null);
		assert(data.length > 0);	
		this.data = data;
	}
	
	/**
	 * Return the tuple dimension
	 */
	public int dimension(){
		return data.length;
	}
	
	/**
	 * @return the data in this tuple
	 */
	public Type[] getValues(){
		return data;
	}
	
	/**
	 * Return the data point in column i
	 */
	public Type getValue(int i){
		return data[i];
	}
	
	/**
	 * Return the data tuple as an array of strings
	 */
	public String[] getValuesAsString(){
		String[] s = new String[data.length];
		for(int i=0;i < data.length; ++i){
			s[i] = data[i].toString();
		}
		return s;
	}
	
	public String getValueAsString(int i){
		return data[i].toString();
	}
	
	public ProfileRecord<Type> clone(){
		return new ProfileRecord<Type>(data.clone());
	}
	
	public String toString(){
		String s = "ProfileRecord with data " + data.toString();
		return s;
	}

	public boolean equals(Object obj){
		if(obj == this){
			return true;
		}
		
		if(obj == null || !(obj instanceof ProfileRecord)){
			return false;
		}
		
		return data.equals(((ProfileRecord)obj).getValues());
	}
}
