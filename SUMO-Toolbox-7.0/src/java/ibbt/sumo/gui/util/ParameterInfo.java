package ibbt.sumo.gui.util;
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

public class ParameterInfo extends Object{
    private String name;
    private String type;
    private String value;
    private String min;
    private String max;
    private String autosampling;

    public ParameterInfo(String name, String type, String value, String min, String max, String autos) {
        this.name = name;
        if (type == null)
            this.type = "real";
        else
            this.type = type;

        if (value == null)
            this.value = "n/a";
        else
            this.value = value;

        if (min == null)
            this.min = "-1.0";
        else
            this.min = min;

        if (max == null)
            this.max = "1.0";
        else
            this.max = max;

        if (autos == null)
            this.autosampling = "false";
        else
            this.autosampling = autos;
    }

    public String getMin() {
            return min;
    }

    public void setMin(String min) {
            this.min = min;
    }

    public String getMax() {
            return max;
    }

    public void setMax(String max) {
            this.max = max;
    }

    public String getAutosampling() {
            return autosampling;
    }

    public void setAutosampling(String autosampling) {
            this.autosampling = autosampling;
    }

    public void setName(String name) {
            this.name = name;
    }

    public void setType(String type) {
            this.type = type;
    }

    public String getName(){
            return this.name;
    }

    public String getType(){
            return this.type;
    }

    public String getValue(){
            return this.value;
    }

    public void setValue(String value){
            this.value = value;
    }

    public String toString(){
            return this.name + " : [" + this.min + ", " + this.max + "]";
}
}
