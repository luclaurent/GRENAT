package ibbt.sumo.util;
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
** Revision: $Id: SUMOFileFormatter.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.logging.Formatter;
import java.util.logging.LogRecord;

/**
 * A custom logging formatter for the SUMO Toolbox.
 */
public class SUMOFileFormatter extends Formatter {
	private SimpleDateFormat fDateFormat = new SimpleDateFormat("HH:mm");
    
	public SUMOFileFormatter() {
		super();
	}

	@Override
	public String format(LogRecord rec) {
		StringBuffer buf = new StringBuffer();
		
		buf.append( fDateFormat.format( new Date() ) );
		buf.append(" [");
		buf.append(rec.getLevel());
		buf.append("] ");
		buf.append(rec.getMessage());
		
		if( !rec.getLoggerName().startsWith("Matlab") )
		{
			buf.append(" [");
			buf.append( rec.getSourceClassName() );
			buf.append(".");
			buf.append( rec.getSourceMethodName() );
			buf.append("]");
		}			
		buf.append("\n");
		
				
		
		return buf.toString();
	}

}
